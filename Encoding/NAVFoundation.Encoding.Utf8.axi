PROGRAM_NAME='NAVFoundation.Encoding.Utf8'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_ENCODING_UTF8__
#DEFINE __NAV_FOUNDATION_ENCODING_UTF8__ 'NAVFoundation.Encoding.Utf8'


/**
 * Validates UTF-8 encoding of a byte array.
 *
 * @function NAVEncodingIsValidUtf8
 * @access public
 * @param {char[]} data - Byte array to validate
 * @returns {char} TRUE if data is valid UTF-8, FALSE otherwise
 *
 * @example
 * stack_var char text[100]
 * text = 'Hello, World!'
 *
 * if (NAVEncodingIsValidUtf8(text)) {
 *     // Valid UTF-8
 * }
 *
 * @note Validates UTF-8 encoding according to RFC 3629:
 *       - 1-byte: 0xxxxxxx (ASCII, U+0000 to U+007F)
 *       - 2-byte: 110xxxxx 10xxxxxx (U+0080 to U+07FF)
 *       - 3-byte: 1110xxxx 10xxxxxx 10xxxxxx (U+0800 to U+FFFF)
 *       - 4-byte: 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx (U+10000 to U+10FFFF)
 *
 * @note Detects invalid sequences:
 *       - Invalid start bytes (10xxxxxx or 11111xxx patterns)
 *       - Invalid continuation bytes (not matching 10xxxxxx)
 *       - Overlong encodings (security vulnerability)
 *       - UTF-16 surrogate pairs U+D800 to U+DFFF (invalid in UTF-8)
 *       - Code points beyond U+10FFFF (invalid Unicode)
 *       - Incomplete sequences at buffer end
 *
 * @note RFC 3629 formal UTF-8 definition:
 *       UTF8-octets = *( UTF8-char )
 *       UTF8-char   = UTF8-1 / UTF8-2 / UTF8-3 / UTF8-4
 *       UTF8-1      = %x00-7F
 *       UTF8-2      = %xC2-DF UTF8-tail
 *       UTF8-3      = %xE0 %xA0-BF UTF8-tail / %xE1-EC 2(UTF8-tail) /
 *                     %xED %x80-9F UTF8-tail / %xEE-EF 2(UTF8-tail)
 *       UTF8-4      = %xF0 %x90-BF 2(UTF8-tail) / %xF1-F3 3(UTF8-tail) /
 *                     %xF4 %x80-8F 2(UTF8-tail)
 *       UTF8-tail   = %x80-BF
 */
define_function char NAVEncodingIsValidUtf8(char data[]) {
    stack_var long i
    stack_var long length
    stack_var integer byte1
    stack_var integer byte2
    stack_var integer byte3
    stack_var integer byte4

    length = length_array(data)
    i = 1

    while (i <= length) {
        byte1 = data[i]

        // UTF8-1: 1-byte sequence (0x00-0x7F)
        if (byte1 <= $7F) {
            i = i + 1
        }
        // UTF8-2: 2-byte sequence (0xC2-0xDF + tail)
        else if (byte1 >= $C2 && byte1 <= $DF) {
            if (i + 1 > length) {
                return false  // Incomplete sequence
            }

            byte2 = data[i + 1]

            if (byte2 < $80 || byte2 > $BF) {
                return false  // Invalid continuation byte
            }

            i = i + 2
        }
        // UTF8-3: 3-byte sequences
        else if (byte1 >= $E0 && byte1 <= $EF) {
            if (i + 2 > length) {
                return false  // Incomplete sequence
            }

            byte2 = data[i + 1]
            byte3 = data[i + 2]

            // 0xE0: Second byte must be 0xA0-0xBF (prevents overlong)
            if (byte1 == $E0) {
                if (byte2 < $A0 || byte2 > $BF) {
                    return false
                }
            }
            // 0xED: Second byte must be 0x80-0x9F (prevents surrogates U+D800-U+DFFF)
            else if (byte1 == $ED) {
                if (byte2 < $80 || byte2 > $9F) {
                    return false
                }
            }
            // 0xE1-0xEC, 0xEE-0xEF: Second byte must be 0x80-0xBF
            else {
                if (byte2 < $80 || byte2 > $BF) {
                    return false
                }
            }

            // Third byte must always be 0x80-0xBF
            if (byte3 < $80 || byte3 > $BF) {
                return false
            }

            i = i + 3
        }
        // UTF8-4: 4-byte sequences
        else if (byte1 >= $F0 && byte1 <= $F4) {
            if (i + 3 > length) {
                return false  // Incomplete sequence
            }

            byte2 = data[i + 1]
            byte3 = data[i + 2]
            byte4 = data[i + 3]

            // 0xF0: Second byte must be 0x90-0xBF (prevents overlong)
            if (byte1 == $F0) {
                if (byte2 < $90 || byte2 > $BF) {
                    return false
                }
            }
            // 0xF4: Second byte must be 0x80-0x8F (prevents > U+10FFFF)
            else if (byte1 == $F4) {
                if (byte2 < $80 || byte2 > $8F) {
                    return false
                }
            }
            // 0xF1-0xF3: Second byte must be 0x80-0xBF
            else {
                if (byte2 < $80 || byte2 > $BF) {
                    return false
                }
            }

            // Third and fourth bytes must always be 0x80-0xBF
            if (byte3 < $80 || byte3 > $BF) {
                return false
            }
            if (byte4 < $80 || byte4 > $BF) {
                return false
            }

            i = i + 4
        }
        // Invalid start byte (0x80-0xBF, 0xC0-0xC1, 0xF5-0xFF)
        else {
            return false
        }
    }

    return true
}


#END_IF // __NAV_FOUNDATION_ENCODING_UTF8__
