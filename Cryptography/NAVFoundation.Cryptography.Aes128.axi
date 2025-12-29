PROGRAM_NAME='NAVFoundation.Cryptography.Aes128'

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

/*
Based on tiny-AES-c
https://github.com/kokke/tiny-AES-c
Adapted for NetLinx. Implements only AES-128-EBC currently.
*/

#IF_NOT_DEFINED __NAV_FOUNDATION_CRYPTOGRAPHY_AES128__
#DEFINE __NAV_FOUNDATION_CRYPTOGRAPHY_AES128__ 'NAVFoundation.Cryptography.Aes128'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Aes128.h.axi'
#include 'NAVFoundation.Cryptography.Pbkdf2.axi'


DEFINE_CONSTANT

// Core AES constants
constant integer Nb = 4    // Number of columns in AES state (always 4 for AES)
constant integer Nk = 4    // Number of 32-bit words in key (4 for AES-128)
constant integer Nr = 10   // Number of rounds (10 for AES-128)


/**
 * @function NAVAes128GetSboxValue
 * @internal
 * @description Retrieves the substitution value for a byte from the S-box.
 *
 * @param {char} box - Input byte to substitute
 *
 * @returns {char} Substituted value from the S-box
 */
define_function char NAVAes128GetSboxValue(char box) {
    return SBOX[box + 1]
}


/**
 * @function NAVAes128KeyExpansion
 * @internal
 * @description Expands a 16-byte AES key into the round key schedule.
 * This produces the round keys used in each round of encryption/decryption.
 *
 * @param {char[]} roundKey - Output buffer for expanded key schedule (176 bytes)
 * @param {char[]} key - Input 16-byte AES key
 *
 * @returns {void}
 *
 * @note This is an internal function used by NAVAes128ContextInit
 * @see NAVAes128ContextInit
 */
define_function NAVAes128KeyExpansion(char roundKey[], char key[]) {
    stack_var integer i
    stack_var integer j
    stack_var integer k
    stack_var char tempa[4] // Used for the column/row operations

    // The first round key is the key itself.
    for (i = 0; i < Nk; i++) {
        roundKey[(i * 4) + 1] = key[(i * 4) + 1]
        roundKey[(i * 4) + 2] = key[(i * 4) + 2]
        roundKey[(i * 4) + 3] = key[(i * 4) + 3]
        roundKey[(i * 4) + 4] = key[(i * 4) + 4]
    }

    // All other round keys are found from the previous round keys.
    for (i = Nk; i < Nb * (Nr + 1); i++) {
        {
            k = (i - 1) * 4
            tempa[1] = roundKey[k + 1]
            tempa[2] = roundKey[k + 2]
            tempa[3] = roundKey[k + 3]
            tempa[4] = roundKey[k + 4]
        }

        if (i % Nk == 0) {
            // This function shifts the 4 bytes in a word to the left once.
            // [a0, a1, a2, a3] becomes [a1, a2, a3, a0]

            // Function RotWord()
            {
                stack_var char temp

                temp = tempa[1]
                tempa[1] = tempa[2]
                tempa[2] = tempa[3]
                tempa[3] = tempa[4]
                tempa[4] = temp
            }

            // SubWord() is a function that takes a four-byte input word and
            // applies the S-box to each of the four bytes to produce an output word.

            // Function SubWord()
            {
                tempa[1] = NAVAes128GetSboxValue(tempa[1])
                tempa[2] = NAVAes128GetSboxValue(tempa[2])
                tempa[3] = NAVAes128GetSboxValue(tempa[3])
                tempa[4] = NAVAes128GetSboxValue(tempa[4])
            }

            tempa[1] = tempa[1] ^ RCON[((i / Nk) + 1)]
        }

        if (i % Nk == 4) {
            // Function SubWord()
            {
                tempa[1] = NAVAes128GetSboxValue(tempa[1])
                tempa[2] = NAVAes128GetSboxValue(tempa[2])
                tempa[3] = NAVAes128GetSboxValue(tempa[3])
                tempa[4] = NAVAes128GetSboxValue(tempa[4])
            }
        }

        j = i * 4
        k = (i - Nk) * 4

        roundKey[j + 1] = roundKey[k + 1] ^ tempa[1]
        roundKey[j + 2] = roundKey[k + 2] ^ tempa[2]
        roundKey[j + 3] = roundKey[k + 3] ^ tempa[3]
        roundKey[j + 4] = roundKey[k + 4] ^ tempa[4]
    }
}


/**
 * @function NAVAes128ContextInit
 * @public
 * @description Initializes an AES context with a 16-byte encryption key.
 * This must be called before any encryption or decryption operations.
 *
 * @param {_NAVAesContext} context - AES context structure to initialize
 * @param {char[]} key - 16-byte (128-bit) encryption key
 *
 * @returns {sinteger} NAV_AES_SUCCESS on success, or an error code on failure
 *
 * @example
 * stack_var _NAVAesContext context
 * stack_var char key[16]
 * stack_var sinteger result
 *
 * // Initialize with a key
 * key = "$00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F"
 * result = NAVAes128ContextInit(context, key)
 *
 * @note The context contains the expanded key schedule needed for encryption/decryption
 * @see NAVAes128ECBEncrypt
 * @see NAVAes128ECBDecrypt
 */
