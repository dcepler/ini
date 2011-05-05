<cfcomponent output="false">

	<cfscript>
	this.name = "ini-cf8";
	this.mappings["/ini"] = getDirectoryFromPath(getCurrentTemplatePath());
	</cfscript>

</cfcomponent>