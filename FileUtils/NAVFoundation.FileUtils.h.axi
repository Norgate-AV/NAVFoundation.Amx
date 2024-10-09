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

#include 'NAVFoundation.Core.axi'


DEFINE_CONSTANT

constant slong NAV_FILE_ERROR_INVALID_FILE_HANDLE                          = -1
constant slong NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME                    = -2
constant slong NAV_FILE_ERROR_INVALID_VALUE_SUPPLIED_FOR_IO_FLAG           = -3
constant slong NAV_FILE_ERROR_INVALID_FILE_PATH                            = -4
constant slong NAV_FILE_ERROR_DISK_IO_ERROR                                = -5
constant slong NAV_FILE_ERROR_INVALID_PARAMETER                            = -6
constant slong NAV_FILE_ERROR_FILE_ALREADY_CLOSED                          = -7
constant slong NAV_FILE_ERROR_FILE_NAME_EXISTS                             = -8
constant slong NAV_FILE_ERROR_EOF_END_OF_FILE_REACHED                      = -9
constant slong NAV_FILE_ERROR_BUFFER_TOO_SMALL                             = -10
constant slong NAV_FILE_ERROR_DISK_FULL                                    = -11
constant slong NAV_FILE_ERROR_FILE_PATH_NOT_LOADED                         = -12
constant slong NAV_FILE_ERROR_DIRECTORY_NAME_EXISTS                        = -13
constant slong NAV_FILE_ERROR_MAXIMUM_NUMBER_OF_FILES_ARE_ALREADY_OPEN     = -14
constant slong NAV_FILE_ERROR_INVALID_FILE_FORMAT                          = -15

constant slong NAV_FILE_SEEK_END                                           = -1


DEFINE_TYPE

struct _NAVFileEntity {
    char Name[NAV_MAX_BUFFER]
    char BaseName[NAV_MAX_BUFFER]
    char Extension[NAV_MAX_CHARS]
    char Path[NAV_MAX_BUFFER]
    char Parent[NAV_MAX_BUFFER]
    char IsDirectory
}


#END_IF // __NAV_FOUNDATION_FILEUTILS_H__
