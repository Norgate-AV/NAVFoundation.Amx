PROGRAM_NAME='NAVAes128SubBytes'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Aes128.axi'


DEFINE_CONSTANT

constant char SUBBYTES_TEST[][][4] = {
    // Test case 1: All zeros
    {
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00}
    },
    {
        {$19, $a0, $9a, $e9},
        {$3d, $f4, $c6, $f8},
        {$e3, $e2, $8d, $48},
        {$be, $2b, $2a, $08}
    },
    // Test case 3: Basic S-box lookups
    {
        {$00, $01, $02, $03},  // Test first 4 S-box values
        {$10, $11, $12, $13},  // Test different S-box regions
        {$20, $21, $22, $23},  // Test different S-box regions
        {$30, $31, $32, $33}   // Test different S-box regions
    },
    {
        {$a4, $68, $6b, $02},
        {$9c, $9f, $5b, $6a},
        {$7f, $35, $ea, $50},
        {$f2, $2b, $43, $49}
    },
    {
        {$aa, $61, $82, $68},
        {$8f, $dd, $d2, $32},
        {$5f, $e3, $4a, $46},
        {$03, $ef, $d2, $9a}
    },
    {
        {$48, $67, $4d, $d6},
        {$6c, $1d, $e3, $5f},
        {$4e, $9d, $b1, $58},
        {$ee, $0d, $38, $e7}
    },
    {
        {$e0, $c8, $d9, $85},
        {$92, $63, $b1, $b8},
        {$7f, $63, $35, $be},
        {$e8, $c0, $50, $01}
    },
    {
        {$f1, $c1, $7c, $5d},
        {$00, $92, $c8, $b5},
        {$6f, $4c, $8b, $d5},
        {$55, $ef, $32, $0c}
    }
}

constant char SUBBYTES_EXPECTED[][][4] = {
    // Test case 1: All zeros should map to S-box[0] = 0x63
    {
        {$63, $63, $63, $63},  // Each 0x00 maps to 0x63 in the S-box
        {$63, $63, $63, $63},
        {$63, $63, $63, $63},
        {$63, $63, $63, $63}
    },
    {
        {$d4, $e0, $b8, $1e},
        {$27, $bf, $b4, $41},
        {$11, $98, $5d, $52},
        {$ae, $f1, $e5, $30}
    },
    // Test case 3: Expected output after S-box substitution
    {
        {$63, $7c, $77, $7b},  // S-box values for 00,01,02,03
        {$ca, $82, $c9, $7d},  // S-box values for 10,11,12,13
        {$b7, $fd, $93, $26},  // S-box values for 20,21,22,23
        {$04, $c7, $23, $c3}   // S-box values for 30,31,32,33
    },
    {
        {$49, $45, $7f, $77},
        {$de, $db, $39, $02},
        {$d2, $96, $87, $53},
        {$89, $f1, $1a, $3b}
    },
    {
        {$ac, $ef, $13, $45},
        {$73, $c1, $b5, $23},
        {$cf, $11, $d6, $5a},
        {$7b, $df, $b5, $b8}
    },
    {
        {$52, $85, $e3, $f6},
        {$50, $a4, $11, $cf},
        {$2f, $5e, $c8, $6a},
        {$28, $d7, $07, $94}
    },
    {
        {$e1, $e8, $35, $97},
        {$4f, $fb, $c8, $6c},
        {$d2, $fb, $96, $ae},
        {$9b, $ba, $53, $7c}
    },
    {
        {$a1, $78, $10, $4c},
        {$63, $4f, $e8, $d5},
        {$a8, $29, $3d, $03},
        {$fc, $df, $23, $fe}
    }
}


define_function RunNAVAes128SubBytesTests() {
    stack_var integer i
    stack_var char state[4][4]
    stack_var char expected[4][4]

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVAes128SubBytes ******************')

    for (i = 1; i <= length_array(SUBBYTES_TEST); i++) {
        stack_var integer j, k
        stack_var char failed

        SetupMatrix(SUBBYTES_TEST[i], state)
        SetupMatrix(SUBBYTES_EXPECTED[i], expected)

        // Perform SubBytes operation
        NAVAes128SubBytes(state)

        // Compare result with expected
        for (j = 1; j <= 4; j++) {
            for (k = 1; k <= 4; k++) {
                if (state[j][k] != expected[j][k]) {
                    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' failed at position [',
                              itoa(j), '][', itoa(k), ']'")

                    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected $', format('%02X', expected[j][k]),
                              ' but got $', format('%02X', state[j][k])")

                    failed = true
                    continue
                }
            }
        }

        if (failed) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Input state:'")
            NAVAes128LogStateMatrix(SUBBYTES_TEST[i])

            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Output state:'")
            NAVAes128LogStateMatrix(state)

            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Expected state:'")
            NAVAes128LogStateMatrix(expected)

            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' failed'")
            continue
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' passed'")
    }
}
