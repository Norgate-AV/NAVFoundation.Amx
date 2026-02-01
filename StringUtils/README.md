# NAVFoundation.StringUtils

The StringUtils library for NAVFoundation provides a comprehensive collection of string manipulation, searching, testing, and formatting functions for NetLinx programming. It aims to simplify common string operations and provide functionality similar to what's available in modern programming languages.

## Overview

Working with strings in NetLinx can be challenging due to limited built-in functionality. This library bridges that gap by providing robust, well-tested functions for performing common string operations.

## Features

- **String Manipulation**: Trimming, substring extraction, replacing, etc.
- **String Testing**: Contains, startsWith, endsWith, etc.
- **String Searching**: Find index of substrings, count occurrences
- **String Parsing**: Parse integers, signed integers, longs, signed longs, floats, and booleans with validation
- **Case Conversion**: Upper/lower case, camelCase, PascalCase, etc.
- **Character Operations**: Check character types, convert case
- **String Splitting and Joining**: Split strings into arrays, join arrays into strings
- **String Formatting**: Various case conversions (snake_case, kebab-case, etc.)

## Function Reference

### String Manipulation

#### String Trimming Functions

```netlinx
// Remove leading whitespace from a string
result = NAVTrimStringLeft('   Hello World')  // Returns 'Hello World'

// Remove trailing whitespace from a string
result = NAVTrimStringRight('Hello World   ')  // Returns 'Hello World'

// Remove both leading and trailing whitespace
result = NAVTrimString('   Hello World   ')  // Returns 'Hello World'

// Trim all strings in an array
NAVTrimStringArray(stringArray)  // Modifies the array in place
```

#### Substring Extraction

```netlinx
// Get a substring from specified position with specified length
result = NAVStringSubstring('Hello World', 1, 5)  // Returns 'Hello'
result = NAVStringSubstring('Hello World', 7, 5)  // Returns 'World'
result = NAVStringSubstring('Hello World', 3, 0)  // Returns 'llo World' (0 means until end)

// Get a substring between start and end positions
result = NAVStringSlice('Hello World', 1, 6)  // Returns 'Hello'

// Get the substring before a token
result = NAVGetStringBefore('Hello World', ' ')  // Returns 'Hello'
result = NAVStringBefore('Hello World', ' ')     // Alias for NAVGetStringBefore

// Get the substring after a token
result = NAVGetStringAfter('Hello World', ' ')   // Returns 'World'
result = NAVStringAfter('Hello World', ' ')      // Alias for NAVGetStringAfter

// Get the substring between two tokens
result = NAVGetStringBetween('Hello [World] Goodbye', '[', ']')  // Returns 'World'
result = NAVStringBetween('Hello [World] Goodbye', '[', ']')     // Alias for NAVGetStringBetween

// Get the substring between the first occurrence of token1 and last occurrence of token2
result = NAVGetStringBetweenGreedy('Hello [World] and [Universe]', '[', ']')  // Returns 'World] and [Universe'
result = NAVStringBetweenGreedy('Hello [World] and [Universe]', '[', ']')     // Alias for NAVGetStringBetweenGreedy
```

#### String Modification

```netlinx
// Remove characters from the right end of a string
result = NAVStripCharsFromRight('Hello World', 3)  // Returns 'Hello Wo'
result = NAVStripRight('Hello World', 3)          // Alias for NAVStripCharsFromRight

// Remove characters from the left end of a string
result = NAVStripCharsFromLeft('Hello World', 3)  // Returns 'lo World'
result = NAVStripLeft('Hello World', 3)          // Alias for NAVStripCharsFromLeft

// Remove a specific number of characters from the beginning
result = NAVRemoveStringByLength('Hello World', 6)  // Returns 'World'

// Replace all occurrences of a substring
result = NAVFindAndReplace('Hello World', 'o', 'X')  // Returns 'HellX WXrld'
result = NAVStringReplace('Hello World', 'o', 'X')   // Alias for NAVFindAndReplace

// Normalize multiple occurrences of a substring to a single occurrence, then replace
result = NAVStringNormalizeAndReplace('Hello  World', ' ', '-')  // Returns 'Hello-World'

// Surround a string with other strings
result = NAVStringSurroundWith('World', 'Hello ', '!')  // Returns 'Hello World!'
result = NAVStringSurround('World', 'Hello ', '!')     // Alias for NAVStringSurroundWith

// Reverse a string
result = NAVStringReverse('Hello World')  // Returns 'dlroW olleH'
```

### String Testing

