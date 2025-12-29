PROGRAM_NAME='NAVFoundation.IniFileParser'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2010-2026 Norgate AV

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

#IF_NOT_DEFINED __NAV_FOUNDATION_INIFILE_PARSER__
#DEFINE __NAV_FOUNDATION_INIFILE_PARSER__ 'NAVFoundation.IniFileParser'

#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.IniFileLexer.axi'
#include 'NAVFoundation.IniFileParser.h.axi'


/**
 * @function NAVIniParserInit
 * @public
 * @description Initialize an INI parser with an array of tokens.
 *
 * @param {_NAVIniParser} parser - The parser structure to initialize
 * @param {_NAVIniToken[]} tokens - Array of tokens to parse
 *
 * @returns {void}
 */
define_function NAVIniParserInit(_NAVIniParser parser, _NAVIniToken tokens[]) {
    parser.tokens = tokens
    parser.tokenCount = length_array(tokens)
    parser.cursor = 0
}


/**
 * @function NAVIniParserHasMoreTokens
 * @private
 * @description Check if there are more tokens to parse.
 *
 * @param {_NAVIniParser} parser - The parser to check
 *
 * @returns {char} True (1) if more tokens exist, False (0) otherwise
 */
define_function char NAVIniParserHasMoreTokens(_NAVIniParser parser) {
    return (parser.tokenCount > 0 && parser.cursor >= 0 && parser.cursor < parser.tokenCount)
}


/**
 * @function NAVIniParserAdvanceCursor
 * @private
 * @description Advance the parser cursor by one position.
 *
 * @param {_NAVIniParser} parser - The parser to advance
 *
 * @returns {char} True (1) if cursor advanced successfully, False (0) if out of bounds
 */
define_function char NAVIniParserAdvanceCursor(_NAVIniParser parser) {
    parser.cursor++

    if (NAVIniParserCursorIsOutOfBounds(parser)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_INIFILE_PARSER__,
                                    'NAVIniParserAdvanceCursor',
                                    "'Parser cursor out of bounds: ', itoa(parser.cursor), ' (tokenCount: ', itoa(parser.tokenCount), ')'")
        return false
    }

    return true
}


/**
 * @function NAVIniParserCursorIsOutOfBounds
 * @private
 * @description Check if the parser cursor is out of valid bounds.
 *
 * @param {_NAVIniParser} parser - The parser to check
 *
 * @returns {char} True (1) if cursor is out of bounds, False (0) otherwise
 */
define_function char NAVIniParserCursorIsOutOfBounds(_NAVIniParser parser) {
    return (parser.cursor <= 0 || parser.cursor > parser.tokenCount)
}


/**
 * @function NAVIniParserParse
 * @public
 * @description Parse the tokens into an INI file structure.
 *
 * @param {_NAVIniParser} parser - The initialized parser
 * @param {_NAVIniFile} iniFile - The output INI file structure
 *
 * @returns {char} True (1) if parsing succeeded, False (0) if failed
 */
define_function char NAVIniParserParse(_NAVIniParser parser, _NAVIniFile iniFile) {
    iniFile.sectionCount = 0

    while (NAVIniParserHasMoreTokens(parser)) {
        stack_var _NAVIniToken token

        if (!NAVIniParserAdvanceCursor(parser)) {
            return false
        }

        token = parser.tokens[parser.cursor]

        switch (token.type) {
            case NAV_INI_TOKEN_TYPE_LBRACKET: {
                if (!NAVIniParserParseSection(parser, iniFile)) {
                    return false
                }
            }
            case NAV_INI_TOKEN_TYPE_IDENTIFIER: {
                if (!NAVIniParserParseProperty(parser, iniFile, token)) {
                    return false
                }
            }
            case NAV_INI_TOKEN_TYPE_NEWLINE:
            case NAV_INI_TOKEN_TYPE_COMMENT: {
                // Ignore
            }
            default: {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_INIFILE_PARSER__,
                                            'NAVIniFileParserParse',
                                            "'Unexpected token type: ', itoa(token.type), ' with value: ', token.value, ' at position ', itoa(parser.cursor)")
                return false
            }
        }
    }

    return true
}


/**
 * @function NAVIniParserParseSection
 * @private
 * @description Parse a section declaration from the token stream.
 *
 * @param {_NAVIniParser} parser - The parser instance
 * @param {_NAVIniFile} iniFile - The INI file structure to add the section to
 *
 * @returns {char} True (1) if section was parsed successfully, False (0) on error
 */
