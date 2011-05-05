<!--- Restructure of Tony Nelson's Advanced INI parser for ColdFusion 8 --->
<cfcomponent output="false">

	<cffunction name="init" access="public" returntype="any">
		<cfargument name="filepath" required="true" type="string" />
		<cfargument name="removeDottedKeys" default="false" type="boolean" />

		<cfscript>
		variables.extendsKey = ";extends"; // safe because keys starting with a semi-colon (;) are treated as comments
		variables.sections = processSections(parseExtends(loadSections(arguments.filePath)), arguments.removeDottedKeys);

		return this;
		</cfscript>
	</cffunction>

	<cffunction name="getSections" access="public" returntype="struct">
		<cfreturn variables.sections />
	</cffunction>

	<cffunction name="getSection" access="public" returntype="struct">
		<cfargument name="key" required="true" type="string" />

		<cfscript>
		arguments.key = trim(arguments.key);

		if (structKeyExists(variables.sections, arguments.key)) {
			return variables.sections[arguments.key];
		} else {
			return StructNew();
		}
		</cfscript>
	</cffunction>

	<cffunction name="loadSections" access="private" returntype="struct">
		<cfargument name="filePath" required="true" type="string">

		<cfscript>
		// parse the INI file like normal
		var sections = getProfileSections(arguments.filePath);
		var data = {};
		var key = "";
		var id = "";
		var section = "";
		var keys = "";
		var i = "";

		for (key in sections) {

			// remove all spaces from the id to better support inheritance
			id = replace(key, " ", "", "all");
			section = {};
			keys = listToArray(sections[key]);
			i = "";

			for (i = 1; i <= arrayLen(keys); i++) {
				section[keys[i]] = getProfileString(arguments.filePath, key, keys[i]);
			}

			data[id] = section;

		}

		return data;
		</cfscript>
	</cffunction>

	<cffunction name="parseExtends" access="private" returntype="struct">
		<cfargument name="sections" required="true" type="struct" />

		<cfscript>
		var data = {};
		var key = "";
		var id = "";
		var extends = "";

		for (key in arguments.sections) {

			// check to see if this section extends a different section [child : parent]
			if (find(":", key)) {
				id = listFirst(key, ":");
				extends = listRest(key, ":");
			} else {
				id = key;
				extends = "";
			}

			data[id] = arguments.sections[key];

			// if it extends another section, add the key
			if (extends != "") {
				data[id][variables.extendsKey] = extends;
			}

		}

		return data;
		</cfscript>
	</cffunction>

	<cffunction name="processSections" access="private" returntype="struct">
		<cfargument name="sections" required="true" type="struct" />
		<cfargument name="removeDottedKeys" required="true" type="boolean" />

		<cfscript>
		var data = {};
		var key = "";

		for (key in arguments.sections) {
			data[key] = processJSON(arguments.sections, key);
		}

		for (key in data) {
			data[key] = processSection(data, key);
		}

		// flatten each section based on inheritance
		for (key in data) {
			data[key] = flattenSection(data, key, arguments.removeDottedKeys);
		}

		// remove ;extends
		for (key in data) {
			structDelete(data[key], variables.extendsKey);
		}

		return data;
		</cfscript>
	</cffunction>

	<cffunction name="processJSON" access="private" returntype="struct">
		<cfargument name="sections" required="true" type="struct" />
		<cfargument name="id" required="true" type="string" />

		<cfscript>
		var section = arguments.sections[arguments.id];
		var key = "";
		var data = {};
		var value = "";
		var deserialized = "";

		// replace all complex JSON strings with complex objects
		for (key in section) {

			value = section[key];

			if (isJSON(value)) {

				deserialized = deserializeJSON(value);

				// simple values stay the same (prevents true from becoming YES)
				if (isSimpleValue(deserialized)) {
					data[key] = trim(value);
				} else {
					data[key] = deserialized;
				}


			} else {
				data[key] = trim(value);
			}

		}

		return data;
		</cfscript>
	</cffunction>

	<cffunction name="processSection" access="private" returntype="struct">
		<cfargument name="sections" required="true" type="struct" />
		<cfargument name="id" required="true" type="string" />
		<cfargument name="config" type="struct" default="#StructNew()#" />

		<cfscript>
		var section = arguments.sections[arguments.id];
		var key = "";

		for (key in section) {

			// leave ;extends alone
			if (key != variables.extendsKey) {
				arguments.config = processKey(arguments.config, key, section[key]);
			}

		}

		structAppend(arguments.config, section, false);

		return arguments.config;
		</cfscript>
	</cffunction>

	<cffunction name="processKey" access="private" returntype="struct">
		<cfargument name="config" required="true" type="struct" />
		<cfargument name="key" required="true" type="string" />
		<cfargument name="value" required="true" type="any" />

		<cfscript>
		var first = "";
		var rest = "";

		// look for nested properties
		if (find(".", arguments.key)) {

			first = listFirst(arguments.key, ".");
			rest = listRest(arguments.key, ".");

			// build the outer container
            if (!structKeyExists(arguments.config, first)) {
				arguments.config[first] = {};
			}

			// recursively process the rest of the property
			structAppend(arguments.config[first], processKey(arguments.config[first], rest, arguments.value), false);

        } else {

			arguments.config[arguments.key] = arguments.value;

		}

        return arguments.config;
		</cfscript>
	</cffunction>

	<cffunction name="flattenSection" access="private" returntype="struct">
		<cfargument name="config" required="true" type="struct" />
		<cfargument name="id" required="true" type="string" />
		<cfargument name="removeDottedKeys" required="true" type="boolean" />

		<cfscript>
		var section = "";
		var extends = "";
		var i = "";

		if (!structKeyExists(arguments.config, arguments.id)) {
			throw(message="Invalid section: #arguments.id#");
		}

		section = arguments.config[arguments.id];

		// check to see if this section extends other sections
		if (structKeyExists(section, variables.extendsKey)) {

			extends = listToArray(section[variables.extendsKey], ":");
			i = "";

			// recursively flatten each parent section
			for (i = 1; i <= arrayLen(extends); i++) {
				structAppend(section, flattenSection(arguments.config, extends[i], arguments.removeDottedKeys), false);
			}


		}

		if (arguments.removeDottedKeys) {
			// remove dotted structure keys
			for (key in section) {
				if (Find(".", key))
					structDelete(section, key);
			}
		}

		return section;
		</cfscript>
	</cffunction>

	<!---
	 Mimics the CFTHROW tag.

	 @param Type      Type for exception. (Optional)
	 @param Message      Message for exception. (Optional)
	 @param Detail      Detail for exception. (Optional)
	 @param ErrorCode      Error code for exception. (Optional)
	 @param ExtendedInfo      Extended Information for exception. (Optional)
	 @param Object      Object to throw. (Optional)
	 @return Does not return a value.
	 @author Raymond Camden (ray@camdenfamily.com)
	 @version 1, October 15, 2002
	--->
	<cffunction name="throw" output="false" returnType="void" hint="CFML Throw wrapper">
	    <cfargument name="type" type="string" default="Application" hint="Type for Exception">
	    <cfargument name="message" type="string" default="" hint="Message for Exception">
	    <cfargument name="detail" type="string" default="" hint="Detail for Exception">
	    <cfargument name="errorCode" type="string" default="" hint="Error Code for Exception">
	    <cfargument name="extendedInfo" type="string" default="" hint="Extended Info for Exception">
	    <cfargument name="object" type="any" hint="Object for Exception">

	    <cfif not isDefined("arguments.object")>
	        <cfthrow type="#arguments.type#" message="#arguments.message#" detail="#arguments.detail#" errorCode="#arguments.errorCode#" extendedInfo="#arguments.extendedInfo#">
	    <cfelse>
	        <cfthrow object="#arguments.object#">
	    </cfif>

	</cffunction>
</cfcomponent>
