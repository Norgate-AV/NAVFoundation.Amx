PROGRAM_NAME='NAVIniFileFindProperty'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char PROPERTY_FIND_TEST[][NAV_INI_PARSER_MAX_KEY_LENGTH] = {
    'key1',
    'key2',
    'key3',
    'key4',
    'key5',
    'nonexistent',
    'KEY1',          // Case sensitive test
    '',              // Empty string
    'key',           // Partial match
    'key10'          // Longer name
}

constant integer PROPERTY_FIND_EXPECTED[] = {
    1, // key1 - should be found at index 1
    2, // key2 - should be found at index 2
    3, // key3 - should be found at index 3
    4, // key4 - should be found at index 4
    5, // key5 - should be found at index 5
    0, // nonexistent - should not be found
    0, // KEY1 - case sensitive, should not be found
    0, // empty string - should not be found
    0, // key - partial match, should not be found
    0  // key10 - longer name, should not be found
}

DEFINE_VARIABLE

// Test data for property finding
volatile char PROPERTY_FIND_INI_DATA[1024]

define_function InitializePropertyFindTestData() {
    PROPERTY_FIND_INI_DATA = "
        '[section1]', 10,
        'key1=value1', 10,
        'key2=value2', 10,
        'key3=value3', 10,
        'key4=value4', 10,
        'key5=value5'
    "
}

define_function TestNAVIniFileFindProperty() {
    stack_var integer x
    stack_var _NAVIniFile iniFile
    stack_var _NAVIniSection testSection
    stack_var char result

    NAVLog( "'***************** NAVIniFileFindProperty *****************'")

    InitializePropertyFindTestData()

    // First parse the test INI data
    result = NAVIniFileParse(PROPERTY_FIND_INI_DATA, iniFile)
    if (!result || iniFile.sectionCount == 0) {
        NAVLog( "'Failed to parse test INI data for property finding tests'")
        return
    }

    // Get the test section (should be the first and only section)
    testSection = iniFile.sections[1]

    // Verify we have the expected number of properties
    if (testSection.propertyCount != 5) {
        NAVLog(itoa(testSection.propertyCount))
        return
    }

    // Run the property finding tests
    for (x = 1; x <= length_array(PROPERTY_FIND_TEST); x++) {
        stack_var char propertyKey[64]
        stack_var integer expected
        stack_var integer found

        propertyKey = PROPERTY_FIND_TEST[x]
        expected = PROPERTY_FIND_EXPECTED[x]

        found = NAVIniFileFindProperty(testSection, propertyKey)

        if (!NAVAssertIntegerEqual('Property Find Test', expected, found)) {
            NAVLogTestFailed(x, itoa(expected), itoa(found))
            continue
        }

        NAVLogTestPassed(x)
    }

    // Additional verification tests
    TestPropertyFindVerification(testSection)
}

define_function TestPropertyFindVerification(_NAVIniSection section) {
    stack_var integer propertyIndex
    stack_var char propertyKey[NAV_INI_PARSER_MAX_KEY_LENGTH]
    stack_var char propertyValue[NAV_INI_PARSER_MAX_VALUE_LENGTH]
    stack_var _NAVIniSection emptySection

    NAVLog( "'--- Property Find Verification ---'")

    // Verify that found properties actually contain the expected key and value
    propertyIndex = NAVIniFileFindProperty(section, 'key1')
    if (propertyIndex > 0 && propertyIndex <= section.propertyCount) {
        propertyKey = section.properties[propertyIndex].key
        propertyValue = section.properties[propertyIndex].value
        if (propertyKey == 'key1' && propertyValue == 'value1') {
            NAVLog("'Pass: Key1 property verification passed'")
        } else {
            NAVLog("'Fail: Key1 property verification failed - expected key1=value1'")
        }
    } else {
        NAVLog(itoa(propertyIndex))
    }

    // Test key2 property
    propertyIndex = NAVIniFileFindProperty(section, 'key2')
    if (propertyIndex > 0 && propertyIndex <= section.propertyCount) {
        propertyValue = section.properties[propertyIndex].value
        if (propertyValue == 'value2') {
            NAVLog("'Pass: Key2 property verification passed'")
        } else {
            NAVLog("'Fail: Key2 property verification failed - expected key2=value2'")
        }
    } else {
        NAVLog(itoa(propertyIndex))
    }

    // Test edge case: empty section
    emptySection.propertyCount = 0
    propertyIndex = NAVIniFileFindProperty(emptySection, 'test')
    if (propertyIndex == 0) {
        NAVLog("'Pass: Empty section property search passed'")
    } else {
        NAVLog("'Fail: Empty section property search failed - should return 0'")
    }
}
