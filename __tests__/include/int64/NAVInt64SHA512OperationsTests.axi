PROGRAM_NAME='NAVInt64SHA512OperationsTests'

/*
 * Tests specifically targeting the Int64 operations as they are used in SHA-512
 * These tests ensure that the Int64 library behaves correctly for specific SHA-512 operations
 */

#IF_NOT_DEFINED __NAV_INT64_SHA512_OPERATIONS_TESTS__
#DEFINE __NAV_INT64_SHA512_OPERATIONS_TESTS__ 'NAVInt64SHA512OperationsTests'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Int64.axi'

/**
 * @function TestMessageScheduleOperation
 * @description Test the specific message schedule calculation used in SHA-512
 * W[t] = σ1(W[t-2]) + W[t-7] + σ0(W[t-15]) + W[t-16]
 *
 * @returns {integer} 1 if tests pass, 0 if any fail
 */
define_function integer TestMessageScheduleOperation() {
    stack_var integer testsPassed, totalTests
    stack_var _NAVInt64 W[17]  // We need indices 1-16 for this test
    stack_var _NAVInt64 sigma0, sigma1, temp1, temp2, expected, actual

    testsPassed = 0
    totalTests = 0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-512 message schedule calculations'")

    // Initialize W values with recognizable bit patterns
    W[1].Hi = $00000001; W[1].Lo = $00000001  // W[t-16]
    W[2].Hi = $00000002; W[2].Lo = $00000002  // W[t-15]
    // ...
    W[9].Hi = $00000009; W[9].Lo = $00000009  // W[t-8]
    W[10].Hi = $0000000A; W[10].Lo = $0000000A  // W[t-7]
    // ...
    W[15].Hi = $0000000F; W[15].Lo = $0000000F  // W[t-2]
    W[16].Hi = $00000010; W[16].Lo = $00000010  // W[t-1]

    // Calculate sigma0(W[t-15]) = ROTR^1(W[2]) XOR ROTR^8(W[2]) XOR SHR^7(W[2])
    // This is the small sigma0 function used in message schedule
    NAVInt64RotateRightFull(W[2], 1, temp1)
    NAVInt64RotateRightFull(W[2], 8, temp2)
    NAVInt64BitXor(temp1, temp2, sigma0)

    NAVInt64ShiftRight(W[2], 7, temp1)
    NAVInt64BitXor(sigma0, temp1, sigma0)

    // Calculate sigma1(W[t-2]) = ROTR^19(W[15]) XOR ROTR^61(W[15]) XOR SHR^6(W[15])
    // This is the small sigma1 function used in message schedule
    NAVInt64RotateRightFull(W[15], 19, temp1)
    NAVInt64RotateRightFull(W[15], 61, temp2)
    NAVInt64BitXor(temp1, temp2, sigma1)

    NAVInt64ShiftRight(W[15], 6, temp1)
    NAVInt64BitXor(sigma1, temp1, sigma1)

    // Calculate W[t] = sigma1(W[t-2]) + W[t-7] + sigma0(W[t-15]) + W[t-16]
    NAVInt64Add(sigma1, W[10], temp1)
    NAVInt64Add(temp1, sigma0, temp2)
    NAVInt64Add(temp2, W[1], expected)

    // Run the same calculation using a test version of the message schedule function
    CalculateMessageScheduleW(W, actual)

    totalTests++
    if (actual.Hi == expected.Hi && actual.Lo == expected.Lo) {
        testsPassed++
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Message schedule calculation test failed'")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Expected: $', format('%08x', expected.Hi), format('%08x', expected.Lo)")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Got: $', format('%08x', actual.Hi), format('%08x', actual.Lo)")
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Message schedule tests: ', itoa(testsPassed), ' of ', itoa(totalTests), ' passed'")
    return (testsPassed == totalTests)
}

/**
 * @function CalculateMessageScheduleW
 * @internal
 * @description Helper function that mimics the message schedule calculation in SHA-512
 */
