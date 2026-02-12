PROGRAM_NAME='NAVFoundation.Cryptography.Sha384.h'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2010-2026 Norgate AV

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

/**
 * @file NAVFoundation.Cryptography.Sha384.h.axi
 * @brief SHA-384 header file defining constants, structures, and error codes.
 *
 * This header defines the constants and structures needed for the SHA-384
 * implementation, including the context structure, error codes, and round
 * constants.
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_CRYPTOGRAPHY_SHA384_H__
#DEFINE __NAV_FOUNDATION_CRYPTOGRAPHY_SHA384_H__ 'NAVFoundation.Cryptography.Sha384.h'

#include 'NAVFoundation.Int64.h.axi'


DEFINE_CONSTANT
/*
 * Constants
 */
/**
 * @constant SHA384_LEVEL_MINIMAL
 * @brief Debug level for minimal logging (only critical operations)
 */
constant integer SHA384_LEVEL_MINIMAL = 1

/**
 * @constant SHA384_LEVEL_NORMAL
 * @brief Debug level for normal logging (important steps)
 */
constant integer SHA384_LEVEL_NORMAL  = 2

/**
 * @constant SHA384_LEVEL_VERBOSE
 * @brief Debug level for verbose logging (all operations)
 */
constant integer SHA384_LEVEL_VERBOSE = 3

/**
 * @constant SHA384_DEBUG_LEVEL
 * @brief Current debug level for the SHA-384 implementation
 */
constant integer SHA384_DEBUG_LEVEL = SHA384_LEVEL_MINIMAL

/**
 * @constant SHA384_HASH_SIZE
 * @brief Size of SHA-384 hash output in bytes (48 bytes = 384 bits)
 */
constant integer SHA384_HASH_SIZE = 48

/**
 * @constant SHA384_BLOCK_SIZE
 * @brief Size of SHA-384 processing block in bytes (128 bytes = 1024 bits)
 */
constant integer SHA384_BLOCK_SIZE = 128

/**
 * @constant SHA384_SUCCESS
 * @brief Status code indicating successful operation
 */
constant integer SHA384_SUCCESS = 0

/**
 * @constant SHA384_NULL
 * @brief Error code indicating null pointer parameter
 */
constant integer SHA384_NULL = 1

/**
 * @constant SHA384_INPUT_TOO_LONG
 * @brief Error code indicating input data too long
 */
constant integer SHA384_INPUT_TOO_LONG = 2

/**
 * @constant SHA384_STATE_ERROR
 * @brief Error code indicating state error (called Input after Result)
 */
constant integer SHA384_STATE_ERROR = 3

/**
 * @constant SHA384_UNKNOWN_ERROR
 * @brief Error code indicating unknown error
 */
constant integer SHA384_UNKNOWN_ERROR = 4

/**
 * @constant SHA384_CONST_K_SIZE
 * @brief Size of SHA-384/512 round constants array
 */
constant integer SHA384_CONST_K_SIZE = 80

/**
 * @constant SHA384_K
 * @brief SHA-384/512 round constants (K[0] through K[79])
 * These are the first 64 bits of the fractional parts of the
 * cube roots of the first 80 prime numbers (2 through 409)
 * Note: SHA-384 uses the same K constants as SHA-512
 */
