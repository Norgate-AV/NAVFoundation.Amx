PROGRAM_NAME='NAVFoundation.XmlUtils'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_XMLUTILS__
#DEFINE __NAV_FOUNDATION_XMLUTILS__ 'NAVFoundation.XmlUtils'

#include 'NAVFoundation.Core.axi'


// define_function WriteConfigToXml(_RoomConfig config, char file[]) {
//     stack_var sinteger result
//     stack_var char buffer[NAV_MAX_BUFFER]

//     result = variable_to_xml(config, buffer, 1, 0)

//     if (result != 0) {
//         NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Variable to XML failed: ', NAVGetVariableToXmlError(result)")
//         return
//     }

//     NAVFileWrite(file, buffer)
// }


// define_function ReadConfigFromXml(_RoomConfig config, char file[]) {
//     stack_var sinteger result
//     stack_var char buffer[NAV_MAX_BUFFER]

//     NAVFileRead(file, buffer)

//     result = xml_to_variable(config, buffer, 1, 0)

//     if (result != 0) {
//         NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'XML to variable failed: ', NAVGetVariableToXmlError(result)")
//         return
//     }
// }

#END_IF // __NAV_FOUNDATION_XMLUTILS__
