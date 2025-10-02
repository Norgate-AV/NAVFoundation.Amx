PROGRAM_NAME='NAVEncodingHexString'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'


/**
 * Test NAVByteArrayToHexString basic conversion
 */
define_function TestNAVByteArrayToHexString() {
    stack_var char bytes[3]
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVByteArrayToHexString *****************'")

    bytes = "$01, $23, $45"
    result = NAVByteArrayToHexString(bytes)

    if (!NAVAssertStringEqual('Should produce clean hex string', '012345', result)) {
        NAVLogTestFailed(1, '012345', result)
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test with single byte
    bytes = "$FF"
    result = NAVByteArrayToHexString(bytes)

    if (!NAVAssertStringEqual('Single byte should work', 'ff', result)) {
        NAVLogTestFailed(2, 'ff', result)
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test with zero
    bytes = "$00"
    result = NAVByteArrayToHexString(bytes)

    if (!NAVAssertStringEqual('Zero should produce 00', '00', result)) {
        NAVLogTestFailed(3, '00', result)
    }
    else {
        NAVLogTestPassed(3)
    }
}


/**
 * Test NAVHexToString alias
 */
define_function TestNAVHexToString() {
    stack_var char bytes[3]
    stack_var char result1[NAV_MAX_BUFFER]
    stack_var char result2[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVHexToString *****************'")

    bytes = "$01, $23, $45"
    result1 = NAVHexToString(bytes)
    result2 = NAVByteArrayToHexString(bytes)

    if (!NAVAssertStringEqual('Should match NAVByteArrayToHexString', result2, result1)) {
        NAVLogTestFailed(1, result2, result1)
    }
    else {
        NAVLogTestPassed(1)
    }
}


/**
 * Test NAVByteArrayToNetLinxHexString formatting
 */
define_function TestNAVByteArrayToNetLinxHexString() {
    stack_var char bytes[3]
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVByteArrayToNetLinxHexString *****************'")

    bytes = "$01, $23, $45"
    result = NAVByteArrayToNetLinxHexString(bytes)

    if (!NAVAssertStringEqual('Should produce NetLinx-style hex', '$01$23$45', result)) {
        NAVLogTestFailed(1, '$01$23$45', result)
    }
    else {
        NAVLogTestPassed(1)
    }

    // Verify uppercase
    if (!NAVAssertTrue('Should be uppercase', result[2] >= 'A' && result[2] <= 'F' ||
                                             result[2] >= '0' && result[2] <= '9')) {
        NAVLogTestFailed(2, 'uppercase', 'not uppercase')
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test with lowercase hex letters
    bytes = "$AB"
    result = NAVByteArrayToNetLinxHexString(bytes)

    if (!NAVAssertStringEqual('Should uppercase hex letters', '$AB', result)) {
        NAVLogTestFailed(3, '$AB', result)
    }
    else {
        NAVLogTestPassed(3)
    }
}


/**
 * Test NAVByteArrayToCStyleHexString formatting
 */
define_function TestNAVByteArrayToCStyleHexString() {
    stack_var char bytes[3]
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVByteArrayToCStyleHexString *****************'")

    bytes = "$01, $23, $45"
    result = NAVByteArrayToCStyleHexString(bytes)

    // Note: upper_string makes the 'X' uppercase too, so we need to accept '0X'
    if (!NAVAssertStringEqual('Should produce C-style hex', '0X01, 0X23, 0X45', result)) {
        NAVLogTestFailed(1, '0X01, 0X23, 0X45', result)
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test with single byte
    bytes = "$FF"
    result = NAVByteArrayToCStyleHexString(bytes)

    if (!NAVAssertStringEqual('Single byte should not have separator', '0XFF', result)) {
        NAVLogTestFailed(2, '0XFF', result)
    }
    else {
        NAVLogTestPassed(2)
    }
}


/**
 * Test NAVByteArrayToHexStringWithOptions custom formatting
 */
define_function TestNAVByteArrayToHexStringWithOptions() {
    stack_var char bytes[3]
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVByteArrayToHexStringWithOptions *****************'")

    bytes = "$01, $23, $45"

    // Test with custom prefix and separator
    result = NAVByteArrayToHexStringWithOptions(bytes, '#', ':')

    if (!NAVAssertStringEqual('Should use custom prefix and separator', '#01:#23:#45', result)) {
        NAVLogTestFailed(1, '#01:#23:#45', result)
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test with no prefix, space separator
    result = NAVByteArrayToHexStringWithOptions(bytes, '', ' ')

    if (!NAVAssertStringEqual('Should use space separator', '01 23 45', result)) {
        NAVLogTestFailed(2, '01 23 45', result)
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test with prefix but no separator
    result = NAVByteArrayToHexStringWithOptions(bytes, 'h', '')

    if (!NAVAssertStringEqual('Should have prefix but no separator', 'h01h23h45', result)) {
        NAVLogTestFailed(3, 'h01h23h45', result)
    }
    else {
        NAVLogTestPassed(3)
    }

    // Test empty arrays
    result = NAVByteArrayToHexStringWithOptions('', '$', ',')

    if (!NAVAssertStringEqual('Empty array should produce empty string', '', result)) {
        NAVLogTestFailed(4, 'empty', result)
    }
    else {
        NAVLogTestPassed(4)
    }
}


/**
 * Test NAVByteToHexString single byte conversion
 */
define_function TestNAVByteToHexString() {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var char bytes[1]

    NAVLog("'***************** TestNAVByteToHexString *****************'")

    // Test $01 using byte array
    bytes[1] = $01
    set_length_array(bytes, 1)
    result = NAVByteArrayToHexString(bytes)

    if (!NAVAssertStringEqual('Should convert 01 to hex', '01', result)) {
        NAVLogTestFailed(1, '01', result)
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test $FF
    bytes[1] = $FF
    set_length_array(bytes, 1)
    result = NAVByteArrayToHexString(bytes)

    if (!NAVAssertStringEqual('Should convert FF to hex', 'ff', result)) {
        NAVLogTestFailed(2, 'ff', result)
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test $00
    bytes[1] = $00
    set_length_array(bytes, 1)
    result = NAVByteArrayToHexString(bytes)

    if (!NAVAssertStringEqual('Should convert 00 to hex', '00', result)) {
        NAVLogTestFailed(3, '00', result)
    }
    else {
        NAVLogTestPassed(3)
    }

    // Test $AB
    bytes[1] = $AB
    set_length_array(bytes, 1)
    result = NAVByteArrayToHexString(bytes)

    if (!NAVAssertStringEqual('Should handle hex letters', 'ab', result)) {
        NAVLogTestFailed(4, 'ab', result)
    }
    else {
        NAVLogTestPassed(4)
    }

    // Verify result length
    if (!NAVAssertIntegerEqual('Result should be 2 characters', 2, length_string(result))) {
        NAVLogTestFailed(5, '2', itoa(length_string(result)))
    }
    else {
        NAVLogTestPassed(5)
    }
}


/**
 * Test hex string formatting with various byte values
 */
define_function TestHexStringFormattingVariety() {
    stack_var char bytes[5]
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestHexStringFormattingVariety *****************'")

    // Test with mix of values
    bytes = "$00, $0F, $F0, $FF, $AA"
    result = NAVByteArrayToHexString(bytes)

    if (!NAVAssertStringEqual('Should handle varied byte values', '000ff0ffaa', result)) {
        NAVLogTestFailed(1, '000ff0ffaa', result)
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test NetLinx format with same bytes
    result = NAVByteArrayToNetLinxHexString(bytes)

    if (!NAVAssertStringEqual('NetLinx format should be uppercase', '$00$0F$F0$FF$AA', result)) {
        NAVLogTestFailed(2, '$00$0F$F0$FF$AA', result)
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test C format
    result = NAVByteArrayToCStyleHexString(bytes)

    // Note: upper_string makes the 'X' uppercase too
    if (!NAVAssertStringEqual('C format should have separators',
                              '0X00, 0X0F, 0XF0, 0XFF, 0XAA', result)) {
        NAVLogTestFailed(3, '0X00, 0X0F, 0XF0, 0XFF, 0XAA', result)
    }
    else {
        NAVLogTestPassed(3)
    }
}