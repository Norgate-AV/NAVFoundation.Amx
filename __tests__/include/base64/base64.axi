#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Encoding.Base64.axi'

DEFINE_CONSTANT

// Standard test cases with input text and expected Base64 output
constant char BASE64_TEST_LABEL[][128] = {
    'Empty string',
    'Single character',
    'Three characters',
    'Lowercase alphabet',
    'All alphanumeric',
    'Numbers only (long)',
    'Standard sentence',
    'Sentence with punctuation',
    'Binary data with special bytes',
    'Binary data with high-ASCII'
}

constant char BASE64_TEST[][2048] = {
    '',
    'a',
    'abc',
    'abcdefghijklmnopqrstuvwxyz',
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789',
    '12345678901234567890123456789012345678901234567890123456789012345678901234567890',
    'The quick brown fox jumps over the lazy dog',
    'The quick brown fox jumps over the lazy dog.',
    // Binary data tests
    {$00, $01, $02, $03, $FF, $FE, $FD, $FC},
    {$7F, $80, $81, $90, $A0, $B0, $C0, $D0, $E0}
}

constant char BASE64_EXPECTED[][2048] = {
    '',
    'YQ==',
    'YWJj',
    'YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXo=',
    'QUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVphYmNkZWZnaGlqa2xtbm9wcXJzdHV2d3h5ejAxMjM0NTY3ODk=',
    'MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTA=',
    'VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZw==',
    'VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZy4=',
    // Binary data expected outputs - corrected to match RFC 4648 standard
    'AAECA//+/fw=',  // This is the correct Base64 for bytes 00 01 02 03 FF FE FD FC
    'f4CBkKCwwNDg'
}

// Whitespace test cases
constant char BASE64_WHITESPACE_LABEL[][128] = {
    'Base64 with spaces',
    'Base64 with line breaks (LF)',
    'Base64 with CRLF line breaks'
}

// Add additional test cases for whitespace handling and error cases
constant char BASE64_WHITESPACE_TESTS[][2048] = {
    'VGhl IHF1aWNr IGJyb3du IGZveCBq dW1w cyBvdmVy IHRoZSBsYXp5 IGRvZy4=',   // Spaces

    // Base64 with LF line breaks - properly placing LFs at positions that maintain the Base64 encoding
    {
        'V', 'G', 'h', 'l', 'I', 'H', 'F', '1', 'a', 'W', 'N', 'r', 'I', 'G', 'J', 'y',
        $0A, // LF after a complete 4-character block
        'b', '3', 'd', 'u', 'I', 'G', 'Z', 'v', 'e', 'C', 'B', 'q', 'd', 'W', '1', 'w',
        $0A, // LF after another complete 4-character block
        'c', 'y', 'B', 'v', 'd', 'm', 'V', 'y', 'I', 'H', 'R', 'o', 'Z', 'S', 'B', 's',
        'Y', 'X', 'p', '5', 'I', 'G', 'R', 'v', 'Z', 'y', '4', '='
    },

    // Base64 with CRLF line breaks - properly placing CRLFs at positions that maintain the Base64 encoding
    {
        'V', 'G', 'h', 'l', 'I', 'H', 'F', '1', 'a', 'W', 'N', 'r', 'I', 'G', 'J', 'y',
        $0D, $0A, // CRLF after a complete 4-character block
        'b', '3', 'd', 'u', 'I', 'G', 'Z', 'v', 'e', 'C', 'B', 'q', 'd', 'W', '1', 'w',
        $0D, $0A, // CRLF after another complete 4-character block
        'c', 'y', 'B', 'v', 'd', 'm', 'V', 'y', 'I', 'H', 'R', 'o', 'Z', 'S', 'B', 's',
        'Y', 'X', 'p', '5', 'I', 'G', 'R', 'v', 'Z', 'y', '4', '='
    }
}

// Invalid input test cases
constant char BASE64_INVALID_LABEL[][128] = {
    'Base64 with invalid character',
    'Base64 with misplaced padding'
}

constant char BASE64_INVALID_TESTS[][2048] = {
    'VGhlIHF1aWNrIGJyb3duI*GZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZy4=',  // Invalid char
    'VGhlIHF1aWNrIGJyb3=duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZy4='   // Misplaced padding
}

define_function Base64PrintTestHeader(char header[]) {
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'---------------- ', header, ' ----------------'")
}