define_function char NAVIniParserParseSection(_NAVIniParser parser, _NAVIniFile iniFile) {
    stack_var _NAVIniToken token
    stack_var char name[NAV_INI_PARSER_MAX_SECTION_NAME_LENGTH]

    if (iniFile.sectionCount == NAV_INI_PARSER_MAX_SECTIONS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_INIFILE_PARSER__,
                                    'NAVIniParserParseSection',
                                    "'Exceeded maximum section limit'")
        return false
    }

    if (!NAVIniParserHasMoreTokens(parser)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_INIFILE_PARSER__,
                                    'NAVIniParserParseSection',
                                    "'Unexpected end of tokens while parsing section name'")
        return false
    }

    if (!NAVIniParserAdvanceCursor(parser)) {
        return false
    }

    token = parser.tokens[parser.cursor]

    if (token.type != NAV_INI_TOKEN_TYPE_IDENTIFIER && token.type != NAV_INI_TOKEN_TYPE_STRING) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_INIFILE_PARSER__,
                                    'NAVIniParserParseSection',
                                    "'Expected section name identifier or string, found type: ', NAVIniLexerGetTokenType(token.type), ' with value: ', token.value, ' at position ', itoa(parser.cursor)")
        return false
    }

    name = token.value

    if (!NAVIniParserHasMoreTokens(parser)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_INIFILE_PARSER__,
                                    'NAVIniParserParseSection',
                                    "'Unexpected end of tokens while expecting closing bracket for section: ', name")
        return false
    }

    if (!NAVIniParserAdvanceCursor(parser)) {
        return false
    }

    token = parser.tokens[parser.cursor]

    if (token.type != NAV_INI_TOKEN_TYPE_RBRACKET) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_INIFILE_PARSER__,
                                    'NAVIniParserParseSection',
                                    "'Expected closing bracket for section: ', name, ', found type: ', NAVIniLexerGetTokenType(token.type), ' with value: ', token.value, ' at position ', itoa(parser.cursor)")
        return false
    }

    // Validate section name length
    if (length_string(name) > NAV_INI_PARSER_MAX_SECTION_NAME_LENGTH) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_INIFILE_PARSER__,
                                    'NAVIniParserParseSection',
                                    "'Section name exceeds maximum length (', itoa(NAV_INI_PARSER_MAX_SECTION_NAME_LENGTH), '): ', name")
        return false
    }

    // Successfully parsed section
    iniFile.sectionCount++
    iniFile.sections[iniFile.sectionCount].name = name
    iniFile.sections[iniFile.sectionCount].propertyCount = 0
    set_length_array(iniFile.sections, iniFile.sectionCount)

    return true
}


/**
 * @function NAVIniParserParseProperty
 * @private
 * @description Parse a property assignment from the token stream.
 *
 * @param {_NAVIniParser} parser - The parser instance
 * @param {_NAVIniFile} iniFile - The INI file structure to add the property to
 * @param {_NAVIniToken} keyToken - The token containing the property key
 *
 * @returns {char} True (1) if property was parsed successfully, False (0) on error
 */
define_function char NAVIniParserParseProperty(_NAVIniParser parser, _NAVIniFile iniFile, _NAVIniToken keyToken) {
    stack_var _NAVIniToken token
    stack_var char key[NAV_INI_PARSER_MAX_KEY_LENGTH]
    stack_var char value[NAV_INI_PARSER_MAX_VALUE_LENGTH]
    stack_var integer index

    if (iniFile.sectionCount == 0) {
        // No section defined yet, create a default section
        iniFile.sectionCount++
        iniFile.sections[iniFile.sectionCount].name = 'default'
        iniFile.sections[iniFile.sectionCount].propertyCount = 0
    }

    index = iniFile.sectionCount

    if (iniFile.sections[index].propertyCount == NAV_INI_PARSER_MAX_PROPERTIES) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_INIFILE_PARSER__,
                                    'NAVIniParserParseProperty',
                                    "'Exceeded maximum property limit in section: ', iniFile.sections[index].name")
        return false
    }

    key = keyToken.value
    value = ''

    if (!NAVIniParserHasMoreTokens(parser)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_INIFILE_PARSER__,
                                    'NAVIniParserParseProperty',
                                    "'Unexpected end of tokens while parsing property: ', key")
        return false
    }

    if (!NAVIniParserAdvanceCursor(parser)) {
        return false
    }

    token = parser.tokens[parser.cursor]

    if (token.type != NAV_INI_TOKEN_TYPE_EQUALS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_INIFILE_PARSER__,
                                    'NAVIniParserParseProperty',
                                    "'Expected equals sign after property key: ', key, ', found type: ', NAVIniLexerGetTokenType(token.type), ' with value: ', token.value, ' at position ', itoa(parser.cursor)")
        return false
    }

    // Consume all tokens until newline or comment to handle multi-token values
    while (NAVIniParserHasMoreTokens(parser)) {
        if (!NAVIniParserAdvanceCursor(parser)) {
            return false
        }

        token = parser.tokens[parser.cursor]

        if (token.type == NAV_INI_TOKEN_TYPE_NEWLINE || token.type == NAV_INI_TOKEN_TYPE_COMMENT) {
            break
        }

        if (token.type == NAV_INI_TOKEN_TYPE_IDENTIFIER || token.type == NAV_INI_TOKEN_TYPE_STRING) {
            if (length_array(value) > 0) {
                value = "value, ' ', token.value"  // Add space between tokens
                continue
            }

            value = token.value
        }
    }

    // Validate property key and value lengths
    if (length_string(key) > NAV_INI_PARSER_MAX_KEY_LENGTH) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_INIFILE_PARSER__,
                                    'NAVIniParserParseProperty',
                                    "'Property key exceeds maximum length (', itoa(NAV_INI_PARSER_MAX_KEY_LENGTH), '): ', key")
        return false
    }

    if (length_string(value) > NAV_INI_PARSER_MAX_VALUE_LENGTH) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_INIFILE_PARSER__,
                                    'NAVIniParserParseProperty',
                                    "'Property value exceeds maximum length (', itoa(NAV_INI_PARSER_MAX_VALUE_LENGTH), '): ', value")
        return false
    }

    // Use the current section index we calculated earlier
    iniFile.sections[index].propertyCount++
    iniFile.sections[index].properties[iniFile.sections[index].propertyCount].key = key
    iniFile.sections[index].properties[iniFile.sections[index].propertyCount].value = value
    set_length_array(iniFile.sections[index].properties, iniFile.sections[index].propertyCount)

    return true
}


#END_IF // __NAV_FOUNDATION_INIFILE_PARSER__
