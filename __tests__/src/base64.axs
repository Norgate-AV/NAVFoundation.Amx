PROGRAM_NAME='base64'

#DEFINE __MAIN__
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Encoding.Base64.axi'


DEFINE_DEVICE

dvTP    =   10001:1:0


DEFINE_CONSTANT

constant char TEST[][2048] = {
    '',
    'a',
    'abc',
    'abcdefghijklmnopqrstuvwxyz',
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789',
    '12345678901234567890123456789012345678901234567890123456789012345678901234567890',
    'The quick brown fox jumps over the lazy dog',
    'The quick brown fox jumps over the lazy dog.'
}


constant char EXPECTED[][2048] = {
    '',
    'YQ==',
    'YWJj',
    'YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXo=',
    'QUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVphYmNkZWZnaGlqa2xtbm9wcXJzdHV2d3h5ejAxMjM0NTY3ODk=',
    'MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTA=',
    'VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZw==',
    'VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZy4='
}


define_function RunTests() {
    stack_var integer x

    for (x = 1; x <= length_array(TEST); x++) {
        stack_var char result[2048]

        result = NAVBase64Encode(TEST[x])

        if (result != EXPECTED[x]) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                        "'Test ', itoa(x), ' failed. Expected "', EXPECTED[x], '" but got "', result, '"'")

            continue
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' passed. Got "', result, '"'")
    }


    for (x = 1; x <= length_array(TEST); x++) {
        stack_var char result[2048]

        result = NAVBase64Decode(EXPECTED[x])

        if (result != TEST[x]) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                        "'Test ', itoa(x), ' failed. Expected "', TEST[x], '" but got "', result, '"'")

            continue
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' passed. Got "', result, '"'")
    }
}


DEFINE_EVENT

button_event[dvTP, 1] {
    push: {
        RunTests()
    }
}
