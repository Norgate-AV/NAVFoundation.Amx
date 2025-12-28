PROGRAM_NAME='NAVFoundation.FileUtils'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_FILEUTILS__
#DEFINE __NAV_FOUNDATION_FILEUTILS__ 'NAVFoundation.FileUtils'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.FileUtils.h.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.PathUtils.axi'


/**
 * @function NAVGetFileError
 * @public
 * @description Converts a file operation error code to a human-readable error message.
 *
 * @param {slong} error - Error code returned by a file operation function
 *
 * @returns {char[]} Human-readable error description
 *
 * @example
 * stack_var slong result
 * stack_var char errorMessage[NAV_MAX_BUFFER]
 *
 * result = NAVFileOpen('/test.txt', 'r')
 * if (result < 0) {
 *     errorMessage = NAVGetFileError(result)
 *     // Display or log the error message
 * }
 */
define_function char[NAV_MAX_BUFFER] NAVGetFileError(slong error) {
    if (error >= 0) {
        return ""
    }

    switch (error) {
        case NAV_FILE_ERROR_INVALID_FILE_HANDLE:                        { return 'Invalid file handle' }
        case NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME:                  { return 'Invalid file path or name' }
        case NAV_FILE_ERROR_INVALID_VALUE_SUPPLIED_FOR_IO_FLAG:         { return 'Invalid value supplied for IOFlag' }
        case NAV_FILE_ERROR_INVALID_FILE_PATH:                          { return 'Invalid file path' }
        case NAV_FILE_ERROR_DISK_IO_ERROR:                              { return 'Disk I/O error' }
        case NAV_FILE_ERROR_INVALID_PARAMETER:                          { return 'Invalid parameter (buffer length must be greater than zero)' }

        // FILE_SEEK
        // case NAV_FILE_ERROR_INVALID_PARAMETER:                          { return 'Invalid parameter (pos points beyond the end-of-file (position is set to the end-of-file))' }

        case NAV_FILE_ERROR_FILE_ALREADY_CLOSED:                        { return 'File already closed' }
        case NAV_FILE_ERROR_FILE_NAME_EXISTS:                           { return 'File name exists' }
        case NAV_FILE_ERROR_EOF_END_OF_FILE_REACHED:                    { return 'EOF (end-of-file) reached' }
        case NAV_FILE_ERROR_BUFFER_TOO_SMALL:                           { return 'Buffer too small' }
        case NAV_FILE_ERROR_DISK_FULL:                                  { return 'Disk full' }
        case NAV_FILE_ERROR_FILE_PATH_NOT_LOADED:                       { return 'File path not loaded' }
        case NAV_FILE_ERROR_MAXIMUM_NUMBER_OF_FILES_ARE_ALREADY_OPEN:   { return 'Maximum number of files are already open (max is 10)' }
        case NAV_FILE_ERROR_INVALID_FILE_FORMAT:                        { return 'Invalid file format' }
        default:                                                        { return "'Unknown error (', itoa(error), ')'" }
    }
}


/**
 * @function NAVFileOpen
 * @public
 * @description Opens a file with specified access mode.
 *
 * @param {char[]} path - Full path to the file
 * @param {char[]} mode - Access mode ('r' for read-only, 'rw' for read-write, 'rwa' for read-write-append)
 *
 * @returns {slong} File handle on success, or negative error code on failure
 *
 * @example
 * stack_var slong fileHandle
 *
 * // Open file for reading
 * fileHandle = NAVFileOpen('/config.txt', 'r')
 * if (fileHandle < 0) {
 *     // Handle error
 * } else {
 *     // Use the file handle
 * }
 *
 * @note Always close the file handle with NAVFileClose when done
 * @see NAVFileClose
 */
