PROGRAM_NAME='NAVSha384HashTests'

#IF_NOT_DEFINED __NAV_SHA384_HASH_TESTS__
#DEFINE __NAV_SHA384_HASH_TESTS__ 'NAVSha384HashTests'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Encoding.axi'
#include 'NAVFoundation.Cryptography.Sha384.h.axi'

DEFINE_CONSTANT

// Standard test vectors from NIST FIPS 180-4 and RFC 4634/6234
constant char SHA384_TEST[][2048] = {
    // Core NIST FIPS 180-4 test vectors
    '',                                                          // 1: Empty string
    'a',                                                         // 2: Single character
    'abc',                                                       // 3: Three characters
    'message digest',                                            // 4: Common test phrase
    'abcdefghijklmnopqrstuvwxyz',                               // 5: Alphabet
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789', // 6: Alphanumeric
    '12345678901234567890123456789012345678901234567890123456789012345678901234567890', // 7: 80 digits
    // Additional well-known test vector from RFC
    'abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu'  // 8: NIST long test vector
}

// Expected SHA-384 digests in binary form
constant char SHA384_EXPECTED[][48] = {
    // 1: Empty string - NIST verified
    {
        $38,$b0,$60,$a7,$51,$ac,$96,$38,$4c,$d9,$32,$7e,$b1,$b1,$e3,$6a,
        $21,$fd,$b7,$11,$14,$be,$07,$43,$4c,$0c,$c7,$bf,$63,$f6,$e1,$da,
        $27,$4e,$de,$bf,$e7,$6f,$65,$fb,$d5,$1a,$d2,$f1,$48,$98,$b9,$5b
    },
    // 2: 'a' - NIST verified
    {
        $54,$a5,$9b,$9f,$22,$b0,$b8,$08,$80,$d8,$42,$7e,$54,$8b,$7c,$23,
        $ab,$d8,$73,$48,$6e,$1f,$03,$5d,$ce,$9c,$d6,$97,$e8,$51,$75,$03,
        $3c,$aa,$88,$e6,$d5,$7b,$c3,$5e,$fa,$e0,$b5,$af,$d3,$14,$5f,$31
    },
    // 3: 'abc' - NIST verified
    {
        $cb,$00,$75,$3f,$45,$a3,$5e,$8b,$b5,$a0,$3d,$69,$9a,$c6,$50,$07,
        $27,$2c,$32,$ab,$0e,$de,$d1,$63,$1a,$8b,$60,$5a,$43,$ff,$5b,$ed,
        $80,$86,$07,$2b,$a1,$e7,$cc,$23,$58,$ba,$ec,$a1,$34,$c8,$25,$a7
    },
    // 4: 'message digest' - NIST verified
    {
        $47,$3e,$d3,$51,$67,$ec,$1f,$5d,$8e,$55,$03,$68,$a3,$db,$39,$be,
        $54,$63,$9f,$82,$88,$68,$e9,$45,$4c,$23,$9f,$c8,$b5,$2e,$3c,$61,
        $db,$d0,$d8,$b4,$de,$13,$90,$c2,$56,$dc,$bb,$5d,$5f,$d9,$9c,$d5
    },
    // 5: 'abcdefghijklmnopqrstuvwxyz' - NIST verified
    {
        $fe,$b6,$73,$49,$df,$3d,$b6,$f5,$92,$48,$15,$d6,$c3,$dc,$13,$3f,
        $09,$18,$09,$21,$37,$31,$fe,$5c,$7b,$5f,$49,$99,$e4,$63,$47,$9f,
        $f2,$87,$7f,$5f,$29,$36,$fa,$63,$bb,$43,$78,$4b,$12,$f3,$eb,$b4
    },
    // 6: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789' - NIST verified
    {
        $17,$61,$33,$6e,$3f,$7c,$bf,$e5,$1d,$eb,$13,$7f,$02,$6f,$89,$e0,
        $1a,$44,$8e,$3b,$1f,$af,$a6,$40,$39,$c1,$46,$4e,$e8,$73,$2f,$11,
        $a5,$34,$1a,$6f,$41,$e0,$c2,$02,$29,$47,$36,$ed,$64,$db,$1a,$84
    },
    // 7: '12345678901234567890123456789012345678901234567890123456789012345678901234567890' - NIST verified
    {
        $b1,$29,$32,$b0,$62,$7d,$1c,$06,$09,$42,$f5,$44,$77,$64,$15,$56,
        $55,$bd,$4d,$a0,$c9,$af,$a6,$dd,$9b,$9e,$f5,$31,$29,$af,$1b,$8f,
        $b0,$19,$59,$96,$d2,$de,$9c,$a0,$df,$9d,$82,$1f,$fe,$e6,$70,$26
    },
    // 8: NIST long test vector - verified
    {
        $09,$33,$0c,$33,$f7,$11,$47,$e8,$3d,$19,$2f,$c7,$82,$cd,$1b,$47,
        $53,$11,$1b,$17,$3b,$3b,$05,$d2,$2f,$a0,$80,$86,$e3,$b0,$f7,$12,
        $fc,$c7,$c7,$1a,$55,$7e,$2d,$b9,$66,$c3,$e9,$fa,$91,$74,$60,$39
    }
}

// Source documentation for test vectors
constant char TEST_VECTOR_SOURCES[8][80] = {
    'NIST FIPS 180-4 / RFC 6234',     // Empty string
    'NIST FIPS 180-4 / RFC 6234',     // 'a'
    'NIST FIPS 180-4 / RFC 6234',     // 'abc'
    'NIST FIPS 180-4 / RFC 6234',     // 'message digest'
    'NIST FIPS 180-4 / RFC 6234',     // 'abcdefghijklmnopqrstuvwxyz'
    'NIST FIPS 180-4 / RFC 6234',     // 'ABCDEFGHIJKLMNOPQRSTUVWXYZ...'
    'NIST FIPS 180-4 / RFC 6234',     // '12345678901234567890...'
    'NIST FIPS 180-4 / RFC 6234'      // 'abcdefghbcdefghi...'
}

/**
 * @function RunNAVSha384HashTests
 * @description Run all SHA-384 hash tests
 *
 * @returns {integer} 1 if all tests pass, 0 if any fail
 */
define_function integer RunNAVSha384HashTests() {
    stack_var integer x
    stack_var integer passed, total

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running SHA-384 Hash Tests ====='")

    total = length_array(SHA384_TEST)
    passed = 0

    // Test all hash values
    for (x = 1; x <= total; x++) {
        stack_var char result[48]

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Test ', itoa(x), ' - "', mid_string(SHA384_TEST[x], 1, min_value(30, length_array(SHA384_TEST[x]))), '..." ====='")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Source: ', TEST_VECTOR_SOURCES[x]")
        result = NAVSha384GetHash(SHA384_TEST[x])

        // Compare with expected result
        if (result == SHA384_EXPECTED[x]) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' passed.'")
            passed++
        } else {
            stack_var integer i, diffPos

            diffPos = 0
            for (i = 1; i <= 48; i++) {
                if (result[i] != SHA384_EXPECTED[x][i]) {
                    diffPos = i
                    break
                }
            }

            if (diffPos > 0) {
                NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'First difference at byte ', itoa(diffPos), ': Expected $', format('%02x', SHA384_EXPECTED[x][diffPos] & $FF), ', Got $', format('%02x', result[diffPos] & $FF)")
            }

            NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Test ', itoa(x), ' failed.'")
        }
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'SHA-384 tests: ', itoa(passed), ' of ', itoa(total), ' passed'")
    return (passed == total)
}

#END_IF // __NAV_SHA384_HASH_TESTS__
