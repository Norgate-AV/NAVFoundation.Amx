# NAVFoundation.FileUtils

Comprehensive file and directory manipulation utilities for AMX NetLinx control systems. This library provides high-level file operations with automatic resource management and robust error handling.

## Overview

NAVFoundation.FileUtils offers two distinct API styles:

- **Convenience API**: Auto-managed file operations (open/read|write/close)
- **Handle API**: Manual file lifecycle control for advanced use cases

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [API Reference](#api-reference)
  - [Error Handling](#error-handling)
  - [File Operations](#file-operations)
  - [Line Operations](#line-operations)
  - [Directory Operations](#directory-operations)
  - [File Management](#file-management)
- [Constants](#constants)
- [Data Types](#data-types)
- [Examples](#examples)

## Installation

```netlinx
#include 'NAVFoundation.FileUtils.axi'
```

## Usage

### Quick Start

```netlinx
// Read entire file
stack_var char content[NAV_MAX_BUFFER]
stack_var slong result

result = NAVFileRead('/config.txt', content)
if (result >= 0) {
    // Process content
}

// Write to file
result = NAVFileWrite('/output.txt', 'Hello, World!')

// Read lines into array
stack_var char lines[100][NAV_MAX_BUFFER]
stack_var slong lineCount

lineCount = NAVFileReadLines('/data.txt', lines)
for (x = 1; x <= lineCount; x++) {
    // Process each line
}
```

## API Reference

### Error Handling

#### NAVGetFileError

Converts a file operation error code to a human-readable error message.

**Signature:**
```netlinx
define_function char[NAV_MAX_BUFFER] NAVGetFileError(slong error)
```

**Parameters:**
- `error` (slong) - Error code returned by a file operation function

**Returns:**
- (char[]) Human-readable error description, or empty string if error >= 0

**Example:**
```netlinx
stack_var slong result
stack_var char errorMessage[NAV_MAX_BUFFER]

result = NAVFileOpen('/test.txt', 'r')
if (result < 0) {
    errorMessage = NAVGetFileError(result)
    // Log or display error message
}
```

---

### File Operations

#### NAVFileOpen

Opens a file with specified access mode.

**Signature:**
```netlinx
define_function slong NAVFileOpen(char path[], char mode[])
```

**Parameters:**
- `path` (char[]) - Full path to the file
- `mode` (char[]) - Access mode:
  - `'r'` - Read-only
  - `'rw'` - Read-write (creates new or overwrites)
  - `'rwa'` - Read-write-append

**Returns:**
- (slong) File handle on success, or negative error code on failure

**Example:**
```netlinx
stack_var slong fileHandle

// Open file for reading
fileHandle = NAVFileOpen('/config.txt', 'r')
if (fileHandle < 0) {
    // Handle error
} else {
    // Use the file handle
}
```

**Notes:**
- Always close the file handle with `NAVFileClose` when done

**See Also:** [NAVFileClose](#navfileclose)

---

#### NAVFileClose

Closes an open file.

**Signature:**
```netlinx
define_function slong NAVFileClose(long handle)
```

**Parameters:**
- `handle` (long) - File handle previously obtained from NAVFileOpen

**Returns:**
- (slong) 0 on success, or negative error code on failure

**Example:**
```netlinx
stack_var slong fileHandle
stack_var slong result

fileHandle = NAVFileOpen('/config.txt', 'r')
if (fileHandle >= 0) {
    // Use the file...
    result = NAVFileClose(fileHandle)
}
```

**See Also:** [NAVFileOpen](#navfileopen)

---

#### NAVFileRead

Reads the entire content of a file into a buffer. Opens the file, reads its content, and closes it automatically.

**Signature:**
```netlinx
define_function slong NAVFileRead(char path[], char data[])
```

**Parameters:**
- `path` (char[]) - Full path to the file
- `data` (char[]) - Output buffer to store file content (modified in-place)

**Returns:**
- (slong) 0 on success, or negative error code on failure

**Example:**
```netlinx
stack_var char fileContent[NAV_MAX_BUFFER]
stack_var slong result

result = NAVFileRead('/config.txt', fileContent)
if (result >= 0) {
    // Use the file content
}
```

**Notes:**
- The size of the output buffer limits how much data can be read

---

#### NAVFileReadHandle

Reads raw bytes from an open file.

**Signature:**
```netlinx
define_function slong NAVFileReadHandle(long handle, char data[])
```

**Parameters:**
- `handle` (long) - File handle previously obtained from NAVFileOpen
- `data` (char[]) - Output buffer to store the data (modified in-place)

**Returns:**
- (slong) Number of bytes read on success, or negative error code on failure

**Example:**
```netlinx
stack_var slong fileHandle
stack_var char buffer[1024]
stack_var slong bytesRead

fileHandle = NAVFileOpen('/data.bin', 'r')
if (fileHandle >= 0) {
    bytesRead = NAVFileReadHandle(fileHandle, buffer)
    if (bytesRead > 0) {
        // Process the data
    }
    NAVFileClose(fileHandle)
}
```

**Notes:**
- Reads up to the maximum buffer size (max_length_array)
- Uses AMX file_read function

**See Also:** [NAVFileOpen](#navfileopen), [NAVFileClose](#navfileclose), [NAVFileReadLineHandle](#navfilereadlinehandle)

---

#### NAVFileReadLineHandle

Reads a single line from an open file.

**Signature:**
```netlinx
define_function slong NAVFileReadLineHandle(long handle, char data[])
```

**Parameters:**
- `handle` (long) - File handle previously obtained from NAVFileOpen
- `data` (char[]) - Output buffer to store the line (modified in-place)

**Returns:**
- (slong) Number of bytes read on success, or negative error code on failure

**Example:**
```netlinx
stack_var slong fileHandle
stack_var char line[NAV_MAX_BUFFER]
stack_var slong result

fileHandle = NAVFileOpen('/config.txt', 'r')
if (fileHandle >= 0) {
    // Read file line by line
    while (1) {
        result = NAVFileReadLineHandle(fileHandle, line)
        if (result < 0) break;  // End of file or error
        // Process the line
    }
    NAVFileClose(fileHandle)
}
```

**Notes:**
- Returns NAV_FILE_ERROR_EOF_END_OF_FILE_REACHED when end of file is reached
- Uses AMX file_read_line function

**See Also:** [NAVFileOpen](#navfileopen), [NAVFileClose](#navfileclose), [NAVFileReadHandle](#navfilereadhandle)

---

#### NAVFileWrite

Writes data to a file, overwriting any existing content. Opens the file, writes the data, and closes it automatically.

**Signature:**
```netlinx
define_function slong NAVFileWrite(char path[], char data[])
```

**Parameters:**
- `path` (char[]) - Full path to the file
- `data` (char[]) - Data to write to the file

**Returns:**
- (slong) 0 on success, or negative error code on failure

**Example:**
```netlinx
stack_var char content[100]
stack_var slong result

content = 'New file content'
result = NAVFileWrite('/config.txt', content)
if (result < 0) {
    // Handle error
}
```

**Notes:**
- Creates a new file if it doesn't exist, otherwise overwrites existing file

---

#### NAVFileWriteHandle

Writes raw bytes to an open file.

**Signature:**
```netlinx
define_function slong NAVFileWriteHandle(long handle, char data[])
```

**Parameters:**
- `handle` (long) - File handle previously obtained from NAVFileOpen
- `data` (char[]) - Data to write to the file

**Returns:**
- (slong) Number of bytes written on success, or negative error code on failure

**Example:**
```netlinx
stack_var slong fileHandle
stack_var char data[1024]
stack_var slong bytesWritten

fileHandle = NAVFileOpen('/data.bin', 'rw')
if (fileHandle >= 0) {
    data = 'Binary data...'
    bytesWritten = NAVFileWriteHandle(fileHandle, data)
    NAVFileClose(fileHandle)
}
```

**Notes:**
- Writes the entire buffer content (length_array)
- Uses AMX file_write function
- Open with 'rw' to overwrite, 'rwa' to append

**See Also:** [NAVFileOpen](#navfileopen), [NAVFileClose](#navfileclose), [NAVFileWriteLineHandle](#navfilewritelinehandle)

---

#### NAVFileWriteLineHandle

Writes a line to an open file, adding a carriage return and line feed.

**Signature:**
```netlinx
define_function slong NAVFileWriteLineHandle(long handle, char buffer[])
```

**Parameters:**
- `handle` (long) - File handle previously obtained from NAVFileOpen
- `buffer` (char[]) - Line text to write

**Returns:**
- (slong) Number of bytes written on success, or negative error code on failure

**Example:**
```netlinx
stack_var slong fileHandle
stack_var char line[100]
stack_var slong result

fileHandle = NAVFileOpen('/log.txt', 'rw')
if (fileHandle >= 0) {
    line = 'Log entry 1'
    result = NAVFileWriteLineHandle(fileHandle, line)
    line = 'Log entry 2'
    result = NAVFileWriteLineHandle(fileHandle, line)
    NAVFileClose(fileHandle)
}
```

**Notes:**
- Uses AMX file_write_line function which automatically adds CRLF
- Open with 'rw' to overwrite, 'rwa' to append

**See Also:** [NAVFileOpen](#navfileopen), [NAVFileClose](#navfileclose), [NAVFileWriteHandle](#navfilewritehandle), [NAVFileReadLineHandle](#navfilereadlinehandle)

---

#### NAVFileAppend

Appends data to the end of a file. Opens the file in append mode, writes the data, and closes it automatically.

**Signature:**
```netlinx
define_function slong NAVFileAppend(char path[], char data[])
```

**Parameters:**
- `path` (char[]) - Full path to the file
- `data` (char[]) - Data to append to the file

**Returns:**
- (slong) 0 on success, or negative error code on failure

**Example:**
```netlinx
stack_var char content[100]
stack_var slong result

content = 'Additional content'
result = NAVFileAppend('/log.txt', content)
```

**Notes:**
- Creates a new file if it doesn't exist

---

#### NAVFileSeek

Seeks to a specific position in an open file.

**Signature:**
```netlinx
define_function slong NAVFileSeek(long handle, slong position)
```

**Parameters:**
- `handle` (long) - File handle returned by NAVFileOpen
- `position` (slong) - Byte position to seek to:
  - 0 = beginning of file
  - -1 = end of file (use NAV_FILE_SEEK_END constant)
  - N = absolute byte position

**Returns:**
- (slong) New position in file on success, or negative error code on failure

**Example:**
```netlinx
stack_var long handle
stack_var slong position

handle = type_cast(NAVFileOpen('/data.txt', 'r'))

// Seek to beginning
position = NAVFileSeek(handle, 0)

// Seek to end (get file size)
position = NAVFileSeek(handle, NAV_FILE_SEEK_END)

// Seek to specific byte
position = NAVFileSeek(handle, 100)

NAVFileClose(handle)
```

**Notes:**
- AMX file_seek only supports absolute positioning, not relative

**See Also:** [NAVFileOpen](#navfileopen), [NAVFileClose](#navfileclose)

---

#### NAVFileGetSize

Gets the size of a file in bytes.

**Signature:**
```netlinx
define_function slong NAVFileGetSize(char path[])
```

**Parameters:**
- `path` (char[]) - Path to the file

**Returns:**
- (slong) File size in bytes on success, or negative error code on failure

**Example:**
```netlinx
stack_var slong fileSize

fileSize = NAVFileGetSize('/user/data.bin')
if (fileSize >= 0) {
    // Use file size
}
```

---

### Line Operations

#### NAVFileWriteLine

Writes a line to a file, adding a carriage return and line feed. Opens the file, writes the line with CRLF, and closes it automatically.

**Signature:**
```netlinx
define_function slong NAVFileWriteLine(char path[], char buffer[])
```

**Parameters:**
- `path` (char[]) - Full path to the file
- `buffer` (char[]) - Line text to write (can be empty)

**Returns:**
- (slong) Number of bytes written on success, or negative error code on failure

**Example:**
```netlinx
stack_var char line[100]
stack_var slong result

line = 'Config setting = value'
result = NAVFileWriteLine('/config.txt', line)
```

**Notes:**
- Creates a new file if it doesn't exist, otherwise overwrites existing file
- Empty buffer is valid - will write just CRLF (2 bytes)
- Always appends CRLF to the buffer content

**See Also:** [NAVFileWrite](#navfilewrite), [NAVFileWriteLineHandle](#navfilewritelinehandle), [NAVFileAppendLine](#navfileappendline)

---

#### NAVFileAppendLine

Appends a line to the end of a file, adding a carriage return and line feed. Opens the file in append mode, writes the line with CRLF, and closes it automatically.

**Signature:**
```netlinx
define_function slong NAVFileAppendLine(char path[], char buffer[])
```

**Parameters:**
- `path` (char[]) - Full path to the file
- `buffer` (char[]) - Line text to append (can be empty)

**Returns:**
- (slong) Number of bytes written on success, or negative error code on failure

**Example:**
```netlinx
stack_var char logEntry[100]
stack_var slong result

logEntry = "NAVGetTimeStamp(), ': System started'"
result = NAVFileAppendLine('/log.txt', logEntry)
```

**Notes:**
- Creates a new file if it doesn't exist
- Empty buffer is valid - will append just CRLF (2 bytes)
- Always appends CRLF to the buffer content

**See Also:** [NAVFileAppend](#navfileappend), [NAVFileWriteLine](#navfilewriteline), [NAVFileWriteLineHandle](#navfilewritelinehandle)

---

#### NAVFileReadLines

Reads all lines from a file into an array. Opens the file, reads all lines, and closes it automatically.

**Signature:**
```netlinx
define_function slong NAVFileReadLines(char path[], char lines[][])
```

**Parameters:**
- `path` (char[]) - Full path to the file
- `lines` (char[][]) - Output array to store lines (modified in-place)

**Returns:**
- (slong) Number of lines read on success, or negative error code on failure

**Example:**
```netlinx
stack_var char configLines[100][NAV_MAX_BUFFER]
stack_var slong lineCount
stack_var integer i

lineCount = NAVFileReadLines('/config.txt', configLines)
if (lineCount > 0) {
    for (i = 1; i <= lineCount; i++) {
        // Process each line
    }
}
```

**Notes:**
- Handles CRLF, LF, and mixed line endings
- Line endings are stripped from returned lines
- Returns 0 for empty files (not an error)
- Maximum lines limited by array size (max_length_array)

**See Also:** [NAVFileWriteLines](#navfilewritelines), [NAVFileAppendLines](#navfileappendlines), [NAVFileReadLineHandle](#navfilereadlinehandle)

---

#### NAVFileWriteLines

Writes an array of lines to a file. Opens the file, writes all lines with CRLF, and closes it automatically.

**Signature:**
```netlinx
define_function slong NAVFileWriteLines(char path[], char lines[][])
```

**Parameters:**
- `path` (char[]) - Full path to the file
- `lines` (char[][]) - Array of lines to write

**Returns:**
- (slong) 0 on success, or negative error code on failure

**Example:**
```netlinx
stack_var char configLines[10][NAV_MAX_BUFFER]
stack_var slong result

configLines[1] = 'Setting1=Value1'
configLines[2] = 'Setting2=Value2'
configLines[3] = 'Setting3=Value3'
set_length_array(configLines, 3)

result = NAVFileWriteLines('/config.txt', configLines)
```

**Notes:**
- Creates a new file if it doesn't exist, otherwise overwrites existing file
- Each line automatically gets CRLF appended
- Empty lines (empty strings) are valid and write just CRLF
- Empty array writes nothing (creates/truncates file to 0 bytes)

**See Also:** [NAVFileReadLines](#navfilereadlines), [NAVFileAppendLines](#navfileappendlines), [NAVFileWriteLineHandle](#navfilewritelinehandle)

---

#### NAVFileAppendLines

Appends an array of lines to the end of a file. Opens the file in append mode, writes all lines with CRLF, and closes it automatically.

**Signature:**
```netlinx
define_function slong NAVFileAppendLines(char path[], char lines[][])
```

**Parameters:**
- `path` (char[]) - Full path to the file
- `lines` (char[][]) - Array of lines to append

**Returns:**
- (slong) 0 on success, or negative error code on failure

**Example:**
```netlinx
stack_var char logEntries[5][NAV_MAX_BUFFER]
stack_var slong result

logEntries[1] = "NAVGetTimeStamp(), ': System started'"
logEntries[2] = "NAVGetTimeStamp(), ': Config loaded'"
logEntries[3] = "NAVGetTimeStamp(), ': Connection established'"
set_length_array(logEntries, 3)

result = NAVFileAppendLines('/log.txt', logEntries)
```

**Notes:**
- Creates a new file if it doesn't exist
- Each line automatically gets CRLF appended
- Empty lines (empty strings) are valid and append just CRLF
- Empty array appends nothing (no-op, returns success)

**See Also:** [NAVFileReadLines](#navfilereadlines), [NAVFileWriteLines](#navfilewritelines), [NAVFileWriteLineHandle](#navfilewritelinehandle)

---

### Directory Operations

#### NAVReadDirectory

Reads the contents of a directory and returns details about each file and subdirectory.

**Signature:**
```netlinx
define_function slong NAVReadDirectory(char path[], _NAVFileEntity entities[])
```

**Parameters:**
- `path` (char[]) - Directory path to read
- `entities` (_NAVFileEntity[]) - Output array to store file/directory information (modified in-place)

**Returns:**
- (slong) Number of entries found on success, or negative error code on failure

**Example:**
```netlinx
stack_var _NAVFileEntity dirEntities[100]
stack_var slong count
stack_var integer i

count = NAVReadDirectory('/user', dirEntities)
if (count > 0) {
    for (i = 1; i <= count; i++) {
        // Process each file entity
        if (dirEntities[i].IsDirectory) {
            // Handle directory
        } else {
            // Handle file
        }
    }
}
```

**Notes:**
- The path should start with a '/' or one will be added automatically

**See Also:** [_NAVFileEntity](#_navfileentity)

---

#### NAVWalkDirectory

Recursively walks a directory structure and returns all files found.

**Signature:**
```netlinx
define_function slong NAVWalkDirectory(char path[], char files[][])
```

**Parameters:**
- `path` (char[]) - Starting directory path
- `files` (char[][]) - Output array to store file paths (modified in-place)

**Returns:**
- (slong) Number of files found on success, or negative error code on failure

**Example:**
```netlinx
stack_var char allFiles[1000][NAV_MAX_BUFFER]
stack_var slong count
stack_var integer i

count = NAVWalkDirectory('/user', allFiles)
if (count > 0) {
    for (i = 1; i <= count; i++) {
        // Process each file
    }
}
```

**Notes:**
- If path is empty, it defaults to the root directory '/'
- This function will recursively scan all subdirectories

---

#### NAVFileExists

Checks if a file exists at the specified path.

**Signature:**
```netlinx
define_function char NAVFileExists(char path[])
```

**Parameters:**
- `path` (char[]) - Path to the file (relative or absolute)

**Returns:**
- (char) true if the file exists, false otherwise

**Example:**
```netlinx
stack_var char exists

// Absolute path
exists = NAVFileExists('/user/config.txt')

// Relative path (checked in root directory)
exists = NAVFileExists('config.txt')
```

---

#### NAVDirectoryExists

Checks if a directory exists.

**Signature:**
```netlinx
define_function char NAVDirectoryExists(char path[])
```

**Parameters:**
- `path` (char[]) - Directory path to check

**Returns:**
- (char) true if the directory exists, false otherwise

**Example:**
```netlinx
stack_var char exists

exists = NAVDirectoryExists('/user/data')
if (!exists) {
    // Directory doesn't exist, create it
    NAVDirectoryCreate('/user/data')
}
```

**Notes:**
- If path is empty, it defaults to the root directory '/'

---

#### NAVDirectoryCreate

Creates a new directory.

**Signature:**
```netlinx
define_function slong NAVDirectoryCreate(char path[])
```

**Parameters:**
- `path` (char[]) - Path of the directory to create

**Returns:**
- (slong) 0 on success, or negative error code on failure

**Example:**
```netlinx
stack_var slong result

result = NAVDirectoryCreate('/user/logs')
if (result < 0) {
    // Handle directory creation error
}
```

**Notes:**
- Parent directories must exist

---

#### NAVDirectoryDelete

Deletes a directory.

**Signature:**
```netlinx
define_function slong NAVDirectoryDelete(char path[])
```

**Parameters:**
- `path` (char[]) - Path of the directory to delete

**Returns:**
- (slong) 0 on success, or negative error code on failure

**Example:**
```netlinx
stack_var slong result

result = NAVDirectoryDelete('/user/temp')
if (result < 0) {
    // Handle directory deletion error
}
```

**Notes:**
- Directory must be empty to be deleted

---

### File Management

#### NAVFileRename

Renames a file or moves it to a new location.

**Signature:**
```netlinx
define_function slong NAVFileRename(char source[], char destination[])
```

**Parameters:**
- `source` (char[]) - Current path of the file
- `destination` (char[]) - New path for the file

**Returns:**
- (slong) 0 on success, or negative error code on failure

**Example:**
```netlinx
stack_var slong result

// Rename a file
result = NAVFileRename('/user/old.txt', '/user/new.txt')

// Move a file
result = NAVFileRename('/user/file.txt', '/archive/file.txt')
```

---

#### NAVFileDelete

Deletes a file.

**Signature:**
```netlinx
define_function slong NAVFileDelete(char path[])
```

**Parameters:**
- `path` (char[]) - Path of the file to delete

**Returns:**
- (slong) 0 on success, or negative error code on failure

**Example:**
```netlinx
stack_var slong result

result = NAVFileDelete('/user/temp.txt')
if (result < 0) {
    // Handle file deletion error
}
```

---

#### NAVFileCopy

Copies a file from one location to another.

**Signature:**
```netlinx
define_function slong NAVFileCopy(char source[], char destination[])
```

**Parameters:**
- `source` (char[]) - Path of the source file
- `destination` (char[]) - Path of the destination file

**Returns:**
- (slong) 0 on success, or negative error code on failure

**Example:**
```netlinx
stack_var slong result

result = NAVFileCopy('/user/original.txt', '/backup/original.txt')
if (result < 0) {
    // Handle file copy error
}
```

**Notes:**
- If the destination file already exists, it will be overwritten

---

## Constants

### Error Codes

| Constant | Value | Description |
|----------|-------|-------------|
| `NAV_FILE_ERROR_INVALID_FILE_HANDLE` | -1 | Invalid file handle |
| `NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME` | -2 | Invalid file path or name |
| `NAV_FILE_ERROR_INVALID_VALUE_SUPPLIED_FOR_IO_FLAG` | -3 | Invalid value supplied for IOFlag |
| `NAV_FILE_ERROR_INVALID_FILE_PATH` | -4 | Invalid file path |
| `NAV_FILE_ERROR_DISK_IO_ERROR` | -5 | Disk I/O error |
| `NAV_FILE_ERROR_INVALID_PARAMETER` | -6 | Invalid parameter (buffer length must be greater than zero) |
| `NAV_FILE_ERROR_FILE_ALREADY_CLOSED` | -7 | File already closed |
| `NAV_FILE_ERROR_FILE_NAME_EXISTS` | -8 | File name exists |
| `NAV_FILE_ERROR_EOF_END_OF_FILE_REACHED` | -9 | EOF (end-of-file) reached |
| `NAV_FILE_ERROR_BUFFER_TOO_SMALL` | -10 | Buffer too small |
| `NAV_FILE_ERROR_DISK_FULL` | -11 | Disk full |
| `NAV_FILE_ERROR_FILE_PATH_NOT_LOADED` | -12 | File path not loaded |
| `NAV_FILE_ERROR_DIRECTORY_NAME_EXISTS` | -13 | Directory name exists |
| `NAV_FILE_ERROR_MAXIMUM_NUMBER_OF_FILES_ARE_ALREADY_OPEN` | -14 | Maximum number of files are already open (max is 10) |
| `NAV_FILE_ERROR_INVALID_FILE_FORMAT` | -15 | Invalid file format |

### Other Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `NAV_FILE_SEEK_END` | -1 | Seek to end of file position. Use with `NAVFileSeek()` to position file pointer at the end of the file. |

---

## Data Types

### _NAVFileEntity

Structure representing a file system entity (file or directory).

**Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `Name` | char[] | The full name of the file or directory |
| `BaseName` | char[] | The base name without extension (for files) or the directory name |
| `Extension` | char[] | The file extension (empty for directories) |
| `Path` | char[] | The full path to the file or directory |
| `Parent` | char[] | The parent directory path |
| `IsDirectory` | char | true if entity is a directory, false if it's a file |

**Example:**
```netlinx
stack_var _NAVFileEntity entities[100]
stack_var slong count
stack_var integer i

count = NAVReadDirectory('/user', entities)
for (i = 1; i <= count; i++) {
    if (entities[i].IsDirectory) {
        // entities[i].Name contains directory name
    } else {
        // entities[i].Name contains filename
        // entities[i].Extension contains file extension
    }
}
```

---

## Examples

### Example 1: Configuration File Management

```netlinx
// Read configuration file line by line
define_function LoadConfig() {
    stack_var char configLines[50][NAV_MAX_BUFFER]
    stack_var slong lineCount
    stack_var integer i
    
    lineCount = NAVFileReadLines('/user/config.txt', configLines)
    
    if (lineCount < 0) {
        send_string 0, "'Error loading config: ', NAVGetFileError(lineCount)"
        return
    }
    
    for (i = 1; i <= lineCount; i++) {
        // Parse each configuration line
        ParseConfigLine(configLines[i])
    }
}

// Save configuration
define_function SaveConfig() {
    stack_var char configLines[50][NAV_MAX_BUFFER]
    stack_var slong result
    
    // Build configuration lines
    configLines[1] = 'IP_ADDRESS=192.168.1.100'
    configLines[2] = 'PORT=23'
    configLines[3] = 'TIMEOUT=5000'
    set_length_array(configLines, 3)
    
    result = NAVFileWriteLines('/user/config.txt', configLines)
    
    if (result < 0) {
        send_string 0, "'Error saving config: ', NAVGetFileError(result)"
    }
}
```

### Example 2: Logging System

```netlinx
// Append log entries
define_function LogMessage(char severity[], char message[]) {
    stack_var char logEntry[NAV_MAX_BUFFER]
    stack_var slong result
    
    logEntry = "NAVGetTimeStamp(), ' [', severity, '] ', message"
    result = NAVFileAppendLine('/user/system.log', logEntry)
    
    if (result < 0) {
        send_string 0, "'Error writing log: ', NAVGetFileError(result)"
    }
}

// Batch log multiple entries
define_function LogMultipleMessages(char messages[][]) {
    stack_var char logEntries[100][NAV_MAX_BUFFER]
    stack_var integer i
    stack_var slong result
    
    for (i = 1; i <= length_array(messages); i++) {
        logEntries[i] = "NAVGetTimeStamp(), ' ', messages[i]"
    }
    set_length_array(logEntries, length_array(messages))
    
    result = NAVFileAppendLines('/user/system.log', logEntries)
    
    if (result < 0) {
        send_string 0, "'Error writing logs: ', NAVGetFileError(result)"
    }
}
```

### Example 3: Directory Listing

```netlinx
// List all files in a directory
define_function ListFiles(char dirPath[]) {
    stack_var _NAVFileEntity entities[100]
    stack_var slong count
    stack_var integer i
    
    count = NAVReadDirectory(dirPath, entities)
    
    if (count < 0) {
        send_string 0, "'Error reading directory: ', NAVGetFileError(count)"
        return
    }
    
    if (count == 0) {
        send_string 0, "'Directory is empty'"
        return
    }
    
    send_string 0, "'Directory listing for ', dirPath, ':'"
    
    for (i = 1; i <= count; i++) {
        if (entities[i].IsDirectory) {
            send_string 0, "'  [DIR]  ', entities[i].Name"
        } else {
            send_string 0, "'  [FILE] ', entities[i].Name, ' (', entities[i].Extension, ')'"
        }
    }
}
```

### Example 4: File Operations with Error Handling

```netlinx
// Copy file with validation
define_function char SafeFileCopy(char source[], char destination[]) {
    stack_var slong result
    
    // Check if source exists
    if (!NAVFileExists(source)) {
        send_string 0, "'Source file does not exist: ', source"
        return false
    }
    
    // Check if destination directory exists
    stack_var char destDir[NAV_MAX_BUFFER]
    destDir = NAVPathDirName(destination)
    
    if (!NAVDirectoryExists(destDir)) {
        send_string 0, "'Destination directory does not exist: ', destDir"
        return false
    }
    
    // Perform copy
    result = NAVFileCopy(source, destination)
    
    if (result < 0) {
        send_string 0, "'Copy failed: ', NAVGetFileError(result)"
        return false
    }
    
    send_string 0, "'File copied successfully'"
    return true
}
```

### Example 5: Handle-based File Processing

```netlinx
// Process large file line by line with manual handle management
define_function ProcessLargeFile(char filePath[]) {
    stack_var slong fileHandle
    stack_var char line[NAV_MAX_BUFFER]
    stack_var slong result
    stack_var integer lineNumber
    
    fileHandle = NAVFileOpen(filePath, 'r')
    
    if (fileHandle < 0) {
        send_string 0, "'Error opening file: ', NAVGetFileError(fileHandle)"
        return
    }
    
    lineNumber = 0
    
    while (1) {
        line = ''
        result = NAVFileReadLineHandle(type_cast(fileHandle), line)
        
        if (result < 0) {
            if (result == NAV_FILE_ERROR_EOF_END_OF_FILE_REACHED) {
                // Normal end of file
                break
            }
            
            send_string 0, "'Error reading line: ', NAVGetFileError(result)"
            break
        }
        
        lineNumber++
        
        // Process the line
        ProcessLine(lineNumber, line)
    }
    
    NAVFileClose(type_cast(fileHandle))
    
    send_string 0, "'Processed ', itoa(lineNumber), ' lines'"
}
```

---

## Best Practices

1. **Always check return values** - All file operations can fail, check for negative error codes
2. **Use convenience API when possible** - Auto-managed functions handle cleanup automatically
3. **Close file handles** - When using handle-based API, always close files with `NAVFileClose()`
4. **Handle EOF gracefully** - NAV_FILE_ERROR_EOF_END_OF_FILE_REACHED is not an error, it's expected
5. **Validate paths** - Check if files/directories exist before operations when appropriate
6. **Use absolute paths** - Paths starting with '/' are more reliable than relative paths
7. **Consider buffer sizes** - Reading is limited by buffer size (max_length_array)
8. **Handle line endings** - The library automatically handles CRLF, LF, and mixed line endings

---

## License

MIT License - Copyright (c) 2023 Norgate AV Services Limited