define_function sinteger NAVAes128ContextInit(_NAVAesContext context, char key[]) {
    if (length_array(key) != 16) {
        return NAV_AES_ERROR_INVALID_KEY_LENGTH
    }

    NAVAes128KeyExpansion(context.RoundKey, key)
    return NAV_AES_SUCCESS
}


/**
 * @function NAVAes128SetKey
 * @public
 * @description Sets both the encryption key and initialization vector for an AES context.
 * This is primarily for use with CBC mode (future implementation).
 *
 * @param {_NAVAesContext} context - AES context to modify
 * @param {char[]} key - 16-byte (128-bit) encryption key
 * @param {char[]} iv - 16-byte initialization vector (for CBC mode)
 *
 * @returns {void}
 *
 * @note For ECB mode, the IV is ignored but should still be valid
 * @see NAVAes128ContextInit
 */
define_function NAVAes128SetKey(_NAVAesContext context, char key[], char iv[]) {
    NAVAes128KeyExpansion(context.RoundKey, key)
    NAVAes128SetIv(context, iv)
}


/**
 * @function NAVAes128SetIv
 * @public
 * @description Sets the initialization vector for an AES context.
 * This is used for CBC mode (future implementation).
 *
 * @param {_NAVAesContext} context - AES context to modify
 * @param {char[]} iv - 16-byte initialization vector
 *
 * @returns {void}
 */
define_function NAVAes128SetIv(_NAVAesContext context, char iv[]) {
    stack_var integer i

    for (i = 0; i < AES_BLOCK_LENGTH; i++) {
        context.Iv[(i + 1)] = iv[(i + 1)]
    }
}


/**
 * @function NAVAes128AddRoundKey
 * @internal
 * @description Adds (XORs) the round key to the state matrix.
 *
 * @param {char} round - The current round number (0-10)
 * @param {char[4][4]} state - The AES state matrix to modify
 * @param {char[]} roundKey - The expanded round key schedule (176 bytes)
 *
 * @returns {void}
 */
define_function NAVAes128AddRoundKey(char round, char state[4][4], char roundKey[]) {
    stack_var integer i, j
    stack_var integer base
    stack_var integer index

    // Calculate base index for this round's key
    base = round * Nb * 4

    // Process column by column to match AES specification
    for (j = 1; j <= 4; j++) {         // Column index
        for (i = 1; i <= 4; i++) {     // Row index
            // Column-major indexing for round key bytes
            index = base + ((j - 1) * 4) + (i - 1) + 1
            state[i][j] = state[i][j] ^ roundKey[index]
        }
    }
}


/**
 * @function NAVAes128SubBytes
 * @internal
 * @description Substitutes each byte in the state matrix with its corresponding S-box value.
 * This provides the non-linearity in the AES cipher.
 *
 * @param {char[4][4]} state - The AES state matrix to transform
 *
 * @returns {void}
 */
define_function NAVAes128SubBytes(char state[4][4]) {
    stack_var integer i
    stack_var integer j

    for (i = 0; i < 4; i++) {
        for (j = 0; j < 4; j++) {
            state[(i + 1)][(j + 1)] = NAVAes128GetSboxValue(state[(i + 1)][(j + 1)])
        }
    }
}


/**
 * @function NAVAes128ShiftRows
 * @internal
 * @description Shifts the rows of the state matrix to provide diffusion.
 * Row 1 is unchanged, row 2 shifts left by 1, row 3 by 2, and row 4 by 3.
 *
 * @param {char[4][4]} state - The AES state matrix to transform
 *
 * @returns {void}
 */
define_function NAVAes128ShiftRows(char state[4][4]) {
    stack_var char temp

    // Row 1: no shift
    // Row 2: shift 1 position left
    temp = state[2][1]
    state[2][1] = state[2][2]
    state[2][2] = state[2][3]
    state[2][3] = state[2][4]
    state[2][4] = temp

    // Row 3: shift 2 positions left
    temp = state[3][1]
    state[3][1] = state[3][3]
    state[3][3] = temp
    temp = state[3][2]
    state[3][2] = state[3][4]
    state[3][4] = temp

    // Row 4: shift 3 positions left
    temp = state[4][4]
    state[4][4] = state[4][3]
    state[4][3] = state[4][2]
    state[4][2] = state[4][1]
    state[4][1] = temp
}


/**
 * @function NAVAes128xtime
 * @internal
 * @description Performs the xtime operation used in Galois field multiplication.
 * This implements the polynomial multiplication by x in GF(2^8).
 *
 * @param {char} x - Byte value to transform
 *
 * @returns {char} Result of xtime operation
 */
