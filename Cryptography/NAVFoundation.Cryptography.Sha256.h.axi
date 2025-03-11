PROGRAM_NAME='NAVFoundation.Cryptography.Sha256.h'

/**
 * @file NAVFoundation.Cryptography.Sha256.h.axi
 * @brief Header file for the NAVFoundation SHA-256 implementation.
 *
 * This file defines the constants, structures, and types needed for the SHA-256
 * cryptographic hash function implementation.
 *
 * @copyright 2023 Norgate AV Services Limited
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_CRYPTOGRAPHY_SHA256_H__
#DEFINE __NAV_FOUNDATION_CRYPTOGRAPHY_SHA256_H__ 'NAVFoundation.Cryptography.Sha256.h'


DEFINE_CONSTANT

/**
 * Constants for SHA-256 algorithm
 */
/**
 * @constant SHA256_HASH_SIZE
 * @description Size of the SHA-256 hash output in bytes (256 bits = 32 bytes)
 */
constant integer SHA256_HASH_SIZE = 32

/**
 * @constant SHA256_SUCCESS
 * @description Return code indicating operation completed successfully
 */
constant integer SHA256_SUCCESS = 0

/**
 * @constant SHA256_STATE_ERROR
 * @description Return code indicating an error related to incorrect state
 */
constant integer SHA256_STATE_ERROR = 1

/**
 * @constant SHA256_FAILURE
 * @description Return code indicating a general failure
 */
constant integer SHA256_FAILURE = 2

/**
 * @constant SHA256_K
 * @description SHA-256 constants - represent the first 32 bits of the fractional parts
 * of the cube roots of the first 64 primes (2 through 311)
 */
constant long SHA256_K[64] = {
    $428a2f98, $71374491, $b5c0fbcf, $e9b5dba5,
    $3956c25b, $59f111f1, $923f82a4, $ab1c5ed5,
    $d807aa98, $12835b01, $243185be, $550c7dc3,
    $72be5d74, $80deb1fe, $9bdc06a7, $c19bf174,
    $e49b69c1, $efbe4786, $0fc19dc6, $240ca1cc,
    $2de92c6f, $4a7484aa, $5cb0a9dc, $76f988da,
    $983e5152, $a831c66d, $b00327c8, $bf597fc7,
    $c6e00bf3, $d5a79147, $06ca6351, $14292967,
    $27b70a85, $2e1b2138, $4d2c6dfc, $53380d13,
    $650a7354, $766a0abb, $81c2c92e, $92722c85,
    $a2bfe8a1, $a81a664b, $c24b8b70, $c76c51a3,
    $d192e819, $d6990624, $f40e3585, $106aa070,
    $19a4c116, $1e376c08, $2748774c, $34b0bcb5,
    $391c0cb3, $4ed8aa4a, $5b9cca4f, $682e6ff3,
    $748f82ee, $78a5636f, $84c87814, $8cc70208,
    $90befffa, $a4506ceb, $bef9a3f7, $c67178f2
}

/**
 * Type definitions for SHA-256
 */
DEFINE_TYPE

/**
 * @struct _NAVSha256Context
 * @description Context structure for SHA-256 operations
 *
 * The SHA-256 algorithm operates on blocks of 512 bits (64 bytes) and produces
 * a 256-bit (32-byte) hash value. This structure holds the state during the
 * computation process.
 */
struct _NAVSha256Context {
    /**
     * @property {long[8]} IntermediateHash
     * @description The current hash values (8 32-bit words)
     */
    long IntermediateHash[8]

    /**
     * @property {long} LengthHigh
     * @description High 32 bits of message length in bits
     */
    long LengthHigh

    /**
     * @property {long} LengthLow
     * @description Low 32 bits of message length in bits
     */
    long LengthLow

    /**
     * @property {integer} MessageBlockIndex
     * @description Current position in the message block
     */
    integer MessageBlockIndex

    /**
     * @property {char[64]} MessageBlock
     * @description 512-bit message block buffer
     */
    char MessageBlock[64]

    /**
     * @property {integer} Computed
     * @description Flag indicating whether the hash has been computed
     */
    integer Computed

    /**
     * @property {integer} Corrupted
     * @description Error code (0 = no error)
     */
    integer Corrupted
}

#END_IF // __NAV_FOUNDATION_CRYPTOGRAPHY_SHA256_H__
