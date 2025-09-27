PROGRAM_NAME='NAVFoundation.IniFileUtils'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_INIFILEUTILS__
#DEFINE __NAV_FOUNDATION_INIFILEUTILS__ 'NAVFoundation.IniFileUtils'

#include 'NAVFoundation.IniFileLexer.axi'
#include 'NAVFoundation.IniFileParser.axi'


(***********************************************************)
(*                    UTILITY FUNCTIONS                   *)
(***********************************************************)

/**
 * @function NAVIniFileParse
 * @public
 * @description Simple high-level function to parse an INI file from string data.
 *
 * @param {char[]} data - The INI file content as a string
 * @param {_NAVIniFile} iniFile - The parsed INI file structure (output)
 *
 * @returns {char} True (1) if parsing succeeded, False (0) if failed
 *
 * @example
 * stack_var char data[2048]
 * stack_var _NAVIniFile ini
 *
 * data = ReadFile('config.ini')  // However you read the file
 * if (NAVIniFileParse(data, ini)) {
 *     // Use ini.sections[x].properties[y].key/value
 * }
 */
define_function char NAVIniFileParse(char data[], _NAVIniFile iniFile) {
    stack_var _NAVIniLexer lexer
    stack_var _NAVIniParser parser

    // Initialize the lexer with the input data
    NAVIniLexerInit(lexer, data)

    // Tokenize the input
    if (!NAVIniLexerTokenize(lexer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_INIFILEUTILS__,
                                    'NAVIniFileParse',
                                    "'Error tokenizing INI data'")
        return false
    }

    // Initialize the parser with the tokens
    NAVIniParserInit(parser, lexer.tokens)

    // Parse the tokens into the INI structure
    if (!NAVIniParserParse(parser, iniFile)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_INIFILEUTILS__,
                                    'NAVIniFileParse',
                                    "'Error parsing INI data'")
        return false
    }

    return true
}

/**
 * @function NAVIniFileFindSection
 * @public
 * @description Helper function to find a section by name in an INI file.
 *
 * @param {_NAVIniFile} iniFile - The parsed INI file structure
 * @param {char[]} sectionName - The name of the section to find
 *
 * @returns {integer} Index of the section (1-based), or 0 if not found
 */
define_function integer NAVIniFileFindSection(_NAVIniFile iniFile, char sectionName[]) {
    stack_var integer i

    // Bounds check
    if (iniFile.sectionCount > NAV_INI_PARSER_MAX_SECTIONS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_INIFILEUTILS__,
                                    'NAVIniFileFindSection',
                                    "'Invalid section count: ', itoa(iniFile.sectionCount)")
        return 0
    }

    for (i = 1; i <= iniFile.sectionCount; i++) {
        if (iniFile.sections[i].name == sectionName) {
            return i
        }
    }

    return 0
}

/**
 * @function NAVIniFileFindProperty
 * @public
 * @description Helper function to find a property by key within a section.
 *
 * @param {_NAVIniSection} section - The section to search
 * @param {char[]} propertyKey - The key to find
 *
 * @returns {integer} Index of the property (1-based), or 0 if not found
 */
define_function integer NAVIniFileFindProperty(_NAVIniSection section, char propertyKey[]) {
    stack_var integer i

    // Bounds check
    if (section.propertyCount > NAV_INI_PARSER_MAX_PROPERTIES) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_INIFILEUTILS__,
                                    'NAVIniFileFindProperty',
                                    "'Invalid property count: ', itoa(section.propertyCount)")
        return 0
    }

    for (i = 1; i <= section.propertyCount; i++) {
        if (section.properties[i].key == propertyKey) {
            return i
        }
    }

    return 0
}

/**
 * @function NAVIniFileGetSectionValue
 * @public
 * @description Helper function to get a property value from a specific section.
 *
 * @param {_NAVIniFile} iniFile - The parsed INI file structure
 * @param {char[]} sectionName - The name of the section
 * @param {char[]} propertyKey - The key to find
 *
 * @returns {char[NAV_INI_PARSER_MAX_VALUE_LENGTH]} The property value, or empty string if not found
 */
define_function char[NAV_INI_PARSER_MAX_VALUE_LENGTH] NAVIniFileGetSectionValue(_NAVIniFile iniFile, char sectionName[], char propertyKey[]) {
    stack_var integer sectionIndex
    stack_var integer propertyIndex

    sectionIndex = NAVIniFileFindSection(iniFile, sectionName)
    if (sectionIndex == 0 || sectionIndex > iniFile.sectionCount || sectionIndex > NAV_INI_PARSER_MAX_SECTIONS) {
        return ''
    }

    propertyIndex = NAVIniFileFindProperty(iniFile.sections[sectionIndex], propertyKey)
    if (propertyIndex == 0 || propertyIndex > iniFile.sections[sectionIndex].propertyCount || propertyIndex > NAV_INI_PARSER_MAX_PROPERTIES) {
        return ''
    }

    return iniFile.sections[sectionIndex].properties[propertyIndex].value
}

/**
 * @function NAVIniFileGetGlobalValue
 * @public
 * @description Helper function to get a property value from the default (global) section.
 *
 * @param {_NAVIniFile} iniFile - The parsed INI file structure
 * @param {char[]} propertyKey - The key to find
 *
 * @returns {char[NAV_INI_PARSER_MAX_VALUE_LENGTH]} The property value, or empty string if not found
 */
define_function char[NAV_INI_PARSER_MAX_VALUE_LENGTH] NAVIniFileGetGlobalValue(_NAVIniFile iniFile, char propertyKey[]) {
    return NAVIniFileGetSectionValue(iniFile, 'default', propertyKey)
}

/**
 * @function NAVIniFileGetValue
 * @public
 * @description Helper function to get a property value using dot notation.
 *              Supports both simple keys and section.key notation:
 *              - "key" -> looks in default section
 *              - "section.key" -> looks in specified section
 *
 * @param {_NAVIniFile} iniFile - The parsed INI file structure
 * @param {char[]} dotPath - The dot-notation path (e.g., "database.host" or "timeout")
 *
 * @returns {char[NAV_INI_PARSER_MAX_VALUE_LENGTH]} The property value, or empty string if not found
 *
 * @example
 * stack_var char[NAV_INI_PARSER_MAX_VALUE_LENGTH] value
 * value = NAVIniFileGetValue(ini, 'database.host')      // [database] host=...
 * value = NAVIniFileGetValue(ini, 'timeout')           // [default] timeout=...
 */
define_function char[NAV_INI_PARSER_MAX_VALUE_LENGTH] NAVIniFileGetValue(_NAVIniFile iniFile, char dotPath[]) {
    stack_var integer dotPos
    stack_var char sectionName[NAV_INI_PARSER_MAX_SECTION_NAME_LENGTH]
    stack_var char propertyKey[NAV_INI_PARSER_MAX_KEY_LENGTH]

    // Find the first dot in the path
    dotPos = find_string(dotPath, '.', 1)

    if (dotPos == 0) {
        // No dot found - treat as global property in default section
        return NAVIniFileGetGlobalValue(iniFile, dotPath)
    } else {
        // Dot found - split into section.property
        sectionName = left_string(dotPath, dotPos - 1)
        propertyKey = right_string(dotPath, length_array(dotPath) - dotPos)

        return NAVIniFileGetSectionValue(iniFile, sectionName, propertyKey)
    }
}


#END_IF // __NAV_FOUNDATION_INIFILEUTILS__
