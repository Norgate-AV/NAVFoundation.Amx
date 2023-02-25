PROGRAM_NAME='NAVFoundation.Testing.axi'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Solutions Ltd

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

#IF_NOT_DEFINED __NAV_FOUNDATION_TESTING__
#DEFINE __NAV_FOUNDATION_TESTING__

#include 'NAVFoundation.Core.axi'


DEFINE_CONSTANT

constant integer NAV_MAX_TESTS                          = 50

constant integer NAV_TEST_MAX_STRING_ARRAY_SIZE         = 255
constant integer NAV_TEST_MAX_INTEGER_ARRAY_SIZE        = 255

constant integer NAV_TEST_TYPE_STRING_RESULT            = 1
constant integer NAV_TEST_TYPE_STRING_ARRAY_RESULT      = 2
constant integer NAV_TEST_TYPE_INTEGER_RESULT           = 3
constant integer NAV_TEST_TYPE_INTEGER_ARRAY_RESULT     = 4


DEFINE_TYPE

struct _NAVUnitTestProperties {
    char Name[NAV_MAX_CHARS]
    char Description[NAV_MAX_CHARS]
    char Message[NAV_MAX_CHARS]
    integer Passed
}


struct _NAVUnitTestStringResult {
    char Expected[NAV_MAX_BUFFER]
    char Actual[NAV_MAX_BUFFER]
}


struct _NAVUnitTestStringArrayResult {
    char Expected[][NAV_MAX_BUFFER]
    char Actual[][NAV_MAX_BUFFER]
}


struct _NAVUnitTestIntegerResult {
    integer Expected
    integer Actual
}


struct _NAVUnitTestIntegerArrayResult {
    integer Expected[]
    integer Actual[]
}


struct _NAVUnitTestWithStringResult  {
    _NAVUnitTestProperties Properties
    _NAVUnitTestStringResult Result
}


struct _NAVUnitTestWithStringArrayResult  {
    _NAVUnitTestProperties Properties
    _NAVUnitTestStringArrayResult Result
}


struct _NAVUnitTestWithIntegerResult  {
    _NAVUnitTestProperties Properties
    _NAVUnitTestIntegerResult Result
}


struct _NAVUnitTestWithIntegerArrayResult  {
    _NAVUnitTestProperties Properties
    _NAVUnitTestIntegerArrayResult Result
}


#END_IF // __NAV_FOUNDATION_TESTING__