define_function char NAVAes128xtime(char x) {
    return type_cast((x << 1) ^ (((x >> 7) & 1) * $1B))
}


/**
 * @function NAVAes128MixColumns
 * @internal
 * @description Mixes the columns of the state matrix to provide diffusion.
 * Each column is treated as a polynomial over GF(2^8) and multiplied with
 * a fixed polynomial a(x) = {03}x^3 + {01}x^2 + {01}x + {02}.
 *
 * @param {char[4][4]} state - The AES state matrix to transform
 *
 * @returns {void}
 */
define_function NAVAes128MixColumns(char state[4][4]) {
    stack_var integer j
    stack_var char tmp, tm, t

    // Process each column (j is column index)
    for (j = 1; j <= 4; j++) {
        t = state[1][j]

        tmp = state[1][j] ^
              state[2][j] ^
              state[3][j] ^
              state[4][j]

        tm = state[1][j] ^ state[2][j]
        tm = NAVAes128xtime(tm)
        state[1][j] = state[1][j] ^ tm ^ tmp

        tm = state[2][j] ^ state[3][j]
        tm = NAVAes128xtime(tm)
        state[2][j] = state[2][j] ^ tm ^ tmp

        tm = state[3][j] ^ state[4][j]
        tm = NAVAes128xtime(tm)
        state[3][j] = state[3][j] ^ tm ^ tmp

        tm = state[4][j] ^ t
        tm = NAVAes128xtime(tm)
        state[4][j] = state[4][j] ^ tm ^ tmp
    }
}


/**
 * @function NAVAes128Multiply
 * @internal
 * @description Multiplies two numbers in the GF(2^8) finite field.
 * This is used in the MixColumns and InvMixColumns transformations.
 *
 * @param {char} x - First byte to multiply
 * @param {char} y - Second byte to multiply
 *
 * @returns {char} Result of the multiplication in GF(2^8)
 */
define_function char NAVAes128Multiply(char x, char y) {
    stack_var char result
    stack_var char powers[8]  // Store all powers of x
    stack_var integer i

    // Pre-calculate all powers of x
    powers[1] = x            // x^1
    for (i = 2; i <= 8; i++) {
        powers[i] = NAVAes128xtime(powers[i-1])  // x^2 through x^8
    }

    result = 0
    // Use pre-calculated powers instead of calculating them each time
    for (i = 0; i < 8; i++) {
        if (!(y & (1 << i))) {
            continue
        }

        result = result ^ powers[i+1]
    }

    return result
}


/**
 * @function NAVAes128GetSboxInvert
 * @internal
 * @description Retrieves the inverse substitution value for a byte from the inverse S-box.
 *
 * @param {char} box - Input byte to substitute
 *
 * @returns {char} Inverse substituted value from the R-box
 */
define_function char NAVAes128GetSboxInvert(char box) {
    return RSBOX[box + 1]
}


/**
 * @function NAVAes128InvMixColumns
 * @internal
 * @description Performs the inverse MixColumns transformation on the state matrix.
 * This is used during decryption to revert the MixColumns transformation.
 *
 * @param {char[4][4]} state - The AES state matrix to transform
 *
 * @returns {void}
 */
define_function NAVAes128InvMixColumns(char state[4][4]) {
    stack_var integer j
    stack_var char a, b, c, d

    // Process each column (j is column index)
    for (j = 1; j <= 4; j++) {
        a = state[1][j]
        b = state[2][j]
        c = state[3][j]
        d = state[4][j]

        state[1][j] = NAVAes128Multiply(a, $0E) ^ NAVAes128Multiply(b, $0B) ^ NAVAes128Multiply(c, $0D) ^ NAVAes128Multiply(d, $09)
        state[2][j] = NAVAes128Multiply(a, $09) ^ NAVAes128Multiply(b, $0E) ^ NAVAes128Multiply(c, $0B) ^ NAVAes128Multiply(d, $0D)
        state[3][j] = NAVAes128Multiply(a, $0D) ^ NAVAes128Multiply(b, $09) ^ NAVAes128Multiply(c, $0E) ^ NAVAes128Multiply(d, $0B)
        state[4][j] = NAVAes128Multiply(a, $0B) ^ NAVAes128Multiply(b, $0D) ^ NAVAes128Multiply(c, $09) ^ NAVAes128Multiply(d, $0E)
    }
}


/**
 * @function NAVAes128InvSubBytes
 * @internal
 * @description Applies the inverse S-box substitution to each byte in the state matrix.
 * This is used during decryption to revert the SubBytes transformation.
 *
 * @param {char[4][4]} state - The AES state matrix to transform
 *
 * @returns {void}
 */
