<cfcomponent extends="mxunit.framework.TestCase">

	<cffunction name="beforeTests">
		<cfscript>
		filePath = expandPath("/ini/config.ini");
		ini = createObject("component", "ini.cf8.Ini").init(filePath);
		</cfscript>
	</cffunction>

	<cffunction name="testSectionsIsAStruct">
		<cfscript>
		var sections = ini.getSections();

		assertIsStruct(sections);
		</cfscript>
	</cffunction>

	<cffunction name="testSectionsHasCorrectKeyCount">
		<cfscript>
		var sections = ini.getSections();

		assertEquals(structCount(sections), 4);
		</cfscript>
	</cffunction>

	<cffunction name="testSimpleSectionIsAStruct">
		<cfscript>
		var section = ini.getSection("production");

		assertIsStruct(section);
		</cfscript>
	</cffunction>

	<cffunction name="testSimpleSectionHasCorrectKeyCount">
		<cfscript>
		var section = ini.getSection("production");

		assertEquals(structCount(section), 3);
		</cfscript>
	</cffunction>

	<cffunction name="testInheritedSectionIsAStruct">
		<cfscript>
		var section = ini.getSection("development");

		assertIsStruct(section);
		</cfscript>
	</cffunction>

	<cffunction name="testInheritedSectionHasCorrectKeyCount">
		<cfscript>
		var section = ini.getSection("development");

		assertEquals(structCount(section), 13);
		</cfscript>
	</cffunction>

	<cffunction name="testInheritedSectionHasCorrectKeys">
		<cfscript>
		var section = ini.getSection("development");

		assertEquals(section["development"], "true");
		assertEquals(section["environment"], "development");
		assertIsArray(section["array"]);
		assertTrue(arrayLen(section["array"]), 3);
		assertIsStruct(section["struct"]);
		assertTrue(structCount(section["struct"]), 2);
		assertEquals(section["yes"], "true");
		assertIsStruct(section["nested"]);
		assertTrue(structCount(section["nested"]), 3);
		assertEquals(section["nested.foo"], "1");
		assertEquals(section["nested.bar"], "2");
		assertIsStruct(section["nested.baz"]);
		assertTrue(structCount(section["nested.baz"]), 1);
		assertEquals(section["staging"], "true");
		assertEquals(section["testing"], "true");
		assertEquals(section["production"], "true");
		assertEquals(section["foo"], "staging");
		</cfscript>
	</cffunction>

	<cffunction name="testPartiallyInheritedSectionHasCorrectKeyCount">
		<cfscript>
		var section = ini.getSection("testing");

		assertEquals(structCount(section), 5);
		</cfscript>
	</cffunction>

	<cffunction name="testNestedPropertyExists">
		<cfscript>
		var section = ini.getSection("development");

		assertTrue(structKeyExists(section, "nested"));
		</cfscript>
	</cffunction>

	<cffunction name="testNestedPropertyIsAStruct">
		<cfscript>
		var section = ini.getSection("development");

		assertIsStruct(section["nested"]);
		</cfscript>
	</cffunction>

	<cffunction name="testNestedPropertyHasCorrectKeyCount">
		<cfscript>
		var section = ini.getSection("development");

		assertEquals(structCount(section["nested"]), 3);
		</cfscript>
	</cffunction>

	<cffunction name="testNestedPropertyHasCorrectKeyValues">
		<cfscript>
		var section = ini.getSection("development");

		assertEquals(section["nested"]["foo"], "1");
		assertEquals(section["nested"]["bar"], "2");
		</cfscript>
	</cffunction>

	<cffunction name="testNestedPropertyHasCorrectKeys">
		<cfscript>
		var section = ini.getSection("development");

		assertTrue(structKeyExists(section["nested"], "foo"));
		assertTrue(structKeyExists(section["nested"], "bar"));
		</cfscript>
	</cffunction>

	<cffunction name="testNestedPropertyStillExists">
		<cfscript>
		var section = ini.getSection("development");

		assertTrue(structKeyExists(section, "nested.foo"));
		assertTrue(structKeyExists(section, "nested.bar"));
		</cfscript>
	</cffunction>

	<cffunction name="testJSONStructExists">
		<cfscript>
		var section = ini.getSection("development");

		assertTrue(structKeyExists(section, "struct"));
		</cfscript>
	</cffunction>

	<cffunction name="testJSONStructIsAStruct">
		<cfscript>
		var section = ini.getSection("development");

		assertIsStruct(section["struct"]);
		</cfscript>
	</cffunction>

	<cffunction name="testJSONStructHasCorrectKeyCount">
		<cfscript>
		var section = ini.getSection("development");

		assertEquals(structCount(section["struct"]), 2);
		</cfscript>
	</cffunction>

	<cffunction name="testJSONStructHasCorrectKeys">
		<cfscript>
		var section = ini.getSection("development");

		assertTrue(structKeyExists(section["struct"], "1"));
		assertTrue(structKeyExists(section["struct"], "0"));
		</cfscript>
	</cffunction>

	<cffunction name="testJSONStructHasCorrectKeyValues">
		<cfscript>
		var section = ini.getSection("development");

		assertEquals(section["struct"]["1"], "yes");
		assertEquals(section["struct"]["0"], "no");
		</cfscript>
	</cffunction>

	<cffunction name="testJSONArrayExists">
		<cfscript>
		var section = ini.getSection("development");

		assertTrue(structKeyExists(section, "array"));
		</cfscript>
	</cffunction>

	<cffunction name="testJSONArrayIsAnArray">
		<cfscript>
		var section = ini.getSection("development");

		assertIsArray(section["array"]);
		</cfscript>
	</cffunction>

	<cffunction name="testJSONStringIsABoolean">
		<cfscript>
		var section = ini.getSection("development");

		assertEquals(section["yes"], "true");
		</cfscript>
	</cffunction>

	<cffunction name="testInheritedValueExists">
		<cfscript>
		var section = ini.getSection("development");

		assertTrue(structKeyExists(section, "production"));
		</cfscript>
	</cffunction>

	<cffunction name="testInheritedValueIsCorrect">
		<cfscript>
		var section = ini.getSection("development");

		assertEquals(section["production"], "true");
		</cfscript>
	</cffunction>

	<cffunction name="testOverriddenValueExists">
		<cfscript>
		var section = ini.getSection("development");

		assertTrue(structKeyExists(section, "environment"));
		</cfscript>
	</cffunction>

	<cffunction name="testOverriddenValueIsCorrect">
		<cfscript>
		var section = ini.getSection("development");

		assertEquals(section["environment"], "development");
		</cfscript>
	</cffunction>

</cfcomponent>
