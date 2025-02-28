PROGRAM_NAME='NAVFoundation.Cryptography.Aes128'

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


define_function char NAVAes128GetSboxValue(char box) {
    return SBOX[box + 1]
}


// This function produces Nb(Nr+1) round keys. The round keys are used in each round to encrypt the states.
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


define_function sinteger NAVAes128ContextInit(_NAVAesContext context, char key[]) {
    if (length_array(key) != 16) {
        return NAV_AES_ERROR_INVALID_KEY_LENGTH
    }

    NAVAes128KeyExpansion(context.RoundKey, key)
    return NAV_AES_SUCCESS
}


define_function NAVAes128SetKey(_NAVAesContext context, char key[], char iv[]) {
    NAVAes128KeyExpansion(context.RoundKey, key)
    NAVAes128SetIv(context, iv)
}


define_function NAVAes128SetIv(_NAVAesContext context, char iv[]) {
    stack_var integer i

    for (i = 0; i < AES_BLOCK_LENGTH; i++) {
        context.Iv[(i + 1)] = iv[(i + 1)]
    }
}


// This function adds the round key to state.
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


// The SubBytes Function Substitutes the values in the
// state matrix with values in an S-box.
define_function NAVAes128SubBytes(char state[4][4]) {
    stack_var integer i
    stack_var integer j

    for (i = 0; i < 4; i++) {
        for (j = 0; j < 4; j++) {
            state[(i + 1)][(j + 1)] = NAVAes128GetSboxValue(state[(i + 1)][(j + 1)])
        }
    }
}


// The ShiftRows() function shifts the rows in the state to the left.
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


define_function char NAVAes128xtime(char x) {
    return type_cast((x << 1) ^ (((x >> 7) & 1) * $1B))
}


// MixColumns function mixes the columns of the state matrix
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


// Multiply is used to multiply numbers in the field GF(2^8)
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


define_function char NAVAes128GetSboxInvert(char box) {
    return RSBOX[box + 1]
}


// MixColumns function mixes the columns of the state matrix.
// The method used to multiply may be difficult to understand for the inexperienced.
// Please use the references to gain more information.
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


// The SubBytes Function Substitutes the values in the
// state matrix with values in an S-box.
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


// Cipher is the main function that encrypts the PlainText.
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


// Convert buffer to AES state matrix - following AES specification
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


// Convert AES state matrix back to buffer - following AES specification
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


// Helper function to XOR blocks
define_function NAVAes128XorWithIv(char buf[], char iv[]) {
    stack_var integer i

    for (i = 0; i < AES_BLOCK_LENGTH; i++) {
        buf[(i + 1)] = buf[(i + 1)] ^ iv[(i + 1)]
    }
}


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


// Core block operation - encrypts a single 16-byte block in place
define_function NAVAes128ECBEncryptBlock(_NAVAesContext context, char buffer[]) {
    stack_var char state[4][4]

    NAVAes128BufferToState(buffer, state)
    NAVAes128Cipher(state, context.RoundKey)
    NAVAes128StateToBuffer(state, buffer)
}


// Higher level function that handles padding and encrypts data using ECB mode
// Returns an error code and updates the ciphertext parameter
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


// For backward compatibility
define_function sinteger NAVAes128Encrypt(_NAVAesContext context, char plaintext[], char ciphertext[]) {
    return NAVAes128ECBEncrypt(context, plaintext, ciphertext)
}


// Add helper function to log state matrix
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


// Core block operation - decrypts a single 16-byte block in place
define_function NAVAes128ECBDecryptBlock(_NAVAesContext context, char buffer[]) {
    stack_var char state[4][4]

    NAVAes128BufferToState(buffer, state)
    NAVAes128InvCipher(state, context.RoundKey)
    NAVAes128StateToBuffer(state, buffer)
}


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


// For backward compatibility
define_function sinteger NAVAes128Decrypt(_NAVAesContext context, char ciphertext[], char plaintext[]) {
    return NAVAes128ECBDecrypt(context, ciphertext, plaintext)
}


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


// AES-specific key derivation function
define_function sinteger NAVAes128DeriveKey(char password[],
                                            char salt[],
                                            integer iterations,
                                            char key[]) {
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
