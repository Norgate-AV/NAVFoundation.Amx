PROGRAM_NAME='NAVAes128KeyExpansion'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Aes128.axi'

DEFINE_CONSTANT

// Test vectors from FIPS-197 Appendix A.1
constant char KEYEXPANSION_TEST[][16] = {
    // Test case 1: FIPS-197 Appendix A.1
    {$2b, $7e, $15, $16, $28, $ae, $d2, $a6, $ab, $f7, $15, $88, $09, $cf, $4f, $3c},

    // Test case 2: All zeros
    {$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00},

    // Test case 3: All ones - verified with external AES implementation
    {$ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff}
}

constant char KEYEXPANSION_EXPECTED[][176] = {
    // Test case 1: From FIPS-197
    {
        // w[0..3]: Original key
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

    // Test case 2: Key expansion for all zeros
    {
        // w[0..3]: Original key
        $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00,
        // w[4..7]
        $62, $63, $63, $63, $62, $63, $63, $63, $62, $63, $63, $63, $62, $63, $63, $63,
        // w[8..11]
        $9b, $98, $98, $c9, $f9, $fb, $fb, $aa, $9b, $98, $98, $c9, $f9, $fb, $fb, $aa,
        // w[12..15]
        $90, $97, $34, $50, $69, $6c, $cf, $fa, $f2, $f4, $57, $33, $0b, $0f, $ac, $99,
        // w[16..19]
        $ee, $06, $da, $7b, $87, $6a, $15, $81, $75, $9e, $42, $b2, $7e, $91, $ee, $2b,
        // w[20..23]
        $7f, $2e, $2b, $88, $f8, $44, $3e, $09, $8d, $da, $7c, $bb, $f3, $4b, $92, $90,
        // w[24..27]
        $ec, $61, $4b, $85, $14, $25, $75, $8c, $99, $ff, $09, $37, $6a, $b4, $9b, $a7,
        // w[28..31]
        $21, $75, $17, $87, $35, $50, $62, $0b, $ac, $af, $6b, $3c, $c6, $1b, $f0, $9b,
        // w[32..35]
        $0e, $f9, $03, $33, $3b, $a9, $61, $38, $97, $06, $0a, $04, $51, $1d, $fa, $9f,
        // w[36..39]
        $b1, $d4, $d8, $e2, $8a, $7d, $b9, $da, $1d, $7b, $b3, $de, $4c, $66, $49, $41,
        // w[40..43]
        $b4, $ef, $5b, $cb, $3e, $92, $e2, $11, $23, $e9, $51, $cf, $6f, $8f, $18, $8e
    },

    // Test case 3: Key expansion for all ones - verified with external AES implementation
    {
        // w[0..3]: Original key
        $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
        // w[4..7]
        $e8, $e9, $e9, $e9, $17, $16, $16, $16, $e8, $e9, $e9, $e9, $17, $16, $16, $16,
        // w[8..11]
        $ad, $ae, $ae, $19, $ba, $b8, $b8, $0f, $52, $51, $51, $e6, $45, $47, $47, $f0,
        // w[12..15]
        $09, $0e, $22, $77, $b3, $b6, $9a, $78, $e1, $e7, $cb, $9e, $a4, $a0, $8c, $6e,
        // w[16..19]
        $e1, $6a, $bd, $3e, $52, $dc, $27, $46, $b3, $3b, $ec, $d8, $17, $9b, $60, $b6,
        // w[20..23]
        $e5, $ba, $f3, $ce, $b7, $66, $d4, $88, $04, $5d, $38, $50, $13, $c6, $58, $e6,
        // w[24..27]
        $71, $d0, $7d, $b3, $c6, $b6, $a9, $3b, $c2, $eb, $91, $6b, $d1, $2d, $c9, $8d,
        // w[28..31]
        $e9, $0d, $20, $8d, $2f, $bb, $89, $b6, $ed, $50, $18, $dd, $3c, $7d, $d1, $50,
        // w[32..35]
        $96, $33, $73, $66, $b9, $88, $fa, $d0, $54, $d8, $e2, $0d, $68, $a5, $33, $5d,
        // w[36..39]
        $8b, $f0, $3f, $23, $32, $78, $c5, $f3, $66, $a0, $27, $fe, $0e, $05, $14, $a3,
        // w[40..43]
        $d6, $0a, $35, $88, $e4, $72, $f0, $7b, $82, $d2, $d7, $85, $8c, $d7, $c3, $26
    }
}

define_function RunNAVAes128KeyExpansionTests() {
    stack_var integer i

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVAes128KeyExpansion ******************')

    for (i = 1; i <= length_array(KEYEXPANSION_TEST); i++) {
        stack_var char roundKey[176]  // 11 round keys × 16 bytes each = 176 bytes
        stack_var char failed
        stack_var integer j

        // Perform key expansion
        NAVAes128KeyExpansion(roundKey, KEYEXPANSION_TEST[i])

        // Compare with expected round keys
        for (j = 1; j <= 176; j++) {
            if (roundKey[j] != KEYEXPANSION_EXPECTED[i][j]) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' failed at byte ', itoa(j)")
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected $', format('%02X', KEYEXPANSION_EXPECTED[i][j]), ' but got $', format('%02X', roundKey[j])")
                failed = true
                continue
            }
        }

        if (failed) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Round keys generated:'")
            NAVAes128LogAllRoundKeys(roundKey)
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' failed'")
            continue
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' passed'")
    }
}
