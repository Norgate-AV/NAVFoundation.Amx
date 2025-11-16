# NAVFoundation.SnapiHelpers

A comprehensive library for working with SNAPI (Standard NetLinx API) protocol commands and device control in AMX NetLinx systems. Provides utility functions for common SNAPI operations, message parsing, and device state management.

## Overview

The SnapiHelpers library provides three main areas of functionality:

1. **Device Control Functions** - High-level functions for common device operations (switching, input selection, power control)
2. **Message Parsing** - Robust parsers for SNAPI command strings with two implementation options:
   - **String-based parser** (`NAVParseSnapiMessage`) - Optimized for performance (~5.5ms avg)
   - **Lexer/Parser** (`NAVSnapiParse`) - Token-based architecture for better debuggability (~18ms avg)
3. **State Management** - Functions to query device feedback channels

## Installation

Include the library in your NetLinx program:

```netlinx
#include 'NAVFoundation.SnapiHelpers.axi'
```

## SNAPI Message Format

SNAPI messages follow this format:
```
COMMAND-param1,param2,"quoted,param"
```

- **Header**: Command name before the first `-`
- **Parameters**: Comma-separated values after the `-`
- **Quoted strings**: Parameters containing commas must be quoted
- **Escaped quotes**: Use `""` to represent a literal quote character

### Examples

```netlinx
'SWITCH-2,1,VID'           // Switch input 2 to output 1, video only
'INPUT-HDMI,1'             // Select HDMI1 input
'PASSTHRU-"Data,Value"'    // Parameter with comma preserved
'POWER-ON'                 // Power on
```

## Public API Functions

### Device Control

#### `NAVSwitch`

Sends a SWITCH command to route inputs to outputs or select an input.

```netlinx
define_function NAVSwitch(dev device, integer input, integer output, integer level)
```

**Parameters:**
- `device` - Target device
- `input` - Input number to switch
- `output` - Output number (use 0 for devices with single output)
- `level` - Switching level:
  - `NAV_SWITCH_LEVEL_VID` (1) - Video only
  - `NAV_SWITCH_LEVEL_AUD` (2) - Audio only
  - `NAV_SWITCH_LEVEL_ALL` (3) - All signals

**Examples:**

```netlinx
// Route input 2 to output 3, video only
NAVSwitch(vdvSwitcher, 2, 3, NAV_SWITCH_LEVEL_VID)

// Select input 2 on device with single output, all signals
NAVSwitch(vdvSwitcher, 2, 0, NAV_SWITCH_LEVEL_ALL)
```

---

#### `NAVInput`

Sends an INPUT command to select an input source.

```netlinx
define_function NAVInput(dev device, char input[])
```

**Parameters:**
- `device` - Target device
- `input` - Input identifier (SNAPI compliant list. HDMI,1; VGA,2; etc.)

**Examples:**

```netlinx
// Select input HDMI 2
NAVInput(vdvDisplay, 'HDMI,2')

// Select input HDMI 1
NAVInput(vdvReceiver, 'HDMI,1')
```

---

#### `NAVInputArray`

Sends an INPUT command to multiple devices simultaneously.

```netlinx
define_function NAVInputArray(dev device[], char input[])
```

**Parameters:**
- `device` - Array of target devices
- `input` - Input identifier (SNAPI compliant list)

**Example:**

```netlinx
stack_var dev displays[2]
displays[1] = vdvDisplay1
displays[2] = vdvDisplay2

// Select input 2 on both displays
NAVInputArray(displays, 'HDMI,2')
```

---

### State Query Functions

#### `NAVGetPower`

Gets the current power state of a device.

```netlinx
define_function integer NAVGetPower(dev device)
```

**Parameters:**
- `device` - Target device

**Returns:** `1` if powered on, `0` if off

**Example:**

```netlinx
if (NAVGetPower(vdvDisplay)) {
    // Device is on
}
```

---

#### `NAVGetVolumeMute`

Gets the current volume mute state of a device.

```netlinx
define_function integer NAVGetVolumeMute(dev device)
```

**Parameters:**
- `device` - Target device

**Returns:** `1` if muted, `0` if unmuted

**Example:**

```netlinx
if (NAVGetVolumeMute(vdvDisplay)) {
    // Volume is muted
}
```

---

### Message Parsing

#### `NAVParseSnapiMessage`

Parses a SNAPI message string into a structured object (string-based implementation).

```netlinx
define_function char NAVParseSnapiMessage(char data[], _NAVSnapiMessage message)
```

**Parameters:**
- `data` - Raw SNAPI message string
- `message` - Message structure to populate (output parameter)

**Returns:** `1` on success, `0` on failure

**Example:**

```netlinx
stack_var _NAVSnapiMessage msg

if (NAVParseSnapiMessage('PASSTHRU-"Some data",123', msg)) {
    // msg.Header = 'PASSTHRU'
    // msg.ParameterCount = 2
    // msg.Parameter[1] = 'Some data'
    // msg.Parameter[2] = '123'
    
    send_string 0, "msg.Header"
    send_string 0, "msg.Parameter[1]"
}
```

