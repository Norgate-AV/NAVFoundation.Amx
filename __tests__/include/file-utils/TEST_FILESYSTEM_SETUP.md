# Test Filesystem Setup

This document describes the required filesystem structure for running FileUtils tests.

## Overview

The FileUtils test suite requires a predefined directory structure with specific files to validate `NAVFileExists`, `NAVDirectoryExists`, and related functions. This structure must be created on the AMX controller before running tests.

## Directory Structure

```
/
├── user/
│   ├── config.txt
│   ├── data.xml
│   ├── noextension
│   └── logs/
│       └── error.log
├── testdir/
│   ├── test.txt
│   ├── file with spaces.txt
│   └── nested/
│       └── deep.txt
└── empty/
    (empty directory)
```

## Setup Instructions

### Step 1: Create Directories

Create the following directories in order (parent directories must exist before children):

```netlinx
NAVDirectoryCreate('/user')
NAVDirectoryCreate('/user/logs')
NAVDirectoryCreate('/testdir')
NAVDirectoryCreate('/testdir/nested')
NAVDirectoryCreate('/empty')
```

### Step 2: Create Files with Content

Create each file with the specified content:

#### `/user/config.txt`
**Purpose:** Test basic file existence detection  
**Content:**
```
setting1=value1
setting2=value2
setting3=value3
```
**Size:** ~45 bytes  
**Test Coverage:** Absolute path, .txt extension

---

#### `/user/data.xml`
**Purpose:** Test different file extension  
**Content:**
```xml
<?xml version="1.0"?>
<data>
  <item>test</item>
</data>
```
**Size:** ~60 bytes  
**Test Coverage:** XML file extension

---

#### `/user/noextension`
**Purpose:** Test files without extensions  
**Content:**
```
This file has no extension
```
**Size:** ~27 bytes  
**Test Coverage:** Files without extension

---

#### `/user/logs/error.log`
**Purpose:** Test nested file paths  
**Content:**
```
[2025-12-27 10:00:00] Error: Test error message
[2025-12-27 10:01:00] Warning: Test warning message
```
**Size:** ~95 bytes  
**Test Coverage:** Nested directories, .log extension

---

#### `/testdir/test.txt`
**Purpose:** Test alternative directory location  
**Content:**
```
Test file content
Line 2
Line 3
```
**Size:** ~33 bytes  
**Test Coverage:** Different root directory

---

#### `/testdir/file with spaces.txt`
**Purpose:** Test filenames containing spaces  
**Content:**
```
This filename contains spaces in it.
```
**Size:** ~37 bytes  
**Test Coverage:** Special characters (spaces) in filename

---

#### `/testdir/nested/deep.txt`
**Purpose:** Test deeply nested file paths  
**Content:**
```
Deeply nested file
```
**Size:** ~19 bytes  
**Test Coverage:** Multiple directory levels, nested paths

---

### Step 3: Verify Empty Directory

Ensure `/empty` directory exists and contains **no files or subdirectories**.

**Test Coverage:** Empty directory handling, directory existence without contents

## Automated Setup Function

You can create this structure programmatically using the following NetLinx code:

```netlinx
define_function char SetupTestFilesystem() {
    stack_var slong result
    
    // Create directories
    NAVDirectoryCreate('/user')
    NAVDirectoryCreate('/user/logs')
    NAVDirectoryCreate('/testdir')
    NAVDirectoryCreate('/testdir/nested')
    NAVDirectoryCreate('/empty')
    
    // Create files with content
    result = NAVFileWrite('/user/config.txt', 
        "'setting1=value1', $0D, $0A, 
         'setting2=value2', $0D, $0A, 
         'setting3=value3'")
    if (result < 0) return false
    
    result = NAVFileWrite('/user/data.xml',
        "'<?xml version=\"1.0\"?>', $0D, $0A,
         '<data>', $0D, $0A,
         '  <item>test</item>', $0D, $0A,
         '</data>'")
    if (result < 0) return false
    
    result = NAVFileWrite('/user/noextension',
        'This file has no extension')
    if (result < 0) return false
    
    result = NAVFileWrite('/user/logs/error.log',
        "'[2025-12-27 10:00:00] Error: Test error message', $0D, $0A,
         '[2025-12-27 10:01:00] Warning: Test warning message'")
    if (result < 0) return false
    
    result = NAVFileWrite('/testdir/test.txt',
        "'Test file content', $0D, $0A,
         'Line 2', $0D, $0A,
         'Line 3'")
    if (result < 0) return false
    
    result = NAVFileWrite('/testdir/file with spaces.txt',
        'This filename contains spaces in it.')
    if (result < 0) return false
    
    result = NAVFileWrite('/testdir/nested/deep.txt',
        'Deeply nested file')
    if (result < 0) return false
    
    return true
}
```

