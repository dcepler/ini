<cfset filePath = expandPath("config.ini") />

<cfset testSuite = new mxunit.runner.DirectoryTestSuite() />

<cfset results = testSuite.run(directory=expandPath('/ini/test/'), recurse=true, componentPath="ini.test.") />

<cfoutput>
#results.getHTMLResults()#
</cfoutput>

<cfscript>
	ini = new Ini(filePath, false);
	section = ini.getSection("development");
</cfscript>

<cfdump var="#section#" label="with Dotted Keys">

<cfscript>
	ini = new Ini(filePath, true);
	section = ini.getSection("development");
</cfscript>

<cfdump var="#section#" label="without Dotted Keys">
