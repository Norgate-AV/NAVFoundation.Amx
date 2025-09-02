PROGRAM_NAME='NAVFoundation.Cryptography.Aes128.h'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Services Limited

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#IF_NOT_DEFINED __NAV_FOUNDATION_CRYPTOGRAPHY_AES128_H__
#DEFINE __NAV_FOUNDATION_CRYPTOGRAPHY_AES128_H__ 'NAVFoundation.Cryptography.Aes128.h'


DEFINE_CONSTANT

/**
 * @constant NAV_AES_SUCCESS
 * @description Operation completed successfully
 */
constant sinteger NAV_AES_SUCCESS                     = 0

/**
 * @constant NAV_AES_ERROR_NULL_CONTEXT
 * @description AES context is null or invalid
 */
constant sinteger NAV_AES_ERROR_NULL_CONTEXT          = -100

/**
 * @constant NAV_AES_ERROR_NULL_PARAMETER
 * @description A required parameter was null or empty
 */
constant sinteger NAV_AES_ERROR_NULL_PARAMETER        = -101

/**
 * @constant NAV_AES_ERROR_MEMORY
 * @description Memory allocation failed
 */
constant sinteger NAV_AES_ERROR_MEMORY                = -102

/**
 * @constant NAV_AES_ERROR_INVALID_KEY_LENGTH
 * @description Invalid key length
 */
constant sinteger NAV_AES_ERROR_INVALID_KEY_LENGTH    = -110

/**
 * @constant NAV_AES_ERROR_KEY_EXPANSION_FAILED
 * @description Key expansion failed
 */
constant sinteger NAV_AES_ERROR_KEY_EXPANSION_FAILED  = -111

/**
 * @constant NAV_AES_ERROR_KEY_DERIVATION_FAILED
 * @description Key derivation failed
 */
constant sinteger NAV_AES_ERROR_KEY_DERIVATION_FAILED = -112

/**
 * @constant NAV_AES_ERROR_INVALID_BLOCK_LENGTH
 * @description Invalid block length
 */
constant sinteger NAV_AES_ERROR_INVALID_BLOCK_LENGTH  = -120

/**
 * @constant NAV_AES_ERROR_CIPHER_OPERATION
 * @description Cipher operation failed
 */
constant sinteger NAV_AES_ERROR_CIPHER_OPERATION      = -121

/**
 * @constant NAV_AES_ERROR_INVALID_PADDING
 * @description Invalid padding
 */
constant sinteger NAV_AES_ERROR_INVALID_PADDING       = -130

/**
 * @constant NAV_AES_ERROR_PADDING_VERIFICATION
 * @description Padding verification failed
 */
constant sinteger NAV_AES_ERROR_PADDING_VERIFICATION  = -131

/**
 * @constant NAV_AES_ERROR_INVALID_IV_LENGTH
 * @description Invalid IV length
 */
constant sinteger NAV_AES_ERROR_INVALID_IV_LENGTH     = -140

/**
 * @constant AES_BLOCK_LENGTH
 * @description Size of an AES block in bytes (always 16 bytes/128 bits)
 */
constant integer AES_BLOCK_LENGTH = 16

/**
 * @constant AES_KEY_LENGTH
 * @description Size of AES-128 key in bytes (16 bytes/128 bits)
 */
constant integer AES_KEY_LENGTH   = 16

/**
 * @constant AES_ROUNDS
 * @description Number of rounds in AES-128 algorithm
 */
constant integer AES_ROUNDS       = 10

/**
 * @constant SBOX
 * @description Substitution box used in SubBytes transformation
 * @note This is a precomputed lookup table for byte substitution
 */
constant char SBOX[256] = {
    //0    1    2    3    4    5    6    7    8    9    A    B    C    D    E    F
    $63, $7c, $77, $7b, $f2, $6b, $6f, $c5, $30, $01, $67, $2b, $fe, $d7, $ab, $76,
    $ca, $82, $c9, $7d, $fa, $59, $47, $f0, $ad, $d4, $a2, $af, $9c, $a4, $72, $c0,
    $b7, $fd, $93, $26, $36, $3f, $f7, $cc, $34, $a5, $e5, $f1, $71, $d8, $31, $15,
    $04, $c7, $23, $c3, $18, $96, $05, $9a, $07, $12, $80, $e2, $eb, $27, $b2, $75,
    $09, $83, $2c, $1a, $1b, $6e, $5a, $a0, $52, $3b, $d6, $b3, $29, $e3, $2f, $84,
    $53, $d1, $00, $ed, $20, $fc, $b1, $5b, $6a, $cb, $be, $39, $4a, $4c, $58, $cf,
    $d0, $ef, $aa, $fb, $43, $4d, $33, $85, $45, $f9, $02, $7f, $50, $3c, $9f, $a8,
    $51, $a3, $40, $8f, $92, $9d, $38, $f5, $bc, $b6, $da, $21, $10, $ff, $f3, $d2,
    $cd, $0c, $13, $ec, $5f, $97, $44, $17, $c4, $a7, $7e, $3d, $64, $5d, $19, $73,
    $60, $81, $4f, $dc, $22, $2a, $90, $88, $46, $ee, $b8, $14, $de, $5e, $0b, $db,
    $e0, $32, $3a, $0a, $49, $06, $24, $5c, $c2, $d3, $ac, $62, $91, $95, $e4, $79,
    $e7, $c8, $37, $6d, $8d, $d5, $4e, $a9, $6c, $56, $f4, $ea, $65, $7a, $ae, $08,
    $ba, $78, $25, $2e, $1c, $a6, $b4, $c6, $e8, $dd, $74, $1f, $4b, $bd, $8b, $8a,
    $70, $3e, $b5, $66, $48, $03, $f6, $0e, $61, $35, $57, $b9, $86, $c1, $1d, $9e,
    $e1, $f8, $98, $11, $69, $d9, $8e, $94, $9b, $1e, $87, $e9, $ce, $55, $28, $df,
    $8c, $a1, $89, $0d, $bf, $e6, $42, $68, $41, $99, $2d, $0f, $b0, $54, $bb, $16
}

