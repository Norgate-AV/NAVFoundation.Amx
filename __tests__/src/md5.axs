PROGRAM_NAME='md5'

#DEFINE __MAIN__
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Md5.axi'


DEFINE_DEVICE

dvTP    =   10001:1:0


DEFINE_CONSTANT

constant char TEST[][255] = {
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


constant char EXPECTED[][32] = {
    'd41d8cd98f00b204e9800998ecf8427e',
    '0cc175b9c0f1b6a831c399e269772661',
    '900150983cd24fb0d6963f7d28e17f72',
    'f96b697d7cb7938d525a2f31aaf161d0',
    'c3fcd3d76192e4007dfb496cca67e13b',
    'd174ab98d277d9f5a5611c2c9f419d9f',
    '57edf4a22be3c955ac49da2e2107b67a',
    '9e107d9d372bb6826bd81d3542a419d6',
    'e4d909c290d0fb1ca068ffaddf22cbd0'
}


define_function RunTests() {
    stack_var integer x

    for (x = 1; x <= length_array(TEST); x++) {
        stack_var char result[32]

        result = NAVMd5GetHash(TEST[x])

        if (result != EXPECTED[x]) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                        "'Test ', itoa(x), ' failed. Expected ', EXPECTED[x], ' but got ', result, ' (', TEST[x], ')'")

            continue
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' passed. Got ', result, ' (', TEST[x], ')'")
    }
}


DEFINE_EVENT

button_event[dvTP, 1] {
    push: {
        RunTests()
    }
}
