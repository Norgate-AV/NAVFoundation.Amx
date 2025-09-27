PROGRAM_NAME='NAVIniFileParse'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char INI_PARSE_EXPECTED_RESULT[] = {
    0, // Empty string should fail
    1, // Simple key-value should succeed
    1, // Section with properties should succeed
    1, // Multiple sections should succeed
    1, // Comments and whitespace should succeed
    1, // Quoted strings should succeed
    1, // Global properties with sections should succeed
    1, // Empty sections should succeed
    1  // Special characters should succeed
}

constant integer INI_PARSE_EXPECTED_SECTIONS[] = {
    0, // Empty string
    1, // Simple key-value (creates default section)
    1, // One section
    2, // Two sections
    1, // One section plus comments
    1, // One section (default)
    2, // Global (default) + database section
    3, // Three sections (empty ones still count)
    1  // One section (default)
}

DEFINE_VARIABLE

volatile char INI_PARSE_TEST_DATA[9][1024]


/**
 * Initialize global test data arrays at runtime
 * Required because NetLinx cannot handle complex string expressions in constants
 */
define_function InitializeParserTestData() {
    // INI_PARSE_TEST_DATA - construct proper strings with actual newlines and special chars
    INI_PARSE_TEST_DATA[1] = ''
    INI_PARSE_TEST_DATA[2] = 'key=value'
    INI_PARSE_TEST_DATA[3] = "'[section1]', 10, 'key1=value1', 10, 'key2=value2'"
    INI_PARSE_TEST_DATA[4] = "'[section1]', 10, 'key1=value1', 10, 10, '[section2]', 10, 'key2=value2'"
    INI_PARSE_TEST_DATA[5] = "'; This is a comment', 10, 'key=value', 10, '# Another comment', 10, '[section]', 10, 'test=123'"
    INI_PARSE_TEST_DATA[6] = "'key1=', $22, 'quoted value', $22, 10, 'key2=', $27, 'single quoted', $27, 10, 'key3=unquoted'"
    INI_PARSE_TEST_DATA[7] = "'timeout=30', 10, 'retries=3', 10, 10, '[database]', 10, 'host=localhost', 10, 'port=5432'"
    INI_PARSE_TEST_DATA[8] = "'[empty1]', 10, 10, '[section2]', 10, 'key=value', 10, 10, '[empty3]'"
    INI_PARSE_TEST_DATA[9] = "'path=C:\temp\file.txt', 10, 'url=http://example.com:8080/path', 10, 'email=user@domain.com'"
    set_length_array(INI_PARSE_TEST_DATA, 9)
}

define_function TestNAVIniFileParse() {
    stack_var integer x

    NAVLog("'***************** NAVIniFileParse *****************'")

    for (x = 1; x <= length_array(INI_PARSE_TEST_DATA); x++) {
        stack_var char data[1024]
        stack_var _NAVIniFile iniFile
        stack_var char result
        stack_var char expected
        stack_var integer expectedSections

        data = INI_PARSE_TEST_DATA[x]
        expected = INI_PARSE_EXPECTED_RESULT[x]
        expectedSections = INI_PARSE_EXPECTED_SECTIONS[x]

        // Clear the ini file structure
        iniFile.sectionCount = 0

        result = NAVIniFileParse(data, iniFile)

        // Test parse result
        if (!NAVAssertCharEqual('INI Parse Result Test', expected, result)) {
            NAVLogTestFailed(x, itoa(expected), itoa(result))
            continue
        }

        // If parsing succeeded, test section count
        if (result && expectedSections > 0) {
            if (!NAVAssertIntegerEqual('INI Section Count Test', expectedSections, iniFile.sectionCount)) {
                NAVLogTestFailed(x, itoa(expectedSections), itoa(iniFile.sectionCount))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    // Additional specific test cases
    TestSpecificIniParseScenarios()
}

define_function TestSpecificIniParseScenarios() {
    stack_var _NAVIniFile ini
    stack_var char data[1024]
    stack_var char result

    NAVLog("'--- Specific INI Parse Scenarios ---'")

    // Test scenario: Section with multiple properties
    data = "'[database]', 10, 'host=localhost', 10, 'port=5432', 10, 'username=admin', 10, 'password=secret'"
    result = NAVIniFileParse(data, ini)

    if (result && ini.sectionCount == 1 && ini.sections[1].propertyCount == 4) {
        NAVLog("'Pass: Multiple properties test passed'")
    } else {
        NAVLog("'Fail: Multiple properties test failed'")
    }

    // Test scenario: Mixed global and section properties
    data = "'timeout=30', 10, 'debug=true', 10, 10, '[app]', 10, 'name=MyApp', 10, 'version=1.0'"
    result = NAVIniFileParse(data, ini)

    if (result && ini.sectionCount == 2) {
        // Should have default section + app section
        if (ini.sections[1].name == 'default' && ini.sections[1].propertyCount == 2 &&
            ini.sections[2].name == 'app' && ini.sections[2].propertyCount == 2) {
            NAVLog("'Pass: Mixed global/section test passed'")
        } else {
            NAVLog("'Fail: Mixed global/section test failed - section structure incorrect'")
        }
    } else {
        NAVLog("'Fail: Mixed global/section test failed - parse failed or wrong section count'")
    }
}
