PROGRAM_NAME='NAVEncodingIntegration'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'


/**
 * Test round-trip conversion: Integer to bytes to hex string
 */
define_function TestRoundTripIntegerConversion() {
    stack_var integer value
    stack_var char bytes[2]
    stack_var char hexString[NAV_MAX_BUFFER]

    NAVLog("'***************** TestRoundTripIntegerConversion *****************'")

    value = $ABCD
    bytes = NAVIntegerToByteArrayLE(value)
    hexString = NAVByteArrayToHexString(bytes)

    if (!NAVAssertStringEqual('Hex string should match', 'cdab', hexString)) {
        NAVLogTestFailed(1, 'cdab', hexString)
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test BE conversion
    bytes = NAVIntegerToByteArrayBE(value)
    hexString = NAVByteArrayToHexString(bytes)

    if (!NAVAssertStringEqual('BE hex string should match', 'abcd', hexString)) {
        NAVLogTestFailed(2, 'abcd', hexString)
    }
    else {
        NAVLogTestPassed(2)
    }
}


/**
 * Test round-trip conversion: Long to bytes to hex string
 */
define_function TestRoundTripLongConversion() {
    stack_var long value
    stack_var char bytes[4]
    stack_var char hexString[NAV_MAX_BUFFER]

    NAVLog("'***************** TestRoundTripLongConversion *****************'")

    value = $ABCDEF12
    bytes = NAVLongToByteArrayLE(value)
    hexString = NAVByteArrayToHexString(bytes)

    if (!NAVAssertStringEqual('Hex string should match', '12efcdab', hexString)) {
        NAVLogTestFailed(1, '12efcdab', hexString)
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test BE conversion
    bytes = NAVLongToByteArrayBE(value)
    hexString = NAVByteArrayToHexString(bytes)

    if (!NAVAssertStringEqual('BE hex string should match', 'abcdef12', hexString)) {
        NAVLogTestFailed(2, 'abcdef12', hexString)
    }
    else {
        NAVLogTestPassed(2)
    }
}


/**
 * Test combined byte order and byte array conversion
 */
define_function TestByteOrderWithArrayConversion() {
    stack_var long networkValue
    stack_var long hostValue
    stack_var char bytes[4]
    stack_var char hexString[NAV_MAX_BUFFER]

    NAVLog("'***************** TestByteOrderWithArrayConversion *****************'")

    // Network order value
    networkValue = $01020304

    // Convert to host order
    hostValue = NAVNetworkToHostLong(networkValue)

    // Convert host value to byte array
    bytes = NAVLongToByteArrayLE(hostValue)

    // Convert to hex string
    hexString = NAVByteArrayToHexString(bytes)

    if (!NAVAssertStringEqual('Should match reversed order', '01020304', hexString)) {
        NAVLogTestFailed(1, '01020304', hexString)
    }
    else {
        NAVLogTestPassed(1)
    }
}


/**
 * Test full encoding workflow: value -> bytes -> hex -> formatted string
 */
define_function TestFullEncodingWorkflow() {
    stack_var long value
    stack_var char bytesLE[4]
    stack_var char bytesBE[4]
    stack_var char hexNetLinx[NAV_MAX_BUFFER]
    stack_var char hexCStyle[NAV_MAX_BUFFER]

    NAVLog("'***************** TestFullEncodingWorkflow *****************'")

    value = $12345678

    // Convert to little-endian bytes
    bytesLE = NAVLongToByteArrayLE(value)

    // Convert to NetLinx format
    hexNetLinx = NAVByteArrayToNetLinxHexString(bytesLE)

    if (!NAVAssertStringEqual('NetLinx format should match', '$78$56$34$12', hexNetLinx)) {
        NAVLogTestFailed(1, '$78$56$34$12', hexNetLinx)
    }
    else {
        NAVLogTestPassed(1)
    }

    // Convert to big-endian bytes
    bytesBE = NAVLongToByteArrayBE(value)

    // Convert to C-style format
    hexCStyle = NAVByteArrayToCStyleHexString(bytesBE)

    // Note: upper_string makes the 'X' uppercase too
    if (!NAVAssertStringEqual('C-style format should match',
                              '0X12, 0X34, 0X56, 0X78', hexCStyle)) {
        NAVLogTestFailed(2, '0X12, 0X34, 0X56, 0X78', hexCStyle)
    }
    else {
        NAVLogTestPassed(2)
    }
}


/**
 * Test CharToLong with byte array conversion
 */
define_function TestCharToLongWithByteArrays() {
    stack_var long originalValues[2]
    stack_var char bytes[8]
    stack_var char tempBytes[4]
    stack_var long reconstructedValues[2]
    stack_var integer i

    NAVLog("'***************** TestCharToLongWithByteArrays *****************'")

    // Original values
    originalValues[1] = $12345678
    originalValues[2] = $ABCDEF01

    // Convert first long to bytes and store
    tempBytes = NAVLongToByteArrayLE(originalValues[1])
    for (i = 1; i <= 4; i++) {
        bytes[i] = tempBytes[i]
    }

    // Convert second long to bytes and append
    tempBytes = NAVLongToByteArrayLE(originalValues[2])
    for (i = 1; i <= 4; i++) {
        bytes[i + 4] = tempBytes[i]
    }
    set_length_array(bytes, 8)

    // Convert back to longs
    NAVCharToLong(reconstructedValues, bytes, 8)

    if (!NAVAssertLongEqual('First value should match', originalValues[1], reconstructedValues[1])) {
        NAVLogTestFailed(1, format('%08X', originalValues[1]), format('%08X', reconstructedValues[1]))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertLongEqual('Second value should match', originalValues[2], reconstructedValues[2])) {
        NAVLogTestFailed(2, format('%08X', originalValues[2]), format('%08X', reconstructedValues[2]))
    }
    else {
        NAVLogTestPassed(2)
    }
}


/**
 * Test multiple format conversions on same data
 */
define_function TestMultipleFormatConversions() {
    stack_var char bytes[3]
    stack_var char hexClean[NAV_MAX_BUFFER]
    stack_var char hexNetLinx[NAV_MAX_BUFFER]
    stack_var char hexCStyle[NAV_MAX_BUFFER]
    stack_var char hexCustom[NAV_MAX_BUFFER]

    NAVLog("'***************** TestMultipleFormatConversions *****************'")

    bytes = "$AA, $BB, $CC"

    // Convert to different formats
    hexClean = NAVByteArrayToHexString(bytes)
    hexNetLinx = NAVByteArrayToNetLinxHexString(bytes)
    hexCStyle = NAVByteArrayToCStyleHexString(bytes)
    hexCustom = NAVByteArrayToHexStringWithOptions(bytes, 'h', '-')

    // Verify all conversions worked
    if (!NAVAssertStringEqual('Clean format should be correct', 'aabbcc', hexClean)) {
        NAVLogTestFailed(1, 'aabbcc', hexClean)
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertStringEqual('NetLinx format should be correct', '$AA$BB$CC', hexNetLinx)) {
        NAVLogTestFailed(2, '$AA$BB$CC', hexNetLinx)
    }
    else {
        NAVLogTestPassed(2)
    }

    // Note: upper_string makes the 'X' uppercase too
    if (!NAVAssertStringEqual('C-style format should be correct',
                              '0XAA, 0XBB, 0XCC', hexCStyle)) {
        NAVLogTestFailed(3, '0XAA, 0XBB, 0XCC', hexCStyle)
    }
    else {
        NAVLogTestPassed(3)
    }

    if (!NAVAssertStringEqual('Custom format should be correct', 'haa-hbb-hcc', hexCustom)) {
        NAVLogTestFailed(4, 'haa-hbb-hcc', hexCustom)
    }
    else {
        NAVLogTestPassed(4)
    }
}


/**
 * Test endianness consistency across conversions
 */
define_function TestEndiannessConsistency() {
    stack_var integer intValue
    stack_var long longValue
    stack_var char intBytesLE[2]
    stack_var char intBytesBE[2]
    stack_var char longBytesLE[4]
    stack_var char longBytesBE[4]

    NAVLog("'***************** TestEndiannessConsistency *****************'")

    intValue = $1234
    longValue = $12345678

    // Get LE and BE representations
    intBytesLE = NAVIntegerToByteArrayLE(intValue)
    intBytesBE = NAVIntegerToByteArrayBE(intValue)
    longBytesLE = NAVLongToByteArrayLE(longValue)
    longBytesBE = NAVLongToByteArrayBE(longValue)

    // Verify LE integer byte order
    if (!NAVAssertIntegerEqual('LE int byte 1 should be LSB', $34, intBytesLE[1])) {
        NAVLogTestFailed(1, "'$34'", format('%02X', intBytesLE[1]))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Verify BE integer byte order
    if (!NAVAssertIntegerEqual('BE int byte 1 should be MSB', $12, intBytesBE[1])) {
        NAVLogTestFailed(2, "'$12'", format('%02X', intBytesBE[1]))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Verify LE long byte order
    if (!NAVAssertIntegerEqual('LE long byte 1 should be LSB', $78, longBytesLE[1])) {
        NAVLogTestFailed(3, "'$78'", format('%02X', longBytesLE[1]))
    }
    else {
        NAVLogTestPassed(3)
    }

    // Verify BE long byte order
    if (!NAVAssertIntegerEqual('BE long byte 1 should be MSB', $12, longBytesBE[1])) {
        NAVLogTestFailed(4, "'$12'", format('%02X', longBytesBE[1]))
    }
    else {
        NAVLogTestPassed(4)
    }
}
