# NAVFoundation.ComSpec

The ComSpec library for NAVFoundation provides a simple, clean API for configuring AMX serial port communication settings. It replaces the error-prone manual approach of sending multiple `SEND_COMMAND` strings with a structured, validated configuration interface.

## Overview

Configuring AMX serial ports typically requires sending multiple commands with specific syntax and constraints. This library encapsulates that complexity into two simple functions: one to initialize defaults, and one to apply a configuration structure to a device.

## Features

- **Simple API**: Initialize with defaults, modify as needed, apply to device
- **Comprehensive Validation**: Validates baud rates, parity, data/stop bits, and mode combinations
- **RS-232/422/485 Support**: Configure standard RS-232, RS-422, or RS-485 modes
- **Character Pacing**: Control inter-character delays in microseconds or milliseconds
- **Flow Control**: Hardware and software handshaking configuration
- **9-bit Mode Support**: Handles rare 9-bit mode with automatic constraint enforcement
- **Error Logging**: Integrates with NAVFoundation.ErrorLogUtils for structured error reporting

## Quick Start

### Basic Usage

```netlinx
#include 'NAVFoundation.ComSpec.axi'

DEFINE_EVENT

data_event[5001:1:0] {
    online: {
        stack_var _NAVComSpec spec

        // Initialize with defaults (9600,N,8,1)
        NAVComSpecInit(spec)

        // Customize settings
        spec.Baud = 115200
        spec.HardFlowControl = true

        // Apply to device
        if (!NAVComSpecApply(data.device, spec)) {
            // Configuration failed - check error log
            send_string 0, 'Configuration failed'
        }
    }
}
```

### RS-485 Configuration

```netlinx
stack_var _NAVComSpec spec

NAVComSpecInit(spec)
spec.Baud = 9600
spec.Rs485 = true              // Enable RS-485 mode
spec.CharDelayMs = 10          // 10ms inter-character delay

NAVComSpecApply(5001:2:0, spec)
```

### Custom Configuration

```netlinx
stack_var _NAVComSpec spec

NAVComSpecInit(spec)
spec.Baud = 57600
spec.Parity = 'E'              // Even parity
spec.StopBits = 2              // 2 stop bits
spec.HardFlowControl = true    // Hardware handshaking
spec.CharDelay = 50            // 5ms delay (50 × 100μs)

NAVComSpecApply(dvRS232Device, spec)
```

## Configuration Structure

The `_NAVComSpec` structure contains all serial port configuration options:

### Basic Settings

| Property   | Type    | Valid Values                                                              | Default | Description                           |
| ---------- | ------- | ------------------------------------------------------------------------- | ------- | ------------------------------------- |
| `Baud`     | long    | 150, 300, 600, 1200, 2400, 4800, 9600, 19200, 38400, 57600, 76800, 115200 | 9600    | Baud rate                             |
| `DataBits` | integer | 8, 9                                                                      | 8       | Data bits (9 only valid with B9Mode)  |
| `StopBits` | integer | 1, 2                                                                      | 1       | Stop bits                             |
| `Parity`   | char    | 'N', 'E', 'O', 'M', 'S'                                                   | 'N'     | Parity (None, Even, Odd, Mark, Space) |

### Mode Settings

| Property | Type | Valid Values | Default | Description        |
| -------- | ---- | ------------ | ------- | ------------------ |
| `Rs485`  | char | true/false   | false   | Enable RS-485 mode |
| `Rs422`  | char | true/false   | false   | Enable RS-422 mode |

> **Note**: `Rs485` and `Rs422` cannot both be `true`. When both are `false`, the port operates in standard RS-232 mode.

### Character Pacing

| Property      | Type    | Range        | Default | Description               |
| ------------- | ------- | ------------ | ------- | ------------------------- |
| `CharDelay`   | integer | 0-65535      | 0       | Delay in 100μs increments |
| `CharDelayMs` | long    | 0-4294967295 | 0       | Delay in 1ms increments   |

> **Note**: Only one of `CharDelay` or `CharDelayMs` can be non-zero. Use `CharDelay` for sub-millisecond precision, `CharDelayMs` for millisecond precision.

### Flow Control

| Property          | Type | Valid Values | Default | Description                     |
| ----------------- | ---- | ------------ | ------- | ------------------------------- |
| `HardFlowControl` | char | true/false   | false   | Hardware handshaking (RTS/CTS)  |
| `SoftFlowControl` | char | true/false   | false   | Software handshaking (XON/XOFF) |

### Advanced Settings

| Property | Type | Valid Values | Default | Description                             |
| -------- | ---- | ------------ | ------- | --------------------------------------- |
| `B9Mode` | char | true/false   | false   | 9-bit mode (forces N,9,1 configuration) |

> **Note**: When `B9Mode` is `true`, the configuration is automatically forced to `N,9,1` (no parity, 9 data bits, 1 stop bit) as this is the only valid 9-bit combination.

