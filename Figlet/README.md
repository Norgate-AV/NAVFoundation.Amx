# NAVFoundation.Figlet

Convert text into ASCII art using the FIGlet Standard font format.

## Overview

NAVFoundation.Figlet provides functions to convert plain text strings into large ASCII art characters, commonly known as FIGlet text. The implementation uses the Standard font with CONTROLLED_SMUSHING layout mode, matching the behavior of the classic FIGlet program.

## Features

- **FIGlet Standard Font**: Full implementation of the Standard font (6-line height)
- **Character Smushing**: Implements rules 1-4 for horizontal character overlap
  - Rule 1: Equal character smushing
  - Rule 2: Underscore smushing
  - Rule 3: Hierarchy smushing
  - Rule 4: Opposite pair smushing
- **Proper Word Spacing**: Maintains correct spacing between words
- **ASCII Support**: Handles printable ASCII characters (32-126)
- **Multi-line Output**: Returns formatted multi-line strings with CRLF line breaks

## Usage

### Basic Example

```netlinx
#include 'NAVFoundation.Figlet.axi'

// Convert text to FIGlet
char result[2048]
result = NAVFiglet('Hello')

// Result will be:
//  _   _      _ _       
// | | | | ___| | | ___  
// | |_| |/ _ \ | |/ _ \ 
// |  _  |  __/ | | (_) |
// |_| |_|\___|_|_|\___/ 
```

### Using Specific Font

```netlinx
// Explicitly specify the Standard font
char result[2048]
result = NAVFigletWithFont('TEST', NAV_FIGLET_FONT_STANDARD)
```

### Logging FIGlet Output

```netlinx
// Helper function to log multi-line FIGlet output
char text[2048]
text = NAVFiglet('NAV')
NAVFigletLog(text)
```

## API Reference

### Functions

#### `NAVFiglet`

Converts text into FIGlet ASCII art using the default Standard font.

```netlinx
define_function char[2048] NAVFiglet(char text[])
```

**Parameters:**
- `text` - The text to convert to FIGlet format

**Returns:**
- Multi-line string containing the FIGlet representation, or empty string if input is empty

**Example:**
```netlinx
char art[2048]
art = NAVFiglet('Hi')
```

#### `NAVFigletWithFont`

Converts text into FIGlet ASCII art using a specific font type.

```netlinx
define_function char[2048] NAVFigletWithFont(char text[], integer font)
```

**Parameters:**
- `text` - The text to convert to FIGlet format
- `font` - The font type to use (currently only `NAV_FIGLET_FONT_STANDARD` is supported)

**Returns:**
- Multi-line string containing the FIGlet representation, or empty string if input is empty

**Example:**
```netlinx
char art[2048]
art = NAVFigletWithFont('Code', NAV_FIGLET_FONT_STANDARD)
```

#### `NAVFigletLog`

Logs FIGlet output to the system log, splitting multi-line output into separate log entries.

```netlinx
define_function NAVFigletLog(char text[])
```

**Parameters:**
- `text` - The FIGlet text to log (typically output from `NAVFiglet`)

**Example:**
```netlinx
NAVFigletLog(NAVFiglet('NAVFoundation'))
```

### Constants

#### Font Types

```netlinx
NAV_FIGLET_FONT_STANDARD    // Standard FIGlet font (default)
NAV_FIGLET_FONT_DEFAULT     // Alias for NAV_FIGLET_FONT_STANDARD
```

### Configuration

```netlinx
NAV_FIGLET_FONT_HEIGHT      // Height of font in lines (6 for Standard)
NAV_FIGLET_MAX_CHAR_WIDTH   // Maximum character width (12 columns)
```

## Implementation Details

### Character Smushing

The implementation uses CONTROLLED_SMUSHING mode with horizontal rules 1-4:

1. **Equal Character Smushing**: Two identical characters (except spaces) smush into one
2. **Underscore Smushing**: Underscores are replaced by: `|/\[]{}()<>`
3. **Hierarchy Smushing**: Characters from different classes use the latter class: `| /\ [] {} () <>`
4. **Opposite Pair Smushing**: Opposing brackets/braces/parentheses become `|`

### Word Spacing

- Space characters overlap by 1 to maintain minimal word separation
- Characters following spaces have 0 overlap to preserve word boundaries
- This ensures proper spacing in multi-word FIGlet output

### Character Support

- Supports ASCII characters 32-126 (printable characters including space)
- Non-printable or out-of-range characters are skipped
- Space character (ASCII 32) has special handling for word separation

## Examples

### Single Character

```netlinx
NAVFiglet('A')
// Result:
//     _    
//    / \   
//   / _ \  
//  / ___ \ 
// /_/   \_\
```

### Multiple Words

```netlinx
NAVFiglet('Hello World!')
// Result:
//  _   _      _ _        __        __         _     _ _ 
// | | | | ___| | | ___   \ \      / /__  _ __| | __| | |
// | |_| |/ _ \ | |/ _ \   \ \ /\ / / _ \| '__| |/ _` | |
// |  _  |  __/ | | (_) |   \ V  V / (_) | |  | | (_| |_|
// |_| |_|\___|_|_|\___/     \_/\_/ \___/|_|  |_|\__,_(_)
```

### Numbers and Symbols

```netlinx
NAVFiglet('123')
// Result:
//  _ ____  _____ 
// / |___ \|___ / 
// | | __) | |_ \ 
// | |/ __/ ___) |
// |_|_____|____/
```

## Technical Notes

- Output strings use CRLF (`$0D$0A`) line breaks
- Trailing spaces are trimmed from each line
- Maximum output size is 2048 characters
- Empty input returns empty string
- Font dispatching architecture supports future font additions

## Dependencies

- `NAVFoundation.StringUtils.axi` - String manipulation utilities
- `NAVFoundation.FigletStandardFont.axi` - Standard font character definitions

## Testing

The module includes comprehensive tests covering:
- Single characters (uppercase, lowercase, numbers)
- Multi-character words
- Multi-word phrases
- Special characters and symbols
- Empty strings
- Full ASCII printable range

Run tests using the NAVFoundation test framework:
```netlinx
#include 'NAVFiglet.axi'  // Test file
```

## Future Enhancements

- Additional font support (Small, Banner, etc.)
- Vertical smushing modes
- Custom font loading
- Right-to-left text support
- Character width optimization