define_function slong NAVFileOpen(char path[], char mode[]) {
    stack_var slong result
    stack_var long flag

    if (!length_array(path)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVFileOpen',
                                    "NAVGetFileError(NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME), ' : The path supplied is empty.'")

        return NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    }

    switch (lower_string(mode)) {
        case 'rwa': {
            flag = FILE_RW_APPEND
        }
        case 'rw': {
            flag = FILE_RW_NEW
        }
        case 'r': {
            flag = FILE_READ_ONLY
        }
        default: {
            flag = FILE_READ_ONLY
        }
    }

    result = file_open(path, flag)

    if(result < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVFileOpen',
                                    "'Error opening file "', path, '" : ', NAVGetFileError(result)")
    }

    return result
}


/**
 * @function NAVFileClose
 * @public
 * @description Closes an open file.
 *
 * @param {long} handle - File handle previously obtained from NAVFileOpen
 *
 * @returns {slong} 0 on success, or negative error code on failure
 *
 * @example
 * stack_var slong fileHandle
 * stack_var slong result
 *
 * fileHandle = NAVFileOpen('/config.txt', 'r')
 * if (fileHandle >= 0) {
 *     // Use the file...
 *     result = NAVFileClose(fileHandle)
 * }
 *
 * @see NAVFileOpen
 */
define_function slong NAVFileClose(long handle) {
    stack_var slong result

    result = file_close(handle)

    if(result < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVFileClose',
                                    "'Error closing file handle "', handle, '" : ', NAVGetFileError(result)")
    }

    return result
}


/**
 * @function NAVFileRead
 * @public
 * @description Reads the entire content of a file into a buffer.
 * Opens the file, reads its content, and closes it automatically.
 *
 * @param {char[]} path - Full path to the file
 * @param {char[]} data - Output buffer to store file content (modified in-place)
 *
 * @returns {slong} 0 on success, or negative error code on failure
 *
 * @example
 * stack_var char fileContent[NAV_MAX_BUFFER]
 * stack_var slong result
 *
 * result = NAVFileRead('/config.txt', fileContent)
 * if (result >= 0) {
 *     // Use the file content
 * }
 *
 * @note The size of the output buffer limits how much data can be read
 */
define_function slong NAVFileRead(char path[], char data[]) {
    stack_var slong result
    stack_var long handle

    if (!length_array(path)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVFileRead',
                                    "NAVGetFileError(NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME), ' : The path supplied is empty.'")

        return NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    }

    result = NAVFileOpen(path, 'r')

    if (result < 0) {
        return result
    }

    handle = type_cast(result)

    result = file_read(handle, data, max_length_array(data))

    if (result < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVFileRead',
                                    "'Error reading file "', path, '" : ', NAVGetFileError(result)")
    }

    NAVFileClose(handle)

    return result
}


/**
 * @function NAVFileReadLine
 * @public
 * @description Reads a single line from an open file.
 *
 * @param {long} handle - File handle previously obtained from NAVFileOpen
 * @param {char[]} data - Output buffer to store the line (modified in-place)
 *
 * @returns {slong} Number of bytes read on success, or negative error code on failure
 *
 * @example
 * stack_var slong fileHandle
 * stack_var char line[NAV_MAX_BUFFER]
 * stack_var slong result
 *
 * fileHandle = NAVFileOpen('/config.txt', 'r')
 * if (fileHandle >= 0) {
 *     // Read file line by line
 *     while (1) {
 *         result = NAVFileReadLine(fileHandle, line)
 *         if (result < 0) break;  // End of file or error
 *         // Process the line
 *     }
 *     NAVFileClose(fileHandle)
 * }
 *
 * @note Returns NAV_FILE_ERROR_EOF_END_OF_FILE_REACHED when end of file is reached
 * @see NAVFileOpen
 * @see NAVFileClose
 */
define_function slong NAVFileReadLine(long handle, char data[]) {
    stack_var slong result

    if (!handle) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVFileReadLine',
                                    "NAVGetFileError(NAV_FILE_ERROR_INVALID_FILE_HANDLE), ' : The handle provided is null.'")
        return NAV_FILE_ERROR_INVALID_FILE_HANDLE
    }

    result = file_read_line(handle, data, max_length_array(data))

    if (result < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVFileReadLine',
                                    "'Error reading line in file : ', NAVGetFileError(result)")
    }

    return result
}