define_function NAVAes128InvSubBytes(char state[4][4]) {
    stack_var integer i, j

    // This matches the original tiny-AES-c access pattern
    for (i = 0; i < 4; i++) {  // Column index in original code
        for (j = 0; j < 4; j++) {  // Row index in original code
            // Access as [row][column] with NetLinx 1-based adjustment
            state[(j + 1)][(i + 1)] = NAVAes128GetSboxInvert(state[(j + 1)][(i + 1)])
        }
    }
}


/**
 * @function NAVAes128InvShiftRows
 * @internal
 * @description Performs the inverse ShiftRows transformation on the state matrix.
 * This is used during decryption to revert the ShiftRows transformation.
 *
 * @param {char[4][4]} state - The AES state matrix to transform
 *
 * @returns {void}
 */
define_function NAVAes128InvShiftRows(char state[4][4]) {
    stack_var char temp

    // Row 1: no shift (remains unchanged)

    // Row 2: shift 1 position right
    temp = state[2][4]
    state[2][4] = state[2][3]
    state[2][3] = state[2][2]
    state[2][2] = state[2][1]
    state[2][1] = temp

    // Row 3: shift 2 positions right (same as 2 left)
    temp = state[3][1]
    state[3][1] = state[3][3]
    state[3][3] = temp
    temp = state[3][2]
    state[3][2] = state[3][4]
    state[3][4] = temp

    // Row 4: shift 3 positions right
    temp = state[4][1]
    state[4][1] = state[4][2]
    state[4][2] = state[4][3]
    state[4][3] = state[4][4]
    state[4][4] = temp
}


/**
 * @function NAVAes128Cipher
 * @internal
 * @description Performs the main AES encryption operation on a single state matrix.
 * This implements the core AES algorithm to transform plaintext into ciphertext.
 *
 * @param {char[4][4]} state - The AES state matrix to encrypt
 * @param {char[]} roundKey - The expanded key schedule (176 bytes)
 *
 * @returns {void}
 *
 * @note This operates on a single 16-byte block and does not handle padding
 */
define_function NAVAes128Cipher(char state[4][4], char roundKey[]) {
    stack_var char round

    // Add the First round key to the state before starting the rounds.
    NAVAes128AddRoundKey(0, state, roundKey)

    // There will be Nr rounds.
    // The first Nr-1 rounds are identical.
    // These Nr-1 rounds are executed in the loop below.
    // Last one without MixColumns()
    for (round = 1; ; round++) {
        NAVAes128SubBytes(state)
        NAVAes128ShiftRows(state)

        if (round == Nr) {
            break
        }

        NAVAes128MixColumns(state)
        NAVAes128AddRoundKey(round, state, roundKey)
    }

    // Add round key to last round
    NAVAes128AddRoundKey(Nr, state, roundKey)
}


/**
 * @function NAVAes128InvCipher
 * @internal
 * @description Performs the main AES decryption operation on a single state matrix.
 * This implements the core AES algorithm to transform ciphertext back to plaintext.
 *
 * @param {char[4][4]} state - The AES state matrix to decrypt
 * @param {char[]} roundKey - The expanded key schedule (176 bytes)
 *
 * @returns {void}
 *
 * @note This operates on a single 16-byte block and does not handle padding
 */
define_function NAVAes128InvCipher(char state[4][4], char roundKey[]) {
    stack_var char round

    // Add the First round key to the state before starting the rounds.
    NAVAes128AddRoundKey(Nr, state, roundKey)

    // There will be Nr rounds.
    // The first Nr-1 rounds are identical.
    // These Nr-1 rounds are executed in the loop below.
    // Last one without InvMixColumn()
    for (round = (Nr - 1); ; round--) {
        NAVAes128InvShiftRows(state)
        NAVAes128InvSubBytes(state)
        NAVAes128AddRoundKey(round, state, roundKey)

        if (round == 0) {
            break
        }

        NAVAes128InvMixColumns(state)
    }
}


/**
 * @function NAVAes128BufferToState
 * @internal
 * @description Converts a 16-byte buffer to the AES state matrix format.
 * This follows the AES specification for column-major ordering.
 *
 * @param {char[]} buffer - 16-byte input buffer
 * @param {char[4][4]} state - Output state matrix
 *
 * @returns {void}
 */
define_function NAVAes128BufferToState(char buffer[], char state[4][4]) {
    stack_var integer r, c, idx

    // Fill column by column as per AES spec
    idx = 1
    for (c = 1; c <= 4; c++) {
        for (r = 1; r <= 4; r++) {
            state[r][c] = buffer[idx]
            idx++
        }
    }
}


/**
 * @function NAVAes128StateToBuffer
 * @internal
 * @description Converts an AES state matrix back to a 16-byte buffer.
 * This follows the AES specification for column-major ordering.
 *
 * @param {char[4][4]} state - Input state matrix
 * @param {char[]} buffer - Output buffer (will be set to 16 bytes)
 *
 * @returns {void}
 */
