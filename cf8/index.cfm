<cfset filePath = expandPath("../config.ini") />

<cfset testSuite = createObject("component", "mxunit.runner.DirectoryTestSuite") />

<cfset results = testSuite.run(directory=expandPath('/ini/cf8/test/'), recurse=true, componentPath="ini.cf8.test.") />

<cfoutput>
#results.getHTMLResults()#
</cfoutput>

<cfscript>
	ini = createObject("component", "Ini").init(filePath, false);
	section = ini.getSection("development");
</cfscript>

<cfdump var="#section#" label="with Dotted Keys">

<cfscript>
	ini = createObject("component", "Ini").init(filePath, true);
	section = ini.getSection("development");
</cfscript>

<cfdump var="#section#" label="without Dotted Keys">