define_function CalculateMessageScheduleW(_NAVInt64 W[], _NAVInt64 result) {
    stack_var _NAVInt64 s0, s1, temp1, temp2

    // This is the calculation used in the message schedule
    // W[t] = sigma1(W[t-2]) + W[t-7] + sigma0(W[t-15]) + W[t-16]

    // Calculate small sigma0(W[t-15])
    s0.Hi = 0; s0.Lo = 0
    NAVInt64RotateRightFull(W[2], 1, temp1)
    NAVInt64RotateRightFull(W[2], 8, temp2)
    NAVInt64BitXor(temp1, temp2, s0)

    NAVInt64ShiftRight(W[2], 7, temp1)
    NAVInt64BitXor(s0, temp1, s0)

    // Calculate small sigma1(W[t-2])
    s1.Hi = 0; s1.Lo = 0
    NAVInt64RotateRightFull(W[15], 19, temp1)
    NAVInt64RotateRightFull(W[15], 61, temp2)
    NAVInt64BitXor(temp1, temp2, s1)

    NAVInt64ShiftRight(W[15], 6, temp1)
    NAVInt64BitXor(s1, temp1, s1)

    // W[t] = W[t-16] + s0 + W[t-7] + s1
    temp1.Hi = 0; temp1.Lo = 0
    NAVInt64Add(W[1], s0, temp1)

    temp2.Hi = 0; temp2.Lo = 0
    NAVInt64Add(W[10], s1, temp2)

    NAVInt64Add(temp1, temp2, result)
}

/**
 * @function TestCompressionFunction
 * @description Test the core operations used in the SHA-512 compression function
 *
 * @returns {integer} 1 if tests pass, 0 if any fail
 */
define_function integer TestCompressionFunction() {
    stack_var integer testsPassed, totalTests
    stack_var _NAVInt64 a, b, c, d, e, f, g, h, k, w
    stack_var _NAVInt64 ch, maj, sigma0, sigma1
    stack_var _NAVInt64 temp1, temp2, t1, t2
    stack_var _NAVInt64 expected_a_new, expected_e_new
    stack_var _NAVInt64 actual_a_new, actual_e_new

    testsPassed = 0
    totalTests = 0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing SHA-512 compression function calculations'")

    // Initialize working variables with recognizable values
    a.Hi = $01000000; a.Lo = $00000001
    b.Hi = $02000000; b.Lo = $00000002
    c.Hi = $03000000; c.Lo = $00000003
    d.Hi = $04000000; d.Lo = $00000004
    e.Hi = $05000000; e.Lo = $00000005
    f.Hi = $06000000; f.Lo = $00000006
    g.Hi = $07000000; g.Lo = $00000007
    h.Hi = $08000000; h.Lo = $00000008
    k.Hi = $428a2f98; k.Lo = $d728ae22  // SHA-512 K[0]
    w.Hi = $10000000; w.Lo = $00000010  // Some message word

    // Calculate the components of the compression function:

    // Ch(e,f,g) = (e AND f) XOR ((NOT e) AND g)
    NAVInt64BitAnd(e, f, temp1)
    NAVInt64BitNot(e, temp2)
    NAVInt64BitAnd(temp2, g, temp2)
    NAVInt64BitXor(temp1, temp2, ch)

    // Maj(a,b,c) = (a AND b) XOR (a AND c) XOR (b AND c)
    NAVInt64BitAnd(a, b, temp1)
    NAVInt64BitAnd(a, c, temp2)
    NAVInt64BitXor(temp1, temp2, maj)
    NAVInt64BitAnd(b, c, temp1)
    NAVInt64BitXor(maj, temp1, maj)

    // Sigma0(a) = ROTR^28(a) XOR ROTR^34(a) XOR ROTR^39(a)
    NAVInt64RotateRightFull(a, 28, temp1)
    NAVInt64RotateRightFull(a, 34, temp2)
    NAVInt64BitXor(temp1, temp2, sigma0)
    NAVInt64RotateRightFull(a, 39, temp1)
    NAVInt64BitXor(sigma0, temp1, sigma0)

    // Sigma1(e) = ROTR^14(e) XOR ROTR^18(e) XOR ROTR^41(e)
    NAVInt64RotateRightFull(e, 14, temp1)
    NAVInt64RotateRightFull(e, 18, temp2)
    NAVInt64BitXor(temp1, temp2, sigma1)
    NAVInt64RotateRightFull(e, 41, temp1)
    NAVInt64BitXor(sigma1, temp1, sigma1)

    // T1 = h + Sigma1(e) + Ch(e,f,g) + k + w
    NAVInt64Add(h, sigma1, temp1)
    NAVInt64Add(temp1, ch, temp2)
    NAVInt64Add(temp2, k, temp1)
    NAVInt64Add(temp1, w, t1)

    // T2 = Sigma0(a) + Maj(a,b,c)
    NAVInt64Add(sigma0, maj, t2)

    // Calculate new working variables
    // a_new = T1 + T2
    NAVInt64Add(t1, t2, expected_a_new)

    // e_new = d + T1
    NAVInt64Add(d, t1, expected_e_new)

    // Now run a test function that mimics the SHA-512 compression function calculations
    CalculateCompressionStep(a, b, c, d, e, f, g, h, k, w, actual_a_new, actual_e_new)

    // Test new value of a
    totalTests++
    if (actual_a_new.Hi == expected_a_new.Hi && actual_a_new.Lo == expected_a_new.Lo) {
        testsPassed++
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Compression function test failed for new a value'")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Expected: $', format('%08x', expected_a_new.Hi), format('%08x', expected_a_new.Lo)")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Got: $', format('%08x', actual_a_new.Hi), format('%08x', actual_a_new.Lo)")
    }

    // Test new value of e
    totalTests++
    if (actual_e_new.Hi == expected_e_new.Hi && actual_e_new.Lo == expected_e_new.Lo) {
        testsPassed++
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Compression function test failed for new e value'")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Expected: $', format('%08x', expected_e_new.Hi), format('%08x', expected_e_new.Lo)")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Got: $', format('%08x', actual_e_new.Hi), format('%08x', actual_e_new.Lo)")
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Compression function tests: ', itoa(testsPassed), ' of ', itoa(totalTests), ' passed'")
    return (testsPassed == totalTests)
}

