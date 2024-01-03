PROGRAM_NAME='NAVFoundation.Cryptography.Md5'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_CRYPTOGRAPHY_MD5__
#DEFINE __NAV_FOUNDATION_CRYPTOGRAPHY_MD5__ 'NAVFoundation.Cryptography.Md5'

#include 'NAVFoundation.BinaryUtils.axi'


DEFINE_CONSTANT

constant long T1  = $d76aa478
constant long T2  = $e8c7b756
constant long T3  = $242070db
constant long T4  = $c1bdceee
constant long T5  = $f57c0faf
constant long T6  = $4787c62a
constant long T7  = $a8304613
constant long T8  = $fd469501
constant long T9  = $698098d8
constant long T10 = $8b44f7af
constant long T11 = $ffff5bb1
constant long T12 = $895cd7be
constant long T13 = $6b901122
constant long T14 = $fd987193
constant long T15 = $a679438e
constant long T16 = $49b40821
constant long T17 = $f61e2562
constant long T18 = $c040b340
constant long T19 = $265e5a51
constant long T20 = $e9b6c7aa
constant long T21 = $d62f105d
constant long T22 = $02441453
constant long T23 = $d8a1e681
constant long T24 = $e7d3fbc8
constant long T25 = $21e1cde6
constant long T26 = $c33707d6
constant long T27 = $f4d50d87
constant long T28 = $455a14ed
constant long T29 = $a9e3e905
constant long T30 = $fcefa3f8
constant long T31 = $676f02d9
constant long T32 = $8d2a4c8a
constant long T33 = $fffa3942
constant long T34 = $8771f681
constant long T35 = $6d9d6122
constant long T36 = $fde5380c
constant long T37 = $a4beea44
constant long T38 = $4bdecfa9
constant long T39 = $f6bb4b60
constant long T40 = $bebfbc70
constant long T41 = $289b7ec6
constant long T42 = $eaa127fa
constant long T43 = $d4ef3085
constant long T44 = $04881d05
constant long T45 = $d9d4d039
constant long T46 = $e6db99e5
constant long T47 = $1fa27cf8
constant long T48 = $c4ac5665
constant long T49 = $f4292244
constant long T50 = $432aff97
constant long T51 = $ab9423a7
constant long T52 = $fc93a039
constant long T53 = $655b59c3
constant long T54 = $8f0ccc92
constant long T55 = $ffeff47d
constant long T56 = $85845dd1
constant long T57 = $6fa87e4f
constant long T58 = $fe2ce6e0
constant long T59 = $a3014314
constant long T60 = $4e0811a1
constant long T61 = $f7537e82
constant long T62 = $bd3af235
constant long T63 = $2ad7d2bb
constant long T64 = $eb86d391


DEFINE_TYPE

struct md5_state_t {
    long  count[2]    // message length
    long  abcd[4]     // digest buffer
    char  buf[64]     // accumulate block
}


//------------------------------------------------------------------
// Name: encrypt()  (StringToEncrypt)
//
// Purpose: encrypts (MD5) input string
//
// Parameters: pcStringToEncrypt - "'fg#','sn#'"
//
// Return: EncryptedString[32]
//
//------------------------------------------------------------------
define_function char[32] NAVGetMd5Hash(char value[]) {
    stack_var integer x
    stack_var md5_state_t state
    stack_var char digest[16]
    stack_var char hash[32]

    // clear buffer
    for (x = 1; x <= 16; x++) {
        digest[x] = 0
    }

    // initialize encryption algorithm
    NAVMd5StateInit(state)

    // process input string
    md5_append(state, value, length_array(value))

    // complete processing of string
    md5_finish(state, digest)

    // Testing
    for (x = 1; x <= 16; x++) {
        hash = "hash, format('%02x', digest[x])"
    }

    // Return the key
    return hash
}


//------------------------------------------------------------------
// Name: md5_init()
//
// Purpose: initialize MD5 encryption algorithm
//
// Parameters: parms - state parameter array
//
// Return: none
//
//------------------------------------------------------------------
define_function integer NAVMd5StateInit(md5_state_t state) {
    // stack_var integer ii

    state.count[1] = 0
    state.count[2] = 0

    // Load magic inititialization constants.
    state.abcd[1] = $67452301
    state.abcd[2] = $efcdab89
    state.abcd[3] = $98badcfe
    state.abcd[4] = $10325476

    //  state.buf = ""
    //  for(ii = 1; ii <= 64; ii++)
    //    state.buf[ii] = 0
    state.buf ="0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0,
                0,0,0,0,0,0,0,0"
}