```netlinx
// Check if a string starts with a substring
isTrue = NAVStartsWith('Hello World', 'Hello')  // Returns true
isTrue = NAVStringStartsWith('Hello World', 'World')  // Returns false (alias for NAVStartsWith)

// Check if a string contains a substring
isTrue = NAVContains('Hello World', 'World')  // Returns true
isTrue = NAVStringContains('Hello World', 'Moon')  // Returns false (alias for NAVContains)

// Check if a string ends with a substring
isTrue = NAVEndsWith('Hello World', 'World')  // Returns true
isTrue = NAVStringEndsWith('Hello World', 'Hello')  // Returns false (alias for NAVEndsWith)
```

### String Searching

```netlinx
// Find the first occurrence of a substring
position = NAVIndexOf('Hello World', 'o', 1)  // Returns 5 (position of first 'o')
position = NAVIndexOf('Hello World', 'o', 6)  // Returns 8 (position of second 'o')

// Find the last occurrence of a substring
position = NAVLastIndexOf('Hello World', 'o')  // Returns 8

// Count occurrences of a substring
count = NAVStringCount('Hello World, hello universe', 'hello', NAV_CASE_INSENSITIVE)  // Returns 2
count = NAVStringCount('Hello World, hello universe', 'hello', NAV_CASE_SENSITIVE)    // Returns 1
```

### String Splitting and Joining

```netlinx
// Split a string into an array
stack_var char text[50]
stack_var char parts[10][20]
stack_var integer count
text = 'Hello,World,How,Are,You'
count = NAVSplitString(text, ',', parts)  // parts contains ['Hello', 'World', 'How', 'Are', 'You']

// Join an array of strings into a single string
stack_var char words[3][10]
stack_var char result[50]
words[1] = 'Hello'
words[2] = 'World'
words[3] = '!'
result = NAVArrayJoinString(words, ' ')  // Returns 'Hello World !'
```

### Character Operations

```netlinx
// Get the character code at a position
code = NAVCharCodeAt('Hello', 1)  // Returns 'H'

// Check if a character is whitespace
isTrue = NAVIsWhitespace(' ')   // Returns true
isTrue = NAVIsSpace('A')       // Returns false (alias for NAVIsWhitespace)

// Check if a character is alphabetic
isTrue = NAVIsAlpha('A')   // Returns true
isTrue = NAVIsAlpha('1')   // Returns false

// Check if a character is a digit
isTrue = NAVIsDigit('5')   // Returns true
isTrue = NAVIsDigit('A')   // Returns false

// Check if a character is alphanumeric
isTrue = NAVIsAlphaNumeric('A')   // Returns true
isTrue = NAVIsAlphaNumeric('_')   // Returns true
isTrue = NAVIsAlphaNumeric('!')   // Returns false

// Check if a character is uppercase or lowercase
isTrue = NAVIsUpperCase('A')   // Returns true
isTrue = NAVIsLowerCase('a')   // Returns true

// Convert character case
char = NAVCharToLower('A')   // Returns 'a'
char = NAVCharToUpper('a')   // Returns 'A'
```

### Case Conversion and Formatting

```netlinx
// Capitalize the first letter of each word
result = NAVStringCapitalize('hello world')  // Returns 'Hello World'

// Insert spaces before uppercase letters
result = NAVInsertSpacesBeforeUppercase('HelloWorld')  // Returns 'hello world'

// Convert to PascalCase
result = NAVStringPascalCase('hello world')  // Returns 'HelloWorld'

// Convert to camelCase
result = NAVStringCamelCase('hello world')  // Returns 'helloWorld'

// Convert to snake_case
result = NAVStringSnakeCase('hello world')  // Returns 'hello_world'

// Convert to kebab-case
result = NAVStringKebabCase('hello world')  // Returns 'hello-world'

// Convert to Train-Case
result = NAVStringTrainCase('hello world')  // Returns 'Hello-World'

// Convert to SCREAM-KEBAB-CASE
result = NAVStringScreamKebabCase('hello world')  // Returns 'HELLO-WORLD'
```

### String Parsing and Conversion

