PROGRAM_NAME='NAVFoundation.ComSpec.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_COMSPEC_H__
#DEFINE __NAV_FOUNDATION_COMSPEC_H__ 'NAVFoundation.ComSpec.h'


DEFINE_TYPE

/**
 * @struct _NAVComSpec
 * @description Communication specification structure for configuring AMX serial port settings.
 * Provides a comprehensive interface for setting baud rate, data bits, parity, stop bits,
 * RS-232/422/485 modes, character pacing, flow control, and 9-bit mode.
 *
 * @property {integer} Baud - Baud rate (150, 300, 600, 1200, 2400, 4800, 9600, 19200, 38400, 57600, 76800, 115200)
 * @property {integer} DataBits - Number of data bits (8 for standard, 9 for B9Mode only)
 * @property {integer} StopBits - Number of stop bits (1 or 2)
 * @property {char} Parity - Parity setting: 'N' (none), 'E' (even), 'O' (odd), 'M' (mark), 'S' (space)
 * @property {char} Rs485 - Enable RS-485 mode (true/false). Cannot be set with Rs422
 * @property {char} Rs422 - Enable RS-422 mode (true/false). Cannot be set with Rs485
 * @property {integer} CharDelay - Character delay in 100-microsecond increments (0-65535). Cannot be used with CharDelayMs
 * @property {long} CharDelayMs - Character delay in millisecond increments (0-4294967295). Cannot be used with CharDelay
 * @property {char} HardFlowControl - Enable hardware handshaking (true/false)
 * @property {char} SoftFlowControl - Enable software handshaking (true/false)
 * @property {char} B9Mode - Enable 9-bit mode (true/false). When enabled, forces N,9,1 (no parity, 9 data bits, 1 stop bit)
 *
 * @note When B9Mode is true, the only valid combination is N,9,1 (no parity, 9 data bits, 1 stop bit)
 * @note Rs485 and Rs422 cannot both be true simultaneously
 * @note CharDelay and CharDelayMs cannot both be non-zero simultaneously
 *
 * @example
 * stack_var _NAVComSpec spec
 * NAVComSpecInit(spec)
 * spec.Baud = 115200
 * spec.HardFlowControl = true
 * NAVComSpecApply(dvSerialPort, spec)
 */
struct _NAVComSpec {
    integer Baud
    integer DataBits
    integer StopBits
    char Parity
    char Rs485
    char Rs422

    // Pacing
    integer CharDelay  // Microsecond delay in 100-microsecond increments (e.g. 1 = 100 microseconds, 10 = 1 millisecond)
    long CharDelayMs   // Millisecond delay in 1-millisecond increments (e.g. 1 = 1 millisecond, 10 = 10 milliseconds)

    // Flow Control
    char HardFlowControl  // Flag for hardware flow control (false=no, true=yes)
    char SoftFlowControl  // Flag for software flow control (false=no, true=yes)

    // 9-bit mode (rarely used - forces N,9,1 configuration)
    char B9Mode  // Flag for B9 mode (false=no, true=yes)
}


#END_IF // __NAV_FOUNDATION_COMSPEC_H__
