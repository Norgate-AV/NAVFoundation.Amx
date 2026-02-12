PROGRAM_NAME='NAVHmacMd5'

/**
 * Test suite for NAVHmacMd5 function
 * RFC 2104 test vectors
 */

DEFINE_CONSTANT

constant char NAV_HMAC_MD5_KEY[][16] = {
    { $0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b },
    { 'Jefe' },
    { $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa }
}

constant char NAV_HMAC_MD5_DATA[][50] = {
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
    }
}

constant char NAV_HMAC_MD5_EXPECTED[][HMAC_MD5_HASH_SIZE] = {
    { $92,$94,$72,$7a,$36,$38,$bb,$1c,$13,$f4,$8e,$f8,$15,$8b,$fc,$9d },
    { $75,$0c,$78,$3e,$6a,$b0,$b5,$03,$ea,$a8,$6e,$31,$0a,$5d,$b7,$38 },
    { $56,$be,$34,$52,$1d,$14,$4c,$88,$db,$b8,$c7,$33,$f0,$e8,$b3,$f6 }
}


define_function TestNAVHmacMd5() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVHmacMd5-RFC 2104 Test Vectors')

    for (x = 1; x <= length_array(NAV_HMAC_MD5_KEY); x++) {
        stack_var char result[HMAC_MD5_HASH_SIZE]

        result = NAVHmacMd5(NAV_HMAC_MD5_KEY[x], NAV_HMAC_MD5_DATA[x])

        if (!NAVAssertStringEqual('Should match expected HMAC-MD5 digest', NAV_HMAC_MD5_EXPECTED[x], result)) {
            NAVLogTestFailed(x, NAV_HMAC_MD5_EXPECTED[x], result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVHmacMd5-RFC 2104 Test Vectors')
}
