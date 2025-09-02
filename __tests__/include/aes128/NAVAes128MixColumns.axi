PROGRAM_NAME='NAVAes128MixColumns'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Aes128.axi'


DEFINE_CONSTANT

constant char MIXCOLUMNS_TEST[][][4] = {
    // Test case 1: All zeros (unchanged)
    {
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00}
    },

    // Test case 2: NIST FIPS-197 MixColumns test vector (Section 5.1.3)
    {
        {$d4, $e0, $b8, $1e},
        {$bf, $b4, $41, $27},
        {$5d, $52, $11, $98},
        {$30, $ae, $f1, $e5}
    },

    // Test case 3: First column test
    {
        {$01, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00}
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

constant char MIXCOLUMNS_EXPECTED[][][4] = {
    {
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00},
        {$00, $00, $00, $00}
    },
    {
        {$04, $e0, $48, $28},
        {$66, $cb, $f8, $06},
        {$81, $19, $d3, $26},
        {$e5, $9a, $7a, $4c}
    },
    {
        {$02, $00, $00, $00},
        {$01, $00, $00, $00},
        {$01, $00, $00, $00},
        {$03, $00, $00, $00}
    },
    {
        {$58, $1b, $db, $1b},
        {$4d, $4b, $e7, $6b},
        {$ca, $5a, $ca, $b0},
        {$f1, $ac, $a8, $e5}
    },
    {
        {$75, $20, $53, $bb},
        {$ec, $0b, $c0, $25},
        {$09, $63, $cf, $d0},
        {$93, $33, $7c, $dc}
    },
    {
        {$0f, $60, $6f, $5e},
        {$d6, $31, $c0, $b3},
        {$da, $38, $10, $13},
        {$a9, $bf, $6b, $01}
    },
    {
        {$25, $bd, $b6, $4c},
        {$d1, $11, $3a, $4c},
        {$a9, $d1, $33, $c0},
        {$ad, $68, $8e, $b0}
    },
    {
        {$4b, $2c, $33, $37},
        {$86, $4a, $9d, $d2},
        {$8d, $89, $f4, $18},
        {$6d, $80, $e8, $d8}
    }
}


define_function RunNAVAes128MixColumnsTests() {
    stack_var integer i
    stack_var char state[4][4]
    stack_var char expected[4][4]

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVAes128MixColumns ******************')

    for (i = 1; i <= length_array(MIXCOLUMNS_TEST); i++) {
        stack_var integer j, k
        stack_var char failed

        SetupMatrix(MIXCOLUMNS_TEST[i], state)
        SetupMatrix(MIXCOLUMNS_EXPECTED[i], expected)

        // Perform MixColumns operation
        NAVAes128MixColumns(state)

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
            NAVAes128LogStateMatrix(MIXCOLUMNS_TEST[i])

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