/**
 * @function NAVFileWrite
 * @public
 * @description Writes data to a file, overwriting any existing content.
 * Opens the file, writes the data, and closes it automatically.
 *
 * @param {char[]} path - Full path to the file
 * @param {char[]} data - Data to write to the file
 *
 * @returns {slong} 0 on success, or negative error code on failure
 *
 * @example
 * stack_var char content[100]
 * stack_var slong result
 *
 * content = 'New file content'
 * result = NAVFileWrite('/config.txt', content)
 * if (result < 0) {
 *     // Handle error
 * }
 *
 * @note Creates a new file if it doesn't exist, otherwise overwrites existing file
 */
define_function slong NAVFileWrite(char path[], char data[]) {
    stack_var slong result
    stack_var long handle

    if (!length_array(path)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVFileWrite',
                                    "NAVGetFileError(NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME), ' : The path supplied is empty.'")

        return NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    }

    result = NAVFileOpen(path, 'rw')

    if (result < 0) {
        return result
    }

    handle = type_cast(result)

    result = file_write(handle, data, length_array(data))

    if (result < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVFileWrite',
                                    "'Error writing file "', path, '" : ', NAVGetFileError(result)")
    }

    NAVFileClose(handle)

    return result
}


/**
 * @function NAVFileWriteLine
 * @public
 * @description Writes a line to a file, adding a carriage return and line feed.
 * Opens the file, writes the line with CRLF, and closes it automatically.
 *
 * @param {char[]} path - Full path to the file
 * @param {char[]} buffer - Line text to write
 *
 * @returns {slong} 0 on success, or negative error code on failure
 *
 * @example
 * stack_var char line[100]
 * stack_var slong result
 *
 * line = 'Config setting = value'
 * result = NAVFileWriteLine('/config.txt', line)
 *
 * @note Creates a new file if it doesn't exist, otherwise overwrites existing file
 * @see NAVFileWrite
 */
define_function slong NAVFileWriteLine(char path[], char buffer[]) {
    return NAVFileWrite(path, "buffer, NAV_CR, NAV_LF")
}


/**
 * @function NAVFileAppend
 * @public
 * @description Appends data to the end of a file.
 * Opens the file in append mode, writes the data, and closes it automatically.
 *
 * @param {char[]} path - Full path to the file
 * @param {char[]} data - Data to append to the file
 *
 * @returns {slong} 0 on success, or negative error code on failure
 *
 * @example
 * stack_var char content[100]
 * stack_var slong result
 *
 * content = 'Additional content'
 * result = NAVFileAppend('/log.txt', content)
 *
 * @note Creates a new file if it doesn't exist
 */
define_function slong NAVFileAppend(char path[], char data[]) {
    stack_var slong result
    stack_var long handle

    if (!length_array(path)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVFileAppend',
                                    "NAVGetFileError(NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME), ' : The path supplied is empty.'")

        return NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    }

    result = NAVFileOpen(path, 'rwa')

    if (result < 0) {
        return result
    }

    handle = type_cast(result)

    result = file_write(handle, data, length_array(data))

    if (result < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVFileAppend',
                                    "'Error appending file "', path, '" : ', NAVGetFileError(result)")
    }

    NAVFileClose(handle)

    return result
}


/**
 * @function NAVFileAppendLine
 * @public
 * @description Appends a line to the end of a file, adding a carriage return and line feed.
 * Opens the file in append mode, writes the line with CRLF, and closes it automatically.
 *
 * @param {char[]} path - Full path to the file
 * @param {char[]} buffer - Line text to append
 *
 * @returns {slong} 0 on success, or negative error code on failure
 *
 * @example
 * stack_var char logEntry[100]
 * stack_var slong result
 *
 * logEntry = "NAVGetTimeStamp(), ': System started'"
 * result = NAVFileAppendLine('/log.txt', logEntry)
 *
 * @note Creates a new file if it doesn't exist
 * @see NAVFileAppend
 */