define_function NAVAes128StateToBuffer(char state[4][4], char buffer[]) {
    stack_var integer r, c, idx

    // Read column by column as per AES spec
    idx = 1
    for (c = 1; c <= 4; c++) {
        for (r = 1; r <= 4; r++) {
            buffer[idx] = state[r][c]
            idx++
        }
    }

    set_length_array(buffer, 16)
}


/**
 * @function NAVAes128XorWithIv
 * @internal
 * @description XORs a block with the initialization vector or previous ciphertext block.
 * This is used in CBC mode to chain blocks together.
 *
 * @param {char[]} buf - The buffer to XOR (modified in-place)
 * @param {char[]} iv - The initialization vector or previous block
 *
 * @returns {void}
 */
define_function NAVAes128XorWithIv(char buf[], char iv[]) {
    stack_var integer i

    for (i = 0; i < AES_BLOCK_LENGTH; i++) {
        buf[(i + 1)] = buf[(i + 1)] ^ iv[(i + 1)]
    }
}


/**
 * @function NAVAes128PKCS7Pad
 * @public
 * @description Applies PKCS#7 padding to a buffer to make its length a multiple of 16 bytes.
 * Even if the input is already a multiple of 16, a full block of padding is added.
 *
 * @param {char[]} input - Data to pad
 *
 * @returns {char[]} Padded data
 *
 * @example
 * stack_var char data[10]
 * stack_var char padded[NAV_MAX_BUFFER]
 *
 * data = 'HelloWorld'  // 10 bytes
 * padded = NAVAes128PKCS7Pad(data)  // Results in 16 bytes with padding value 0x06
 *
 * @note Always adds between 1 and 16 bytes of padding
 */
define_function char[NAV_MAX_BUFFER] NAVAes128PKCS7Pad(char input[]) {
    stack_var char output[NAV_MAX_BUFFER]
    stack_var integer paddingLength
    stack_var integer i
    stack_var integer inputLength

    inputLength = length_array(input)
    paddingLength = AES_BLOCK_LENGTH - (inputLength % AES_BLOCK_LENGTH)

    if (paddingLength == 0) {
        paddingLength = AES_BLOCK_LENGTH
    }

    // Copy input
    for (i = 1; i <= inputLength; i++) {
        output[i] = input[i]
    }

    // Add padding
    for (i = 1; i <= paddingLength; i++) {
        output[inputLength + i] = type_cast(paddingLength)
    }

    // Set length of output buffer
    set_length_array(output, inputLength + paddingLength)

    return output
}


/**
 * @function NAVAes128PKCS7Unpad
 * @public
 * @description Removes PKCS#7 padding from a buffer and verifies its integrity.
 * Returns an empty string if the padding is invalid.
 *
 * @param {char[]} buffer - Padded data to process
 *
 * @returns {char[]} Unpadded data, or empty string if padding is invalid
 *
 * @example
 * stack_var char padded[16]
 * stack_var char original[NAV_MAX_BUFFER]
 *
 * // Padded data with padding value 0x06 in the last 6 bytes
 * original = NAVAes128PKCS7Unpad(padded)
 */
define_function char[2048] NAVAes128PKCS7Unpad(char buffer[]) {
    stack_var integer totalLen
    stack_var integer paddingLen
    stack_var integer unpaddedLen
    stack_var integer i
    stack_var char result[2048]

    totalLen = length_array(buffer)

    // Get padding length from last byte
    paddingLen = buffer[totalLen]

    // Verify padding length is valid (1-16)
    if (paddingLen < 1 || paddingLen > 16) {
        return ''
    }

    // Verify all padding bytes have same value
    for (i = totalLen - paddingLen + 1; i <= totalLen; i++) {
        if (buffer[i] != paddingLen) {
            return ''
        }
    }

    // Calculate unpadded length
    unpaddedLen = totalLen - paddingLen

    // Copy unpadded data
    for (i = 1; i <= unpaddedLen; i++) {
        result[i] = buffer[i]
    }

    // Set correct length of result
    set_length_array(result, unpaddedLen)

    return result
}


/**
 * @function NAVAes128ECBEncryptBlock
 * @internal
 * @description Encrypts a single 16-byte block using AES-128 in ECB mode.
 * The buffer is modified in place with the encrypted result.
 *
 * @param {_NAVAesContext} context - Initialized AES context
 * @param {char[]} buffer - 16-byte block to encrypt (modified in-place)
 *
 * @returns {void}
 *
 * @note Does not handle padding or blocks of other sizes
 */
define_function NAVAes128ECBEncryptBlock(_NAVAesContext context, char buffer[]) {
    stack_var char state[4][4]

    NAVAes128BufferToState(buffer, state)
    NAVAes128Cipher(state, context.RoundKey)
    NAVAes128StateToBuffer(state, buffer)
}


