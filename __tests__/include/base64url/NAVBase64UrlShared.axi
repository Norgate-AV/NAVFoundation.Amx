#IF_NOT_DEFINED __NAVBASE64URL_SHARED__
#DEFINE __NAVBASE64URL_SHARED__

DEFINE_CONSTANT

constant char BASE64URL_TEST[][2048] = {
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
    {$7F, $80, $81, $90, $A0, $B0, $C0, $D0, $E0},
    // Character set difference tests
    'subjects?',
    {$FB, $FF},
    {$FF, $FF, $FF},
    // JWT examples
    '{"alg":"HS256","typ":"JWT"}',
    '{"sub":"1234567890","name":"John Doe","iat":1516239022}'
}

// Expected Base64Url encoding WITHOUT padding (JWT standard)
constant char BASE64URL_EXPECTED_UNPADDED[][2048] = {
    '',
    'YQ',
    'YWJj',
    'YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXo',
    'QUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVphYmNkZWZnaGlqa2xtbm9wcXJzdHV2d3h5ejAxMjM0NTY3ODk',
    'MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTA',
    'VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZw',
    'VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZy4',
    // Binary data expected outputs
    'AAECA__-_fw',
    'f4CBkKCwwNDg',
    // Character set differences (- and _ instead of + and /)
    'c3ViamVjdHM_',
    '-_8',
    '____',
    // JWT examples
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
    'eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ'
}

constant char BASE64_TO_URL_INPUT[][2048] = {
    '+/8=',       // Standard Base64 to be converted to Base64URL
    'c3ViamVjdHM/',
    '//8=',
    'AAECA//+/fw='
}

constant char BASE64_TO_URL_EXPECTED[][2048] = {
    '-_8',
    'c3ViamVjdHM_',
    '__8',
    'AAECA__-_fw'
}

constant char BASE64URL_WHITESPACE_TESTS[][2048] = {
    'VGhl IHF1aWNr IGJyb3du IGZveCBq dW1w cyBvdmVy IHRoZSBsYXp5 IGRvZy4',   // Spaces (no padding)

    // Base64Url with LF line breaks
    {
        'V', 'G', 'h', 'l', 'I', 'H', 'F', '1', 'a', 'W', 'N', 'r', 'I', 'G', 'J', 'y',
        $0A, // LF
        'b', '3', 'd', 'u', 'I', 'G', 'Z', 'v', 'e', 'C', 'B', 'q', 'd', 'W', '1', 'w',
        $0A, // LF
        'c', 'y', 'B', 'v', 'd', 'm', 'V', 'y', 'I', 'H', 'R', 'o', 'Z', 'S', 'B', 's',
        'Y', 'X', 'p', '5', 'I', 'G', 'R', 'v', 'Z', 'y', '4'
    },

    // Base64Url with CRLF line breaks
    {
        'V', 'G', 'h', 'l', 'I', 'H', 'F', '1', 'a', 'W', 'N', 'r', 'I', 'G', 'J', 'y',
        $0D, $0A, // CRLF
        'b', '3', 'd', 'u', 'I', 'G', 'Z', 'v', 'e', 'C', 'B', 'q', 'd', 'W', '1', 'w',
        $0D, $0A, // CRLF
        'c', 'y', 'B', 'v', 'd', 'm', 'V', 'y', 'I', 'H', 'R', 'o', 'Z', 'S', 'B', 's',
        'Y', 'X', 'p', '5', 'I', 'G', 'R', 'v', 'Z', 'y', '4'
    }
}

constant char BASE64URL_WHITESPACE_EXPECTED[2048] = 'The quick brown fox jumps over the lazy dog.'

constant char BASE64URL_INVALID_TESTS[][2048] = {
    'VGhlIHF1aWNrIGJyb3duI*GZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZy4',  // Invalid char
    'VGhlIHF1aWNrIGJyb3=duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZy4',   // Misplaced padding
    'AAECA//+/fw='  // Standard Base64 (should still decode but with warnings)
}

define_function char[NAV_MAX_BUFFER] Base64UrlFormatBinaryForDisplay(char data[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer i, length

    length = length_array(data)
    result = "'Length: ', itoa(length), ' = '"

    for (i = 1; i <= length; i++) {
        if (i > 1) {
            result = "result, ' '"
        }
        result = "result, '0x', format('%02X', data[i])"
    }

    return result
}

define_function char[NAV_MAX_BUFFER] Base64UrlFormatStringForDisplay(char value[]) {
    stack_var integer i
    stack_var char result[NAV_MAX_BUFFER]

    result = "'Length: ', itoa(length_array(value)), ' = '"

    for (i = 1; i <= length_array(value); i++) {
        if (value[i] < 32 || value[i] > 127) {
            if (i > 1) result = "result, ' '"
            result = "result, '$', format('%02X', value[i])"
        } else {
            if (i > 1) result = "result, ' '"
            result = "result, '"', value[i], '"'"
        }
    }

    return result
}

#END_IF     // __NAVBASE64URL_SHARED__