define_function slong NAVFileAppendLine(char path[], char buffer[]) {
    return NAVFileAppend(path, "buffer, NAV_CR, NAV_LF")
}


/**
 * @function NAVReadDirectory
 * @public
 * @description Reads the contents of a directory and returns details about each file and subdirectory.
 *
 * @param {char[]} path - Directory path to read
 * @param {_NAVFileEntity[]} entities - Output array to store file/directory information (modified in-place)
 *
 * @returns {slong} Number of entries found on success, or negative error code on failure
 *
 * @example
 * stack_var _NAVFileEntity dirEntities[100]
 * stack_var slong count
 * stack_var integer i
 *
 * count = NAVReadDirectory('/user', dirEntities)
 * if (count > 0) {
 *     for (i = 1; i <= count; i++) {
 *         // Process each file entity
 *         if (dirEntities[i].IsDirectory) {
 *             // Handle directory
 *         } else {
 *             // Handle file
 *         }
 *     }
 * }
 *
 * @note The path should start with a '/' or one will be added automatically
 */
define_function slong NAVReadDirectory(char path[], _NAVFileEntity entities[]) {
    stack_var char entity[NAV_MAX_BUFFER]
    stack_var slong result
    stack_var long count
    stack_var long index

    index = 1

    if (!NAVStartsWith(path, '/')) {
        path = "'/', path"
    }

    result = file_dir(path, entity, index)

    if (result < 0) {
        if (result == NAV_FILE_ERROR_FILE_PATH_NOT_LOADED) {
            // Empty directory or non-existent directory
            return 0
        }

        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVReadDirectory',
                                    "'Error reading directory "', path, '" : ', NAVGetFileError(result)")

        return result
    }

    // Check if entity buffer is empty - indicates non-existent directory
    if (length_array(entity) == 0) {
        // No valid entry returned, directory likely doesn't exist
        return 0
    }

    // result contains the number of REMAINING files after index 1
    // Total files = 1 (current) + result (remaining)
    count = type_cast(result) + index
    set_length_array(entities, count)

    // Process entries starting from index 1
    while (index <= count) {
        // We already have the data for index 1 from the first call above
        // For subsequent entries, call file_dir again
        if (index > 1) {
            result = file_dir(path, entity, index)

            if (result < 0) {
                if (result == NAV_FILE_ERROR_FILE_PATH_NOT_LOADED) {
                    // No more entries - adjust count and exit
                    count = index - 1
                    set_length_array(entities, count)
                    return type_cast(count)
                }

                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_FILEUTILS__,
                                            'NAVReadDirectory',
                                            "'Error reading directory "', path, '" : ', NAVGetFileError(result)")

                index++
                continue
            }
        }

        entities[index].Name = NAVPathName(entity)
        entities[index].BaseName = NAVPathBaseName(entity)
        entities[index].Extension = NAVPathExtName(entity)
        entities[index].Path = NAVPathJoinPath(path, entity, '', '')
        entities[index].Parent = path
        entities[index].IsDirectory = NAVPathIsDirectory(entity)

        index++
    }

    return type_cast(count)
}


/**
 * @function NAVWalkDirectory
 * @public
 * @description Recursively walks a directory structure and returns all files found.
 *
 * @param {char[]} path - Starting directory path
 * @param {char[][]} files - Output array to store file paths (modified in-place)
 *
 * @returns {slong} Number of files found on success, or negative error code on failure
 *
 * @example
 * stack_var char allFiles[1000][NAV_MAX_BUFFER]
 * stack_var slong count
 * stack_var integer i
 *
 * count = NAVWalkDirectory('/user', allFiles)
 * if (count > 0) {
 *     for (i = 1; i <= count; i++) {
 *         // Process each file
 *     }
 * }
 *
 * @note If path is empty, it defaults to the root directory '/'
 * @note This function will recursively scan all subdirectories
 */
