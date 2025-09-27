PROGRAM_NAME='NAVIniFileGetValue'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVIniFileGetValue (dot notation)
constant char VALUE_GET_DOT_TEST[][64] = {
    'timeout',           // Global value
    'retries',           // Global value
    'debug',             // Global value
    'database.host',     // Section value
    'database.port',     // Section value
    'database.name',     // Section value
    'application.title', // Section value with spaces
    'application.version', // Section value with dots
    'application.enabled', // Section value boolean
    'nonexistent',       // Non-existent global
    'database.missing',  // Non-existent in existing section
    'missing.key',       // Non-existent section
    ''                   // Empty key
}

constant char VALUE_GET_DOT_EXPECTED[][255] = {
    '30',
    '3',
    'true',
    'localhost',
    '5432',
    'testdb',
    'My Application',
    '1.0.5',
    'false',
    '',  // Non-existent should return empty
    '',  // Non-existent should return empty
    '',  // Non-existent should return empty
    ''   // Empty key should return empty
}

// Test cases for NAVIniFileGetSectionValue
constant char VALUE_GET_SECTION_TEST[][2][64] = {
    { 'database', 'host' },
    { 'database', 'port' },
    { 'application', 'title' },
    { 'application', 'version' },
    { 'nonexistent', 'key' },
    { 'database', 'missing' },
    { '', 'key' }
}

constant char VALUE_GET_SECTION_EXPECTED[][255] = {
    'localhost',
    '5432',
    'My Application',
    '1.0.5',
    '',  // Non-existent section
    '',  // Non-existent key in existing section
    ''   // Empty section name
}

// Test cases for NAVIniFileGetGlobalValue
constant char VALUE_GET_GLOBAL_TEST[][64] = {
    'timeout',
    'retries',
    'debug',
    'nonexistent',
    ''
}

constant char VALUE_GET_GLOBAL_EXPECTED[][255] = {
    '30',
    '3',
    'true',
    '',  // Non-existent
    ''   // Empty key
}

DEFINE_VARIABLE

// Test data for value retrieval
volatile char VALUE_GET_INI_DATA[2048]

/**
 * Initialize global test data arrays at runtime
 * Required because NetLinx cannot handle complex string expressions in constants
 */
define_function InitializeValueGetTestData() {
    VALUE_GET_INI_DATA = "
        'timeout=30', 10,
        'retries=3', 10,
        'debug=true', 10,
        10,
        '[database]', 10,
        'host=localhost', 10,
        'port=5432', 10,
        'name=testdb', 10,
        10,
        '[application]', 10,
        'title=My Application', 10,
        'version=1.0.5', 10,
        'enabled=false'
    "
}

define_function TestNAVIniFileGetValue() {
    stack_var integer x
    stack_var _NAVIniFile iniFile
    stack_var char result

    NAVLog("'***************** NAVIniFileGetValue *****************'")

    InitializeValueGetTestData()

    // Parse the test INI data
    result = NAVIniFileParse(VALUE_GET_INI_DATA, iniFile)
    if (!result) {
        NAVLog("'Failed to parse test INI data for value retrieval tests'")
        return
    }

    // Test NAVIniFileGetValue (dot notation)
    for (x = 1; x <= length_array(VALUE_GET_DOT_TEST); x++) {
        stack_var char key[NAV_INI_PARSER_MAX_KEY_LENGTH]
        stack_var char expected[NAV_INI_PARSER_MAX_VALUE_LENGTH]
        stack_var char value[NAV_INI_PARSER_MAX_VALUE_LENGTH]

        key = VALUE_GET_DOT_TEST[x]
        expected = VALUE_GET_DOT_EXPECTED[x]

        value = NAVIniFileGetValue(iniFile, key)

        if (!NAVAssertStringEqual('GetValue Dot Notation Test', expected, value)) {
            NAVLogTestFailed(x, expected, value)
            continue
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVIniFileGetSectionValue() {
    stack_var integer x
    stack_var _NAVIniFile iniFile
    stack_var char result

    NAVLog("'***************** NAVIniFileGetSectionValue *****************'")

    InitializeValueGetTestData()

    // Parse the test INI data
    result = NAVIniFileParse(VALUE_GET_INI_DATA, iniFile)
    if (!result) {
        NAVLog("'Failed to parse test INI data for section value tests'")
        return
    }

    // Test NAVIniFileGetSectionValue
    for (x = 1; x <= length_array(VALUE_GET_SECTION_TEST); x++) {
        stack_var char section[NAV_INI_PARSER_MAX_SECTION_NAME_LENGTH]
        stack_var char key[NAV_INI_PARSER_MAX_KEY_LENGTH]
        stack_var char expected[NAV_INI_PARSER_MAX_VALUE_LENGTH]
        stack_var char value[NAV_INI_PARSER_MAX_VALUE_LENGTH]

        section = VALUE_GET_SECTION_TEST[x][1]
        key = VALUE_GET_SECTION_TEST[x][2]
        expected = VALUE_GET_SECTION_EXPECTED[x]

        value = NAVIniFileGetSectionValue(iniFile, section, key)

        if (!NAVAssertStringEqual('GetSectionValue Test', expected, value)) {
            NAVLogTestFailed(x, expected, value)
            continue
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVIniFileGetGlobalValue() {
    stack_var integer x
    stack_var _NAVIniFile iniFile
    stack_var char result

    NAVLog("'***************** NAVIniFileGetGlobalValue *****************'")

    InitializeValueGetTestData()

    // Parse the test INI data
    result = NAVIniFileParse(VALUE_GET_INI_DATA, iniFile)
    if (!result) {
        NAVLog("'Failed to parse test INI data for global value tests'")
        return
    }

    // Test NAVIniFileGetGlobalValue
    for (x = 1; x <= length_array(VALUE_GET_GLOBAL_TEST); x++) {
        stack_var char key[NAV_INI_PARSER_MAX_KEY_LENGTH]
        stack_var char expected[NAV_INI_PARSER_MAX_VALUE_LENGTH]
        stack_var char value[NAV_INI_PARSER_MAX_VALUE_LENGTH]

        key = VALUE_GET_GLOBAL_TEST[x]
        expected = VALUE_GET_GLOBAL_EXPECTED[x]

        value = NAVIniFileGetGlobalValue(iniFile, key)

        if (!NAVAssertStringEqual('GetGlobalValue Test', expected, value)) {
            NAVLogTestFailed(x, expected, value)
            continue
        }

        NAVLogTestPassed(x)
    }
}
