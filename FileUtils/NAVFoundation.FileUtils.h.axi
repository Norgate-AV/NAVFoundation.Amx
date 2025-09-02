PROGRAM_NAME='NAVFoundation.FileUtils.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_FILEUTILS_H__
#DEFINE __NAV_FOUNDATION_FILEUTILS_H__ 'NAVFoundation.FileUtils.h'

DEFINE_CONSTANT

/**
 * @section File Error Constants
 * @description Error codes returned by file operations
 */

/**
 * @constant NAV_FILE_ERROR_INVALID_FILE_HANDLE
 * @description Error: The provided file handle is not valid
 */
constant slong NAV_FILE_ERROR_INVALID_FILE_HANDLE                          = -1

/**
 * @constant NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
 * @description Error: The file path or name is invalid
 */
constant slong NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME                    = -2

/**
 * @constant NAV_FILE_ERROR_INVALID_VALUE_SUPPLIED_FOR_IO_FLAG
 * @description Error: The I/O flag value is invalid (must be FILE_READ_ONLY, FILE_RW_NEW, etc.)
 */
constant slong NAV_FILE_ERROR_INVALID_VALUE_SUPPLIED_FOR_IO_FLAG           = -3

/**
 * @constant NAV_FILE_ERROR_INVALID_FILE_PATH
 * @description Error: The file path is invalid or inaccessible
 */
constant slong NAV_FILE_ERROR_INVALID_FILE_PATH                            = -4

/**
 * @constant NAV_FILE_ERROR_DISK_IO_ERROR
 * @description Error: A disk I/O error occurred during operation
 */
constant slong NAV_FILE_ERROR_DISK_IO_ERROR                                = -5

/**
 * @constant NAV_FILE_ERROR_INVALID_PARAMETER
 * @description Error: An invalid parameter was provided (e.g., buffer length <= 0)
 */
constant slong NAV_FILE_ERROR_INVALID_PARAMETER                            = -6

/**
 * @constant NAV_FILE_ERROR_FILE_ALREADY_CLOSED
 * @description Error: Attempting to close a file that is already closed
 */
constant slong NAV_FILE_ERROR_FILE_ALREADY_CLOSED                          = -7

/**
 * @constant NAV_FILE_ERROR_FILE_NAME_EXISTS
 * @description Error: Attempting to create a file but the name already exists
 */
constant slong NAV_FILE_ERROR_FILE_NAME_EXISTS                             = -8

/**
 * @constant NAV_FILE_ERROR_EOF_END_OF_FILE_REACHED
 * @description Error: End-of-file was reached during a read operation
 */
constant slong NAV_FILE_ERROR_EOF_END_OF_FILE_REACHED                      = -9

/**
 * @constant NAV_FILE_ERROR_BUFFER_TOO_SMALL
 * @description Error: The provided buffer is too small to hold the data
 */
constant slong NAV_FILE_ERROR_BUFFER_TOO_SMALL                             = -10

/**
 * @constant NAV_FILE_ERROR_DISK_FULL
 * @description Error: The disk is full, operation cannot complete
 */
constant slong NAV_FILE_ERROR_DISK_FULL                                    = -11

/**
 * @constant NAV_FILE_ERROR_FILE_PATH_NOT_LOADED
 * @description Error: The file path could not be loaded or doesn't exist
 */
constant slong NAV_FILE_ERROR_FILE_PATH_NOT_LOADED                         = -12

/**
 * @constant NAV_FILE_ERROR_DIRECTORY_NAME_EXISTS
 * @description Error: Attempting to create a directory but the name already exists
 */
constant slong NAV_FILE_ERROR_DIRECTORY_NAME_EXISTS                        = -13

/**
 * @constant NAV_FILE_ERROR_MAXIMUM_NUMBER_OF_FILES_ARE_ALREADY_OPEN
 * @description Error: Maximum number of open files has been reached (limit is 10)
 */
constant slong NAV_FILE_ERROR_MAXIMUM_NUMBER_OF_FILES_ARE_ALREADY_OPEN     = -14

/**
 * @constant NAV_FILE_ERROR_INVALID_FILE_FORMAT
 * @description Error: The file format is invalid or corrupted
 */
constant slong NAV_FILE_ERROR_INVALID_FILE_FORMAT                          = -15

/**
 * @constant NAV_FILE_SEEK_END
 * @description Special value for file_seek to position at the end of file
 * @note Used as: file_seek(handle, type_cast(NAV_FILE_SEEK_END))
 */
constant slong NAV_FILE_SEEK_END                                           = -1


DEFINE_TYPE

/**
 * @struct _NAVFileEntity
 * @description Represents a file or directory entry from the filesystem
 *
 * @property {char[NAV_MAX_BUFFER]} Name - Full name of the file or directory
 * @property {char[NAV_MAX_BUFFER]} BaseName - Name without directory path
 * @property {char[NAV_MAX_CHARS]} Extension - File extension (e.g. '.txt')
 * @property {char[NAV_MAX_BUFFER]} Path - Complete path including filename
 * @property {char[NAV_MAX_BUFFER]} Parent - Parent directory path
 * @property {char} IsDirectory - Boolean flag, true if the entity is a directory
 */
struct _NAVFileEntity {
    char Name[NAV_MAX_BUFFER]
    char BaseName[NAV_MAX_BUFFER]
    char Extension[NAV_MAX_CHARS]
    char Path[NAV_MAX_BUFFER]
    char Parent[NAV_MAX_BUFFER]
    char IsDirectory
}


#END_IF // __NAV_FOUNDATION_FILEUTILS_H__