define_function slong NAVWalkDirectory(char path[], char files[][]) {
    stack_var _NAVFileEntity entities[1000]
    stack_var slong count
    stack_var integer x
    stack_var integer fileCount
    stack_var integer startIndex

    if (!length_array(path)) {
        path = '/'
    }

    // Get starting index from current array length
    startIndex = length_array(files)

    count = NAVReadDirectory(path, entities)
    if (count <= 0) {
        return count
    }

    for (x = 1; x <= length_array(entities); x++) {
        stack_var _NAVFileEntity entity
        stack_var char entityPath[NAV_MAX_BUFFER]

        entity = entities[x]
        entityPath = NAVPathJoinPath(path, entity.BaseName, '', '')

        if (entity.IsDirectory) {
            stack_var slong result

            // Recursively walk subdirectory - it will append to files array
            result = NAVWalkDirectory(entityPath, files)

            // Log errors but continue processing other directories
            if (result < 0) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                            __NAV_FOUNDATION_FILEUTILS__,
                                            'NAVWalkDirectory',
                                            "'Error walking subdirectory "', entityPath, '" : ', NAVGetFileError(result)")
            }
        }
        else {
            // Add file to the array
            fileCount = length_array(files) + 1
            set_length_array(files, fileCount)
            files[fileCount] = entityPath
        }
    }

    // Return total number of files added by this call (and recursive calls)
    count = type_cast(length_array(files) - startIndex)

    return count
}


/**
 * @function NAVFileExists
 * @public
 * @description Checks if a file exists at the specified path.
 *
 * @param {char[]} path - Path to the file (relative or absolute)
 *
 * @returns {char} true if the file exists, false otherwise
 *
 * @example
 * stack_var char exists
 *
 * // Absolute path
 * exists = NAVFileExists('/user/config.txt')
 *
 * // Relative path (checked in root directory)
 * exists = NAVFileExists('config.txt')
 */
define_function char NAVFileExists(char path[]) {
    stack_var _NAVFileEntity entities[255]
    stack_var char dirPath[NAV_MAX_BUFFER]
    stack_var char fileName[NAV_MAX_BUFFER]
    stack_var integer x

    if (!length_array(path)) {
        return false
    }

    dirPath = NAVPathDirName(path)
    fileName = NAVPathBaseName(path)

    if (!length_array(fileName)) {
        return false
    }

    // Handle current directory indicator
    if (dirPath == '.') {
        dirPath = '/'
    }

    // Ensure directory path starts with /
    if (!NAVStartsWith(dirPath, '/')) {
        dirPath = "'/', dirPath"
    }

    if (NAVReadDirectory(dirPath, entities) <= 0) {
        return false
    }

    for (x = 1; x <= length_array(entities); x++) {
        if (entities[x].BaseName == fileName && !entities[x].IsDirectory) {
            return true
        }
    }

    return false
}


/**
 * @function NAVDirectoryExists
 * @public
 * @description Checks if a directory exists.
 *
 * @param {char[]} path - Directory path to check
 *
 * @returns {char} true if the directory exists, false otherwise
 *
 * @example
 * stack_var char exists
 *
 * exists = NAVDirectoryExists('/user/data')
 * if (!exists) {
 *     // Directory doesn't exist, create it
 *     NAVDirectoryCreate('/user/data')
 * }
 *
 * @note If path is empty, it defaults to the root directory '/'
 */
define_function char NAVDirectoryExists(char path[]) {
    stack_var _NAVFileEntity entities[255]
    stack_var char dirPath[NAV_MAX_BUFFER]
    stack_var char parentPath[NAV_MAX_BUFFER]
    stack_var char dirName[NAV_MAX_BUFFER]
    stack_var integer x

    if (!length_array(path)) {
        return false
    }

    dirPath = path

    // Handle current directory indicator
    if (dirPath == '.') {
        dirPath = '/'
    }

    // Ensure directory path starts with /
    if (!NAVStartsWith(dirPath, '/')) {
        dirPath = "'/', dirPath"
    }

    // Remove trailing slash if present (except for root)
    if (length_array(dirPath) > 1 && NAVEndsWith(dirPath, '/')) {
        dirPath = left_string(dirPath, length_array(dirPath) - 1)
    }

    // Root directory always exists
    if (dirPath == '/') {
        return true
    }

    // Get parent directory and directory name
    parentPath = NAVPathDirName(dirPath)
    dirName = NAVPathBaseName(dirPath)

    // If parent is '.', convert to root
    if (parentPath == '.') {
        parentPath = '/'
    }

    // Read parent directory to check if this directory exists in it
    if (NAVReadDirectory(parentPath, entities) <= 0) {
        return false
    }

    // Search for the directory name in parent's contents
    for (x = 1; x <= length_array(entities); x++) {
        if (entities[x].BaseName == dirName && entities[x].IsDirectory) {
            return true
        }
    }

    return false
}


