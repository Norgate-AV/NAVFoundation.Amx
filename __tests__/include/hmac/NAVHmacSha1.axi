PROGRAM_NAME='NAVHmacSha1'

/**
 * Test suite for NAVHmacSha1 function
 * RFC 2202 test vectors
 */

DEFINE_CONSTANT

constant char NAV_HMAC_SHA1_KEY[][25] = {
    { $0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b },
    { 'Jefe' },
    { $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa },
    { $01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19 }
}

constant char NAV_HMAC_SHA1_DATA[][50] = {
    {
        'Hi There'
    },
    {
        'what do ya want for nothing?'
    },
    {
        $dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,
        $dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,
        $dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,
        $dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,
        $dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd,$dd
    },
    {
        $cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,
        $cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,
        $cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,
        $cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,
        $cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd,$cd
    }
}

constant char NAV_HMAC_SHA1_EXPECTED[][HMAC_SHA1_HASH_SIZE] = {
    { $b6,$17,$31,$86,$55,$05,$72,$64,$e2,$8b,$c0,$b6,$fb,$37,$8c,$8e,$f1,$46,$be,$00 },
    { $ef,$fc,$df,$6a,$e5,$eb,$2f,$a2,$d2,$74,$16,$d5,$f1,$84,$df,$9c,$25,$9a,$7c,$79 },
    { $12,$5d,$73,$42,$b9,$ac,$11,$cd,$91,$a3,$9a,$f4,$8a,$a1,$7b,$4f,$63,$f1,$75,$d3 },
    { $4c,$90,$07,$f4,$02,$62,$50,$c6,$bc,$84,$14,$f9,$bf,$50,$c8,$6c,$2d,$72,$35,$da }
}


define_function TestNAVHmacSha1() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVHmacSha1-RFC 2202 Test Vectors')

    for (x = 1; x <= length_array(NAV_HMAC_SHA1_KEY); x++) {
        stack_var char result[HMAC_SHA1_HASH_SIZE]

        result = NAVHmacSha1(NAV_HMAC_SHA1_KEY[x], NAV_HMAC_SHA1_DATA[x])

        if (!NAVAssertStringEqual('Should match expected HMAC-SHA1 digest', NAV_HMAC_SHA1_EXPECTED[x], result)) {
            NAVLogTestFailed(x, NAV_HMAC_SHA1_EXPECTED[x], result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVHmacSha1-RFC 2202 Test Vectors')
}