```netlinx
// Parse unsigned integer (0-65535)
stack_var integer value
stack_var char success
success = NAVParseInteger('12345', value)     // Returns true, value = 12345
success = NAVParseInteger('99999', value)     // Returns false (out of range)
success = NAVParseInteger('-100', value)      // Returns false (negative)
success = NAVParseInteger('Volume=50', value) // Returns true, value = 50 (extracts first number)
success = NAVParseInteger('   42  99   ', value) // Returns true, value = 42 (stops at space)

// Parse signed integer (-32768 to 32767)
stack_var sinteger svalue
success = NAVParseSignedInteger('-12345', svalue)  // Returns true, svalue = -12345
success = NAVParseSignedInteger('50000', svalue)   // Returns false (out of range)
success = NAVParseSignedInteger('Offset=-100', svalue) // Returns true, svalue = -100
success = NAVParseSignedInteger('   -10  20   ', svalue) // Returns true, svalue = -10

// Parse unsigned long (0-4294967295)
stack_var long lvalue
success = NAVParseLong('1234567890', lvalue)   // Returns true, lvalue = 1234567890
success = NAVParseLong('4294967295', lvalue)   // Returns true (max LONG value)
success = NAVParseLong('5000000000', lvalue)   // Returns false (overflow)
success = NAVParseLong('-1000', lvalue)        // Returns false (negative)
success = NAVParseLong('   100  200   ', lvalue) // Returns true, lvalue = 100

// Parse signed long (-2147483648 to 2147483647)
stack_var slong slvalue
success = NAVParseSignedLong('-1234567890', slvalue)  // Returns true, slvalue = -1234567890
success = NAVParseSignedLong('2147483647', slvalue)   // Returns true (max SLONG)
success = NAVParseSignedLong('3000000000', slvalue)   // Returns false (overflow)
success = NAVParseSignedLong('xyz-123', slvalue)     // Returns true, slvalue = -123 (extracts number)
success = NAVParseSignedLong('   -100  200   ', slvalue) // Returns true, slvalue = -100

// Parse floating-point number
stack_var float fvalue
success = NAVParseFloat('3.14159', fvalue)      // Returns true, fvalue = 3.14159
success = NAVParseFloat('-1.25e-3', fvalue)     // Returns true, fvalue = -0.00125
success = NAVParseFloat('Temp=22.5', fvalue)    // Returns true, fvalue = 22.5 (extracts first number)
success = NAVParseFloat('   10.5  20.3   ', fvalue) // Returns true, fvalue = 10.5

// Parse boolean values (case-insensitive)
stack_var char bvalue
success = NAVParseBoolean('true', bvalue)   // Returns true, bvalue = 1
success = NAVParseBoolean('FALSE', bvalue)  // Returns true, bvalue = 0
success = NAVParseBoolean('1', bvalue)      // Returns true, bvalue = 1
success = NAVParseBoolean('0', bvalue)      // Returns true, bvalue = 0
success = NAVParseBoolean('yes', bvalue)    // Returns true, bvalue = 1
success = NAVParseBoolean('no', bvalue)     // Returns true, bvalue = 0
success = NAVParseBoolean('ON', bvalue)     // Returns true, bvalue = 1
success = NAVParseBoolean('off', bvalue)    // Returns true, bvalue = 0
success = NAVParseBoolean('maybe', bvalue)  // Returns false (invalid)
success = NAVParseBoolean('', bvalue)       // Returns false (empty string)
```

**Parsing Behavior Notes:**

- All parsing functions skip leading whitespace
- They parse the first valid number encountered
- Parsing stops at the first space or non-digit character after the number (matching ATOI/ATOF behavior)
- Example: `'   10  20   '` parses as `10`, not `20` or `1020`
- The functions validate ranges and return `false` if the value is out of bounds
- `NAVParseInteger` and `NAVParseSignedInteger` use ATOI internally
- `NAVParseLong` and `NAVParseSignedLong` use manual digit-by-digit parsing for full range support and overflow detection
- `NAVParseFloat` uses ATOF internally
- `NAVParseBoolean` performs case-insensitive matching of valid boolean strings:
    - **True values**: `'1'`, `'true'`, `'yes'`, `'on'`
    - **False values**: `'0'`, `'false'`, `'no'`, `'off'`
    - Returns `false` for any other input (including empty strings, partial matches like `'tr'` or `'fals'`, or numeric values other than `'1'` or `'0'`)

### Time and Duration Functions

```netlinx
// Convert time string to milliseconds
ms = NAVStringToLongMilliseconds('1h')   // Returns 3600000 (1 hour in ms)
ms = NAVStringToLongMilliseconds('30m')  // Returns 1800000 (30 minutes in ms)
ms = NAVStringToLongMilliseconds('45s')  // Returns 45000 (45 seconds in ms)

// Convert milliseconds to human-readable time span
result = NAVGetTimeSpan(3600000)  // Returns '1h 0s 0ms'
result = NAVGetTimeSpan(45000)    // Returns '45s 0ms'
```

### String Gathering and Processing

