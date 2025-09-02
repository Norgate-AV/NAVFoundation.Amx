PROGRAM_NAME='NAVAes128ContextInit'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Aes128.axi'

DEFINE_CONSTANT

// Test vectors from FIPS-197 Appendix A.1
constant char CONTEXTINIT_TEST[][16] = {
    // Test case 1: FIPS-197 test vector
    {$2b, $7e, $15, $16, $28, $ae, $d2, $a6, $ab, $f7, $15, $88, $09, $cf, $4f, $3c},

    // Test case 2: Invalid key length (should fail)
    {$00, $11, $22, $33, $44, $55, $66, $77},

    // Test case 3: Another valid key
    {$00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f}
}

// Expected round keys after expansion (176 bytes = 11 round keys × 16 bytes each)
constant char CONTEXTINIT_EXPECTED[][176] = {
    // Test case 1: FIPS-197 expected round keys
    {
        // w[0..3]
        $2b, $7e, $15, $16, $28, $ae, $d2, $a6, $ab, $f7, $15, $88, $09, $cf, $4f, $3c,
        // w[4..7]
        $a0, $fa, $fe, $17, $88, $54, $2c, $b1, $23, $a3, $39, $39, $2a, $6c, $76, $05,
        // w[8..11]
        $f2, $c2, $95, $f2, $7a, $96, $b9, $43, $59, $35, $80, $7a, $73, $59, $f6, $7f,
        // w[12..15]
        $3d, $80, $47, $7d, $47, $16, $fe, $3e, $1e, $23, $7e, $44, $6d, $7a, $88, $3b,
        // w[16..19]
        $ef, $44, $a5, $41, $a8, $52, $5b, $7f, $b6, $71, $25, $3b, $db, $0b, $ad, $00,
        // w[20..23]
        $d4, $d1, $c6, $f8, $7c, $83, $9d, $87, $ca, $f2, $b8, $bc, $11, $f9, $15, $bc,
        // w[24..27]
        $6d, $88, $a3, $7a, $11, $0b, $3e, $fd, $db, $f9, $86, $41, $ca, $00, $93, $fd,
        // w[28..31]
        $4e, $54, $f7, $0e, $5f, $5f, $c9, $f3, $84, $a6, $4f, $b2, $4e, $a6, $dc, $4f,
        // w[32..35]
        $ea, $d2, $73, $21, $b5, $8d, $ba, $d2, $31, $2b, $f5, $60, $7f, $8d, $29, $2f,
        // w[36..39]
        $ac, $77, $66, $f3, $19, $fa, $dc, $21, $28, $d1, $29, $41, $57, $5c, $00, $6e,
        // w[40..43]
        $d0, $14, $f9, $a8, $c9, $ee, $25, $89, $e1, $3f, $0c, $c8, $b6, $63, $0c, $a6
    },

    // Test case 2: No expected round keys (invalid input)
    {$00},

    // Test case 3: Expected round keys for the second valid key
    {
        // Round keys verified with external AES implementation
        $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f,
        $d6, $aa, $74, $fd, $d2, $af, $72, $fa, $da, $a6, $78, $f1, $d6, $ab, $76, $fe,
        $b6, $92, $cf, $0b, $64, $3d, $bd, $f1, $be, $9b, $c5, $00, $68, $30, $b3, $fe,
        $b6, $ff, $74, $4e, $d2, $c2, $c9, $bf, $6c, $59, $0c, $bf, $04, $69, $bf, $41,
        $47, $f7, $f7, $bc, $95, $35, $3e, $03, $f9, $6c, $32, $bc, $fd, $05, $8d, $fd,
        $3c, $aa, $a3, $e8, $a9, $9f, $9d, $eb, $50, $f3, $af, $57, $ad, $f6, $22, $aa,
        $5e, $39, $0f, $7d, $f7, $a6, $92, $96, $a7, $55, $3d, $c1, $0a, $a3, $1f, $6b,
        $14, $f9, $70, $1a, $e3, $5f, $e2, $8c, $44, $0a, $df, $4d, $4e, $a9, $c0, $26,
        $47, $43, $87, $35, $a4, $1c, $65, $b9, $e0, $16, $ba, $f4, $ae, $bf, $7a, $d2,
        $54, $99, $32, $d1, $f0, $85, $57, $68, $10, $93, $ed, $9c, $be, $2c, $97, $4e,
        $13, $11, $1d, $7f, $e3, $94, $4a, $17, $f3, $07, $a7, $8b, $4d, $2b, $30, $c5
    }
}


define_function RunNAVAes128ContextInitTests() {
    stack_var integer i

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVAes128ContextInit ******************')

    for (i = 1; i <= length_array(CONTEXTINIT_TEST); i++) {
        stack_var _NAVAesContext context
        stack_var sinteger result
        stack_var char failed
        stack_var integer j

        // Test initialization with new error code return system
        result = NAVAes128ContextInit(context, CONTEXTINIT_TEST[i])

        // Test case 2 should fail with specific error code (invalid key length)
        if (i == 2) {
            if (result == NAV_AES_ERROR_INVALID_KEY_LENGTH) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' passed: Correctly rejected invalid key with error: ', NAVAes128GetError(result)")
            }
            else {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' failed: Expected error code ', itoa(NAV_AES_ERROR_INVALID_KEY_LENGTH),
                           ' (', NAVAes128GetError(NAV_AES_ERROR_INVALID_KEY_LENGTH), ') but got ', itoa(result),
                           ' (', NAVAes128GetError(result), ')'")
            }
            continue
        }

        // Valid key cases should return NAV_AES_SUCCESS (0)
        if (result != NAV_AES_SUCCESS) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' failed: Context initialization returned error: ',
                       itoa(result), ' (', NAVAes128GetError(result), ')'")
            continue
        }

        // Compare round keys with expected values
        for (j = 1; j <= 176; j++) {
            if (context.RoundKey[j] != CONTEXTINIT_EXPECTED[i][j]) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' failed at round key byte ', itoa(j)")
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected $', format('%02X', CONTEXTINIT_EXPECTED[i][j]),
                          ' but got $', format('%02X', context.RoundKey[j])")

                failed = true
                break
            }
        }

        if (failed) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Round keys generated:'")
            NAVAes128LogAllRoundKeys(context.RoundKey)

            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' failed'")
            continue
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' passed'")
    }
}