/**
 * @function NAVDirectoryCreate
 * @public
 * @description Creates a new directory.
 *
 * @param {char[]} path - Path of the directory to create
 *
 * @returns {slong} 0 on success, or negative error code on failure
 *
 * @example
 * stack_var slong result
 *
 * result = NAVDirectoryCreate('/user/logs')
 * if (result < 0) {
 *     // Handle directory creation error
 * }
 *
 * @note Parent directories must exist
 */
define_function slong NAVDirectoryCreate(char path[]) {
    stack_var slong result

    if (!length_array(path)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVDirectoryCreate',
                                    "NAVGetFileError(NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME), ' : The path supplied is empty.'")

        return NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    }

    result = file_createdir(path)

    if (result < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVDirectoryCreate',
                                    "'Error creating directory "', path, '" : ', NAVGetFileError(result)")
    }

    return result
}


/**
 * @function NAVDirectoryDelete
 * @public
 * @description Deletes a directory.
 *
 * @param {char[]} path - Path of the directory to delete
 *
 * @returns {slong} 0 on success, or negative error code on failure
 *
 * @example
 * stack_var slong result
 *
 * result = NAVDirectoryDelete('/user/temp')
 * if (result < 0) {
 *     // Handle directory deletion error
 * }
 *
 * @note Directory must be empty to be deleted
 */
define_function slong NAVDirectoryDelete(char path[]) {
    stack_var slong result

    if (!length_array(path)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVDirectoryDelete',
                                    "NAVGetFileError(NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME), ' : The path supplied is empty.'")

        return NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    }

    result = file_removedir(path)

    if (result < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVDirectoryDelete',
                                    "'Error deleting directory "', path, '" : ', NAVGetFileError(result)")
    }

    return result
}


/**
 * @function NAVFileSeek
 * @public
 * @description Seeks to a specific position in an open file.
 *
 * @param {long} handle - File handle returned by NAVFileOpen
 * @param {slong} position - Byte position to seek to:
 *                           0 = beginning of file
 *                           -1 = end of file (use NAV_FILE_SEEK_END constant)
 *                           N = absolute byte position
 *
 * @returns {slong} New position in file on success, or negative error code on failure
 *
 * @example
 * stack_var long handle
 * stack_var slong position
 *
 * handle = type_cast(NAVFileOpen('/data.txt', 'r'))
 *
 * // Seek to beginning
 * position = NAVFileSeek(handle, 0)
 *
 * // Seek to end (get file size)
 * position = NAVFileSeek(handle, NAV_FILE_SEEK_END)
 *
 * // Seek to specific byte
 * position = NAVFileSeek(handle, 100)
 *
 * NAVFileClose(handle)
 *
 * @note AMX file_seek only supports absolute positioning, not relative
 * @see NAVFileOpen
 * @see NAVFileClose
 */
define_function slong NAVFileSeek(long handle, slong position) {
    stack_var slong result

    if (!handle) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVFileSeek',
                                    "NAVGetFileError(NAV_FILE_ERROR_INVALID_FILE_HANDLE), ' : Invalid file handle (0)'")

        return NAV_FILE_ERROR_INVALID_FILE_HANDLE
    }

    result = file_seek(handle, type_cast(position))

    if (result < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVFileSeek',
                                    "'Error seeking to position ', itoa(position), ' : ', NAVGetFileError(result)")
    }

    return result
}


