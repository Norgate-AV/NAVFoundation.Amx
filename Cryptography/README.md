# NAVFoundation.Cryptography

## Overview

The NAVFoundation.Cryptography collection provides essential cryptographic utilities and functions for AMX control systems. These libraries enable secure communication, data protection, and authentication capabilities in your AMX applications.

## Purpose

This collection addresses security requirements in AV control systems by providing cryptographic implementations optimized for the AMX NetLinx environment. The libraries handle important cryptographic tasks such as:

- Secure hashing of data (MD5, SHA1, SHA256, SHA512)
- Encryption and decryption of sensitive information (AES128)
- Password-based key derivation (PBKDF2)

## Available Libraries

The NAVFoundation.Cryptography collection includes the following libraries:

- [Aes128](./NAVFoundation.Cryptography.Aes128.md) - Implementation of 128-bit Advanced Encryption Standard for symmetric encryption
- [Md5](./NAVFoundation.Cryptography.Md5.md) - MD5 message-digest algorithm for cryptographic hashing
- [Pbkdf2](./NAVFoundation.Cryptography.Pbkdf2.md) - Password-Based Key Derivation Function 2 for secure key generation
- [Sha1](./NAVFoundation.Cryptography.Sha1.md) - Secure Hash Algorithm 1 for cryptographic hashing
- [Sha256](./NAVFoundation.Cryptography.Sha256.md) - Secure Hash Algorithm 256 for stronger cryptographic hashing
- [Sha512](./NAVFoundation.Cryptography.Sha512.md) - Secure Hash Algorithm 512 for maximum-strength cryptographic hashing

## Getting Started

To use any of the cryptography libraries in your project, include the specific module header:

```netlinx
#include 'NAVFoundation.Cryptography.Aes128.axi'
```

See the individual library documentation for detailed usage instructions and examples.

## Security Considerations

When implementing cryptographic solutions, be aware of:

- Key management best practices
- Appropriate algorithm selection for your security requirements
- Secure storage of sensitive information
- Regular updates to address security vulnerabilities
- Modern security standards (Note: MD5 and SHA1 are considered cryptographically weak for certain applications)
