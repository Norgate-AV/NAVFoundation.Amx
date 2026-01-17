PROGRAM_NAME='NAVFoundation.Int64.h'

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
 * @file NAVFoundation.Int64.h.axi
 * @brief Header file defining Int64 structure and constants.
 *
 * This header defines the _NAVInt64 structure used to represent 64-bit integers
 * as a pair of 32-bit values (high and low). The structure and operations have
 * been optimized for use in cryptographic operations like SHA-512.
 *
 * IMPLEMENTATION NOTES:
 * - The _NAVInt64 structure uses Hi and Lo 32-bit parts to represent a 64-bit value
 * - Some operations have precision limitations documented in the implementation file
 * - This library is primarily intended for use in the SHA-512 implementation
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_INT64_H__
#DEFINE __NAV_FOUNDATION_INT64_H__ 'NAVFoundation.Int64.h'

/*
 * Structure definitions
 */
DEFINE_TYPE

/**
 * @struct _NAVInt64
 * @brief Structure to represent a 64-bit integer using two 32-bit parts
 * @member Hi - High 32 bits (most significant)
 * @member Lo - Low 32 bits (least significant)
 */
struct _NAVInt64 {
    long Hi
    long Lo
}

#END_IF // __NAV_FOUNDATION_INT64_H__
