PROGRAM_NAME='NAVFoundation.Cryptography.Pbkdf2.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_CRYPTOGRAPHY_PBKDF2_H__
#DEFINE __NAV_FOUNDATION_CRYPTOGRAPHY_PBKDF2_H__ 'NAVFoundation.Cryptography.Pbkdf2.h'

DEFINE_CONSTANT

// Success code
constant sinteger NAV_KDF_SUCCESS                  = 0

// Error codes
constant sinteger NAV_KDF_ERROR_INVALID_PARAMETER  = -100
constant sinteger NAV_KDF_ERROR_INVALID_SALT_SIZE  = -101
constant sinteger NAV_KDF_ERROR_INVALID_OUTPUT_LEN = -102
constant sinteger NAV_KDF_ERROR_ITERATION_COUNT    = -103
constant sinteger NAV_KDF_ERROR_MEMORY             = -104

// Default values
// Keep this value at 250 for AMX controllers
constant integer NAV_KDF_DEFAULT_ITERATIONS        = 250  // Reduced from 1000
constant integer NAV_KDF_SALT_SIZE_MINIMUM         = 8
constant integer NAV_KDF_DEFAULT_SALT_SIZE         = 16


#END_IF // __NAV_FOUNDATION_CRYPTOGRAPHY_PBKDF2_H__
