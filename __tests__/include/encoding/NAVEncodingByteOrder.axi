PROGRAM_NAME='NAVEncodingByteOrder'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test data for byte order conversion
constant long TEST_LONG_VALUE = $12345678
constant long TEST_SHORT_VALUE = $1234


/**
 * Test NAVNetworkToHostLong with typical value
 */
define_function TestNAVNetworkToHostLong() {
    stack_var long networkValue
    stack_var long result

    NAVLog("'***************** TestNAVNetworkToHostLong *****************'")

    networkValue = $01020304
    result = NAVNetworkToHostLong(networkValue)

    if (!NAVAssertLongEqual('Should reverse byte order', $04030201, result)) {
        NAVLogTestFailed(1, "'$04030201'", format('%08X', result))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test with zero
    result = NAVNetworkToHostLong(0)
    if (!NAVAssertLongEqual('Should handle zero', 0, result)) {
        NAVLogTestFailed(2, '0', itoa(result))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test with all FF
    result = NAVNetworkToHostLong($FFFFFFFF)
    if (!NAVAssertLongEqual('Should handle all bits set', $FFFFFFFF, result)) {
        NAVLogTestFailed(3, "'$FFFFFFFF'", format('%08X', result))
    }
    else {
        NAVLogTestPassed(3)
    }
}


/**
 * Test NAVHostToNetworkShort with typical value
 */
define_function TestNAVHostToNetworkShort() {
    stack_var long hostValue
    stack_var long result

    NAVLog("'***************** TestNAVHostToNetworkShort *****************'")

    hostValue = $0102
    result = NAVHostToNetworkShort(hostValue)

    if (!NAVAssertLongEqual('Should reverse byte order', $0201, result)) {
        NAVLogTestFailed(1, "'$0201'", format('%04X', result))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test with zero
    result = NAVHostToNetworkShort(0)
    if (!NAVAssertLongEqual('Should handle zero', 0, result)) {
        NAVLogTestFailed(2, '0', itoa(result))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test with all FF in 16-bit range
    result = NAVHostToNetworkShort($FFFF)
    if (!NAVAssertLongEqual('Should handle all bits set', $FFFF, result)) {
        NAVLogTestFailed(3, "'$FFFF'", format('%04X', result))
    }
    else {
        NAVLogTestPassed(3)
    }
}


/**
 * Test NAVToLittleEndian alias function
 */
define_function TestNAVToLittleEndian() {
    stack_var long bigEndianValue
    stack_var long result

    NAVLog("'***************** TestNAVToLittleEndian *****************'")

    bigEndianValue = $01020304
    result = NAVToLittleEndian(bigEndianValue)

    if (!NAVAssertLongEqual('Should convert to little-endian', $04030201, result)) {
        NAVLogTestFailed(1, "'$04030201'", format('%08X', result))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Verify it's equivalent to NAVNetworkToHostLong
    if (!NAVAssertLongEqual('Should match NAVNetworkToHostLong',
                           NAVNetworkToHostLong(bigEndianValue), result)) {
        NAVLogTestFailed(2, 'match', 'mismatch')
    }
    else {
        NAVLogTestPassed(2)
    }
}


/**
 * Test NAVToBigEndian alias function
 */
define_function TestNAVToBigEndian() {
    stack_var long littleEndianValue
    stack_var long result

    NAVLog("'***************** TestNAVToBigEndian *****************'")

    littleEndianValue = $0102
    result = NAVToBigEndian(littleEndianValue)

    if (!NAVAssertLongEqual('Should convert to big-endian', $0201, result)) {
        NAVLogTestFailed(1, "'$0201'", format('%04X', result))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Verify it's equivalent to NAVHostToNetworkShort
    if (!NAVAssertLongEqual('Should match NAVHostToNetworkShort',
                           NAVHostToNetworkShort(littleEndianValue), result)) {
        NAVLogTestFailed(2, 'match', 'mismatch')
    }
    else {
        NAVLogTestPassed(2)
    }
}


/**
 * Test byte order reversibility
 */
define_function TestByteOrderReversibility() {
    stack_var long originalLong
    stack_var long processedLong
    stack_var long originalShort
    stack_var long processedShort

    NAVLog("'***************** TestByteOrderReversibility *****************'")

    // Test long reversibility
    originalLong = $12345678
    processedLong = NAVNetworkToHostLong(NAVNetworkToHostLong(originalLong))

    if (!NAVAssertLongEqual('Double conversion should restore original', originalLong, processedLong)) {
        NAVLogTestFailed(1, format('%08X', originalLong), format('%08X', processedLong))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test short reversibility
    originalShort = $1234
    processedShort = NAVHostToNetworkShort(NAVHostToNetworkShort(originalShort))

    if (!NAVAssertLongEqual('Double conversion should restore original', originalShort, processedShort)) {
        NAVLogTestFailed(2, format('%04X', originalShort), format('%04X', processedShort))
    }
    else {
        NAVLogTestPassed(2)
    }
}
