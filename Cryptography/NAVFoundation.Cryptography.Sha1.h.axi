PROGRAM_NAME='NAVFoundation.Cryptography.Sha1.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_CRYPTOGRAPHY_SHA1_H__
#DEFINE __NAV_FOUNDATION_CRYPTOGRAPHY_SHA1_H__ 'NAVFoundation.Cryptography.Sha1.h'


DEFINE_CONSTANT

/**
 * Constants defined in SHA-1
**/
constant long K[] = {
    $5a827999,
    $6ed9eba1,
    $8f1bbcdc,
    $ca62c1d6
}

constant integer SHA_SUCCESS            = 0
constant integer SHA_NULL               = 1     // Null pointer parameter
constant integer SHA_INPUT_TOO_LONG     = 2     // input data too long
constant integer SHA_STATE_ERROR        = 3     // called Input after Result

constant long SHA1_HASH_SIZE            = 20


DEFINE_TYPE

/**
 * This structure will hold context information for the SHA-1
 * hashing operation
**/
struct _NAVSha1Context {
    // Message Digest
    long IntermediateHash[SHA1_HASH_SIZE / 4]

    // Message length in bits
    long LengthLow
    long LengthHigh

    // Index into message block array
    integer MessageBlockIndex

    // 512-bit message blocks
    char MessageBlock[64]

    // Is the digest computed?
    integer Computed

    // Is the message digest corrupted?
    integer Corrupted
}


#END_IF // __NAV_FOUNDATION_CRYPTOGRAPHY_SHA1_H__