## API Reference

### NAVComSpecInit

Initializes a `_NAVComSpec` structure with common default values.

**Signature:**

```netlinx
define_function NAVComSpecInit(_NAVComSpec spec)
```

**Parameters:**

- `spec`: The structure to initialize (passed by reference)

**Default Values:**

- Baud: 9600
- DataBits: 8
- StopBits: 1
- Parity: 'N'
- Rs485: false
- Rs422: false
- CharDelay: 0
- CharDelayMs: 0
- HardFlowControl: false
- SoftFlowControl: false
- B9Mode: false

**Example:**

```netlinx
stack_var _NAVComSpec spec
NAVComSpecInit(spec)
```

### NAVComSpecApply

Applies serial port communication settings to a device.

**Signature:**

```netlinx
define_function char NAVComSpecApply(dev device, _NAVComSpec spec)
```

**Parameters:**

- `device`: Target device to configure
- `spec`: Structure containing the serial port settings

**Returns:**

- `true` (1): Settings were applied successfully
- `false` (0): Validation failed or device offline

**Example:**

```netlinx
if (NAVComSpecApply(5001:1:0, spec)) {
    send_string 0, 'Configuration successful'
}
else {
    send_string 0, 'Configuration failed - check diagnostics'
}
```

**Validation:**
The function validates:

- Device is not a socket (device.number != 0)
- Device is online
- Baud rate is valid
- Parity is valid ('N', 'E', 'O', 'M', 'S')
- Data bits are valid (8, or 9 with B9Mode enabled)
- Stop bits are valid (1 or 2)
- Rs485 and Rs422 are not both enabled
- CharDelay and CharDelayMs are not both non-zero

**Commands Sent:**
The function sends the following commands to the device:

1. `SET MODE DATA` - Set port mode (required for IR ports in RS-232 mode)
2. `RXON` - Enable receiving
3. `B9MON` or `B9MOFF` - Configure 9-bit mode
4. `SET BAUD` - Configure baud, parity, data bits, stop bits, and RS-422/485 mode
5. `CHARD` or `CHARDM` - Configure character delay
6. `HSON` or `HSOFF` - Configure hardware handshaking
7. `XON` or `XOFF` - Configure software handshaking

## Common Use Cases

### Simple RS-232 Configuration

Most devices use simple 8-N-1 configuration at various baud rates:

```netlinx
stack_var _NAVComSpec spec

NAVComSpecInit(spec)
spec.Baud = 9600   // or 19200, 38400, 115200, etc.

NAVComSpecApply(dvDevice, spec)
```

### Device Requiring Character Delays

Some older devices require delays between characters:

```netlinx
stack_var _NAVComSpec spec

NAVComSpecInit(spec)
spec.Baud = 9600
spec.CharDelayMs = 5  // 5ms between characters

NAVComSpecApply(dvDevice, spec)
```

### Hardware Flow Control

For devices supporting RTS/CTS flow control:

```netlinx
stack_var _NAVComSpec spec

NAVComSpecInit(spec)
spec.Baud = 115200
spec.HardFlowControl = true

NAVComSpecApply(dvDevice, spec)
```

### RS-485 Multi-drop Network

```netlinx
stack_var _NAVComSpec spec

NAVComSpecInit(spec)
spec.Baud = 9600
spec.Rs485 = true
spec.CharDelayMs = 10

NAVComSpecApply(dvDevice, spec)
```

## Migration from Manual Configuration

### Old Approach

```netlinx
send_command 5001:1:0, 'SET BAUD 115200,N,8,1 485 DISABLE'
send_command 5001:1:0, 'B9MOFF'
send_command 5001:1:0, 'CHARD-0'
send_command 5001:1:0, 'CHARDM-0'
send_command 5001:1:0, 'HSOFF'
```

### New Approach

```netlinx
#include 'NAVFoundation.ComSpec.axi'

stack_var _NAVComSpec spec

NAVComSpecInit(spec)
spec.Baud = 115200

NAVComSpecApply(5001:1:0, spec)
```

Benefits of the new approach:

- Type-safe configuration
- Validation prevents invalid combinations
- Error logging for troubleshooting
- Self-documenting code
- Easier to maintain and modify

## Dependencies

- `NAVFoundation.ErrorLogUtils.axi` - Error logging

## Notes

- The `_NAVSerialPortSettings` struct in `NAVFoundation.Core.h.axi` is now deprecated in favor of `_NAVComSpec`
- 9-bit mode (B9Mode) is rarely used in modern installations. It was historically used for multidrop RS-485 networks but modern protocols typically don't require it.
- When both `CharDelay` and `CharDelayMs` are zero, both commands are sent to ensure the port has zero delay configured.

## License

MIT License - Copyright (c) 2010-2026 Norgate AV
