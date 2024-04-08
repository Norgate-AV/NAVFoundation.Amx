PROGRAM_NAME='sha1'

#DEFINE __MAIN__
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Sha1.axi'


DEFINE_DEVICE

dvTP    =   10001:1:0


DEFINE_CONSTANT

constant char TEST[][2048] = {
    '',
    'a',
    'abc',
    'message digest',
    'abcdefghijklmnopqrstuvwxyz',
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789',
    '12345678901234567890123456789012345678901234567890123456789012345678901234567890',
    'The quick brown fox jumps over the lazy dog',
    'The quick brown fox jumps over the lazy dog.'
}


constant char EXPECTED[][40] = {
    'da39a3ee5e6b4b0d3255bfef95601890afd80709',
    '86f7e437faa5a7fce15d1ddcb9eaeaea377667b8',
    'a9993e364706816aba3e25717850c26c9cd0d89d',
    'c12252ceda8be8994d5fa0290a47231c1d16aae3',
    '32d10c7b8cf96570ca04ce37f2a19d84240d3a89',
    '761c457bf73b14d27e9e9265c46f4b4dda11f940',
    '50abf5706a150990a08b2c5ea40fa0e585554732',
    '2fd4e1c67a2d28fced849ee1bb76e7391b93eb12',
    '408d94384216f890ff7a0c3528e8bed1e0b01621'
}


define_function RunTests() {
    stack_var integer x

    for (x = 1; x <= length_array(TEST); x++) {
        stack_var char result[40]

        result = NAVSha1GetHash(TEST[x])

        if (result != EXPECTED[x]) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                        "'Test ', itoa(x), ' failed. Expected ', EXPECTED[x], ' but got "', result, '"'")

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