/**
 * @constant RSBOX
 * @description Inverse substitution box used in InvSubBytes transformation
 * @note This is a precomputed lookup table for inverse byte substitution
 */
constant char RSBOX[256] = {
    $52, $09, $6a, $d5, $30, $36, $a5, $38, $bf, $40, $a3, $9e, $81, $f3, $d7, $fb,
    $7c, $e3, $39, $82, $9b, $2f, $ff, $87, $34, $8e, $43, $44, $c4, $de, $e9, $cb,
    $54, $7b, $94, $32, $a6, $c2, $23, $3d, $ee, $4c, $95, $0b, $42, $fa, $c3, $4e,
    $08, $2e, $a1, $66, $28, $d9, $24, $b2, $76, $5b, $a2, $49, $6d, $8b, $d1, $25,
    $72, $f8, $f6, $64, $86, $68, $98, $16, $d4, $a4, $5c, $cc, $5d, $65, $b6, $92,
    $6c, $70, $48, $50, $fd, $ed, $b9, $da, $5e, $15, $46, $57, $a7, $8d, $9d, $84,
    $90, $d8, $ab, $00, $8c, $bc, $d3, $0a, $f7, $e4, $58, $05, $b8, $b3, $45, $06,
    $d0, $2c, $1e, $8f, $ca, $3f, $0f, $02, $c1, $af, $bd, $03, $01, $13, $8a, $6b,
    $3a, $91, $11, $41, $4f, $67, $dc, $ea, $97, $f2, $cf, $ce, $f0, $b4, $e6, $73,
    $96, $ac, $74, $22, $e7, $ad, $35, $85, $e2, $f9, $37, $e8, $1c, $75, $df, $6e,
    $47, $f1, $1a, $71, $1d, $29, $c5, $89, $6f, $b7, $62, $0e, $aa, $18, $be, $1b,
    $fc, $56, $3e, $4b, $c6, $d2, $79, $20, $9a, $db, $c0, $fe, $78, $cd, $5a, $f4,
    $1f, $dd, $a8, $33, $88, $07, $c7, $31, $b1, $12, $10, $59, $27, $80, $ec, $5f,
    $60, $51, $7f, $a9, $19, $b5, $4a, $0d, $2d, $e5, $7a, $9f, $93, $c9, $9c, $ef,
    $a0, $e0, $3b, $4d, $ae, $2a, $f5, $b0, $c8, $eb, $bb, $3c, $83, $53, $99, $61,
    $17, $2b, $04, $7e, $ba, $77, $d6, $26, $e1, $69, $14, $63, $55, $21, $0c, $7d
}

/**
 * @constant RCON
 * @description Round constants used in key expansion
 */
constant char RCON[11] = {
    $8d, $01, $02, $04, $08, $10, $20, $40, $80, $1b, $36
}

DEFINE_TYPE

/**
 * @struct _NAVAesContext
 * @description Context structure for AES-128 encryption/decryption operations
 *
 * @property {char[4][4]} State - Current block state matrix
 * @property {char[176]} RoundKey - Expanded key schedule (11 round keys of 16 bytes each)
 * @property {char[16]} Iv - Initialization vector for CBC mode (future implementation)
 *
 * @note This structure must be initialized via NAVAes128ContextInit before use
 * @see NAVAes128ContextInit
 */
struct _NAVAesContext {
    char State[4][4]        // Current block state
    char RoundKey[176]      // Expanded key (AES-128 needs 11 round keys of 16 bytes each)
    char Iv[16]             // Initialization vector for CBC mode
}


#END_IF // __NAV_FOUNDATION_CRYPTOGRAPHY_AES128_H__