```netlinx
// Gather and process strings from a buffer based on a delimiter
stack_var _NAVRxBuffer buffer
buffer.Data = 'Hello,World,How,Are,You'
NAVStringGather(buffer, ',')  // Processes each word separately using a callback

// To use this function, define a callback:
#DEFINE USING_NAV_STRING_GATHER_CALLBACK
define_function NAVStringGatherCallback(_NAVStringGatherResult result) {
    // Process the gathered string data
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Gathered data: ', result.Data")
}
```

### Miscellaneous String Functions

```netlinx
// Compare two strings lexicographically
result = NAVStringCompare('apple', 'banana')  // Returns negative value
result = NAVStringCompare('apple', 'apple')   // Returns 0
result = NAVStringCompare('banana', 'apple')  // Returns positive value
```

## Example: Working with Strings

```netlinx
// Basic string manipulation
stack_var char text[100]
text = '   Hello, World!   '

// Trim whitespace
text = NAVTrimString(text)  // 'Hello, World!'

// Extract parts
stack_var char firstWord[20]
firstWord = NAVGetStringBefore(text, ',')  // 'Hello'

// Replace characters
text = NAVStringReplace(text, 'World', 'NetLinx')  // 'Hello, NetLinx!'

// Check content
if (NAVContains(text, 'NetLinx')) {
    // String contains 'NetLinx'
}

// Split into words
stack_var char words[10][20]
stack_var integer wordCount
wordCount = NAVSplitString(text, ' ', words)
// words[1] = "Hello,"
// words[2] = "NetLinx!"
```

## Example: Case Conversion

```netlinx
stack_var char text[50]
text = 'hello world example'

// Convert to various case formats
stack_var char camelCase[50]
stack_var char pascalCase[50]
stack_var char snakeCase[50]
stack_var char kebabCase[50]

camelCase = NAVStringCamelCase(text)    // 'helloWorldExample'
pascalCase = NAVStringPascalCase(text)  // 'HelloWorldExample'
snakeCase = NAVStringSnakeCase(text)    // 'hello_world_example'
kebabCase = NAVStringKebabCase(text)    // 'hello-world-example'
```

## Example: Parsing Structured Data

```netlinx
stack_var char data[100]
data = '[name=John][age=30][city=New York]'

// Extract each field
stack_var char name[20]
stack_var char age[5]
stack_var char city[30]

name = NAVGetStringBetween(data, '[name=', ']')  // 'John'
age = NAVGetStringBetween(data, '[age=', ']')    // '30'
city = NAVGetStringBetween(data, '[city=', ']')  // 'New York'
```

## Example: Parsing Numbers from User Input

```netlinx
// Parse a volume level from a command string
stack_var char command[50]
stack_var integer volume
stack_var char success

command = 'VOLUME=75'
success = NAVParseInteger(command, volume)
if (success) {
    // volume = 75, valid range 0-65535
    send_command dvAudioDevice, "'VOLUME-', itoa(volume)"
}

// Parse temperature with negative values
stack_var char tempStr[20]
stack_var sinteger temperature

tempStr = 'TEMP=-15'
success = NAVParseSignedInteger(tempStr, temperature)
if (success) {
    // temperature = -15, valid range -32768 to 32767
}

// Parse large numbers like timestamps
stack_var char timestampStr[20]
stack_var long timestamp

timestampStr = '1672531200'
success = NAVParseLong(timestampStr, timestamp)
if (success) {
    // timestamp = 1672531200 (Unix timestamp)
}

// Handle mixed content - extracts first number
stack_var char response[50]
stack_var float value

response = 'Temperature: 22.5 degrees'
success = NAVParseFloat(response, value)
if (success) {
    // value = 22.5
}

// Parse boolean configuration values
stack_var char enabledStr[10]
stack_var char boolValue

enabledStr = 'true'
success = NAVParseBoolean(enabledStr, boolValue)
if (success) {
    if (boolValue) {
        // Feature is enabled
        send_command dvDevice, "'FEATURE-ON'"
    } else {
        // Feature is disabled
        send_command dvDevice, "'FEATURE-OFF'"
    }
}

// Handle configuration from INI files or user input
stack_var char config[20]
config = 'DEBUG=yes'
config = NAVGetStringAfter(config, '=')  // Extract 'yes'
success = NAVParseBoolean(config, boolValue)
if (success && boolValue) {
    // Enable debug mode
}
```

## Performance Tips

- For operations on large strings, be aware of NetLinx's memory limitations
- `NAVStringReplace` may be slow on very large strings with many replacements
- Consider pre-allocating arrays with appropriate sizes before calling `NAVSplitString`
- For efficiency, use direct functions like `NAVIsDigit` instead of regular expressions

## Contributing

For issues, suggestions, or contributions, please contact Norgate AV Services Limited.

## License

MIT License - Copyright (c) 2010-2026 Norgate AV
