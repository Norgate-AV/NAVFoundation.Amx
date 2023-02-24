PROGRAM_NAME='NAVFoundation.BinaryUtils'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Solutions Ltd

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

#IF_NOT_DEFINED __NAV_FOUNDATION_BINARYUTILS__
#DEFINE __NAV_FOUNDATION_BINARYUTILS__


define_function char[NAV_MAX_BUFFER] NAVCharToDecimalBinaryString(char value) {
    stack_var integer msb
    stack_var integer lsb
    stack_var char binary[8]

    msb = value / $10
    lsb = value % $10

    switch (msb) {
        case $00: binary = "0,0,0,0"
        case $01: binary = "0,0,0,1"
        case $02: binary = "0,0,1,0"
        case $03: binary = "0,0,1,1"
        case $04: binary = "0,1,0,0"
        case $05: binary = "0,1,0,1"
        case $06: binary = "0,1,1,0"
        case $07: binary = "0,1,1,1"
        case $08: binary = "1,0,0,0"
        case $09: binary = "1,0,0,1"
        case $0A: binary = "1,0,1,0"
        case $0B: binary = "1,0,1,1"
        case $0C: binary = "1,1,0,0"
        case $0D: binary = "1,1,0,1"
        case $0E: binary = "1,1,1,0"
        case $0F: binary = "1,1,1,1"
    }

    switch (lsb) {
        case $00: binary = "binary,0,0,0,0"
        case $01: binary = "binary,0,0,0,1"
        case $02: binary = "binary,0,0,1,0"
        case $03: binary = "binary,0,0,1,1"
        case $04: binary = "binary,0,1,0,0"
        case $05: binary = "binary,0,1,0,1"
        case $06: binary = "binary,0,1,1,0"
        case $07: binary = "binary,0,1,1,1"
        case $08: binary = "binary,1,0,0,0"
        case $09: binary = "binary,1,0,0,1"
        case $0A: binary = "binary,1,0,1,0"
        case $0B: binary = "binary,1,0,1,1"
        case $0C: binary = "binary,1,1,0,0"
        case $0D: binary = "binary,1,1,0,1"
        case $0E: binary = "binary,1,1,1,0"
        case $0F: binary = "binary,1,1,1,1"
    }

    return binary
}


define_function long NAVDecimalToBinary(integer value) {
    stack_var long result
    stack_var char x
    stack_var char j

    result = 0

    for (x = 16; x; x--) {
        for (j = 0; j < 5; j++) {
            if ((result >> (4 * j) & $0F) > 4) {
                result = result + (3 << (4 * j))
            }
        }

        result = result << 1 | (value >> (x - 1) & 1)
    }

    return result
}


define_function char[NAV_MAX_BUFFER] NAVCharToAsciiBinaryString(integer value) {
    stack_var integer msb
    stack_var integer lsb
    stack_var char binary[8]

    msb = value / $10
    lsb = value % $10

    switch (msb) {
        case $00: binary = "'0000'"
        case $01: binary = "'0001'"
        case $02: binary = "'0010'"
        case $03: binary = "'0011'"
        case $04: binary = "'0100'"
        case $05: binary = "'0101'"
        case $06: binary = "'0110'"
        case $07: binary = "'0111'"
        case $08: binary = "'1000'"
        case $09: binary = "'1001'"
        case $0A: binary = "'1010'"
        case $0B: binary = "'1011'"
        case $0C: binary = "'1100'"
        case $0D: binary = "'1101'"
        case $0E: binary = "'1110'"
        case $0F: binary = "'1111'"
    }

    switch (lsb) {
        case $00: binary = "binary,'0000'"
        case $01: binary = "binary,'0001'"
        case $02: binary = "binary,'0010'"
        case $03: binary = "binary,'0011'"
        case $04: binary = "binary,'0100'"
        case $05: binary = "binary,'0101'"
        case $06: binary = "binary,'0110'"
        case $07: binary = "binary,'0111'"
        case $08: binary = "binary,'1000'"
        case $09: binary = "binary,'1001'"
        case $0A: binary = "binary,'1010'"
        case $0B: binary = "binary,'1011'"
        case $0C: binary = "binary,'1100'"
        case $0D: binary = "binary,'1101'"
        case $0E: binary = "binary,'1110'"
        case $0F: binary = "binary,'1111'"
    }

    return binary
}


#END_IF // __NAV_FOUNDATION_BINARYUTILS__
