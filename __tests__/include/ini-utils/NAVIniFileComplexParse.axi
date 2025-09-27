PROGRAM_NAME='NAVIniFileComplexParse'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_VARIABLE

// Complex test scenario with comments, quotes, special characters
volatile char COMPLEX_INI_DATA[4096]

/**
 * Initialize global test data arrays at runtime
 * Required because NetLinx cannot handle complex string expressions in constants
 */
define_function InitializeComplexTestData() {
    COMPLEX_INI_DATA = "
        '; Global configuration', 10,
        '; This is a comment', 10,
        'timeout=30', 10,
        'retries=3', 10,
        'enabled=true', 10,
        10,
        '; Database configuration', 10,
        '[database]', 10,
        'host=', $22, '192.168.1.100', $22, 10,
        'port=5432', 10,
        'name=', $27, 'my_database', $27, 10,
        'connection_string=', $22, 'server=localhost;database=test', $22, 10,
        10,
        '# Application settings', 10,
        '[application]', 10,
        'title=My Amazing App', 10,
        'version=2.1.3', 10,
        'debug=false', 10,
        'log_path=C:\logs\app.log', 10,
        'website=https://example.com:8080/app', 10,
        10,
        '[empty_section]', 10,
        10,
        '[paths]', 10,
        'temp_dir=/tmp/myapp', 10,
        'config_file=./config/settings.ini', 10,
        'data_path=~/Documents/MyApp Data', 10,
        10,
        '[special_chars]', 10,
        'email=user@example.com', 10,
        'percentage=95%', 10,
        'money=$1,234.56'
    "
}

define_function TestNAVIniFileComplexParse() {
    stack_var _NAVIniFile iniFile
    stack_var char result

    NAVLog("'***************** NAVIniFileComplexParse *****************'")

    InitializeComplexTestData()

    // Parse the complex INI data
    result = NAVIniFileParse(COMPLEX_INI_DATA, iniFile)

    if (!result) {
        NAVLog("'Fail: Failed to parse complex INI data'")
        return
    }

    NAVLog("'Pass: Complex INI data parsed successfully'")

    // Test 1: Verify section count (should have default + 5 named sections)
    if (iniFile.sectionCount == 6) {
        NAVLog("'Pass: Section count correct (6 sections)'")
    } else {
        NAVLog("'Fail: Section count incorrect (', itoa(iniFile.sectionCount), ' sections found). Expected 6.'")
    }

    // Test 2: Global values
    TestComplexGlobalValues(iniFile)

    // Test 3: Quoted strings
    TestComplexQuotedStrings(iniFile)

    // Test 4: Special characters and paths
    TestComplexSpecialCharacters(iniFile)

    // Test 5: Empty sections
    TestComplexEmptySections(iniFile)

    // Test 6: Case sensitivity
    TestComplexCaseSensitivity(iniFile)
}

define_function TestComplexGlobalValues(_NAVIniFile iniFile) {
    stack_var char value[NAV_INI_PARSER_MAX_VALUE_LENGTH]

    NAVLog("'--- Testing Global Values ---'")

    // Test timeout value
    value = NAVIniFileGetGlobalValue(iniFile, 'timeout')
    if (value == '30') {
        NAVLog("'Pass: Global timeout value correct'")
    } else {
        NAVLog("'Fail: Global timeout value incorrect'")
    }

    // Test boolean value
    value = NAVIniFileGetGlobalValue(iniFile, 'enabled')
    if (value == 'true') {
        NAVLog("'Pass: Global enabled value correct'")
    } else {
        NAVLog("'Fail: Global enabled value incorrect'")
    }
}

