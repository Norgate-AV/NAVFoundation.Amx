PROGRAM_NAME='NAVFoundation.FileUtils'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2022 Norgate AV Solutions Ltd

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


DEFINE_TYPE

struct _NAVFileEntity {
    char Name[NAV_MAX_BUFFER]
    char BaseName[NAV_MAX_BUFFER]
    char Extension[NAV_MAX_CHARS]
    char Path[NAV_MAX_BUFFER]
    char Parent[NAV_MAX_BUFFER]
    integer IsDirectory
}


define_function integer NAVIsDirectory(char entity[]) {
    if (NAVStartsWith(entity, '/')) {
        return true
    }

    return false
}


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


define_function slong NAVFileReadLine(long handle, char data[]) {
    stack_var slong result

    if (!handle) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVFileReadLine',
                                    "NAVGetFileError(NAV_FILE_ERROR_INVALID_FILE_HANDLE), ' : The handle provided is null.'")
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


define_function slong NAVFileAppendLine(char path[], char buffer[]) {
    return NAVFileAppend(path, "buffer, NAV_CR, NAV_LF")
}


define_function slong NAVReadDirectory(char path[], _NAVFileEntity entities[]) {
    stack_var char entity[NAV_MAX_BUFFER]
    stack_var slong result
    stack_var long count
    stack_var long index

    index = 1

    if (!length_array(path)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVReadDirectory',
                                    'The path supplied is empty. Using root directory.')

        path = '/'
    }

    result = file_dir(path, entity, index)

    if (result < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_FILEUTILS__,
                                    'NAVReadDirectory',
                                    "'Error reading directory "', path, '" : ', NAVGetFileError(result)")

        return result
    }

    count = type_cast(result)
    if (count == 0) {
        return type_cast(count)
    }

    count = count + index
    set_length_array(entities, count)

    while (index <= count) {
        result = file_dir(path, entity, index)

        if (result < 0) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_FILEUTILS__,
                                        'NAVReadDirectory',
                                        "'Error reading directory "', path, '" : ', NAVGetFileError(result)")

            continue
        }

        entities[index].Name = NAVGetFileEntityName(entity)
        entities[index].BaseName = NAVGetFileEntityBaseName(entity)
        entities[index].Extension = NAVGetFileEntityExtension(entity)
        entities[index].Path = entity
        entities[index].Parent = NAVGetFileEntityParent(entity)
        entities[index].IsDirectory = NAVIsDirectory(entity)

        #IF_DEFINED NAV_FILEUTILS_DEBUG
        NAVLog("'Entity ', itoa(index), ' Name: ', entities[index].Name")
        NAVLog("'Entity ', itoa(index), ' BaseName: ', entities[index].BaseName")
        NAVLog("'Entity ', itoa(index), ' Extension: ', entities[index].Extension")
        NAVLog("'Entity ', itoa(index), ' Path: ', entities[index].Path")
        NAVLog("'Entity ', itoa(index), ' Parent: ', entities[index].Parent")
        NAVLog("'Entity ', itoa(index), ' IsDirectory: ', NAVIntegerToBooleanString(entities[index].IsDirectory)")
        #END_IF

        index++
    }

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                __NAV_FOUNDATION_FILEUTILS__,
                                'NAVReadDirectory',
                                "'Number of entities: ', itoa(count)")

    return type_cast(count)
}


define_function char[NAV_MAX_BUFFER] NAVGetFileEntityBaseName(char path[]) {
    stack_var char name[NAV_MAX_BUFFER]
    stack_var integer index

    if (NAVIsDirectory(path)) {
        return name
    }

    index = length_array(path)

    while (index > 0) {
        if (path[index] == '/' || path[index] == '\') {
            break
        }

        index--
    }

    // name = NAVGetFileEntityName(path)

    return NAVStringSubstring(name, index + 1, NAVIndexOf(name, '.', 1))
}


