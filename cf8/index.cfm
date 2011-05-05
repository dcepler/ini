<cfset testSuite = createObject("component", "mxunit.runner.DirectoryTestSuite") />

<cfset results = testSuite.run(directory=expandPath('/ini/cf8/test/'), recurse=true, componentPath="ini.cf8.test.") />

<cfoutput>
#results.getHTMLResults()#
</cfoutput>

<cfscript>
	ini = createObject("component", "ini").init(expandPath("../config.ini"), false);
	section = ini.getSection("development");
</cfscript>

<cfdump var="#section#">