/**
 * @function NAVFileGetSize
 * @public
 * @description Gets the size of a file in bytes.
 *
 * @param {char[]} path - Path to the file
 *
 * @returns {slong} File size in bytes on success, or negative error code on failure
 *
 * @example
 * stack_var slong fileSize
 *
 * fileSize = NAVFileGetSize('/user/data.bin')
 * if (fileSize >= 0) {
 *     // Use file size
 * }
 */
define_function slong NAVFileGetSize(char path[]) {
    stack_var slong result
    stack_var long handle

    result = NAVFileOpen(path, 'r')

    if (result < 0) {
        return result
    }

    handle = type_cast(result)

    // Use NAVFileSeek to get file size by seeking to end
    result = NAVFileSeek(handle, NAV_FILE_SEEK_END)

    NAVFileClose(handle)

    return result
}


/**
 * @function NAVFileRename
 * @public
 * @description Renames a file or moves it to a new location.
 *
 * @param {char[]} source - Current path of the file
 * @param {char[]} destination - New path for the file
 *
 * @returns {slong} 0 on success, or negative error code on failure
 *
 * @example
 * stack_var slong result
 *
 * // Rename a file
 * result = NAVFileRename('/user/old.txt', '/user/new.txt')
 *
 * // Move a file
 * result = NAVFileRename('/user/file.txt', '/archive/file.txt')
 */
define_function slong NAVFileRename(char source[], char destination[]) {
    stack_var slong result

    if (!length_array(source)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVFileRename',
                                    "NAVGetFileError(NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME), ' : The source path supplied is empty.'")

        return NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    }

    if (!length_array(destination)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVFileRename',
                                    "NAVGetFileError(NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME), ' : The destination path supplied is empty.'")

        return NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    }

    result = file_rename(source, destination)

    if (result < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVFileRename',
                                    "'Error renaming file "', source, '" : ', NAVGetFileError(result)")
    }

    return result
}


/**
 * @function NAVFileDelete
 * @public
 * @description Deletes a file.
 *
 * @param {char[]} path - Path of the file to delete
 *
 * @returns {slong} 0 on success, or negative error code on failure
 *
 * @example
 * stack_var slong result
 *
 * result = NAVFileDelete('/user/temp.txt')
 * if (result < 0) {
 *     // Handle file deletion error
 * }
 */
define_function slong NAVFileDelete(char path[]) {
    stack_var slong result

    if (!length_array(path)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVFileDelete',
                                    "NAVGetFileError(NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME), ' : The path supplied is empty.'")

        return NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    }

    result = file_delete(path)

    if (result < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVFileDelete',
                                    "'Error deleting file "', path, '" : ', NAVGetFileError(result)")
    }

    return result
}


/**
 * @function NAVFileCopy
 * @public
 * @description Copies a file from one location to another.
 *
 * @param {char[]} source - Path of the source file
 * @param {char[]} destination - Path of the destination file
 *
 * @returns {slong} 0 on success, or negative error code on failure
 *
 * @example
 * stack_var slong result
 *
 * result = NAVFileCopy('/user/original.txt', '/backup/original.txt')
 * if (result < 0) {
 *     // Handle file copy error
 * }
 *
 * @note If the destination file already exists, it will be overwritten
 */
define_function slong NAVFileCopy(char source[], char destination[]) {
    stack_var slong result

    if (!length_array(source)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVFileCopy',
                                    "NAVGetFileError(NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME), ' : The source path supplied is empty.'")

        return NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    }

    if (!length_array(destination)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVFileCopy',
                                    "NAVGetFileError(NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME), ' : The destination path supplied is empty.'")

        return NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    }

    result = file_copy(source, destination)

    if (result < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVFileCopy',
                                    "'Error copying file "', source, '" to "', destination, '" : ', NAVGetFileError(result)")
    }

    return result
}


#END_IF // __NAV_FOUNDATION_FILEUTILS__
