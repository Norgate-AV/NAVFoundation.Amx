PROGRAM_NAME='sha1'

#DEFINE __MAIN__
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Sha1.axi'


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
    'This is a longer test case to check the SHA-1 implementation. It should handle longer strings correctly and produce the expected hash value.'
}


constant char EXPECTED[][20] = {
    {$DA, $39, $A3, $EE, $5E, $6B, $4B, $0D, $32, $55, $BF, $EF, $95, $60, $18, $90, $AF, $D8, $07, $09},
    {$86, $F7, $E4, $37, $FA, $A5, $A7, $FC, $E1, $5D, $1D, $DC, $B9, $EA, $EA, $EA, $37, $76, $67, $B8},
    {$A9, $99, $3E, $36, $47, $06, $81, $6A, $BA, $3E, $25, $71, $78, $50, $C2, $6C, $9C, $D0, $D8, $9D},
    {$C1, $22, $52, $CE, $DA, $8B, $E8, $99, $4D, $5F, $A0, $29, $0A, $47, $23, $1C, $1D, $16, $AA, $E3},
    {$32, $D1, $0C, $7B, $8C, $F9, $65, $70, $CA, $04, $CE, $37, $F2, $A1, $9D, $84, $24, $0D, $3A, $89},
    {$76, $1C, $45, $7B, $F7, $3B, $14, $D2, $7E, $9E, $92, $65, $C4, $6F, $4B, $4D, $DA, $11, $F9, $40},
    {$50, $AB, $F5, $70, $6A, $15, $09, $90, $A0, $8B, $2C, $5E, $A4, $0F, $A0, $E5, $85, $55, $47, $32},
    {$2F, $D4, $E1, $C6, $7A, $2D, $28, $FC, $ED, $84, $9E, $E1, $BB, $76, $E7, $39, $1B, $93, $EB, $12},
    {$40, $8D, $94, $38, $42, $16, $F8, $90, $FF, $7A, $0C, $35, $28, $E8, $BE, $D1, $E0, $B0, $16, $21},
    {$AD, $A4, $44, $2F, $42, $00, $4E, $0E, $E7, $62, $09, $38, $BD, $4D, $3E, $8D, $AC, $86, $21, $A4},
    {$78, $23, $70, $6B, $4A, $AF, $A0, $8C, $A5, $01, $70, $F1, $99, $5E, $7A, $EF, $AC, $E8, $88, $CD},
    {$59, $74, $9D, $06, $44, $1B, $A8, $AD, $69, $F8, $A6, $A0, $C5, $DD, $CE, $0F, $5F, $99, $9B, $8E}
}


define_function RunTests() {
    stack_var integer x

    for (x = 1; x <= length_array(TEST); x++) {
        stack_var char result[20]

        result = NAVSha1GetHash(TEST[x])

        if (result != EXPECTED[x]) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                        "'Test ', itoa(x), ' failed'")
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