//------------------------------------------------------------------
// Name:md5_append()
//
// Purpose: process partial string (64 characters) for MD5 encryption
//
// Parameters: parms - state parameter array
//             data - character string to encrypt
//             nbytes - length of string to encrypt
//
// Return: none
//
//------------------------------------------------------------------
define_function md5_append(md5_state_t state, char data[], integer bytes) {
    stack_var integer p_idx
    stack_var integer left
    stack_var integer offset
    stack_var long bits
    stack_var integer copy
    stack_var integer x
    // stack_var char strOutput[500]

    p_idx = 0;
    left = bytes
    offset = type_cast((state.count[1] >> 3) & 63)
    bits = bytes << 3

    if (bytes <= 0) {
        return
    }

    // Update the message length
    state.count[2] = state.count[2] + (bytes >> 29)
    state.count[1] = state.count[1] + bits

    if (state.count[1] < bits) {
        state.count[2]++
    }

    // Process an initial partial block.
    if (offset) {
        if((offset + bytes) > 64) {
            copy = 64 - offset
        }
        else {
            copy = bytes
        }

        state.buf = "left_string(state.buf, offset), mid_string(data, p_idx + 1, copy)"

        if ((offset + copy) < 64) {
            return
        }

        p_idx = p_idx + copy

        left = left - copy

        md5_process(state, state.buf)
    }

    //    /* Process full blocks. */
    for (x = 1; left >= 64; left = left - 64, x++) {
        md5_process(state, "right_string(data, length_string(data) - p_idx)")
        p_idx = p_idx + 64
    }

    //    /* Process a final partial block. */
    if (left) {
        state.buf = right_string(data, length_string(data) - p_idx)
        set_length_string(state.buf, left)
    }
}


//------------------------------------------------------------------
// Name: md5_finish()
//
// Purpose: complete encryption of input string
//
// Parameters: parms - state parameter array
//             digest - output storage for encrypted codes
//
// Return: encoded (base64) character
//
//------------------------------------------------------------------
define_function integer md5_finish(md5_state_t state, char digest[]) {
    stack_var char pad[64]
    stack_var integer x
    stack_var integer j
    stack_var char data[8]
    // stack_var integer ii
    // stack_var char strOutput[500]

    pad ="$80,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"

    // Save the length before padding.
    set_length_string(data, 8)

    for (x = 1, j = 0; j < 8; j++, x++) {
        data[x] = type_cast((state.count[(j >> 2) + 1] >> ((j & 3) << 3)))
    }

    // Pad to 56 bytes mod 64.
    md5_append(state, pad, type_cast(((55 - (state.count[1] >> 3)) & 63) + 1))

    // Append the length.
    md5_append(state, data, 8)

    // transfer encrypted code
    for (x = 1, j = 0; j < 16; j++, x++) {
        digest[x] = type_cast((state.abcd[(j >> 2) + 1] >> ((j & 3) << 3)))
    }
}