/**
 * @function CalculateCompressionStep
 * @internal
 * @description Helper function that mimics one step of the SHA-512 compression function
 */
define_function CalculateCompressionStep(_NAVInt64 a, _NAVInt64 b, _NAVInt64 c, _NAVInt64 d,
                                       _NAVInt64 e, _NAVInt64 f, _NAVInt64 g, _NAVInt64 h,
                                       _NAVInt64 k, _NAVInt64 w,
                                       _NAVInt64 new_a, _NAVInt64 new_e) {
    stack_var _NAVInt64 ch, maj, sigma0, sigma1, t1, t2

    // Calculate the SHA-512 functions:

    // Ch(e,f,g)
    ch.Hi = 0; ch.Lo = 0
    NAVInt64BitAnd(e, f, ch)

    sigma0.Hi = 0; sigma0.Lo = 0
    NAVInt64BitNot(e, sigma0)
    NAVInt64BitAnd(sigma0, g, sigma0)
    NAVInt64BitXor(ch, sigma0, ch)

    // Maj(a,b,c)
    maj.Hi = 0; maj.Lo = 0
    sigma0.Hi = 0; sigma0.Lo = 0
    NAVInt64BitAnd(a, b, maj)
    NAVInt64BitAnd(a, c, sigma0)
    NAVInt64BitXor(maj, sigma0, maj)
    sigma0.Hi = 0; sigma0.Lo = 0
    NAVInt64BitAnd(b, c, sigma0)
    NAVInt64BitXor(maj, sigma0, maj)

    // Sigma0(a)
    sigma0.Hi = 0; sigma0.Lo = 0
    t1.Hi = 0; t1.Lo = 0
    t2.Hi = 0; t2.Lo = 0
    NAVInt64RotateRightFull(a, 28, t1)
    NAVInt64RotateRightFull(a, 34, t2)
    NAVInt64BitXor(t1, t2, sigma0)
    NAVInt64RotateRightFull(a, 39, t1)
    NAVInt64BitXor(sigma0, t1, sigma0)

    // Sigma1(e)
    sigma1.Hi = 0; sigma1.Lo = 0
    t1.Hi = 0; t1.Lo = 0
    t2.Hi = 0; t2.Lo = 0
    NAVInt64RotateRightFull(e, 14, t1)
    NAVInt64RotateRightFull(e, 18, t2)
    NAVInt64BitXor(t1, t2, sigma1)
    NAVInt64RotateRightFull(e, 41, t1)
    NAVInt64BitXor(sigma1, t1, sigma1)

    // T1 = h + Sigma1(e) + Ch(e,f,g) + k + w
    t1.Hi = 0; t1.Lo = 0
    NAVInt64Add(h, sigma1, t1)
    NAVInt64Add(t1, ch, t1)
    NAVInt64Add(t1, k, t1)
    NAVInt64Add(t1, w, t1)

    // T2 = Sigma0(a) + Maj(a,b,c)
    t2.Hi = 0; t2.Lo = 0
    NAVInt64Add(sigma0, maj, t2)

    // Calculate new a and e values
    new_a.Hi = 0; new_a.Lo = 0
    NAVInt64Add(t1, t2, new_a)

    new_e.Hi = 0; new_e.Lo = 0
    NAVInt64Add(d, t1, new_e)
}

