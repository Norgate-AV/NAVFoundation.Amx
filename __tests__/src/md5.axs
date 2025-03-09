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


constant char EXPECTED[][16] = {
    {$d4, $1d, $8c, $d9, $8f, $00, $b2, $04, $e9, $80, $09, $98, $ec, $f8, $42, $7e},
    {$0c, $c1, $75, $b9, $c0, $f1, $b6, $a8, $31, $c3, $99, $e2, $69, $77, $26, $61},
    {$90, $01, $50, $98, $3c, $d2, $4f, $b0, $d6, $96, $3f, $7d, $28, $e1, $7f, $72},
    {$f9, $6b, $69, $7d, $7c, $b7, $93, $8d, $52, $5a, $2f, $31, $aa, $f1, $61, $d0},
    {$c3, $fc, $d3, $d7, $61, $92, $e4, $00, $7d, $fb, $49, $6c, $ca, $67, $e1, $3b},
    {$d1, $74, $ab, $98, $d2, $77, $d9, $f5, $a5, $61, $1c, $2c, $9f, $41, $9d, $9f},
    {$57, $ed, $f4, $a2, $2b, $e3, $c9, $55, $ac, $49, $da, $2e, $21, $07, $b6, $7a},
    {$9e, $10, $7d, $9d, $37, $2b, $b6, $82, $6b, $d8, $1d, $35, $42, $a4, $19, $d6},
    {$e4, $d9, $09, $c2, $90, $d0, $fb, $1c, $a0, $68, $ff, $ad, $df, $22, $cb, $d0}
    // 'd41d8cd98f00b204e9800998ecf8427e',
    // '0cc175b9c0f1b6a831c399e269772661',
    // '900150983cd24fb0d6963f7d28e17f72',
    // 'f96b697d7cb7938d525a2f31aaf161d0',
    // 'c3fcd3d76192e4007dfb496cca67e13b',
    // 'd174ab98d277d9f5a5611c2c9f419d9f',
    // '57edf4a22be3c955ac49da2e2107b67a',
    // '9e107d9d372bb6826bd81d3542a419d6',
    // 'e4d909c290d0fb1ca068ffaddf22cbd0'
}


define_function RunTests() {
    stack_var integer x

    for (x = 1; x <= length_array(TEST); x++) {
        stack_var char result[16]

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
        set_log_level(NAV_LOG_LEVEL_DEBUG)
        RunTests()
    }
}