constant long SHA384_K[SHA384_CONST_K_SIZE][2] = {
    {$428a2f98, $d728ae22}, {$71374491, $23ef65cd}, {$b5c0fbcf, $ec4d3b2f}, {$e9b5dba5, $8189dbbc},
    {$3956c25b, $f348b538}, {$59f111f1, $b605d019}, {$923f82a4, $af194f9b}, {$ab1c5ed5, $da6d8118},
    {$d807aa98, $a3030242}, {$12835b01, $45706fbe}, {$243185be, $4ee4b28c}, {$550c7dc3, $d5ffb4e2},
    {$72be5d74, $f27b896f}, {$80deb1fe, $3b1696b1}, {$9bdc06a7, $25c71235}, {$c19bf174, $cf692694},
    {$e49b69c1, $9ef14ad2}, {$efbe4786, $384f25e3}, {$0fc19dc6, $8b8cd5b5}, {$240ca1cc, $77ac9c65},
    {$2de92c6f, $592b0275}, {$4a7484aa, $6ea6e483}, {$5cb0a9dc, $bd41fbd4}, {$76f988da, $831153b5},
    {$983e5152, $ee66dfab}, {$a831c66d, $2db43210}, {$b00327c8, $98fb213f}, {$bf597fc7, $beef0ee4},
    {$c6e00bf3, $3da88fc2}, {$d5a79147, $930aa725}, {$06ca6351, $e003826f}, {$14292967, $0a0e6e70},
    {$27b70a85, $46d22ffc}, {$2e1b2138, $5c26c926}, {$4d2c6dfc, $5ac42aed}, {$53380d13, $9d95b3df},
    {$650a7354, $8baf63de}, {$766a0abb, $3c77b2a8}, {$81c2c92e, $47edaee6}, {$92722c85, $1482353b},
    {$a2bfe8a1, $4cf10364}, {$a81a664b, $bc423001}, {$c24b8b70, $d0f89791}, {$c76c51a3, $0654be30},
    {$d192e819, $d6ef5218}, {$d6990624, $5565a910}, {$f40e3585, $5771202a}, {$106aa070, $32bbd1b8},
    {$19a4c116, $b8d2d0c8}, {$1e376c08, $5141ab53}, {$2748774c, $df8eeb99}, {$34b0bcb5, $e19b48a8},
    {$391c0cb3, $c5c95a63}, {$4ed8aa4a, $e3418acb}, {$5b9cca4f, $7763e373}, {$682e6ff3, $d6b2b8a3},
    {$748f82ee, $5defb2fc}, {$78a5636f, $43172f60}, {$84c87814, $a1f0ab72}, {$8cc70208, $1a6439ec},
    {$90befffa, $23631e28}, {$a4506ceb, $de82bde9}, {$bef9a3f7, $b2c67915}, {$c67178f2, $e372532b},
    {$ca273ece, $ea26619c}, {$d186b8c7, $21c0c207}, {$eada7dd6, $cde0eb1e}, {$f57d4f7f, $ee6ed178},
    {$06f067aa, $72176fba}, {$0a637dc5, $a2c898a6}, {$113f9804, $bef90dae}, {$1b710b35, $131c471b},
    {$28db77f5, $23047d84}, {$32caab7b, $40c72493}, {$3c9ebe0a, $15c9bebc}, {$431d67c4, $9c100d4c},
    {$4cc5d4be, $cb3e42b6}, {$597f299c, $fc657e2a}, {$5fcb6fab, $3ad6faec}, {$6c44198c, $4a475817}
}

/*
 * Structure definitions
 */
DEFINE_TYPE

/**
 * @struct _NAVSha384Context
 * @brief Context structure for the SHA-384 implementation
 *
 * @member IntermediateHash - The current hash value (8 × 64-bit words)
 * @member LengthHigh - High 64 bits of message length in bits
 * @member LengthLow - Low 64 bits of message length in bits
 * @member MessageBlockIndex - Current byte index in the message block
 * @member MessageBlock - Current message block (128 bytes for SHA-384)
 * @member Computed - Flag indicating if the digest has been computed
 * @member Corrupted - Flag indicating if an error occurred
 */
struct _NAVSha384Context {
    _NAVInt64 IntermediateHash[8]
    _NAVInt64 LengthHigh
    _NAVInt64 LengthLow
    integer MessageBlockIndex
    char MessageBlock[SHA384_BLOCK_SIZE]
    integer Computed
    integer Corrupted
}

#END_IF // __NAV_FOUNDATION_CRYPTOGRAPHY_SHA384_H__