/**
 * @function NAVAes128ECBEncrypt
 * @public
 * @description Encrypts data using AES-128 in Electronic Code Book (ECB) mode.
 * Automatically applies PKCS#7 padding to handle data of any length.
 *
 * @param {_NAVAesContext} context - Initialized AES context containing the key schedule
 * @param {char[]} plaintext - Data to encrypt (any length, including empty)
 * @param {char[]} ciphertext - Output buffer to receive encrypted data
 *
 * @returns {sinteger} NAV_AES_SUCCESS on success, or an error code on failure
 *
 * @example
 * stack_var _NAVAesContext context
 * stack_var char plaintext[100]
 * stack_var char ciphertext[200]
 * stack_var sinteger result
 *
 * // Assume context is initialized
 * plaintext = 'Secret message'
 * result = NAVAes128ECBEncrypt(context, plaintext, ciphertext)
 *
 * @note Output length will always be a multiple of 16 bytes
 * @note Even an empty input will produce 16 bytes of output (one block of padding)
 * @note ECB mode should not be used for encrypting more than one block of
 *       sensitive data as it does not hide data patterns
 * @see NAVAes128ContextInit
 * @see NAVAes128ECBDecrypt
 */
define_function sinteger NAVAes128ECBEncrypt(_NAVAesContext context, char plaintext[], char ciphertext[]) {
    stack_var integer i, blocks
    stack_var char block[16]
    stack_var char paddedText[NAV_MAX_BUFFER]

    // Clear output buffer
    set_length_array(ciphertext, 0)

    // Apply PKCS#7 padding to all inputs, including those that are exactly block-sized
    // This follows the PKCS#7 standard which requires a full block of padding
    // when input length is a multiple of block size
    paddedText = NAVAes128PKCS7Pad(plaintext)
    if (length_array(paddedText) == 0) {
        return NAV_AES_ERROR_INVALID_PADDING
    }

    // Allocate properly sized output buffer
    set_length_array(ciphertext, length_array(paddedText))

    // Copy padded text to output
    for (i = 1; i <= length_array(paddedText); i++) {
        ciphertext[i] = paddedText[i]
    }

    blocks = length_array(ciphertext) / AES_BLOCK_LENGTH

    for (i = 0; i < blocks; i++) {
        stack_var integer j
        stack_var integer offset

        offset = i * AES_BLOCK_LENGTH

        // Extract block
        for (j = 1; j <= AES_BLOCK_LENGTH; j++) {
            block[j] = ciphertext[offset + j]
        }

        // Encrypt block in place
        NAVAes128ECBEncryptBlock(context, block)

        // Copy back
        for (j = 1; j <= AES_BLOCK_LENGTH; j++) {
            ciphertext[offset + j] = block[j]
        }
    }

    return NAV_AES_SUCCESS
}


/**
 * @function NAVAes128Encrypt
 * @public
 * @description Legacy wrapper for NAVAes128ECBEncrypt.
 * Provided for backward compatibility.
 *
 * @param {_NAVAesContext} context - Initialized AES context
 * @param {char[]} plaintext - Data to encrypt
 * @param {char[]} ciphertext - Output buffer to receive encrypted data
 *
 * @returns {sinteger} Result from NAVAes128ECBEncrypt
 *
 * @see NAVAes128ECBEncrypt
 */
define_function sinteger NAVAes128Encrypt(_NAVAesContext context, char plaintext[], char ciphertext[]) {
    return NAVAes128ECBEncrypt(context, plaintext, ciphertext)
}


/**
 * @function NAVAes128LogStateMatrix
 * @internal
 * @description Debug helper function to log the contents of an AES state matrix.
 *
 * @param {char[4][4]} state - AES state matrix to log
 *
 * @returns {void}
 *
 * @note This is a debug/diagnostic function not intended for normal operation
 */
define_function NAVAes128LogStateMatrix(char state[4][4]) {
    stack_var char msg[100]
    stack_var integer r, c

    for (r = 1; r <= 4; r++) {
        msg = ''

        for (c = 1; c <= 4; c++) {
            msg = "msg, format('$%02X ', state[r][c])"
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, msg)
    }
}


/**
 * @function NAVAes128ECBDecryptBlock
 * @internal
 * @description Decrypts a single 16-byte block using AES-128 in ECB mode.
 * The buffer is modified in place with the decrypted result.
 *
 * @param {_NAVAesContext} context - Initialized AES context
 * @param {char[]} buffer - 16-byte block to decrypt (modified in-place)
 *
 * @returns {void}
 *
 * @note Does not handle padding or blocks of other sizes
 */
define_function NAVAes128ECBDecryptBlock(_NAVAesContext context, char buffer[]) {
    stack_var char state[4][4]

    NAVAes128BufferToState(buffer, state)
    NAVAes128InvCipher(state, context.RoundKey)
    NAVAes128StateToBuffer(state, buffer)
}


