PROGRAM_NAME='NAVSha512HashTests'

#IF_NOT_DEFINED __NAV_SHA512_HASH_TESTS__
#DEFINE __NAV_SHA512_HASH_TESTS__ 'NAVSha512HashTests'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Encoding.axi'
#include 'NAVFoundation.Cryptography.Sha512.h.axi'

DEFINE_CONSTANT

// Standard test vectors from NIST FIPS 180-4 and RFC 4634/6234
constant char SHA512_TEST[][2048] = {
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

// Expected SHA-512 digests in binary form
constant char SHA512_EXPECTED[][64] = {
    // 1: Empty string - NIST verified
    {
        $cf,$83,$e1,$35,$7e,$ef,$b8,$bd,$f1,$54,$28,$50,$d6,$6d,$80,$07,
        $d6,$20,$e4,$05,$0b,$57,$15,$dc,$83,$f4,$a9,$21,$d3,$6c,$e9,$ce,
        $47,$d0,$d1,$3c,$5d,$85,$f2,$b0,$ff,$83,$18,$d2,$87,$7e,$ec,$2f,
        $63,$b9,$31,$bd,$47,$41,$7a,$81,$a5,$38,$32,$7a,$f9,$27,$da,$3e
    },
    // 2: 'a' - NIST verified
    {
        $1f,$40,$fc,$92,$da,$24,$16,$94,$75,$09,$79,$ee,$6c,$f5,$82,$f2,
        $d5,$d7,$d2,$8e,$18,$33,$5d,$e0,$5a,$bc,$54,$d0,$56,$0e,$0f,$53,
        $02,$86,$0c,$65,$2b,$f0,$8d,$56,$02,$52,$aa,$5e,$74,$21,$05,$46,
        $f3,$69,$fb,$bb,$ce,$8c,$12,$cf,$c7,$95,$7b,$26,$52,$fe,$9a,$75
    },
    // 3: 'abc' - NIST verified
    {
        $dd,$af,$35,$a1,$93,$61,$7a,$ba,$cc,$41,$73,$49,$ae,$20,$41,$31,
        $12,$e6,$fa,$4e,$89,$a9,$7e,$a2,$0a,$9e,$ee,$e6,$4b,$55,$d3,$9a,
        $21,$92,$99,$2a,$27,$4f,$c1,$a8,$36,$ba,$3c,$23,$a3,$fe,$eb,$bd,
        $45,$4d,$44,$23,$64,$3c,$e8,$0e,$2a,$9a,$c9,$4f,$a5,$4c,$a4,$9f
    },
    // 4: 'message digest' - NIST verified
    {
        $10,$7d,$bf,$38,$9d,$9e,$9f,$71,$a3,$a9,$5f,$6c,$05,$5b,$92,$51,
        $bc,$52,$68,$c2,$be,$16,$d6,$c1,$34,$92,$ea,$45,$b0,$19,$9f,$33,
        $09,$e1,$64,$55,$ab,$1e,$96,$11,$8e,$8a,$90,$5d,$55,$97,$b7,$20,
        $38,$dd,$b3,$72,$a8,$98,$26,$04,$6d,$e6,$66,$87,$bb,$42,$0e,$7c
    },
    // 5: 'abcdefghijklmnopqrstuvwxyz' - NIST verified
    {
        $4d,$bf,$f8,$6c,$c2,$ca,$1b,$ae,$1e,$16,$46,$8a,$05,$cb,$98,$81,
        $c9,$7f,$17,$53,$bc,$e3,$61,$90,$34,$89,$8f,$aa,$1a,$ab,$e4,$29,
        $95,$5a,$1b,$f8,$ec,$48,$3d,$74,$21,$fe,$3c,$16,$46,$61,$3a,$59,
        $ed,$54,$41,$fb,$0f,$32,$13,$89,$f7,$7f,$48,$a8,$79,$c7,$b1,$f1
    },
    // 6: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789' - NIST verified
    {
        $1e,$07,$be,$23,$c2,$6a,$86,$ea,$37,$ea,$81,$0c,$8e,$c7,$80,$93,
        $52,$51,$5a,$97,$0e,$92,$53,$c2,$6f,$53,$6c,$fc,$7a,$99,$96,$c4,
        $5c,$83,$70,$58,$3e,$0a,$78,$fa,$4a,$90,$04,$1d,$71,$a4,$ce,$ab,
        $74,$23,$f1,$9c,$71,$b9,$d5,$a3,$e0,$12,$49,$f0,$be,$bd,$58,$94
    },
    // 7: '12345678901234567890123456789012345678901234567890123456789012345678901234567890' - NIST verified
    {
        $72,$ec,$1e,$f1,$12,$4a,$45,$b0,$47,$e8,$b7,$c7,$5a,$93,$21,$95,
        $13,$5b,$b6,$1d,$e2,$4e,$c0,$d1,$91,$40,$42,$24,$6e,$0a,$ec,$3a,
        $23,$54,$e0,$93,$d7,$6f,$30,$48,$b4,$56,$76,$43,$46,$90,$0c,$b1,
        $30,$d2,$a4,$fd,$5d,$d1,$6a,$bb,$5e,$30,$bc,$b8,$50,$de,$e8,$43
    },
    // 8: NIST long test vector - verified
    {
        $8e,$95,$9b,$75,$da,$e3,$13,$da,$8c,$f4,$f7,$28,$14,$fc,$14,$3f,
        $8f,$77,$79,$c6,$eb,$9f,$7f,$a1,$72,$99,$ae,$ad,$b6,$88,$90,$18,
        $50,$1d,$28,$9e,$49,$00,$f7,$e4,$33,$1b,$99,$de,$c4,$b5,$43,$3a,
        $c7,$d3,$29,$ee,$b6,$dd,$26,$54,$5e,$96,$e5,$5b,$87,$4b,$e9,$09
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
 * @function RunNAVSha512HashTests
 * @description Run all SHA-512 hash tests
 *
 * @returns {integer} 1 if all tests pass, 0 if any fail
 */
define_function integer RunNAVSha512HashTests() {
    stack_var integer x
    stack_var integer passed, total

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running SHA-512 Hash Tests ====='")

    total = length_array(SHA512_TEST)
    passed = 0

    // Test all hash values
    for (x = 1; x <= total; x++) {
        stack_var char result[64]

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Test ', itoa(x), ' - "', mid_string(SHA512_TEST[x], 1, min_value(30, length_array(SHA512_TEST[x]))), '..." ====='")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Source: ', TEST_VECTOR_SOURCES[x]")
        result = NAVSha512GetHash(SHA512_TEST[x])

        // Compare with expected result
        if (result == SHA512_EXPECTED[x]) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' passed.'")
            passed++
        } else {
            stack_var integer i, diffPos

            diffPos = 0
            for (i = 1; i <= 64; i++) {
                if (result[i] != SHA512_EXPECTED[x][i]) {
                    diffPos = i
                    break
                }
            }

            if (diffPos > 0) {
                NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'First difference at byte ', itoa(diffPos), ': Expected $', format('%02x', SHA512_EXPECTED[x][diffPos] & $FF), ', Got $', format('%02x', result[diffPos] & $FF)")
            }

            NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Test ', itoa(x), ' failed.'")
        }
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'SHA-512 tests: ', itoa(passed), ' of ', itoa(total), ' passed'")
    return (passed == total)
}

#END_IF // __NAV_SHA512_HASH_TESTS__