define_function TestComplexQuotedStrings(_NAVIniFile iniFile) {
    stack_var char value[NAV_INI_PARSER_MAX_VALUE_LENGTH]

    NAVLog("'--- Testing Quoted Strings ---'")

    // Test double-quoted string
    value = NAVIniFileGetSectionValue(iniFile, 'database', 'host')
    if (value == '192.168.1.100') {
        NAVLog("'Pass: Double-quoted host value correct'")
    } else {
        NAVLog("'Fail: Double-quoted host value incorrect'")
    }

    // Test single-quoted string
    value = NAVIniFileGetSectionValue(iniFile, 'database', 'name')
    if (value == 'my_database') {
        NAVLog("'Pass: Single-quoted database name correct'")
    } else {
        NAVLog("'Fail: Single-quoted database name incorrect'")
    }

    // Test complex quoted string with special characters
    value = NAVIniFileGetSectionValue(iniFile, 'database', 'connection_string')
    if (find_string(value, 'server=localhost', 1) > 0 && find_string(value, 'database=test', 1) > 0) {
        NAVLog("'Pass: Complex connection string parsed correctly'")
    } else {
        NAVLog("'Fail: Complex connection string parsed incorrectly'")
    }
}

define_function TestComplexSpecialCharacters(_NAVIniFile iniFile) {
    stack_var char value[NAV_INI_PARSER_MAX_VALUE_LENGTH]

    NAVLog("'--- Testing Special Characters ---'")

    // Test Windows path
    value = NAVIniFileGetSectionValue(iniFile, 'application', 'log_path')
    if (find_string(value, 'C:\logs\app.log', 1) > 0) {
        NAVLog("'Pass: Windows path parsed correctly'")
    } else {
        NAVLog("'Fail: Windows path parsed incorrectly'")
    }

    // Test URL with port
    value = NAVIniFileGetSectionValue(iniFile, 'application', 'website')
    if (find_string(value, 'https://example.com:8080', 1) > 0) {
        NAVLog("'Pass: URL with port parsed correctly'")
    } else {
        NAVLog("'Fail: URL with port parsed incorrectly'")
    }

    // Test email address
    value = NAVIniFileGetSectionValue(iniFile, 'special_chars', 'email')
    if (value == 'user@example.com') {
        NAVLog("'Pass: Email address parsed correctly'")
    } else {
        NAVLog("'Fail: Email address parsed incorrectly'")
    }

    // Test percentage
    value = NAVIniFileGetSectionValue(iniFile, 'special_chars', 'percentage')
    if (value == '95%') {
        NAVLog("'Pass: Percentage value parsed correctly'")
    } else {
        NAVLog("'Fail: Percentage value parsed incorrectly'")
    }
}

define_function TestComplexEmptySections(_NAVIniFile iniFile) {
    stack_var integer sectionIndex

    NAVLog("'--- Testing Empty Sections ---'")

    // Find the empty section
    sectionIndex = NAVIniFileFindSection(iniFile, 'empty_section')
    if (sectionIndex > 0) {
        if (iniFile.sections[sectionIndex].propertyCount == 0) {
            NAVLog("'Pass: Empty section found with 0 properties'")
        } else {
            NAVLog(itoa(iniFile.sections[sectionIndex].propertyCount))
        }
    } else {
        NAVLog("'Fail: Empty section not found'")
    }
}

define_function TestComplexCaseSensitivity(_NAVIniFile iniFile) {
    stack_var char value[NAV_INI_PARSER_MAX_VALUE_LENGTH]

    NAVLog("'--- Testing Case Sensitivity ---'")

    // Test that section names are case sensitive
    value = NAVIniFileGetSectionValue(iniFile, 'DATABASE', 'host')
    if (value == '') {
        NAVLog("'Pass: Section names are case sensitive'")
    } else {
        NAVLog("'Fail: Section names are case sensitive'")
    }

    // Test that property names are case sensitive
    value = NAVIniFileGetSectionValue(iniFile, 'database', 'HOST')
    if (value == '') {
        NAVLog("'Pass: Property names are case sensitive'")
    } else {
        NAVLog("'Fail: Property names are case sensitive'")
    }
}
