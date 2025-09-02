PROGRAM_NAME='NAVAes128ShiftRows'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Aes128.axi'


DEFINE_CONSTANT

constant char SHIFTROWS_TEST[][][4] = {
    {
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00}
    },
    {
        {$d4, $e0, $b8, $1e},
        {$27, $bf, $b4, $41},
        {$11, $98, $5d, $52},
        {$ae, $f1, $e5, $30}
    },
    // Test case 3: Simple pattern to verify row shifts
    {
        {$00, $01, $02, $03},  // Row 1: no shift
        {$10, $11, $12, $13},  // Row 2: shift left by 1
        {$20, $21, $22, $23},  // Row 3: shift left by 2
        {$30, $31, $32, $33}   // Row 4: shift left by 3
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

constant char SHIFTROWS_EXPECTED[][][4] = {
    {
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00}
    },
    {
        {$d4, $e0, $b8, $1e},
        {$bf, $b4, $41, $27},
        {$5d, $52, $11, $98},
        {$30, $ae, $f1, $e5}
    },
    // Test case 3: Expected output after ShiftRows
    {
        {$00, $01, $02, $03},  // Row 1: unchanged
        {$11, $12, $13, $10},  // Row 2: shifted left by 1
        {$22, $23, $20, $21},  // Row 3: shifted left by 2
        {$33, $30, $31, $32}   // Row 4: shifted left by 3
    },
    {
        {$49, $45, $7f, $77},
        {$db, $39, $02, $de},
        {$87, $53, $d2, $96},
        {$3b, $89, $f1, $1a}
    },
    {
        {$ac, $ef, $13, $45},
        {$c1, $b5, $23, $73},
        {$d6, $5a, $cf, $11},
        {$b8, $7b, $df, $b5}
    },
    {
        {$52, $85, $e3, $f6},
        {$a4, $11, $cf, $50},
        {$c8, $6a, $2f, $5e},
        {$94, $28, $d7, $07}
    },
    {
        {$e1, $e8, $35, $97},
        {$fb, $c8, $6c, $4f},
        {$96, $ae, $d2, $fb},
        {$7c, $9b, $ba, $53}
    },
    {
        {$a1, $78, $10, $4c},
        {$4f, $e8, $d5, $63},
        {$3d, $03, $a8, $29},
        {$fe, $fc, $df, $23}
    }
}


define_function RunNAVAes128ShiftRowsTests() {
    stack_var integer i
    stack_var char state[4][4]
    stack_var char expected[4][4]

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVAes128ShiftRows ******************')

    for (i = 1; i <= length_array(SHIFTROWS_TEST); i++) {
        stack_var integer j, k
        stack_var char failed

        SetupMatrix(SHIFTROWS_TEST[i], state)
        SetupMatrix(SHIFTROWS_EXPECTED[i], expected)

        // Perform ShiftRows operation
        NAVAes128ShiftRows(state)

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
            NAVAes128LogStateMatrix(SHIFTROWS_TEST[i])

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
