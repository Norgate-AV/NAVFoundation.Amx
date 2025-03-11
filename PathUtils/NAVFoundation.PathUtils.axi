PROGRAM_NAME='NAVFoundation.PathUtils'

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

/**
 * @file NAVFoundation.PathUtils.axi
 * @brief Utility functions for file path manipulation.
 *
 * This module provides a comprehensive set of functions for manipulating file paths,
 * including extracting components, normalizing paths, resolving paths, and determining path relationships.
 * The implementation is inspired by Node.js path module and provides similar functionality.
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_PATHUTILS__
#DEFINE __NAV_FOUNDATION_PATHUTILS__ 'NAVFoundation.PathUtils'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.StringUtils.axi'


DEFINE_CONSTANT

/**
 * @constant NAV_CHAR_DOT
 * @description ASCII value of a dot character (.)
 */
constant char NAV_CHAR_DOT              = 46

/**
 * @constant NAV_CHAR_FORWARD_SLASH
 * @description ASCII value of a forward slash character (/)
 */
constant char NAV_CHAR_FORWARD_SLASH    = 47

/**
 * @constant NAV_CHAR_BACKWARD_SLASH
 * @description ASCII value of a backward slash character (\)
 */
constant char NAV_CHAR_BACKWARD_SLASH   = 92

/**
 * @constant NAV_PATH_RESOLVE_MAX_ARGS
 * @description Maximum number of arguments for path resolve functions
 */
constant integer NAV_PATH_RESOLVE_MAX_ARGS  = 4

/**
 * @constant NAV_PATH_JOIN_MAX_ARGS
 * @description Maximum number of arguments for path join functions
 */
constant integer NAV_PATH_JOIN_MAX_ARGS     = 4


/**
 * @function NAVPathIsDirectory
 * @public
 * @description Determines if a path refers to a directory.
 *
 * This function checks if the path begins with a forward slash,
 * which is a simple heuristic for identifying directories.
 *
 * @param {char[]} entity - The path to check
 *
 * @returns {char} TRUE if the path appears to be a directory, FALSE otherwise
 *
 * @example
 * stack_var char isDir
 *
 * isDir = NAVPathIsDirectory('/home/user')  // Returns TRUE
 * isDir = NAVPathIsDirectory('file.txt')    // Returns FALSE
 */
define_function char NAVPathIsDirectory(char entity[]) {
    if (NAVStartsWith(entity, '/')) {
        return true
    }

    return false
}


/**
 * @function NAVPathBaseName
 * @public
 * @description Extracts the last portion of a path.
 *
 * Returns the last part of a path, similar to the Unix basename command.
 *
 * @param {char[]} path - The path to process
 *
 * @returns {char[NAV_MAX_BUFFER]} The last portion of the path (filename or directory name)
 *
 * @example
 * stack_var char result[NAV_MAX_BUFFER]
 *
 * result = NAVPathBaseName('/home/user/file.txt')  // Returns 'file.txt'
 * result = NAVPathBaseName('/home/user/')          // Returns '' (empty string)
 * result = NAVPathBaseName('file.txt')             // Returns 'file.txt'
 *
 * @see NAVPathDirName
 * @see NAVPathName
 */
define_function char[NAV_MAX_BUFFER] NAVPathBaseName(char path[]) {
    stack_var char node[255][255]
    stack_var integer count

    if (!length_array(path)) {
        return ''
    }

    if (path == '/' || path == '\') {
        return ''
    }

    count = NAVPathSplitPath(NAVPathRemoveEscapedBackslashes(path), node)

    if (count <= 0) {
        return ''
    }

    return node[count]
}


/**
 * @function NAVPathExtName
 * @public
 * @description Returns the extension of a path.
 *
 * Extracts the file extension including the dot (.) character.
 *
 * @param {char[]} path - The path to process
 *
 * @returns {char[NAV_MAX_BUFFER]} The file extension (including the dot), or empty string if none
 *
 * @example
 * stack_var char result[NAV_MAX_BUFFER]
 *
 * result = NAVPathExtName('/home/user/file.txt')  // Returns '.txt'
 * result = NAVPathExtName('index.html')           // Returns '.html'
 * result = NAVPathExtName('file')                 // Returns ''
 *
 * @see NAVPathBaseName
 * @see NAVPathName
 */
