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

#IF_NOT_DEFINED __NAV_FOUNDATION_PATHUTILS__
#DEFINE __NAV_FOUNDATION_PATHUTILS__ 'NAVFoundation.PathUtils'

#include 'NAVFoundation.Core.axi'


DEFINE_CONSTANT

constant char NAV_CHAR_DOT              = 46
constant char NAV_CHAR_FORWARD_SLASH    = 47
constant char NAV_CHAR_BACKWARD_SLASH   = 92

constant integer NAV_PATH_RESOLVE_MAX_ARGS  = 4
constant integer NAV_PATH_JOIN_MAX_ARGS     = 4


define_function char NAVPathIsDirectory(char entity[]) {
    if (NAVStartsWith(entity, '/')) {
        return true
    }

    return false
}


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
                end = x
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

    return NAVStringSubstring(path, 1, end - 1)
}


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


// NetLinx does not support variadic functions, so we need to limit it in some way.
// We could pass in an array of strings, but that would be a bit cumbersome.
// Instead, we will limit the number of arguments to 4.
// An empty string should be used to indicate the argument is not used.
// Eg. NAVPathJoinPath('a', 'b', 'c', '')
// If you only want to join 2 paths, then use NAVPathJoinPath('a', 'b', '', '')
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


define_function slong NAVPathSplitPath(char path[], char elements[][]) {
    stack_var slong count

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


define_function char NAVPathIsAbsolute(char path[]) {
    return NAVStartsWith(path, '/')
}


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


// NetLinx does not support variadic functions, so we need to limit it in some way.
// We could pass in an array of strings, but that would be a bit cumbersome.
// Instead, we will limit the number of arguments to 4.
// An empty string should be used to indicate the argument is not used.
// Eg. NAVPathResolve('a', 'b', 'c', '')
// If you only want to resolve 2 paths, then use NAVPathResolve('a', 'b', '', '')
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
            lastCommonSeparator = x
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
                        lastCommonSeparator = x
                    }
                    active (x == 0): {
                        lastCommonSeparator = 0
                    }
                }
            }
        }
    }

    result = ''

    for (x = fromStart + lastCommonSeparator + 1; x <= fromEnd; x++) {
        if (x == fromEnd || NAVCharCodeAt(resolvedPathFrom, fromStart + x) == NAV_CHAR_FORWARD_SLASH) {
            if (length_array(result) == 0) {
                result = "result, '..'"
                continue
            }

            result = "result, '/..'"
        }
    }

    return "result, NAVStringSlice(resolvedPathTo, toStart + lastCommonSeparator + 1, 0)"
}


define_function char[NAV_MAX_BUFFER] NAVPathGetCwd() {
    stack_var slong result
    stack_var char cwd[NAV_MAX_BUFFER]

    result = file_getdir(cwd)

    if (result < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_PATHUTILS__,
                                    'NAVPathGetCwd',
                                    "'Failed to get the current working directory : ', NAVGetFileError(result)")

        return ''
    }

    return cwd
}


define_function slong NAVPathSetCwd(char path[]) {
    stack_var slong result

    result = file_setdir(path)

    if (result < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_PATHUTILS__,
                                    'NAVPathSetCwd',
                                    "'Failed to set the current working directory : ', NAVGetFileError(result)")
    }

    return result
}


define_function char NAVPathIsPathSeparator(char c) {
    return c == NAV_CHAR_FORWARD_SLASH || c == NAV_CHAR_BACKWARD_SLASH
}


define_function char NAVPathIsPosixPathSeparator(char c) {
    return c == NAV_CHAR_FORWARD_SLASH
}


define_function char NAVPathIsWindowsPathSeparator(char c) {
    return c == NAV_CHAR_BACKWARD_SLASH
}


define_function char[NAV_MAX_BUFFER] NAVPathRemoveEscapedBackslashes(char path[]) {
    return NAVFindAndReplace(path, '\\', '\')
}


#END_IF // __NAV_FOUNDATION_PATHUTILS__
