PROGRAM_NAME='NAVFoundation.Cryptography.Pbkdf2.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_CRYPTOGRAPHY_PBKDF2_H__
#DEFINE __NAV_FOUNDATION_CRYPTOGRAPHY_PBKDF2_H__ 'NAVFoundation.Cryptography.Pbkdf2.h'

DEFINE_CONSTANT

/**
 * @constant NAV_KDF_SUCCESS
 * @description Operation completed successfully
 */
constant sinteger NAV_KDF_SUCCESS                  = 0

/**
 * @constant NAV_KDF_ERROR_INVALID_PARAMETER
 * @description A required parameter was null, empty or invalid
 */
constant sinteger NAV_KDF_ERROR_INVALID_PARAMETER  = -100

/**
 * @constant NAV_KDF_ERROR_INVALID_SALT_SIZE
 * @description The salt size is too small (minimum 8 bytes recommended)
 */
constant sinteger NAV_KDF_ERROR_INVALID_SALT_SIZE  = -101

/**
 * @constant NAV_KDF_ERROR_INVALID_OUTPUT_LEN
 * @description The requested output length is invalid (must be positive)
 */
constant sinteger NAV_KDF_ERROR_INVALID_OUTPUT_LEN = -102

/**
 * @constant NAV_KDF_ERROR_ITERATION_COUNT
 * @description The iteration count is invalid (must be at least 1)
 */
constant sinteger NAV_KDF_ERROR_ITERATION_COUNT    = -103

/**
 * @constant NAV_KDF_ERROR_MEMORY
 * @description Memory allocation or buffer size error
 */
constant sinteger NAV_KDF_ERROR_MEMORY             = -104

/**
 * @constant NAV_KDF_DEFAULT_ITERATIONS
 * @description Default number of iterations for PBKDF2
 * @note Set to 250 for AMX controllers due to performance constraints
 * @note Higher values like 1000+ would be more secure but too slow on AMX
 */
constant integer NAV_KDF_DEFAULT_ITERATIONS        = 250

/**
 * @constant NAV_KDF_SALT_SIZE_MINIMUM
 * @description Minimum recommended salt size in bytes
 * @note NIST recommends at least 8 bytes (64 bits) for a salt
 */
constant integer NAV_KDF_SALT_SIZE_MINIMUM         = 8

/**
 * @constant NAV_KDF_DEFAULT_SALT_SIZE
 * @description Default salt size when generating random salt
 * @note 16 bytes (128 bits) provides good security margin
 */
constant integer NAV_KDF_DEFAULT_SALT_SIZE         = 16


#END_IF // __NAV_FOUNDATION_CRYPTOGRAPHY_PBKDF2_H__