/**
 * @function NAVAes128ECBDecrypt
 * @public
 * @description Decrypts data that was encrypted using AES-128 in ECB mode.
 * Automatically handles PKCS#7 padding verification and removal.
 *
 * @param {_NAVAesContext} context - Initialized AES context (must be the same used for encryption)
 * @param {char[]} ciphertext - Encrypted data (must be a multiple of 16 bytes)
 * @param {char[]} plaintext - Output buffer to receive decrypted data
 *
 * @returns {sinteger} NAV_AES_SUCCESS on success, or an error code on failure
 *
 * @example
 * stack_var _NAVAesContext context
 * stack_var char ciphertext[100]
 * stack_var char plaintext[100]
 * stack_var sinteger result
 *
 * // Assume context is initialized and ciphertext contains encrypted data
 * result = NAVAes128ECBDecrypt(context, ciphertext, plaintext)
 * if (result == NAV_AES_SUCCESS) {
 *     // Use decrypted data in plaintext
 * }
 *
 * @note Empty ciphertext input will produce empty plaintext output
 * @note The function verifies PKCS#7 padding integrity during decryption
 * @see NAVAes128ECBEncrypt
 */
define_function sinteger NAVAes128ECBDecrypt(_NAVAesContext context, char ciphertext[], char plaintext[]) {
    stack_var char decodedText[NAV_MAX_BUFFER]
    stack_var char unpaddedText[NAV_MAX_BUFFER]
    stack_var integer i, blocks

    // Verify parameters
    if (length_array(ciphertext) == 0) {
        set_length_array(plaintext, 0)
        return NAV_AES_SUCCESS // Empty input = empty output, not an error
    }

    // Check if the ciphertext length is a multiple of the block size
    if (length_array(ciphertext) % AES_BLOCK_LENGTH != 0) {
        set_length_array(plaintext, 0)
        return NAV_AES_ERROR_INVALID_BLOCK_LENGTH
    }

    // Allocate space for decryption result
    set_length_array(decodedText, length_array(ciphertext))

    // Copy ciphertext to decodedText for processing
    for (i = 1; i <= length_array(ciphertext); i++) {
        decodedText[i] = ciphertext[i]
    }

    // Calculate number of blocks
    blocks = length_array(ciphertext) / AES_BLOCK_LENGTH

    // Process each block
    for (i = 0; i < blocks; i++) {
        stack_var integer offset
        stack_var char block[16]
        stack_var integer j

        offset = i * AES_BLOCK_LENGTH

        // Create block slice
        for (j = 1; j <= AES_BLOCK_LENGTH; j++) {
            block[j] = decodedText[offset + j]
        }

        // Decrypt block in place
        NAVAes128ECBDecryptBlock(context, block)

        // Copy back to decoded text
        for (j = 1; j <= AES_BLOCK_LENGTH; j++) {
            decodedText[offset + j] = block[j]
        }
    }

    // Remove PKCS#7 padding
    unpaddedText = NAVAes128PKCS7Unpad(decodedText)

    // Special case: We need to distinguish between padding error and empty result
    if (length_array(unpaddedText) == 0) {
        // Check if the padding was valid but produced an empty result
        // In PKCS#7, a valid full block of padding would be 16 bytes all with value 16
        if (length_array(decodedText) == 16) {
            stack_var integer allEqual

            allEqual = true

            for (i = 1; i <= 16; i++) {
                if (decodedText[i] != 16) {
                    allEqual = false
                    break
                }
            }

            if (allEqual) {
                // Valid padding that produced empty result - this is OK
                set_length_array(plaintext, 0)
                return NAV_AES_SUCCESS
            }
        }

        // Otherwise it's an actual padding error
        set_length_array(plaintext, 0)
        return NAV_AES_ERROR_PADDING_VERIFICATION
    }

    // Copy unpaddedText to output
    set_length_array(plaintext, length_array(unpaddedText))
    for (i = 1; i <= length_array(unpaddedText); i++) {
        plaintext[i] = unpaddedText[i]
    }

    return NAV_AES_SUCCESS
}


/**
 * @function NAVAes128Decrypt
 * @public
 * @description Legacy wrapper for NAVAes128ECBDecrypt.
 * Provided for backward compatibility.
 *
 * @param {_NAVAesContext} context - Initialized AES context
 * @param {char[]} ciphertext - Encrypted data
 * @param {char[]} plaintext - Output buffer to receive decrypted data
 *
 * @returns {sinteger} Result from NAVAes128ECBDecrypt
 *
 * @see NAVAes128ECBDecrypt
 */
define_function sinteger NAVAes128Decrypt(_NAVAesContext context, char ciphertext[], char plaintext[]) {
    return NAVAes128ECBDecrypt(context, ciphertext, plaintext)
}


/**
 * @function NAVAes128LogAllRoundKeys
 * @internal
 * @description Debug helper function to log all round keys.
 *
 * @param {char[]} roundKey - The expanded key schedule (176 bytes)
 *
 * @returns {void}
 *
 * @note This is a debug/diagnostic function not intended for normal operation
 */
