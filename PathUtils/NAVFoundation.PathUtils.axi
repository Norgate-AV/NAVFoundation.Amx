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

    count = NAVSplitPath(path, node)

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


define_function slong NAVSplitPath(char path[], char elements[][]) {
    stack_var slong count

    count = NAVSplitString(path, '/', elements)

    if (count > 0) {
        return count
    }

    count = NAVSplitString(path, '\', elements)

    if (count > 0) {
        return count
    }

    count = NAVSplitString(path, '\\', elements)

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


define_function char[NAV_MAX_BUFFER] NAVPathGetCwd() {
    stack_var char result[NAV_MAX_BUFFER]

    file_getdir(result)

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
