PROGRAM_NAME='NAVHmacSha512'

/**
 * Test suite for NAVHmacSha512 function
 * RFC 4231 test vectors
 */

DEFINE_CONSTANT

constant char NAV_HMAC_SHA512_KEY[][25] = {
    { $0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b },
    { 'Jefe' },
    { $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa },
    { $01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19 }
}

constant char NAV_HMAC_SHA512_DATA[][50] = {
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

constant char NAV_HMAC_SHA512_EXPECTED[][HMAC_SHA512_HASH_SIZE] = {
    {
        $87,$aa,$7c,$de,$a5,$ef,$61,$9d,$4f,$f0,$b4,$24,$1a,$1d,$6c,$b0,
        $23,$79,$f4,$e2,$ce,$4e,$c2,$78,$7a,$d0,$b3,$05,$45,$e1,$7c,$de,
        $da,$a8,$33,$b7,$d6,$b8,$a7,$02,$03,$8b,$27,$4e,$ae,$a3,$f4,$e4,
        $be,$9d,$91,$4e,$eb,$61,$f1,$70,$2e,$69,$6c,$20,$3a,$12,$68,$54
    },
    {
        $16,$4b,$7a,$7b,$fc,$f8,$19,$e2,$e3,$95,$fb,$e7,$3b,$56,$e0,$a3,
        $87,$bd,$64,$22,$2e,$83,$1f,$d6,$10,$27,$0c,$d7,$ea,$25,$05,$54,
        $97,$58,$bf,$75,$c0,$5a,$99,$4a,$6d,$03,$4f,$65,$f8,$f0,$e6,$fd,
        $ca,$ea,$b1,$a3,$4d,$4a,$6b,$4b,$63,$6e,$07,$0a,$38,$bc,$e7,$37
    },
    {
        $fa,$73,$b0,$08,$9d,$56,$a2,$84,$ef,$b0,$f0,$75,$6c,$89,$0b,$e9,
        $b1,$b5,$db,$dd,$8e,$e8,$1a,$36,$55,$f8,$3e,$33,$b2,$27,$9d,$39,
        $bf,$3e,$84,$82,$79,$a7,$22,$c8,$06,$b4,$85,$a4,$7e,$67,$c8,$07,
        $b9,$46,$a3,$37,$be,$e8,$94,$26,$74,$27,$88,$59,$e1,$32,$92,$fb
    },
    {
        $b0,$ba,$46,$56,$37,$45,$8c,$69,$90,$e5,$a8,$c5,$f6,$1d,$4a,$f7,
        $e5,$76,$d9,$7f,$f9,$4b,$87,$2d,$e7,$6f,$80,$50,$36,$1e,$e3,$db,
        $a9,$1c,$a5,$c1,$1a,$a2,$5e,$b4,$d6,$79,$27,$5c,$c5,$78,$80,$63,
        $a5,$f1,$97,$41,$12,$0c,$4f,$2d,$e2,$ad,$eb,$eb,$10,$a2,$98,$dd
    }
}


define_function TestNAVHmacSha512() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVHmacSha512-RFC 4231 Test Vectors')

    for (x = 1; x <= length_array(NAV_HMAC_SHA512_KEY); x++) {
        stack_var char result[HMAC_SHA512_HASH_SIZE]

        result = NAVHmacSha512(NAV_HMAC_SHA512_KEY[x], NAV_HMAC_SHA512_DATA[x])

        if (!NAVAssertStringEqual('Should match expected HMAC-SHA512 digest', NAV_HMAC_SHA512_EXPECTED[x], result)) {
            NAVLogTestFailed(x, NAV_HMAC_SHA512_EXPECTED[x], result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVHmacSha512-RFC 4231 Test Vectors')
}