define_function NAVAes128LogAllRoundKeys(char roundKey[]) {
    stack_var integer round
    stack_var integer start
    stack_var char msg[200]

    for (round = 0; round <= Nr; round++) {
        msg = "'Round ', itoa(round), ' key:'"
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, msg)

        start = round * 16
        msg = ''

        // Print 16 bytes of this round key
        {
            stack_var integer i

            for (i = 1; i <= 16; i++) {
                msg = "msg, format('$%02X ', roundKey[start + i])"
            }
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, msg)
    }
}


/**
 * @function NAVAes128GetError
 * @public
 * @description Converts an AES error code to a human-readable error message.
 *
 * @param {sinteger} error - Error code returned by an AES function
 *
 * @returns {char[100]} Human-readable description of the error
 *
 * @example
 * stack_var sinteger result
 *
 * result = NAVAes128ECBEncrypt(context, plaintext, ciphertext)
 * if (result != NAV_AES_SUCCESS) {
 *     NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Error: ', NAVAes128GetError(result)")
 * }
 */
define_function char[100] NAVAes128GetError(sinteger error) {
    switch (error) {
        case NAV_AES_SUCCESS:                       { return 'Success' }
        case NAV_AES_ERROR_NULL_CONTEXT:            { return 'Null context' }
        case NAV_AES_ERROR_NULL_PARAMETER:          { return 'Null parameter' }
        case NAV_AES_ERROR_MEMORY:                  { return 'Memory error' }
        case NAV_AES_ERROR_INVALID_KEY_LENGTH:      { return 'Invalid key length' }
        case NAV_AES_ERROR_KEY_EXPANSION_FAILED:    { return 'Key expansion failed' }
        case NAV_AES_ERROR_INVALID_BLOCK_LENGTH:    { return 'Invalid block length' }
        case NAV_AES_ERROR_CIPHER_OPERATION:        { return 'Cipher operation error' }
        case NAV_AES_ERROR_INVALID_PADDING:         { return 'Invalid padding' }
        case NAV_AES_ERROR_PADDING_VERIFICATION:    { return 'Padding verification error' }
        case NAV_AES_ERROR_INVALID_IV_LENGTH:       { return 'Invalid IV length' }
        case NAV_AES_ERROR_KEY_DERIVATION_FAILED:   { return 'Key derivation failed' }
        default:                                    { return 'Unknown error' }
    }
}


/**
 * @function NAVAes128DeriveKey
 * @public
 * @description Derives a 16-byte encryption key from a password and salt using PBKDF2-HMAC-SHA1.
 * This provides a secure way to generate encryption keys from user passwords.
 *
 * @param {char[]} password - Password string (any length, must not be empty)
 * @param {char[]} salt - Cryptographic salt (at least 8 bytes recommended)
 * @param {integer} iterations - Number of PBKDF2 iterations (use NAV_KDF_DEFAULT_ITERATIONS if unsure)
 * @param {char[]} key - Output buffer to receive the 16-byte key
 *
 * @returns {sinteger} NAV_AES_SUCCESS on success, or an error code on failure
 *
 * @example
 * stack_var char password[50]
 * stack_var char salt[16]
 * stack_var char key[16]
 * stack_var sinteger result
 *
 * password = 'SecurePassword123'
 * salt = NAVPbkdf2GetRandomSalt(16)
 * result = NAVAes128DeriveKey(password, salt, NAV_KDF_DEFAULT_ITERATIONS, key)
 *
 * @note Higher iteration counts improve security but slow down derivation
 * @note Always use a unique salt for each encryption operation
 * @note Salt should be stored alongside the ciphertext for later decryption
 * @see NAVPbkdf2GetRandomSalt
 */
define_function sinteger NAVAes128DeriveKey(char password[], char salt[], integer iterations, char key[]) {
    stack_var sinteger result

    // Validate parameters
    if (length_array(password) == 0) {
        return NAV_AES_ERROR_NULL_PARAMETER
    }

    // Use the default iterations if not specified
    if (iterations <= 0) {
        iterations = NAV_KDF_DEFAULT_ITERATIONS
    }

    // Ensure output buffer is properly sized
    set_length_array(key, 16)

    // Call the general-purpose key derivation function
    result = NAVPbkdf2Sha1(password, salt, iterations, key, 16)

    // Map PBKDF2 errors to AES errors if needed
    if (result != NAV_KDF_SUCCESS) {
        // Clear key on error
        set_length_array(key, 0)

        // Map errors or just pass through
        switch (result) {
            case NAV_KDF_ERROR_INVALID_PARAMETER:  return NAV_AES_ERROR_NULL_PARAMETER
            case NAV_KDF_ERROR_MEMORY:             return NAV_AES_ERROR_MEMORY
            default:                               return NAV_AES_ERROR_KEY_DERIVATION_FAILED
        }
    }

    return NAV_AES_SUCCESS
}


#END_IF // __NAV_FOUNDATION_CRYPTOGRAPHY_AES128__