//------------------------------------------------------------------
// Name: md5_process()
//
// Purpose: main encryption processing routine
//
// Parameters: parms - state parameters for encryption
//             data - string to be processed (up to 64 characters)
//
// Return: none
//
//------------------------------------------------------------------
define_function integer md5_process(md5_state_t state, char data[]) {
    stack_var long A
    stack_var long B
    stack_var long C
    stack_var long D
    stack_var long T
    stack_var integer I
    stack_var long X[16]
    stack_var long data3[4]

    a = state.abcd[1]
    b = state.abcd[2]
    c = state.abcd[3]
    d = state.abcd[4]

    (********************************************************
        * On big-endian machines, we must arrange the bytes in the right
        * order.  COLDFIRE IS A BIG-ENDIAN MACHINE !!!
    *********************************************************)
    for (i = 1; i <= 16; i++) {
        data3[1] = data[((i - 1) * 4) + 1]
        data3[2] = data[((i - 1) * 4) + 2]
        data3[3] = data[((i - 1) * 4) + 3]
        data3[4] = data[((i - 1) * 4) + 4]
        X[i] = data3[1] + (data3[2] << 8) + (data3[3] << 16) + (data3[4] << 24)
    }


    // Round 1.
    FF(a, b, c, d,  0,  7,  T1, X, t)
    FF(d, a, b, c,  1, 12,  T2, X, t)
    FF(c, d, a, b,  2, 17,  T3, X, t)
    FF(b, c, d, a,  3, 22,  T4, X, t)
    FF(a, b, c, d,  4,  7,  T5, X, t)
    FF(d, a, b, c,  5, 12,  T6, X, t)
    FF(c, d, a, b,  6, 17,  T7, X, t)
    FF(b, c, d, a,  7, 22,  T8, X, t)
    FF(a, b, c, d,  8,  7,  T9, X, t)
    FF(d, a, b, c,  9, 12, T10, X, t)
    FF(c, d, a, b, 10, 17, T11, X, t)
    FF(b, c, d, a, 11, 22, T12, X, t)
    FF(a, b, c, d, 12,  7, T13, X, t)
    FF(d, a, b, c, 13, 12, T14, X, t)
    FF(c, d, a, b, 14, 17, T15, X, t)
    FF(b, c, d, a, 15, 22, T16, X, t)

    // Round 2.
    GG(a, b, c, d,  1,  5, T17, X, t)
    GG(d, a, b, c,  6,  9, T18, X, t)
    GG(c, d, a, b, 11, 14, T19, X, t)
    GG(b, c, d, a,  0, 20, T20, X, t)
    GG(a, b, c, d,  5,  5, T21, X, t)
    GG(d, a, b, c, 10,  9, T22, X, t)
    GG(c, d, a, b, 15, 14, T23, X, t)
    GG(b, c, d, a,  4, 20, T24, X, t)
    GG(a, b, c, d,  9,  5, T25, X, t)
    GG(d, a, b, c, 14,  9, T26, X, t)
    GG(c, d, a, b,  3, 14, T27, X, t)
    GG(b, c, d, a,  8, 20, T28, X, t)
    GG(a, b, c, d, 13,  5, T29, X, t)
    GG(d, a, b, c,  2,  9, T30, X, t)
    GG(c, d, a, b,  7, 14, T31, X, t)
    GG(b, c, d, a, 12, 20, T32, X, t)

    // Round 3.
    HH(a, b, c, d,  5,  4, T33, X, t)
    HH(d, a, b, c,  8, 11, T34, X, t)
    HH(c, d, a, b, 11, 16, T35, X, t)
    HH(b, c, d, a, 14, 23, T36, X, t)
    HH(a, b, c, d,  1,  4, T37, X, t)
    HH(d, a, b, c,  4, 11, T38, X, t)
    HH(c, d, a, b,  7, 16, T39, X, t)
    HH(b, c, d, a, 10, 23, T40, X, t)
    HH(a, b, c, d, 13,  4, T41, X, t)
    HH(d, a, b, c,  0, 11, T42, X, t)
    HH(c, d, a, b,  3, 16, T43, X, t)
    HH(b, c, d, a,  6, 23, T44, X, t)
    HH(a, b, c, d,  9,  4, T45, X, t)
    HH(d, a, b, c, 12, 11, T46, X, t)
    HH(c, d, a, b, 15, 16, T47, X, t)
    HH(b, c, d, a,  2, 23, T48, X, t)

    // Round 4.
    II(a, b, c, d,  0,  6, T49, X, t)
    II(d, a, b, c,  7, 10, T50, X, t)
    II(c, d, a, b, 14, 15, T51, X, t)
    II(b, c, d, a,  5, 21, T52, X, t)
    II(a, b, c, d, 12,  6, T53, X, t)
    II(d, a, b, c,  3, 10, T54, X, t)
    II(c, d, a, b, 10, 15, T55, X, t)
    II(b, c, d, a,  1, 21, T56, X, t)
    II(a, b, c, d,  8,  6, T57, X, t)
    II(d, a, b, c, 15, 10, T58, X, t)
    II(c, d, a, b,  6, 15, T59, X, t)
    II(b, c, d, a, 13, 21, T60, X, t)
    II(a, b, c, d,  4,  6, T61, X, t)
    II(d, a, b, c, 11, 10, T62, X, t)
    II(c, d, a, b,  2, 15, T63, X, t)
    II(b, c, d, a,  9, 21, T64, X, t)

    // Then perform the following additions. (That is increment each
    // of the four registers by the value it had before this block
    // was started.
    state.abcd[1] = state.abcd[1] + a
    state.abcd[2] = state.abcd[2] + b
    state.abcd[3] = state.abcd[3] + c
    state.abcd[4] = state.abcd[4] + d
}


//------------------------------------------------------------------
// F, G, H, and I are basic MD5 functions.
//------------------------------------------------------------------
define_function long F(long x, long y, long z) { return (((x) & (y)) | (~(x) & (z))) }
define_function long G(long x, long y, long z) { return (((x) & (z)) | ((y) & ~(z))) }
define_function long H(long x, long y, long z) { return ((x) ^ (y) ^ (z))            }
define_function long I(long x, long y, long z) { return ((y) ^ ((x) | ~(z)))         }


//------------------------------------------------------------------
// FF, GG, HH, and II transformations for rounds 1, 2, 3, and 4.
// Rotation is separate from addition to prevent recomputation.
//------------------------------------------------------------------
define_function long FF(long a, long b, long c, long d, long k, long s, long Ti, long X[16], long t) {
    k++
    t = a + F(b, c, d) + X[k] + Ti
    a = NAVBinaryRotateLeft(t, s) + b
}


define_function long GG(long a, long b, long c, long d, long k, long s, long Ti, long X[16], long t) {
    k++
    t = a + G(b, c, d) + X[k] + Ti
    a = NAVBinaryRotateLeft(t, s) + b
}


define_function long HH(long a, long b, long c, long d, long k, long s, long Ti, long X[16], long t) {
    k++
    t = a + H(b, c, d) + X[k] + Ti
    a = NAVBinaryRotateLeft(t, s) + b
}


define_function long II(long a, long b, long c, long d, long k, long s, long Ti, long X[16], long t) {
    k++
    t = a + I(b, c, d) + X[k] + Ti
    a = NAVBinaryRotateLeft(t, s) + b
}


#END_IF // __NAV_FOUNDATION_CRYPTOGRAPHY_MD5__
