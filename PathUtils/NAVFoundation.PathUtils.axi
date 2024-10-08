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


define_function char NAVPathIsDirectory(char entity[]) {
    if (NAVStartsWith(entity, '/')) {
        return true
    }

    return false
}


define_function char NAVIsDirectory(char entity[]) {
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

    index = NAVLastIndexOf(basename, '.')
    if (index < 0) {
        return ''
    }

    return NAVStringSubstring(basename, index, length_array(basename) - index)
}


define_function char[NAV_MAX_BUFFER] NAVPathDirName(char path[]) {
    stack_var char node[255][255]
    stack_var integer count

    if (!length_array(path)) {
        return '.'
    }

    count = NAVSplitPath(path, node)

    if (count <= 0) {
        return ''
    }

    return node[count - 1]
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


#END_IF // __NAV_FOUNDATION_PATHUTILS__
