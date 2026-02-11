PROGRAM_NAME='NAVHmacGeneric'

/**
 * Test suite for NAVHmacGetDigest generic function
 * Tests algorithm selection and error handling
 */

DEFINE_CONSTANT

constant char NAV_HMAC_GENERIC_KEY[][20] = {
    {$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b},
    {$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b},
    {$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b},
    {$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b},
    {$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b},
    {$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b}
}

constant char NAV_HMAC_GENERIC_DATA[][10] = {
    'Hi There',
    'Hi There',
    'Hi There',
    'Hi There',
    'Hi There',
    'Hi There'
}

constant char NAV_HMAC_GENERIC_ALGO[][10] = {
    'MD5',
    'SHA1',
    'SHA-256',
    'SHA256',
    'SHA512',
    'INVALID'
}

constant char NAV_HMAC_GENERIC_EXPECTED[][HMAC_SHA512_HASH_SIZE] = {
    // MD5
    {
        $92,$94,$72,$7a,$36,$38,$bb,$1c,$13,$f4,$8e,$f8,$15,$8b,$fc,$9d
    },

    // SHA1
    {
        $b6,$17,$31,$86,$55,$05,$72,$64,$e2,$8b,$c0,$b6,$fb,$37,$8c,$8e,$f1,$46,$be,$00
    },

    // SHA-256 (with hyphen)
    {
        $b0,$34,$4c,$61,$d8,$db,$38,$53,$5c,$a8,$af,$ce,$af,$0b,$f1,$2b,
        $88,$1d,$c2,$00,$c9,$83,$3d,$a7,$26,$e9,$37,$6c,$2e,$32,$cf,$f7
    },

    // SHA256 (without hyphen)
    {
        $b0,$34,$4c,$61,$d8,$db,$38,$53,$5c,$a8,$af,$ce,$af,$0b,$f1,$2b,
        $88,$1d,$c2,$00,$c9,$83,$3d,$a7,$26,$e9,$37,$6c,$2e,$32,$cf,$f7
    },

    // SHA512
    {
        $87,$aa,$7c,$de,$a5,$ef,$61,$9d,$4f,$f0,$b4,$24,$1a,$1d,$6c,$b0,
        $23,$79,$f4,$e2,$ce,$4e,$c2,$78,$7a,$d0,$b3,$05,$45,$e1,$7c,$de,
        $da,$a8,$33,$b7,$d6,$b8,$a7,$02,$03,$8b,$27,$4e,$ae,$a3,$f4,$e4,
        $be,$9d,$91,$4e,$eb,$61,$f1,$70,$2e,$69,$6c,$20,$3a,$12,$68,$54
    },

    // INVALID
    { '' }
}

define_function TestNAVHmacGeneric() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVHmacGetDigest-Generic Algorithm Selection')

    for (x = 1; x <= length_array(NAV_HMAC_GENERIC_ALGO); x++) {
        stack_var char result[HMAC_SHA512_HASH_SIZE]

        result = NAVHmacGetDigest(NAV_HMAC_GENERIC_ALGO[x], NAV_HMAC_GENERIC_KEY[x], NAV_HMAC_GENERIC_DATA[x])

        if (!NAVAssertStringEqual("'Should match expected HMAC-', NAV_HMAC_GENERIC_ALGO[x], ' digest'", NAV_HMAC_GENERIC_EXPECTED[x], result)) {
            NAVLogTestFailed(x, NAV_HMAC_GENERIC_EXPECTED[x], result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVHmacGetDigest-Generic Algorithm Selection')
}