define_function char[NAV_MAX_BUFFER] NAVGetFileEntityParent(char path[]) {
    stack_var integer index
    stack_var char parent[NAV_MAX_BUFFER]

    index = length_array(path)

    while (index > 0) {
        if (path[index] == '/' || path[index] == '\') {
            break
        }

        index--
    }

    parent = NAVStringSubstring(path, 1, index)

    if (length_array(parent) == 0) {
        parent = '/'
    }

    return parent
}


define_function char[NAV_MAX_BUFFER] NAVGetFileEntityName(char path[]) {
    stack_var integer index

    index = length_array(path)

    while (index > 0) {
        if (path[index] == '/' || path[index] == '\') {
            break
        }

        index--
    }

    return NAVStringSubstring(path, index + 1, length_array(path))
}


define_function char[NAV_MAX_CHARS] NAVGetFileEntityExtension(char path[]) {
    stack_var integer index

    if (NAVIsDirectory(path)) {
        return ''
    }

    index = length_array(path)

    while (index > 0) {
        if (path[index] == '.') {
            break
        }

        index--
    }

    return NAVStringSubstring(path, index + 1, length_array(path))
}


define_function slong NAVWalkDirectory(char path[], char files[][]) {
    stack_var _NAVFileEntity entities[1000]
    stack_var slong count
    stack_var integer x

    if (!length_array(path)) {
        path = '/'
    }

    count = NAVReadDirectory(path, entities)
    if (count <= 0) {
        return count
    }

    for (x = 1; x <= length_array(entities); x++) {
        stack_var _NAVFileEntity entity
        stack_var char entityPath[NAV_MAX_BUFFER]

        entity = entities[x]
        entityPath = NAVJoinPath(path, entity.Name)

        if (entity.IsDirectory) {
            NAVWalkDirectory(entityPath, files)
        }
        else {
            // files[count] = entityPath
            // count++
        }
    }

    return count
}


define_function integer NAVFileExists(char path[], char fileName[]) {
    stack_var _NAVFileEntity entities[255]
    stack_var integer x

    if (!length_array(fileName)) {
        return false
    }

    if (!length_array(path)) {
        path = '/'
    }

    if (NAVReadDirectory(path, entities) <= 0) {
        return false
    }

    for (x = 1; x <= length_array(entities); x++) {
        if (entities[x].Name == fileName) {
            return true
        }
    }

    return false
}


define_function char[NAV_MAX_BUFFER] NAVJoinPath(char parent[], char child[]) {
    stack_var char path[NAV_MAX_BUFFER]

    path = ""

    if (!length_array(parent)) {
        return path
    }

    path = parent
    if (!NAVStartsWith(path, '/')) {
        path = "'/', path"
    }

    if (!length_array(child)) {
        return path
    }

    path = "path, '/', child"

    return path
}


// define_function NAVReadCsvFile(char path[], char lines[][]) {
//     stack_var char file[NAV_MAX_BUFFER]
//     stack_var integer index
//     stack_var integer lineIndex

//     if (!length_array(path)) {
//         return
//     }

//     file = NAVFileRead(path)
//     if (!length_array(file)) {
//         return
//     }

//     index = 0
//     lineIndex = 0

//     while (index < length_array(file)) {
//         stack_var char line[NAV_MAX_BUFFER]
//         stack_var integer lineLength

//         line = NAVStringSubstring(file, index, index + 1)
//         lineLength = length_array(line)

//         if (lineLength == 0) {
//             break
//         }

//     }
// }


// define_function slong NAVSplitPath(char path[], char elements[][]) {
//     stack_var char element[NAV_MAX_BUFFER]
//     stack_var long index
//     stack_var long count

//     if (!length_array(path)) {
//         return 0
//     }

//     count = 0
//     index = 0

//     while (index < length_array(path)) {
//         element = NAVSubstring(path, index, index + 1)

//         if (element == '/') {
//             if (length_array(elements[count])) {
//                 count++
//             }
//         } else {
//             elements[count] = "elements[count], element"
//         }

//         index++
//     }

//     if (length_array(elements[count])) {
//         count++
//     }

//     return count
// }


#END_IF // __NAV_FOUNDATION_FILEUTILS__