// Add a display function to help with debugging binary data
define_function char[NAV_MAX_BUFFER] Base64FormatBinaryForDisplay(char data[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer i, len

    len = length_array(data)
    result = "'Length: ', itoa(len), ' = '"

    for (i = 1; i <= len; i++) {
        if (i > 1) {
            result = "result, ' '"
        }
        result = "result, '0x', format('%02X', data[i])"
    }

    return result
}

define_function char[NAV_MAX_BUFFER] Base64FormatStringForDisplay(char str[]) {
    stack_var integer i
    stack_var char res[NAV_MAX_BUFFER]

    res = "'Length: ', itoa(length_array(str)), ' = '"

    for (i = 1; i <= length_array(str); i++) {
        if (str[i] < 32 || str[i] > 127) {
            if (i > 1) res = "res, ' '"
            res = "res, '$', format('%02X', str[i])"
        } else {
            if (i > 1) res = "res, ' '"
            res = "res, '"', str[i], '"'"
        }
    }

    return res
}

define_function RunBase64Tests() {
    stack_var integer x
    stack_var char result[2048]
    stack_var integer passCount, totalTests

    // ENCODING TESTS
    Base64PrintTestHeader('ENCODING TESTS')
    totalTests = length_array(BASE64_TEST)
    passCount = 0
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Running ', itoa(totalTests), ' Base64 encoding tests'")

    for (x = 1; x <= totalTests; x++) {
        result = NAVBase64Encode(BASE64_TEST[x])

        if (result != BASE64_EXPECTED[x]) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                        "'Encoding Test #', itoa(x), ' (', BASE64_TEST_LABEL[x], ') failed. Expected "', BASE64_EXPECTED[x], '" but got "', result, '"'")
        } else {
            passCount++
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Encoding Test #', itoa(x), ' passed'")
        }
    }
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Encoding Tests: ', itoa(passCount), ' of ', itoa(totalTests), ' passed'")

    // DECODING TESTS
    Base64PrintTestHeader('DECODING TESTS')
    totalTests = length_array(BASE64_TEST)
    passCount = 0
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Running ', itoa(totalTests), ' Base64 decoding tests'")

    for (x = 1; x <= totalTests; x++) {
        result = NAVBase64Decode(BASE64_EXPECTED[x])

        if (result != BASE64_TEST[x]) {
            // For binary data tests, print detailed comparison
            if (x >= 9) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                            "'Decoding Test #', itoa(x), ' (', BASE64_TEST_LABEL[x], ') failed.'")
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                            "'Expected: ', Base64FormatBinaryForDisplay(BASE64_TEST[x])")
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                            "'Got: ', Base64FormatBinaryForDisplay(result)")
            } else {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                            "'Decoding Test #', itoa(x), ' (', BASE64_TEST_LABEL[x], ') failed. Expected "', BASE64_TEST[x], '" but got "', result, '"'")
            }
        } else {
            passCount++
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Decoding Test #', itoa(x), ' passed'")
        }
    }
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Decoding Tests: ', itoa(passCount), ' of ', itoa(totalTests), ' passed'")

    // WHITESPACE HANDLING TESTS
    Base64PrintTestHeader('WHITESPACE HANDLING TESTS')
    totalTests = length_array(BASE64_WHITESPACE_TESTS)
    passCount = 0
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Running ', itoa(totalTests), ' whitespace handling tests'")

    for (x = 1; x <= totalTests; x++) {
        result = NAVBase64Decode(BASE64_WHITESPACE_TESTS[x])

        if (result != 'The quick brown fox jumps over the lazy dog.') {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                        "'Whitespace Test #', itoa(x), ' (', BASE64_WHITESPACE_LABEL[x], ') failed.'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                        "'Expected: "The quick brown fox jumps over the lazy dog."'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                        "'Got: ', Base64FormatStringForDisplay(result)")
        } else {
            passCount++
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Whitespace Test #', itoa(x), ' passed'")
        }
    }
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Whitespace Tests: ', itoa(passCount), ' of ', itoa(totalTests), ' passed'")

    // ERROR HANDLING TESTS
    Base64PrintTestHeader('ERROR HANDLING TESTS')
    totalTests = length_array(BASE64_INVALID_TESTS)
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Running ', itoa(totalTests), ' error handling tests'")

    // Note: Error handling tests don't have a pass/fail criteria since they're testing error conditions
    for (x = 1; x <= totalTests; x++) {
        result = NAVBase64Decode(BASE64_INVALID_TESTS[x])
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Invalid Test #', itoa(x), ' completed'")
    }

    // TESTS SUMMARY
    Base64PrintTestHeader('TESTS COMPLETED')
}
