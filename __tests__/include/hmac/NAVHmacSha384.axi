PROGRAM_NAME='NAVHmacSha384'

/**
 * Test suite for NAVHmacSha384 function
 * RFC 4231 test vectors
 */

DEFINE_CONSTANT

constant char NAV_HMAC_SHA384_KEY[][131] = {
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

constant char NAV_HMAC_SHA384_DATA[][60] = {
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

constant char NAV_HMAC_SHA384_EXPECTED[][HMAC_SHA384_HASH_SIZE] = {
    {
        $af,$d0,$39,$44,$d8,$48,$95,$62,$6b,$08,$25,$f4,$ab,$46,$90,$7f,
        $15,$f9,$da,$db,$e4,$10,$1e,$c6,$82,$aa,$03,$4c,$7c,$eb,$c5,$9c,
        $fa,$ea,$9e,$a9,$07,$6e,$de,$7f,$4a,$f1,$52,$e8,$b2,$fa,$9c,$b6
    },
    {
        $af,$45,$d2,$e3,$76,$48,$40,$31,$61,$7f,$78,$d2,$b5,$8a,$6b,$1b,
        $9c,$7e,$f4,$64,$f5,$a0,$1b,$47,$e4,$2e,$c3,$73,$63,$22,$44,$5e,
        $8e,$22,$40,$ca,$5e,$69,$e2,$c7,$8b,$32,$39,$ec,$fa,$b2,$16,$49
    },
    {
        $88,$06,$26,$08,$d3,$e6,$ad,$8a,$0a,$a2,$ac,$e0,$14,$c8,$a8,$6f,
        $0a,$a6,$35,$d9,$47,$ac,$9f,$eb,$e8,$3e,$f4,$e5,$59,$66,$14,$4b,
        $2a,$5a,$b3,$9d,$c1,$38,$14,$b9,$4e,$3a,$b6,$e1,$01,$a3,$4f,$27
    },
    {
        $3e,$8a,$69,$b7,$78,$3c,$25,$85,$19,$33,$ab,$62,$90,$af,$6c,$a7,
        $7a,$99,$81,$48,$08,$50,$00,$9c,$c5,$57,$7c,$6e,$1f,$57,$3b,$4e,
        $68,$01,$dd,$23,$c4,$a7,$d6,$79,$cc,$f8,$a3,$86,$c6,$74,$cf,$fb
    },
    {
        $4e,$ce,$08,$44,$85,$81,$3e,$90,$88,$d2,$c6,$3a,$04,$1b,$c5,$b4,
        $4f,$9e,$f1,$01,$2a,$2b,$58,$8f,$3c,$d1,$1f,$05,$03,$3a,$c4,$c6,
        $0c,$2e,$f6,$ab,$40,$30,$fe,$82,$96,$24,$8d,$f1,$63,$f4,$49,$52
    }
}


define_function TestNAVHmacSha384() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVHmacSha384-RFC 4231 Test Vectors')

    for (x = 1; x <= length_array(NAV_HMAC_SHA384_KEY); x++) {
        stack_var char result[HMAC_SHA384_HASH_SIZE]

        result = NAVHmacSha384(NAV_HMAC_SHA384_KEY[x], NAV_HMAC_SHA384_DATA[x])

        if (!NAVAssertStringEqual('Should match expected HMAC-SHA384 digest', NAV_HMAC_SHA384_EXPECTED[x], result)) {
            NAVLogTestFailed(x, NAV_HMAC_SHA384_EXPECTED[x], result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVHmacSha384-RFC 4231 Test Vectors')
}