define_function char[NAV_MAX_BUFFER] NAVPathExtName(char path[]) {
    stack_var char basename[255]
    stack_var integer index

    if (!length_array(path)) {
        return ''
    }

    basename = NAVPathBaseName(path)

    if (!length_array(basename)) {
        return ''
    }

    if (path == '.' || path == '..') {
        return ''
    }

    index = NAVLastIndexOf(basename, '.')
    if (index <= 0) {
        return ''
    }

    return NAVStringSubstring(basename, index, (length_array(basename) - index) + 1)
}


/**
 * @function NAVPathDirName
 * @public
 * @description Returns the directory portion of a path.
 *
 * Returns the directory name of a path, similar to the Unix dirname command.
 *
 * @param {char[]} path - The path to process
 *
 * @returns {char[NAV_MAX_BUFFER]} The directory portion of the path
 *
 * @example
 * stack_var char result[NAV_MAX_BUFFER]
 *
 * result = NAVPathDirName('/home/user/file.txt')  // Returns '/home/user'
 * result = NAVPathDirName('/home/user/')          // Returns '/home'
 * result = NAVPathDirName('file.txt')             // Returns '.'
 *
 * @see NAVPathBaseName
 */
define_function char[NAV_MAX_BUFFER] NAVPathDirName(char path[]) {
    stack_var integer x
    stack_var char hasRoot
    stack_var char matchedSlash
    stack_var sinteger end

    if (!length_array(path)) {
        return "'.'"
    }

    hasRoot = NAVStartsWith(path, '/')

    end = -1
    matchedSlash = true

    for (x = length_array(path); x >= 1; x--) {
        if (path[x] == NAV_CHAR_FORWARD_SLASH) {
            if (!matchedSlash) {
                end = type_cast(x)
                break
            }
        }
        else {
            matchedSlash = false
        }
    }

    if (end == -1) {
        if (hasRoot) {
            return "'/'"
        }

        return "'.'"
    }

    if (hasRoot && end == 1) {
        return "'//'"
    }

    return NAVStringSubstring(path, 1, type_cast(end - 1))
}


/**
 * @function NAVPathName
 * @public
 * @description Returns the filename without extension.
 *
 * Extracts the filename portion of a path without its extension.
 *
 * @param {char[]} path - The path to process
 *
 * @returns {char[NAV_MAX_BUFFER]} The filename without extension
 *
 * @example
 * stack_var char result[NAV_MAX_BUFFER]
 *
 * result = NAVPathName('/home/user/file.txt')  // Returns 'file'
 * result = NAVPathName('index.html')           // Returns 'index'
 * result = NAVPathName('file')                 // Returns 'file'
 *
 * @see NAVPathBaseName
 * @see NAVPathExtName
 */
define_function char[NAV_MAX_BUFFER] NAVPathName(char path[]) {
    stack_var char basename[255]

    if (!length_array(path)) {
        return ''
    }

    basename = NAVPathBaseName(path)

    if (!length_array(basename)) {
        return ''
    }

    if (NAVContains(basename, '.')) {
        return NAVStringSubstring(basename, 1, NAVIndexOf(basename, '.', 1) - 1)
    }

    return basename
}


/**
 * @function NAVPathJoinPath
 * @public
 * @description Joins path segments into a single path.
 *
 * Combines multiple path segments into a single normalized path.
 * NetLinx does not support variadic functions, so this function is limited
 * to combining up to 4 path segments.
 *
 * @param {char[]} arg1 - First path segment
 * @param {char[]} arg2 - Second path segment (optional)
 * @param {char[]} arg3 - Third path segment (optional)
 * @param {char[]} arg4 - Fourth path segment (optional)
 *
 * @returns {char[NAV_MAX_BUFFER]} The combined normalized path
 *
 * @example
 * stack_var char result[NAV_MAX_BUFFER]
 *
 * result = NAVPathJoinPath('/home', 'user', 'docs', '')
 * // Returns '/home/user/docs'
 *
 * result = NAVPathJoinPath('base', '../sibling', '', '')
 * // Returns 'sibling' (with normalization)
 *
 * @note Empty string arguments are ignored. Use empty strings for unused arguments.
 * @note To join more than 4 segments, use multiple calls to this function.
 *
 * @see NAVPathNormalize
 */
