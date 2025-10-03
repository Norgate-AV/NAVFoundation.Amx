PROGRAM_NAME='NAVEncodingByteArray'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'


/**
 * Test NAVIntegerToByteArrayLE conversion
 */
define_function TestNAVIntegerToByteArrayLE() {
    stack_var integer value
    stack_var char bytes[2]

    NAVLog("'***************** TestNAVIntegerToByteArrayLE *****************'")

    value = $1234
    bytes = NAVIntegerToByteArrayLE(value)

    if (!NAVAssertIntegerEqual('First byte should be $34', $34, bytes[1])) {
        NAVLogTestFailed(1, "'$34'", format('%02X', bytes[1]))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Second byte should be $12', $12, bytes[2])) {
        NAVLogTestFailed(2, "'$12'", format('%02X', bytes[2]))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test with zero
    bytes = NAVIntegerToByteArrayLE(0)
    if (!NAVAssertIntegerEqual('Zero should produce $00 $00', 0, bytes[1] + bytes[2])) {
        NAVLogTestFailed(3, '0', itoa(bytes[1] + bytes[2]))
    }
    else {
        NAVLogTestPassed(3)
    }

    // Test array length
    if (!NAVAssertIntegerEqual('Array should have length 2', 2, length_array(bytes))) {
        NAVLogTestFailed(4, '2', itoa(length_array(bytes)))
    }
    else {
        NAVLogTestPassed(4)
    }
}


/**
 * Test NAVIntegerToByteArrayBE conversion
 */
define_function TestNAVIntegerToByteArrayBE() {
    stack_var integer value
    stack_var char bytes[2]

    NAVLog("'***************** TestNAVIntegerToByteArrayBE *****************'")

    value = $1234
    bytes = NAVIntegerToByteArrayBE(value)

    if (!NAVAssertIntegerEqual('First byte should be $12', $12, bytes[1])) {
        NAVLogTestFailed(1, "'$12'", format('%02X', bytes[1]))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Second byte should be $34', $34, bytes[2])) {
        NAVLogTestFailed(2, "'$34'", format('%02X', bytes[2]))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test array length
    if (!NAVAssertIntegerEqual('Array should have length 2', 2, length_array(bytes))) {
        NAVLogTestFailed(3, '2', itoa(length_array(bytes)))
    }
    else {
        NAVLogTestPassed(3)
    }
}


/**
 * Test NAVIntegerToByteArray alias (should use LE)
 */
define_function TestNAVIntegerToByteArray() {
    stack_var integer value
    stack_var char bytes[2]
    stack_var char bytesLE[2]

    NAVLog("'***************** TestNAVIntegerToByteArray *****************'")

    value = $1234
    bytes = NAVIntegerToByteArray(value)
    bytesLE = NAVIntegerToByteArrayLE(value)

    if (!NAVAssertIntegerEqual('Should match LE byte 1', bytesLE[1], bytes[1])) {
        NAVLogTestFailed(1, format('%02X', bytesLE[1]), format('%02X', bytes[1]))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Should match LE byte 2', bytesLE[2], bytes[2])) {
        NAVLogTestFailed(2, format('%02X', bytesLE[2]), format('%02X', bytes[2]))
    }
    else {
        NAVLogTestPassed(2)
    }
}


/**
 * Test NAVLongToByteArrayLE conversion
 */
define_function TestNAVLongToByteArrayLE() {
    stack_var long value
    stack_var char bytes[4]

    NAVLog("'***************** TestNAVLongToByteArrayLE *****************'")

    value = $12345678
    bytes = NAVLongToByteArrayLE(value)

    if (!NAVAssertIntegerEqual('Byte 1 should be $78', $78, bytes[1])) {
        NAVLogTestFailed(1, "'$78'", format('%02X', bytes[1]))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Byte 2 should be $56', $56, bytes[2])) {
        NAVLogTestFailed(2, "'$56'", format('%02X', bytes[2]))
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertIntegerEqual('Byte 3 should be $34', $34, bytes[3])) {
        NAVLogTestFailed(3, "'$34'", format('%02X', bytes[3]))
    }
    else {
        NAVLogTestPassed(3)
    }

    if (!NAVAssertIntegerEqual('Byte 4 should be $12', $12, bytes[4])) {
        NAVLogTestFailed(4, "'$12'", format('%02X', bytes[4]))
    }
    else {
        NAVLogTestPassed(4)
    }

    // Test array length
    if (!NAVAssertIntegerEqual('Array should have length 4', 4, length_array(bytes))) {
        NAVLogTestFailed(5, '4', itoa(length_array(bytes)))
    }
    else {
        NAVLogTestPassed(5)
    }
}


/**
 * Test NAVLongToByteArrayBE conversion
 */
define_function TestNAVLongToByteArrayBE() {
    stack_var long value
    stack_var char bytes[4]

    NAVLog("'***************** TestNAVLongToByteArrayBE *****************'")

    value = $12345678
    bytes = NAVLongToByteArrayBE(value)

    if (!NAVAssertIntegerEqual('Byte 1 should be $12', $12, bytes[1])) {
        NAVLogTestFailed(1, "'$12'", format('%02X', bytes[1]))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Byte 2 should be $34', $34, bytes[2])) {
        NAVLogTestFailed(2, "'$34'", format('%02X', bytes[2]))
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertIntegerEqual('Byte 3 should be $56', $56, bytes[3])) {
        NAVLogTestFailed(3, "'$56'", format('%02X', bytes[3]))
    }
    else {
        NAVLogTestPassed(3)
    }

    if (!NAVAssertIntegerEqual('Byte 4 should be $78', $78, bytes[4])) {
        NAVLogTestFailed(4, "'$78'", format('%02X', bytes[4]))
    }
    else {
        NAVLogTestPassed(4)
    }

    // Test array length
    if (!NAVAssertIntegerEqual('Array should have length 4', 4, length_array(bytes))) {
        NAVLogTestFailed(5, '4', itoa(length_array(bytes)))
    }
    else {
        NAVLogTestPassed(5)
    }
}


/**
 * Test NAVLongToByteArray alias (should use LE)
 */
define_function TestNAVLongToByteArray() {
    stack_var long value
    stack_var char bytes[4]
    stack_var char bytesLE[4]

    NAVLog("'***************** TestNAVLongToByteArray *****************'")

    value = $12345678
    bytes = NAVLongToByteArray(value)
    bytesLE = NAVLongToByteArrayLE(value)

    if (!NAVAssertIntegerEqual('Should match LE byte 1', bytesLE[1], bytes[1])) {
        NAVLogTestFailed(1, format('%02X', bytesLE[1]), format('%02X', bytes[1]))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Should match LE byte 2', bytesLE[2], bytes[2])) {
        NAVLogTestFailed(2, format('%02X', bytesLE[2]), format('%02X', bytes[2]))
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertIntegerEqual('Should match LE byte 3', bytesLE[3], bytes[3])) {
        NAVLogTestFailed(3, format('%02X', bytesLE[3]), format('%02X', bytes[3]))
    }
    else {
        NAVLogTestPassed(3)
    }

    if (!NAVAssertIntegerEqual('Should match LE byte 4', bytesLE[4], bytes[4])) {
        NAVLogTestFailed(4, format('%02X', bytesLE[4]), format('%02X', bytes[4]))
    }
    else {
        NAVLogTestPassed(4)
    }
}


/**
 * Test NAVCharToLong conversion
 */
define_function TestNAVCharToLong() {
    stack_var char bytes[8]
    stack_var long values[2]

    NAVLog("'***************** TestNAVCharToLong *****************'")

    bytes = "$01, $02, $03, $04, $05, $06, $07, $08"
    NAVCharToLong(values, bytes, 8)

    if (!NAVAssertLongEqual('First long should be $04030201', $04030201, values[1])) {
        NAVLogTestFailed(1, "'$04030201'", format('%08X', values[1]))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertLongEqual('Second long should be $08070605', $08070605, values[2])) {
        NAVLogTestFailed(2, "'$08070605'", format('%08X', values[2]))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Clear array for next test
    values[1] = 0
    values[2] = 0
    set_length_array(values, 0)

    // Test with 4 bytes
    bytes = "$AA, $BB, $CC, $DD"
    NAVCharToLong(values, bytes, 4)

    if (!NAVAssertLongEqual('Single long should be $DDCCBBAA', $DDCCBBAA, values[1])) {
        NAVLogTestFailed(3, "'$DDCCBBAA'", format('%08X', values[1]))
    }
    else {
        NAVLogTestPassed(3)
    }
}


/**
 * Test NAVCharToLong with partial data
 */
define_function TestNAVCharToLongPartial() {
    stack_var char bytes[10]
    stack_var long values[3]

    NAVLog("'***************** TestNAVCharToLongPartial *****************'")

    bytes = "$01, $02, $03, $04, $05, $06, $07, $08, $09, $0A"

    // Convert only 8 bytes (should produce 2 longs)
    NAVCharToLong(values, bytes, 8)

    if (!NAVAssertLongEqual('First long from 8 bytes', $04030201, values[1])) {
        NAVLogTestFailed(1, "'$04030201'", format('%08X', values[1]))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertLongEqual('Second long from 8 bytes', $08070605, values[2])) {
        NAVLogTestFailed(2, "'$08070605'", format('%08X', values[2]))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Clear array
    values[1] = 0
    values[2] = 0
    values[3] = 0
    set_length_array(values, 0)

    // Convert only 4 bytes (should produce 1 long)
    NAVCharToLong(values, bytes, 4)

    if (!NAVAssertLongEqual('Single long from 4 bytes', $04030201, values[1])) {
        NAVLogTestFailed(3, "'$04030201'", format('%08X', values[1]))
    }
    else {
        NAVLogTestPassed(3)
    }
}


/**
 * Test edge cases with maximum values
 */
define_function TestMaximumValues() {
    stack_var long maxLong
    stack_var long maxShort
    stack_var char bytes[4]

    NAVLog("'***************** TestMaximumValues *****************'")

    maxLong = $FFFFFFFF
    bytes = NAVLongToByteArrayLE(maxLong)

    if (!NAVAssertIntegerEqual('All bytes should be FF', $FF, bytes[1])) {
        NAVLogTestFailed(1, "'$FF'", format('%02X', bytes[1]))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('All bytes should be FF', $FF, bytes[2])) {
        NAVLogTestFailed(2, "'$FF'", format('%02X', bytes[2]))
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertIntegerEqual('All bytes should be FF', $FF, bytes[3])) {
        NAVLogTestFailed(3, "'$FF'", format('%02X', bytes[3]))
    }
    else {
        NAVLogTestPassed(3)
    }

    if (!NAVAssertIntegerEqual('All bytes should be FF', $FF, bytes[4])) {
        NAVLogTestFailed(4, "'$FF'", format('%02X', bytes[4]))
    }
    else {
        NAVLogTestPassed(4)
    }

    // Test max short
    maxShort = $FFFF
    bytes = NAVIntegerToByteArrayLE(maxShort)

    if (!NAVAssertIntegerEqual('Both bytes should be FF', $FF, bytes[1])) {
        NAVLogTestFailed(5, "'$FF'", format('%02X', bytes[1]))
    }
    else {
        NAVLogTestPassed(5)
    }

    if (!NAVAssertIntegerEqual('Both bytes should be FF', $FF, bytes[2])) {
        NAVLogTestFailed(6, "'$FF'", format('%02X', bytes[2]))
    }
    else {
        NAVLogTestPassed(6)
    }
}
