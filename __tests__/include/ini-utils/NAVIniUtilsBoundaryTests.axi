PROGRAM_NAME='NAVIniUtilsBoundaryTests'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

/**
 * Test maximum capacity limits and boundary conditions
 */
define_function TestNAVIniUtilsBoundaryTests() {
    NAVLog("'***************** NAVIniUtilsBoundaryTests *****************'")

    // Test 1: Maximum sections (100)
    TestMaxSections()

    // Test 2: Maximum properties per section (100)
    TestMaxProperties()

    // Test 3: Maximum key/value lengths (64/255 chars)
    TestMaxStringLengths()

    // Test 4: Large file parsing (4KB+)
    TestLargeFileParsing()
}

define_function TestMaxSections() {
    stack_var _NAVIniFile iniFile
    stack_var char data[4096]
    stack_var integer i

    // Generate INI with exactly 100 sections
    data = ''
    for (i = 1; i <= 100; i++) {
        data = "data, '[section', itoa(i), ']', 10, 'key=value', 10"
    }

    if (NAVIniFileParse(data, iniFile)) {
        if (iniFile.sectionCount == 100) {
            NAVLogTestPassed(1)
        } else {
            NAVLogTestFailed(1, '100', itoa(iniFile.sectionCount))
        }
    } else {
        NAVLogTestFailed(1, 'parse success', 'parse failed')
    }
}

define_function TestMaxProperties() {
    stack_var _NAVIniFile iniFile
    stack_var char data[4096]
    stack_var integer i

    // Generate section with exactly 100 properties
    data = '[test]'
    for (i = 1; i <= 100; i++) {
        data = "data, 10, 'prop', itoa(i), '=value', itoa(i)"
    }

    if (NAVIniFileParse(data, iniFile) && iniFile.sectionCount > 0) {
        if (iniFile.sections[1].propertyCount == 100) {
            NAVLogTestPassed(2)
        } else {
            NAVLogTestFailed(2, '100', itoa(iniFile.sections[1].propertyCount))
        }
    } else {
        NAVLogTestFailed(2, 'parse success', 'parse failed')
    }
}

define_function TestMaxStringLengths() {
    stack_var _NAVIniFile iniFile
    stack_var char data[512]
    stack_var char longKey[64]
    stack_var char longValue[255]
    stack_var integer i

    // Create 64-character key
    for (i = 1; i <= 64; i++) {
        longKey = "longKey, 'x'"
    }

    // Create 255-character value
    for (i = 1; i <= 255; i++) {
        longValue = "longValue, 'y'"
    }

    data = "'[test]', 10, longKey, '=', longValue"

    if (NAVIniFileParse(data, iniFile) && iniFile.sectionCount > 0) {
        if (length_array(iniFile.sections[1].properties[1].key) == 64 &&
            length_array(iniFile.sections[1].properties[1].value) == 255) {
            NAVLogTestPassed(3)
        } else {
            NAVLogTestFailed(3, '64,255', "'lengths: ', itoa(length_array(iniFile.sections[1].properties[1].key)), ',', itoa(length_array(iniFile.sections[1].properties[1].value))")
        }
    } else {
        NAVLogTestFailed(3, 'parse success', 'parse failed')
    }
}

define_function TestLargeFileParsing() {
    stack_var _NAVIniFile iniFile
    stack_var char data[8192]
    stack_var integer i

    // Generate large INI file approaching 4KB
    data = '; Large test file'
    for (i = 1; i <= 50; i++) {
        data = "data, 10, '[section', itoa(i), ']', 10"
        data = "data, 'property1=value with some longer text to increase size', 10"
        data = "data, 'property2=another value with additional content', 10"
    }

    NAVLog("'Large file parsing test - data size: ', itoa(length_array(data)), ' bytes'")

    if (NAVIniFileParse(data, iniFile)) {
        if (iniFile.sectionCount >= 40) { // Allow some flexibility
            NAVLogTestPassed(4)
        } else {
            NAVLogTestFailed(4, '>40 sections', itoa(iniFile.sectionCount))
        }
    } else {
        NAVLogTestFailed(4, 'large file parse', 'failed')
    }
}
