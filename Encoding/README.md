# NAVFoundation.Encoding

## Overview

The NAVFoundation.Encoding collection provides data encoding and decoding utilities for AMX control systems. These libraries enable standard-compliant transformation between binary data and text representations, which is essential for data interchange, storage, and transmission in various formats.

## Purpose

This collection addresses common encoding needs in AV control systems by providing implementations of standard encoding schemes optimized for the AMX NetLinx environment. The libraries handle important encoding tasks such as:

- Converting binary data to text representations for transmission in text-based protocols
- Transforming data for compatibility with external systems
- Preparing data for embedding in APIs, configuration files, and other text-based formats
- Working with standardized encoding formats used in authentication systems

## Available Libraries

The NAVFoundation.Encoding collection includes the following libraries:

- [Base64](./NAVFoundation.Encoding.Base64.md) - RFC 4648 compliant Base64 encoding for general purpose binary-to-text encoding
- [Base32](./NAVFoundation.Encoding.Base32.md) - RFC 4648 compliant Base32 encoding with case-insensitive handling for human-readable data

## Getting Started

To use any of the encoding libraries in your project, include the specific module you need:

```netlinx
#include 'NAVFoundation.Encoding.Base64.axi'
```

See the individual library documentation for detailed usage instructions and examples.

## Encoding Selection Guide

When implementing data encoding solutions, consider these factors:

### Base64

- **Best for:** General-purpose binary data encoding
- **Advantages:** Compact representation (33% size increase), widely supported
- **Limitations:** Case-sensitive, includes special characters (+ and /)
- **Common uses:** Email attachments (MIME), embedding binary in JSON/XML, HTTP APIs

### Base32

- **Best for:** Human-readable codes, authentication tokens
- **Advantages:** Case-insensitive, no special characters, avoids ambiguous characters
- **Limitations:** Less compact than Base64 (60% size increase)
- **Common uses:** TOTP/2FA authentication secrets, DNS labels, human-readable identifiers

## Implementation Details

All encoding libraries in this collection:

- Comply with RFC 4648 specifications
- Support both encoding and decoding operations
- Handle whitespace and special characters according to standards
- Properly process binary data including NetLinx's signed byte representations
- Provide comprehensive error handling
- Are thoroughly tested with a variety of input conditions