## Test Coverage Summary

| Test Case | File/Directory | Purpose |
|-----------|----------------|---------|
| Root directory | `/` | Verify root always exists |
| Top-level directory | `/user`, `/testdir` | Standard directory paths |
| Nested directory | `/user/logs`, `/testdir/nested` | Multi-level paths |
| Empty directory | `/empty` | Empty directory handling |
| Standard file | `/user/config.txt` | Basic file existence |
| Different extension | `/user/data.xml` | Non-.txt extensions |
| No extension | `/user/noextension` | Files without extensions |
| Spaces in name | `/testdir/file with spaces.txt` | Special characters |
| Nested file | `/user/logs/error.log` | Files in subdirectories |
| Deep nesting | `/testdir/nested/deep.txt` | Multiple directory levels |

## Verification

After setup, verify the structure exists:

```netlinx
// Verify directories
NAVAssertTrue('Root exists', NAVDirectoryExists('/'))
NAVAssertTrue('User dir exists', NAVDirectoryExists('/user'))
NAVAssertTrue('Logs dir exists', NAVDirectoryExists('/user/logs'))
NAVAssertTrue('Testdir exists', NAVDirectoryExists('/testdir'))
NAVAssertTrue('Nested dir exists', NAVDirectoryExists('/testdir/nested'))
NAVAssertTrue('Empty dir exists', NAVDirectoryExists('/empty'))

// Verify files
NAVAssertTrue('Config exists', NAVFileExists('/user/config.txt'))
NAVAssertTrue('XML exists', NAVFileExists('/user/data.xml'))
NAVAssertTrue('No ext exists', NAVFileExists('/user/noextension'))
NAVAssertTrue('Error log exists', NAVFileExists('/user/logs/error.log'))
NAVAssertTrue('Test file exists', NAVFileExists('/testdir/test.txt'))
NAVAssertTrue('Spaces file exists', NAVFileExists('/testdir/file with spaces.txt'))
NAVAssertTrue('Deep file exists', NAVFileExists('/testdir/nested/deep.txt'))
```

## Cleanup

To remove the test filesystem after testing:

```netlinx
define_function char CleanupTestFilesystem() {
    // Delete files first
    NAVFileDelete('/user/config.txt')
    NAVFileDelete('/user/data.xml')
    NAVFileDelete('/user/noextension')
    NAVFileDelete('/user/logs/error.log')
    NAVFileDelete('/testdir/test.txt')
    NAVFileDelete('/testdir/file with spaces.txt')
    NAVFileDelete('/testdir/nested/deep.txt')
    
    // Delete directories (deepest first)
    NAVDirectoryDelete('/user/logs')
    NAVDirectoryDelete('/testdir/nested')
    NAVDirectoryDelete('/empty')
    NAVDirectoryDelete('/user')
    NAVDirectoryDelete('/testdir')
    
    return true
}
```

## Notes

- **File Content Matters for Size Tests:** If you add tests for `NAVFileGetSize`, the specific byte counts listed above are important.
- **Line Endings:** Use CRLF (`$0D, $0A`) for consistency across AMX systems.
- **Empty Directory:** The `/empty` directory must remain empty for tests to work correctly.
- **Spaces in Filenames:** The file `file with spaces.txt` tests edge cases in path parsing.
- **Extensions:** Mix of `.txt`, `.xml`, `.log`, and no extension provides good coverage.

## File Content Summary

All files contain **plain text** content:
- Simple configuration-style text for config files
- Valid XML for .xml files
- Log-format text for .log files
- Generic text for other files

Content is **minimal** (19-95 bytes per file) to:
- Minimize storage requirements
- Speed up file operations during tests
- Keep tests focused on path handling, not content processing