define_function char[NAV_MAX_BUFFER] NAVPathJoinPath(char arg1[], char arg2[], char arg3[], char arg4[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var char path[255]
    stack_var integer length
    stack_var integer x

    for (x = NAV_PATH_JOIN_MAX_ARGS; x >= 1; x--) {
        length = x

        switch (x) {
            case 4: {
                if (!length_array(arg4)) {
                    continue
                }

                break
            }
            case 3: {
                if (!length_array(arg3)) {
                    continue
                }

                break
            }
            case 2: {
                if (!length_array(arg2)) {
                    continue
                }

                break
            }
            case 1: {
                if (!length_array(arg1)) {
                    continue
                }

                break
            }
            case 0: {
                break
            }
        }

        break
    }

    if (!length) {
        return "'.'"
    }

    result = ''

    for (x = 0; x < length; x++) {
        switch (x + 1) {
            case 1: {
                path = NAVPathRemoveEscapedBackslashes(arg1)
            }
            case 2: {
                path = NAVPathRemoveEscapedBackslashes(arg2)
            }
            case 3: {
                path = NAVPathRemoveEscapedBackslashes(arg3)
            }
            case 4: {
                path = NAVPathRemoveEscapedBackslashes(arg4)
            }
        }

        if (!length_array(result)) {
            result = path
            continue
        }

        result = "result, '/', path"
    }

    if (!length_array(result)) {
        return "'.'"
    }

    return NAVPathNormalize(result)
}


/**
 * @function NAVPathSplitPath
 * @public
 * @description Splits a path into its component parts.
 *
 * Splits a path string into an array of path segments using either
 * forward or backward slashes as separators.
 *
 * @param {char[]} path - The path to split
 * @param {char[][]} elements - Output array to store the path segments
 *
 * @returns {integer} Number of path segments found
 *
 * @example
 * stack_var char segments[10][255]
 * stack_var integer count
 *
 * count = NAVPathSplitPath('/home/user/docs', segments)
 * // count = 3, segments = ['home', 'user', 'docs']
 *
 * @note If the path contains no separators, the count will be 0
 * @note This function works with either forward (/) or backward (\) slashes
 */
define_function integer NAVPathSplitPath(char path[], char elements[][]) {
    stack_var integer count

    count = NAVSplitString(path, '/', elements)

    if (count > 0) {
        return count
    }

    count = NAVSplitString(path, '\', elements)

    if (count > 0) {
        return count
    }

    return count
}


/**
 * @function NAVPathIsAbsolute
 * @public
 * @description Determines if a path is absolute.
 *
 * Checks if the path starts with a forward slash, indicating
 * it is an absolute path.
 *
 * @param {char[]} path - The path to check
 *
 * @returns {char} TRUE if the path is absolute, FALSE otherwise
 *
 * @example
 * stack_var char result
 *
 * result = NAVPathIsAbsolute('/home/user')  // Returns TRUE
 * result = NAVPathIsAbsolute('user/docs')   // Returns FALSE
 */
define_function char NAVPathIsAbsolute(char path[]) {
    return NAVStartsWith(path, '/')
}


/**
 * @function __NAVPathNormalizeString
 * @internal
 * @description Internal helper function for path normalization.
 *
 * Processes a path string to resolve '.', '..' segments and
 * normalize path separators.
 *
 * @param {char[]} path - The path to normalize
 * @param {char} allowAboveRoot - Whether to allow '..' to resolve above the root
 * @param {char[]} separator - The path separator to use
 *
 * @returns {char[NAV_MAX_BUFFER]} The normalized path
 *
 * @note This is an internal helper function used by NAVPathNormalize
 */
define_function char[NAV_MAX_BUFFER] __NAVPathNormalizeString(char path[], char allowAboveRoot, char separator[]) {
    stack_var integer x
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer length
    stack_var integer lastSegmentLength
    stack_var integer lastSlash
    stack_var sinteger dots
    stack_var char code

    result = ''
    lastSegmentLength = 0
    lastSlash = 0
    dots = 0
    code = 0

    length = length_array(path)

    for (x = 0; x <= length; x++) {
        select {
            active (x < length): {
                code = NAVCharCodeAt(path, x + 1)
            }
            active (NAVPathIsPosixPathSeparator(code)): {
                break
            }
            active (true): {
                code = NAV_CHAR_FORWARD_SLASH
            }
        }

        select {
            active (NAVPathIsPosixPathSeparator(code)): {
                select {
                    active (lastSlash == x || dots == 1): {
                        // NOOP
                    }
                    active (dots == 2): {
                        if (length_array(result) < 2 || lastSegmentLength != 2 ||
                            NAVCharCodeAt(result, length_array(result)) != NAV_CHAR_DOT ||
                            NAVCharCodeAt(result, length_array(result) - 1) != NAV_CHAR_DOT) {
                                select {
                                    active (length_array(result) > 2): {
                                        stack_var integer lastSlashIndex

                                        lastSlashIndex = NAVLastIndexOf(result, separator)

                                        if (lastSlashIndex == 0) {
                                            result = ''
                                            lastSegmentLength = 0
                                        }
                                        else {
                                            result = NAVStringSlice(result, 1, lastSlashIndex)
                                            lastSegmentLength = (length_array(result) - NAVLastIndexOf(result, separator))
                                        }

                                        lastSlash = (x + 1)
                                        dots = 0

                                        continue
                                    }
                                    active (length_array(result) != 0): {
                                        result = ''

                                        lastSegmentLength = 0

                                        lastSlash = (x + 1)
                                        dots = 0

                                        continue
                                    }
                                }
                        }

                        if (allowAboveRoot) {
                            if (length_array(result) > 0) {
                                result = "result, separator, '..'"
                            }
                            else {
                                result = "result, '..'"
                            }

                            lastSegmentLength = 2
                        }
                    }
                    active (true): {
                        if (length_array(result) > 0) {
                            result = "result, separator, NAVStringSlice(path, lastSlash + 1, x + 1)"
                        }
                        else {
                            result = NAVStringSlice(path, lastSlash + 1, x + 1)
                        }

                        lastSegmentLength = (x - lastSlash)
                    }
                }

                lastSlash = (x + 1)
                dots = 0
            }
            active (code == NAV_CHAR_DOT && dots != -1): {
                dots++
            }
            active (true): {
                dots = -1
            }
        }
    }

    return result
}


/**
 * @function NAVPathNormalize
 * @public
 * @description Normalizes a file path.
 *
 * Resolves '.', '..' segments, removes duplicate slashes,
 * and standardizes path separators.
 *
 * @param {char[]} path - The path to normalize
 *
 * @returns {char[NAV_MAX_BUFFER]} The normalized path
 *
 * @example
 * stack_var char result[NAV_MAX_BUFFER]
 *
 * result = NAVPathNormalize('/home/user/../lib/')
 * // Returns '/home/lib/'
 *
 * result = NAVPathNormalize('user/./docs/../files')
 * // Returns 'user/files'
 *
 * @see NAVPathJoinPath
 * @see NAVPathResolve
 */
define_function char[NAV_MAX_BUFFER] NAVPathNormalize(char path[]) {
    stack_var char isAbsolute
    stack_var char trailingSlash
    stack_var char result[NAV_MAX_BUFFER]

    if (!length_array(path)) {
        return "'.'"
    }

    result = NAVPathRemoveEscapedBackslashes(path)

    isAbsolute = NAVPathIsAbsolute(result)
    trailingSlash = NAVEndsWith(result, '/')

    result = __NAVPathNormalizeString(result, !isAbsolute, '/')

    if (!length_array(result)) {
        if (isAbsolute) {
            return "'/'"
        }

        if (trailingSlash) {
            return "'./'"
        }

        return "'.'"
    }

    if (trailingSlash) {
        result = "result, '/'"
    }

    if (isAbsolute) {
        result = "'/', result"
    }

    return result
}


/**
 * @function NAVPathResolve
 * @public
 * @description Resolves a sequence of paths to an absolute path.
 *
 * Resolves a sequence of paths or path segments into an absolute path.
 * The resulting path is normalized with duplicated slashes removed.
 *
 * @param {char[]} arg1 - First path segment
 * @param {char[]} arg2 - Second path segment (optional)
 * @param {char[]} arg3 - Third path segment (optional)
 * @param {char[]} arg4 - Fourth path segment (optional)
 *
 * @returns {char[NAV_MAX_BUFFER]} The resolved absolute path
 *
 * @example
 * stack_var char result[NAV_MAX_BUFFER]
 *
 * result = NAVPathResolve('/home', 'user/docs', '../files', '')
 * // Returns '/home/user/files'
 *
 * @note Empty string arguments are ignored. Use empty strings for unused arguments.
 * @note If no path segments are provided, the root path '/' is returned.
 *
 * @see NAVPathNormalize
 * @see NAVPathJoinPath
 */
define_function char[NAV_MAX_BUFFER] NAVPathResolve(char arg1[], char arg2[], char arg3[], char arg4[]) {
    stack_var char resolved[NAV_MAX_BUFFER]
    stack_var char isAbsolute
    stack_var char slashCheck
    stack_var integer length
    stack_var integer x

    for (x = NAV_PATH_RESOLVE_MAX_ARGS; x >= 1; x--) {
        length = x

        switch (x) {
            case 4: {
                if (!length_array(arg4)) {
                    continue
                }

                break
            }
            case 3: {
                if (!length_array(arg3)) {
                    continue
                }

                break
            }
            case 2: {
                if (!length_array(arg2)) {
                    continue
                }

                break
            }
            case 1: {
                if (!length_array(arg1)) {
                    continue
                }

                break
            }
            case 0: {
                break
            }
        }

        break
    }

    if (!length) {
        return "'/'"
    }

    resolved = ''
    isAbsolute = false
    slashCheck = false

    for (x = length; x >= 1 && !isAbsolute; x--) {
        stack_var char path[255]
        stack_var integer pathLength

        switch (x) {
            case 1: {
                path = NAVPathRemoveEscapedBackslashes(arg1)
            }
            case 2: {
                path = NAVPathRemoveEscapedBackslashes(arg2)
            }
            case 3: {
                path = NAVPathRemoveEscapedBackslashes(arg3)
            }
            case 4: {
                path = NAVPathRemoveEscapedBackslashes(arg4)
            }
        }

        pathLength = length_array(path)

        if (!pathLength) {
            continue
        }

        if (x == (length - 1) && NAVPathIsPosixPathSeparator(NAVCharCodeAt(path, pathLength - 1))) {
            slashCheck = true
        }

        if (length_array(resolved) != 0) {
            resolved = "path, '/', resolved"
        }
        else {
            resolved = path
        }

        isAbsolute = NAVPathIsAbsolute(path)
    }

    if (!isAbsolute) {
        stack_var char cwd[255]

        cwd = NAVPathGetCwd()

        if (cwd == '/') {
            resolved = "cwd, resolved"
        }
        else {
            resolved = "cwd, '/', resolved"
        }

        isAbsolute = NAVPathIsAbsolute(cwd)
    }

    resolved = __NAVPathNormalizeString(resolved, !isAbsolute, '/')

    if (!isAbsolute) {
        if (!length_array(resolved)) {
            return "'.'"
        }

        if (slashCheck) {
            return "resolved, '/'"
        }

        return resolved
    }

    if (!length_array(resolved) || resolved == '/') {
        return "'/'"
    }

    if (slashCheck) {
        return "'/', resolved, '/'"
    }

    return "'/', resolved"
}


/**
 * @function NAVPathRelative
 * @public
 * @description Computes the relative path from one path to another.
 *
 * Calculates the relative path from the 'from' path to the 'to' path.
 *
 * @param {char[]} pathFrom - Source path
 * @param {char[]} pathTo - Target path
 *
 * @returns {char[NAV_MAX_BUFFER]} The relative path from source to target
 *
 * @example
 * stack_var char result[NAV_MAX_BUFFER]
 *
 * result = NAVPathRelative('/home/user/docs', '/home/user/files')
 * // Returns '../files'
 *
 * result = NAVPathRelative('/home/user', '/home/other/docs')
 * // Returns '../other/docs'
 *
 * @note If the paths are identical, an empty string is returned
 * @see NAVPathResolve
 */
define_function char[NAV_MAX_BUFFER] NAVPathRelative(char pathFrom[], char pathTo[]) {
    stack_var char resolvedPathFrom[255]
    stack_var char resolvedPathTo[255]

    stack_var integer fromStart
    stack_var integer fromEnd
    stack_var integer fromLength

    stack_var integer toStart
    stack_var integer toEnd
    stack_var integer toLength

    stack_var integer length

    stack_var sinteger lastCommonSeparator
    stack_var integer x

    stack_var char result[NAV_MAX_BUFFER]

    if (pathFrom == pathTo) {
        return ''
    }

    resolvedPathFrom = NAVPathResolve(pathFrom, '', '', '')
    resolvedPathTo = NAVPathResolve(pathTo, '', '', '')

    if (resolvedPathFrom == resolvedPathTo) {
        return ''
    }

    fromStart = 1
    while (fromStart < length_array(resolvedPathFrom) &&
            NAVCharCodeAt(resolvedPathFrom, fromStart + 1) == NAV_CHAR_FORWARD_SLASH) {
        fromStart++
    }

    fromEnd = length_array(resolvedPathFrom)
    while (fromEnd > fromStart &&
            NAVCharCodeAt(resolvedPathFrom, fromEnd) == NAV_CHAR_FORWARD_SLASH) {
        fromEnd--
    }

    fromLength = (fromEnd - fromStart)

    toStart = 1
    while (toStart < length_array(resolvedPathTo) &&
            NAVCharCodeAt(resolvedPathTo, toStart + 1) == NAV_CHAR_FORWARD_SLASH) {
        toStart++
    }

    toEnd = length_array(resolvedPathTo)
    while (toEnd > toStart &&
            NAVCharCodeAt(resolvedPathTo, toEnd) == NAV_CHAR_FORWARD_SLASH) {
        toEnd--
    }

    toLength = (toEnd - toStart)

    if (fromLength < toLength) {
        length = fromLength
    }
    else {
        length = toLength
    }

    lastCommonSeparator = -1
    x = 0

    for (; x < length; x++) {
        stack_var char fromCode

        fromCode = NAVCharCodeAt(resolvedPathFrom, fromStart + x)

        if (fromCode != NAVCharCodeAt(resolvedPathTo, toStart + x)) {
            break
        }

        if (fromCode == NAV_CHAR_FORWARD_SLASH) {
            lastCommonSeparator = type_cast(x)
        }
    }

    if (x == length) {
        select {
            active (toLength > length): {
                if (NAVCharCodeAt(resolvedPathTo, toStart + x) == NAV_CHAR_FORWARD_SLASH) {
                    return NAVStringSlice(resolvedPathTo, toStart + x + 1, 0)
                }

                if (x == 0) {
                    return NAVStringSlice(resolvedPathTo, toStart + x, 0)
                }
            }
            active (fromLength > length): {
                select {
                    active (NAVCharCodeAt(resolvedPathFrom, fromStart + x) == NAV_CHAR_FORWARD_SLASH): {
                        lastCommonSeparator = type_cast(x)
                    }
                    active (x == 0): {
                        lastCommonSeparator = 0
                    }
                }
            }
        }
    }

    result = ''

    for (x = fromStart + type_cast(lastCommonSeparator + 1); x <= fromEnd; x++) {
        if (x == fromEnd || NAVCharCodeAt(resolvedPathFrom, fromStart + x) == NAV_CHAR_FORWARD_SLASH) {
            if (length_array(result) == 0) {
                result = "result, '..'"
                continue
            }

            result = "result, '/..'"
        }
    }

    return "result, NAVStringSlice(resolvedPathTo, toStart + type_cast(lastCommonSeparator + 1), 0)"
}


/**
 * @function NAVPathGetCwd
 * @public
 * @description Gets the current working directory.
 *
 * Retrieves the current working directory of the file system.
 *
 * @returns {char[NAV_MAX_BUFFER]} The current working directory
 *
 * @example
 * stack_var char cwd[NAV_MAX_BUFFER]
 *
 * cwd = NAVPathGetCwd()
 * // Returns the current working directory path
 *
 * @note If the current working directory cannot be determined, an empty string is returned
 * @see NAVPathSetCwd
 */
define_function char[NAV_MAX_BUFFER] NAVPathGetCwd() {
    stack_var slong result
    stack_var char cwd[NAV_MAX_BUFFER]

    result = file_getdir(cwd)

    if (result < 0) {
        return ''
    }

    return cwd
}


/**
 * @function NAVPathSetCwd
 * @public
 * @description Sets the current working directory.
 *
 * Changes the current working directory to the specified path.
 *
 * @param {char[]} path - The path to set as the current working directory
 *
 * @returns {slong} Result code (0 for success, negative for error)
 *
 * @example
 * stack_var slong result
 *
 * result = NAVPathSetCwd('/home/user')
 * // Sets the current working directory to '/home/user'
 *
 * @note If the path cannot be set, an error code is returned
 * @see NAVPathGetCwd
 */
define_function slong NAVPathSetCwd(char path[]) {
    return file_setdir(path)
}


/**
 * @function NAVPathIsPathSeparator
 * @public
 * @description Determines if a character is a path separator.
 *
 * Checks if the character is either a forward slash or a backward slash.
 *
 * @param {char} c - The character to check
 *
 * @returns {char} TRUE if the character is a path separator, FALSE otherwise
 *
 * @example
 * stack_var char result
 *
 * result = NAVPathIsPathSeparator('/')  // Returns TRUE
 * result = NAVPathIsPathSeparator('\\') // Returns TRUE
 * result = NAVPathIsPathSeparator('a')  // Returns FALSE
 */
define_function char NAVPathIsPathSeparator(char c) {
    return c == NAV_CHAR_FORWARD_SLASH || c == NAV_CHAR_BACKWARD_SLASH
}


/**
 * @function NAVPathIsPosixPathSeparator
 * @public
 * @description Determines if a character is a POSIX path separator.
 *
 * Checks if the character is a forward slash.
 *
 * @param {char} c - The character to check
 *
 * @returns {char} TRUE if the character is a POSIX path separator, FALSE otherwise
 *
 * @example
 * stack_var char result
 *
 * result = NAVPathIsPosixPathSeparator('/')  // Returns TRUE
 * result = NAVPathIsPosixPathSeparator('\\') // Returns FALSE
 */
define_function char NAVPathIsPosixPathSeparator(char c) {
    return c == NAV_CHAR_FORWARD_SLASH
}


/**
 * @function NAVPathIsWindowsPathSeparator
 * @public
 * @description Determines if a character is a Windows path separator.
 *
 * Checks if the character is a backward slash.
 *
 * @param {char} c - The character to check
 *
 * @returns {char} TRUE if the character is a Windows path separator, FALSE otherwise
 *
 * @example
 * stack_var char result
 *
 * result = NAVPathIsWindowsPathSeparator('\\')  // Returns TRUE
 * result = NAVPathIsWindowsPathSeparator('/')  // Returns FALSE
 */
define_function char NAVPathIsWindowsPathSeparator(char c) {
    return c == NAV_CHAR_BACKWARD_SLASH
}


/**
 * @function NAVPathRemoveEscapedBackslashes
 * @public
 * @description Removes escaped backslashes from a path.
 *
 * Replaces escaped backslashes in a path with forward slashes.
 *
 * @param {char[]} path - The path to process
 *
 * @returns {char[NAV_MAX_BUFFER]} The path with escaped backslashes removed
 *
 * @example
 * stack_var char result[NAV_MAX_BUFFER]
 *
 * result = NAVPathRemoveEscapedBackslashes('C:\\\\path\\\\to\\\\file')
 * // Returns 'C:/path/to/file'
 */
define_function char[NAV_MAX_BUFFER] NAVPathRemoveEscapedBackslashes(char path[]) {
    return NAVFindAndReplace(path, '\\', '\')
}


#END_IF // __NAV_FOUNDATION_PATHUTILS__