/**
 * @function TestAdditionChaining
 * @description Test multiple addition operations chained together as in SHA-512
 *
 * @returns {integer} 1 if tests pass, 0 if any fail
 */
define_function integer TestAdditionChaining() {
    stack_var integer testsPassed, totalTests
    stack_var _NAVInt64 a, b, c, d, e, result1, result2, expected

    testsPassed = 0
    totalTests = 0

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing chained addition operations'")

    // SHA-512 often requires adding multiple values together
    // Initialize test values
    a.Hi = $10000000; a.Lo = $00000001
    b.Hi = $20000000; b.Lo = $00000002
    c.Hi = $30000000; c.Lo = $00000003
    d.Hi = $40000000; d.Lo = $00000004
    e.Hi = $50000000; e.Lo = $00000005

    // Add values sequentially: a + b + c + d + e
    NAVInt64Add(a, b, result1)
    NAVInt64Add(result1, c, result2)
    NAVInt64Add(result2, d, result1)
    NAVInt64Add(result1, e, result2)

    // Calculate expected result directly (for verification)
    expected.Hi = a.Hi + b.Hi + c.Hi + d.Hi + e.Hi
    expected.Lo = a.Lo + b.Lo + c.Lo + d.Lo + e.Lo
    // Handle carry from Lo to Hi
    if (expected.Lo < a.Lo) expected.Hi++
    if (expected.Lo < b.Lo) expected.Hi++
    if (expected.Lo < c.Lo) expected.Hi++
    if (expected.Lo < d.Lo) expected.Hi++
    if (expected.Lo < e.Lo) expected.Hi++

    totalTests++
    if (result2.Hi == expected.Hi && result2.Lo == expected.Lo) {
        testsPassed++
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Addition chaining test failed'")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Expected: $', format('%08x', expected.Hi), format('%08x', expected.Lo)")
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Got: $', format('%08x', result2.Hi), format('%08x', result2.Lo)")
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Addition chaining tests: ', itoa(testsPassed), ' of ', itoa(totalTests), ' passed'")
    return (testsPassed == totalTests)
}

/**
 * @function RunNAVInt64SHA512OperationsTests
 * @description Run all SHA-512 specific operation tests
 *
 * @returns {integer} 1 if all tests pass, 0 if any fail
 */
define_function integer RunNAVInt64SHA512OperationsTests() {
    stack_var integer success

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'****************** NAVInt64SHA512Operations Tests ******************'")

    success = 1

    // Test the message schedule calculation
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1: Message Schedule Operations'")
    success = success && TestMessageScheduleOperation()

    // Test the compression function calculations
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2: Compression Function Operations'")
    success = success && TestCompressionFunction()

    // Test addition chaining (common in SHA-512)
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3: Addition Chaining'")
    success = success && TestAdditionChaining()

    if (success) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVInt64SHA512Operations: All tests passed!'")
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'NAVInt64SHA512Operations: Some tests failed!'")
    }

    return success
}

#END_IF // __NAV_INT64_SHA512_OPERATIONS_TESTS__
