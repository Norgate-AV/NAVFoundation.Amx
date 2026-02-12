PROGRAM_NAME='NAVHmacSha256'

/**
 * Test suite for NAVHmacSha256 function
 * RFC 4231 test vectors
 */

DEFINE_CONSTANT

constant char NAV_HMAC_SHA256_KEY[][131] = {
    { $0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b },
    { 'Jefe' },
    { $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa },
    { $01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19 },
    {
        $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,
        $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,
        $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,
        $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,
        $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,
        $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,
        $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa
    }
}

constant char NAV_HMAC_SHA256_DATA[][60] = {
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
    },
    {
        'Test Using Larger Than Block-Size Key - Hash Key First'
    }
}

constant char NAV_HMAC_SHA256_EXPECTED[][HMAC_SHA256_HASH_SIZE] = {
    {
        $b0,$34,$4c,$61,$d8,$db,$38,$53,$5c,$a8,$af,$ce,$af,$0b,$f1,$2b,
        $88,$1d,$c2,$00,$c9,$83,$3d,$a7,$26,$e9,$37,$6c,$2e,$32,$cf,$f7
    },
    {
        $5b,$dc,$c1,$46,$bf,$60,$75,$4e,$6a,$04,$24,$26,$08,$95,$75,$c7,
        $5a,$00,$3f,$08,$9d,$27,$39,$83,$9d,$ec,$58,$b9,$64,$ec,$38,$43
    },
    {
        $77,$3e,$a9,$1e,$36,$80,$0e,$46,$85,$4d,$b8,$eb,$d0,$91,$81,$a7,
        $29,$59,$09,$8b,$3e,$f8,$c1,$22,$d9,$63,$55,$14,$ce,$d5,$65,$fe
    },
    {
        $82,$55,$8a,$38,$9a,$44,$3c,$0e,$a4,$cc,$81,$98,$99,$f2,$08,$3a,
        $85,$f0,$fa,$a3,$e5,$78,$f8,$07,$7a,$2e,$3f,$f4,$67,$29,$66,$5b
    },
    {
        $60,$e4,$31,$59,$1e,$e0,$b6,$7f,$0d,$8a,$26,$aa,$cb,$f5,$b7,$7f,
        $8e,$0b,$c6,$21,$37,$28,$c5,$14,$05,$46,$04,$0f,$0e,$e3,$7f,$54
    }
}


define_function TestNAVHmacSha256() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVHmacSha256-RFC 4231 Test Vectors')

    for (x = 1; x <= length_array(NAV_HMAC_SHA256_KEY); x++) {
        stack_var char result[HMAC_SHA256_HASH_SIZE]

        result = NAVHmacSha256(NAV_HMAC_SHA256_KEY[x], NAV_HMAC_SHA256_DATA[x])

        if (!NAVAssertStringEqual('Should match expected HMAC-SHA256 digest', NAV_HMAC_SHA256_EXPECTED[x], result)) {
            NAVLogTestFailed(x, NAV_HMAC_SHA256_EXPECTED[x], result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVHmacSha256-RFC 4231 Test Vectors')
}