**Features:**
- ✅ Handles quoted strings with commas
- ✅ Properly unescapes `""` to `"`
- ✅ Supports empty parameters
- ✅ Handles trailing commas
- ✅ Best performance (~5.5ms average)

---

#### `NAVSnapiParse`

Parses a SNAPI message string using lexer/parser implementation.

```netlinx
define_function char NAVSnapiParse(char data[], _NAVSnapiMessage message)
```

**Parameters:**
- `data` - Raw SNAPI command string
- `message` - Message structure to populate (output parameter)

**Returns:** `1` on success, `0` on failure

**Example:**

```netlinx
stack_var _NAVSnapiMessage msg

if (NAVSnapiParse('INPUT-HDMI,1', msg)) {
    // msg.Header = 'INPUT'
    // msg.ParameterCount = 2
    // msg.Parameter[1] = 'HDMI'
    // msg.Parameter[2] = '1'
}
```

**Features:**
- ✅ Token-based parsing architecture
- ✅ Better debuggability and extensibility
- ✅ Same API as `NAVParseSnapiMessage`
- ⚠️ Slower performance (~18ms average)

**When to use:**
- Use `NAVParseSnapiMessage` for performance-critical applications
- Use `NAVSnapiParse` when you need better architecture, debugging visibility, or plan to extend parsing logic

---

#### `NAVSnapiMessageLog`

Logs the contents of a parsed SNAPI message to the debug console.

```netlinx
define_function NAVSnapiMessageLog(_NAVSnapiMessage message)
```

**Parameters:**
- `message` - Parsed SNAPI message structure

**Example:**

```netlinx
stack_var _NAVSnapiMessage msg
NAVParseSnapiMessage('SWITCH-2,1,VID', msg)
NAVSnapiMessageLog(msg)

// Output:
// Parsed SNAPI Message:
//   Header: SWITCH
//   Parameter Count: 3
//     Parameter 1: 2
//     Parameter 2: 1
//     Parameter 3: VID
```

---

## Data Structures

### `_NAVSnapiMessage`

Represents a parsed SNAPI protocol message.

```netlinx
struct _NAVSnapiMessage {
    char Header[NAV_MAX_SNAPI_MESSAGE_HEADER_LENGTH]        // Command name (max 100 chars)
    char Parameter[NAV_MAX_SNAPI_MESSAGE_PARAMETERS][NAV_MAX_SNAPI_MESSAGE_PARAMETER_LENGTH]  // Parameters (max 20 params × 255 chars)
    integer ParameterCount                                   // Number of parameters
}
```

**Properties:**
- `Header` - Command name (e.g., "SWITCH", "INPUT", "PASSTHRU")
- `Parameter` - Array of parameter values (quotes removed, commas preserved)
- `ParameterCount` - Number of parameters parsed

---

## Constants

### Switching Levels

```netlinx
NAV_SWITCH_LEVEL_VID = 1   // Video only
NAV_SWITCH_LEVEL_AUD = 2   // Audio only
NAV_SWITCH_LEVEL_ALL = 3   // All signals
```

### SNAPI Message Limits

```netlinx
NAV_MAX_SNAPI_MESSAGE_HEADER_LENGTH = 100       // Max command name length
NAV_MAX_SNAPI_MESSAGE_PARAMETER_LENGTH = 255    // Max parameter value length
NAV_MAX_SNAPI_MESSAGE_PARAMETERS = 20           // Max number of parameters
```

### Extended Feedback Channels

```netlinx
NAV_IP_CONNECTED = 301                          // IP connection status
NAV_INPUT_1_SIGNAL = 401                        // Input 1 signal presence
NAV_INPUT_2_SIGNAL = 402                        // Input 2 signal presence
// ... through NAV_INPUT_6_SIGNAL = 406
NAV_PRESET_1 = 501                              // Preset 1 selection
NAV_PRESET_2 = 502                              // Preset 2 selection
// ... through NAV_PRESET_12 = 512
```

Arrays available:
- `NAV_INPUT_SIGNAL[]` - All input signal channels (401-406)
- `NAV_PRESET[]` - All preset channels (501-512)

---

## Parser Implementation Comparison

| Feature | NAVParseSnapiMessage | NAVSnapiParse |
|---------|---------------------|---------------|
| **Implementation** | String-based state machine | Token-based lexer/parser |
| **Performance** | ~5.5ms average | ~18ms average |
| **API** | Single function call | Single function call |
| **Quoted strings** | ✅ Supported | ✅ Supported |
| **Escaped quotes** | ✅ Supported | ✅ Supported |
| **Empty parameters** | ✅ Supported | ✅ Supported |
| **Special characters** | ✅ All except `-` in headers | ✅ All except `-` in headers |
| **Debuggability** | Moderate | Excellent (token stream) |
| **Extensibility** | Limited | Easy to extend |
| **Memory usage** | Lower | Higher (token array) |
| **Best for** | Production/performance | Development/debugging |

