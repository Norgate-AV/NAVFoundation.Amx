PROGRAM_NAME='sha256'

#DEFINE __MAIN__
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Encoding.axi'
#include 'NAVFoundation.Cryptography.Sha256.axi'


DEFINE_DEVICE

dvTP    =   10001:1:0


DEFINE_CONSTANT

constant char TEST[][2048] = {
    '',
    'a',
    'abc',
    'message digest',
    'abcdefghijklmnopqrstuvwxyz',
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789',
    '12345678901234567890123456789012345678901234567890123456789012345678901234567890',
    'The quick brown fox jumps over the lazy dog',
    'The quick brown fox jumps over the lazy dog.',
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    'The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog.',
    'This is a longer test case to check the SHA-256 implementation. It should handle longer strings correctly and produce the expected hash value.'
}


constant char EXPECTED[][32] = {
    {$e3,$b0,$c4,$42,$98,$fc,$1c,$14,$9a,$fb,$f4,$c8,$99,$6f,$b9,$24,$27,$ae,$41,$e4,$64,$9b,$93,$4c,$a4,$95,$99,$1b,$78,$52,$b8,$55},
    {$ca,$97,$81,$12,$ca,$1b,$bd,$ca,$fa,$c2,$31,$b3,$9a,$23,$dc,$4d,$a7,$86,$ef,$f8,$14,$7c,$4e,$72,$b9,$80,$77,$85,$af,$ee,$48,$bb},
    {$ba,$78,$16,$bf,$8f,$01,$cf,$ea,$41,$41,$40,$de,$5d,$ae,$22,$23,$b0,$03,$61,$a3,$96,$17,$7a,$9c,$b4,$10,$ff,$61,$f2,$00,$15,$ad},
    // Updated test vector for "message digest"
    {$f7,$84,$6f,$55,$cf,$23,$e1,$4e,$eb,$ea,$b5,$b4,$e1,$55,$0c,$ad,$5b,$50,$9e,$33,$48,$fb,$c4,$ef,$a3,$a1,$41,$3d,$39,$3c,$b6,$50},
    {$71,$c4,$80,$df,$93,$d6,$ae,$2f,$1e,$fa,$d1,$44,$7c,$66,$c9,$52,$5e,$31,$62,$18,$cf,$51,$fc,$8d,$9e,$d8,$32,$f2,$da,$f1,$8b,$73},
    {$db,$4b,$fc,$bd,$4d,$a0,$cd,$85,$a6,$0c,$3c,$37,$d3,$fb,$d8,$80,$5c,$77,$f1,$5f,$c6,$b1,$fd,$fe,$61,$4e,$e0,$a7,$c8,$fd,$b4,$c0},
    // Updated test vector for 80 digits of "12345..."
    {$f3,$71,$bc,$4a,$31,$1f,$2b,$00,$9e,$ef,$95,$2d,$d8,$3c,$a8,$0e,$2b,$60,$02,$6c,$8e,$93,$55,$92,$d0,$f9,$c3,$08,$45,$3c,$81,$3e},
    {$d7,$a8,$fb,$b3,$07,$d7,$80,$94,$69,$ca,$9a,$bc,$b0,$08,$2e,$4f,$8d,$56,$51,$e4,$6d,$3c,$db,$76,$2d,$02,$d0,$bf,$37,$c9,$e5,$92},
    {$ef,$53,$7f,$25,$c8,$95,$bf,$a7,$82,$52,$65,$29,$a9,$b6,$3d,$97,$aa,$63,$15,$64,$d5,$d7,$89,$c2,$b7,$65,$44,$8c,$86,$35,$fb,$6c},
    // Updated test vector for "Lorem ipsum..."
    {$09,$a8,$e2,$cf,$b2,$0c,$56,$94,$c6,$b8,$ff,$32,$c8,$89,$c2,$7b,$92,$68,$89,$fe,$d9,$15,$ab,$45,$67,$95,$7d,$12,$8c,$21,$62,$42},
    // Updated test vector for "The quick brown fox..." (3x)
    {$3f,$55,$28,$46,$2b,$83,$89,$dd,$df,$a6,$91,$68,$21,$52,$58,$85,$a7,$f0,$da,$9b,$56,$ad,$35,$1b,$48,$09,$9f,$80,$fd,$17,$75,$ca},
    // Updated test vector for longer test case
    {$a3,$99,$48,$a1,$45,$ff,$a2,$04,$1e,$c7,$99,$e1,$91,$4e,$7f,$e2,$2d,$49,$bc,$50,$1e,$c0,$fd,$44,$bf,$43,$70,$57,$dd,$93,$83,$b2}
}


define_function RunTests() {
    stack_var integer x

    for (x = 1; x <= length_array(TEST); x++) {
        stack_var char result[32]

        result = NAVSha256GetHash(TEST[x])

        if (result != EXPECTED[x]) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected: "', NAVHexToString(EXPECTED[x]), '"'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got     : "', NAVHexToString(result), '"'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' failed.'")
            continue
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' passed'")
    }
}


DEFINE_EVENT

button_event[dvTP, 1] {
    push: {
        RunTests()
    }
}
