PROGRAM_NAME='NAVIniFileFindSection'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char SECTION_FIND_TEST[][64] = {
    'database',
    'application',
    'logging',
    'cache',
    'nonexistent',
    'DATABASE',      // Case sensitive test
    '',              // Empty string
    'data',          // Partial match
    'application_backup' // Longer name
}

constant integer SECTION_FIND_EXPECTED[] = {
    1, // database - should be found at index 1
    2, // application - should be found at index 2
    3, // logging - should be found at index 3
    4, // cache - should be found at index 4
    0, // nonexistent - should not be found
    0, // DATABASE - case sensitive, should not be found
    0, // empty string - should not be found
    0, // data - partial match, should not be found
    0  // application_backup - longer name, should not be found
}

DEFINE_VARIABLE

// Test data for section finding
volatile char SECTION_FIND_INI_DATA[1024]

define_function InitializeSectionFindTestData() {
    SECTION_FIND_INI_DATA = "
        '[database]', 10,
        'host=localhost', 10,
        10,
        '[application]', 10,
        'name=MyApp', 10,
        10,
        '[logging]', 10,
        'level=debug', 10,
        10,
        '[cache]', 10,
        'enabled=true'
    "
}

define_function TestNAVIniFileFindSection() {
    stack_var integer x
    stack_var _NAVIniFile iniFile
    stack_var char result

    NAVLog("'***************** NAVIniFileFindSection *****************'")

    InitializeSectionFindTestData()

    // First parse the test INI data
    result = NAVIniFileParse(SECTION_FIND_INI_DATA, iniFile)
    if (!result) {
        NAVLog("'Failed to parse test INI data for section finding tests'")
        return
    }

    // Run the section finding tests
    for (x = 1; x <= length_array(SECTION_FIND_TEST); x++) {
        stack_var char sectionName[NAV_INI_PARSER_MAX_SECTION_NAME_LENGTH]
        stack_var integer expected
        stack_var integer found

        sectionName = SECTION_FIND_TEST[x]
        expected = SECTION_FIND_EXPECTED[x]

        found = NAVIniFileFindSection(iniFile, sectionName)

        if (!NAVAssertIntegerEqual('Section Find Test', expected, found)) {
            NAVLogTestFailed(x, itoa(expected), itoa(found))
            continue
        }

        NAVLogTestPassed(x)
    }

    // Additional verification tests
    TestSectionFindVerification(iniFile)
}

define_function TestSectionFindVerification(_NAVIniFile iniFile) {
    stack_var integer sectionIndex
    stack_var char sectionName[NAV_INI_PARSER_MAX_SECTION_NAME_LENGTH]
    stack_var _NAVIniFile emptyIni

    NAVLog("'--- Section Find Verification ---'")

    // Verify that found sections actually contain the expected name
    sectionIndex = NAVIniFileFindSection(iniFile, 'database')
    if (sectionIndex > 0 && sectionIndex <= iniFile.sectionCount) {
        sectionName = iniFile.sections[sectionIndex].name
        if (sectionName == 'database') {
            NAVLog("'Pass: Database section verification passed'")
        } else {
            NAVLog(sectionName)
        }
    } else {
        NAVLog(itoa(sectionIndex))
    }

    // Test edge case: empty INI file
    emptyIni.sectionCount = 0
    sectionIndex = NAVIniFileFindSection(emptyIni, 'test')
    if (sectionIndex == 0) {
        NAVLog("'Pass: Empty INI section search passed'")
    } else {
        NAVLog("'Fail: Empty INI section search failed - should return 0'")
    }
}