Both parsers:
- Return the same `_NAVSnapiMessage` structure
- Handle all edge cases correctly
- Pass comprehensive test suite (25+ test cases)
- Comply with SNAPI grammar specification

---

## Usage Examples

### Basic Switching

```netlinx
// Route input 2 to output 1 (video only)
NAVSwitch(vdvSwitcher, 2, 1, NAV_SWITCH_LEVEL_VID)

// Route input 3 to output 2 (all signals)
NAVSwitch(vdvSwitcher, 3, 2, NAV_SWITCH_LEVEL_ALL)
```

### Input Selection

```netlinx
// Single device
NAVInput(vdvDisplay, 'HDMI,1')

// Multiple devices
stack_var dev displays[3]
displays[1] = vdvDisplay1
displays[2] = vdvDisplay2
displays[3] = vdvDisplay3
NAVInputArray(displays, 'HDMI,2')
```

### Parsing SNAPI Feedback

```netlinx
data_event[vdvDevice] {
    string: {
        stack_var _NAVSnapiMessage msg
        
        if (NAVParseSnapiMessage(data.text, msg)) {
            switch (msg.Header) {
                case 'SWITCH': {
                    // Handle switch feedback
                    stack_var integer input
                    stack_var integer output
                    
                    if (msg.ParameterCount >= 2) {
                        input = atoi(msg.Parameter[1])
                        output = atoi(msg.Parameter[2])
                        send_string 0, "'Switched: Input ', itoa(input), ' -> Output ', itoa(output)"
                    }
                }
                case 'POWER': {
                    // Handle power feedback
                    if (msg.ParameterCount >= 1) {
                        if (msg.Parameter[1] == 'ON') {
                            send_string 0, 'Device powered on'
                        }
                    }
                }
            }
        }
    }
}
```

### Complex Message Parsing

```netlinx
// Parse message with quoted parameter containing comma
stack_var _NAVSnapiMessage msg

NAVParseSnapiMessage('PASSTHRU-"Name,Value","Data"', msg)
// msg.Header = 'PASSTHRU'
// msg.Parameter[1] = 'Name,Value'  (comma preserved)
// msg.Parameter[2] = 'Data'
// msg.ParameterCount = 2

// Parse message with escaped quotes
NAVParseSnapiMessage('TEXT-"""Hello"""', msg)
// msg.Header = 'TEXT'
// msg.Parameter[1] = '"Hello"'  (quotes preserved)
// msg.ParameterCount = 1

// Parse message with empty parameters
NAVParseSnapiMessage('DATA-,,value', msg)
// msg.Header = 'DATA'
// msg.Parameter[1] = ''  (empty)
// msg.Parameter[2] = ''  (empty)
// msg.Parameter[3] = 'value'
// msg.ParameterCount = 3
```

### Device State Queries

```netlinx
// Check power state before sending command
if (!NAVGetPower(vdvDisplay)) {
    pulse [vdvDisplay, PWR_ON]
}

// Check mute state
if (NAVGetVolumeMute(vdvReceiver)) {
    send_string 0, 'Audio is muted'
}
```

---

## Dependencies

This library requires:
- `NAVFoundation.Core.axi` - Core utilities
- `NAVFoundation.StringUtils.axi` - String manipulation functions
- `NAVFoundation.SnapiParser.axi` - Lexer/parser implementation (for `NAVSnapiParse`)
- `SNAPI.axi` - Standard AMX SNAPI definitions
- `G4API.axi` - AMX G4 API definitions

---

## Performance Notes

Based on comprehensive testing with 25 test cases:

- **NAVParseSnapiMessage**: 4-7ms range, ~5.5ms average
  - Optimized string-based implementation
  - Comparable to AMX's built-in DuetParseCmdHeader/Param (~6ms avg)
  - Best choice for production systems

- **NAVSnapiParse**: 9-36ms range, ~18ms average
  - Token-based lexer/parser architecture
  - ~3x slower but still acceptable for most applications
  - Better for development, debugging, and future extensibility

Both parsers:
- Handle all SNAPI grammar edge cases correctly
- Support quoted strings, escaped quotes, empty parameters
- Return identical results for all test cases

---

## Testing

The library includes comprehensive test coverage:
- 25+ test cases covering edge cases
- Empty strings, whitespace, special characters
- Quoted strings with commas and escaped quotes
- Trailing commas, multiple empty parameters
- Performance benchmarking

---

## License

MIT License - Copyright (c) 2023 Norgate AV Services Limited

---

## See Also

- **NAVFoundation.SnapiParser** - Low-level lexer/parser implementation
- **NAVFoundation.SnapiLexer** - Tokenization engine
- **SNAPI-GRAMMAR.bnf** - Formal BNF grammar specification
