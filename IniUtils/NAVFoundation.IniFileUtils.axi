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
#include 'NAVFoundation.Regex.axi'


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


/**
 * @function NAVIniFileHasKey
 * @public
 * @description Helper function to check if a property key exists using dot notation.
 *              Supports both simple keys and section.key notation:
 *              - "key" -> looks in default section
 *              - "section.key" -> looks in specified section
 *
 * @param {_NAVIniFile} iniFile - The parsed INI file structure
 * @param {char[]} dotPath - The dot-notation path (e.g., "database.host" or "timeout")
 *
 * @returns {char} True (1) if the key exists, False (0) otherwise
 *
 * @example
 * stack_var char exists
 * exists = NAVIniFileHasKey(ini, 'database.host')      // [database] host=...
 * exists = NAVIniFileHasKey(ini, 'timeout')           // [default] timeout=...
 */
define_function char NAVIniFileHasKey(_NAVIniFile iniFile, char dotPath[]) {
    stack_var integer dotPos
    stack_var char sectionName[NAV_INI_PARSER_MAX_SECTION_NAME_LENGTH]
    stack_var char propertyKey[NAV_INI_PARSER_MAX_KEY_LENGTH]
    stack_var integer sectionIndex
    stack_var integer propertyIndex

    // Find the first dot in the path
    dotPos = find_string(dotPath, '.', 1)

    if (dotPos == 0) {
        // No dot found - treat as global property in default section
        sectionIndex = NAVIniFileFindSection(iniFile, 'default')
        if (sectionIndex == 0) {
            return false
        }

        propertyIndex = NAVIniFileFindProperty(iniFile.sections[sectionIndex], dotPath)

        return propertyIndex != 0
    } else {
        // Dot found - split into section.property
        sectionName = left_string(dotPath, dotPos - 1)
        propertyKey = right_string(dotPath, length_array(dotPath) - dotPos)

        sectionIndex = NAVIniFileFindSection(iniFile, sectionName)
        if (sectionIndex == 0) {
            return false
        }

        propertyIndex = NAVIniFileFindProperty(iniFile.sections[sectionIndex], propertyKey)

        return propertyIndex != 0
    }
}


/**
 * @function NAVIniFileGetIntegerValue
 * @public
 * @description Get an integer property value using dot notation with a default fallback.
 *              Uses atoi() for conversion - invalid strings convert to 0.
 *              Returns the default value if key doesn't exist.
 *
 * @param {_NAVIniFile} iniFile - The parsed INI file structure
 * @param {char[]} dotPath - The dot-notation path (e.g., "database.port" or "timeout")
 * @param {integer} defaultValue - The default integer value to return if not found
 *
 * @returns {integer} The integer value or defaultValue if not found
 *
 * @example
 * stack_var integer port
 * stack_var integer timeout
 * port = NAVIniFileGetIntegerValue(ini, 'database.port', 5432)
 * timeout = NAVIniFileGetIntegerValue(ini, 'timeout', 30)
 *
 * @note atoi() converts invalid strings to 0. Use NAVIniFileHasKey() to check existence first if needed.
 */
define_function integer NAVIniFileGetIntegerValue(_NAVIniFile iniFile, char dotPath[], integer defaultValue) {
    stack_var char value[NAV_INI_PARSER_MAX_VALUE_LENGTH]
    stack_var integer valueInt

    if (!NAVIniFileHasKey(iniFile, dotPath)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_INIFILEUTILS__,
                                    'NAVIniFileGetIntegerValue',
                                    "'Key not found: ', dotPath, '. Returning default value (', itoa(defaultValue), ')'")

        return defaultValue
    }

    value = NAVIniFileGetValue(iniFile, dotPath)
    if (!length_array(value)) {
        return defaultValue
    }

    // Trim whitespace and validate it's a valid integer
    value = NAVTrimString(value)

    if (NAVRegexTest('/^\d+$/', value)) {
        return atoi(value)
    }

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                __NAV_FOUNDATION_INIFILEUTILS__,
                                'NAVIniFileGetIntegerValue',
                                "'Invalid integer value for key ', dotPath, ': ', value, '. Returning default value (', itoa(defaultValue), ')'")

    return defaultValue
}


/**
 * @function NAVIniFileGetSignedIntegerValue
 * @public
 * @description Get a signed integer property value using dot notation with a default fallback.
 *              Uses atoi() for conversion - invalid strings convert to 0.
 *              Returns the default value if key doesn't exist.
 *
 * @param {_NAVIniFile} iniFile - The parsed INI file structure
 * @param {char[]} dotPath - The dot-notation path (e.g., "database.offset" or "adjustment")
 * @param {sinteger} defaultValue - The default signed integer value to return if not found
 *
 * @returns {sinteger} The signed integer value or defaultValue if not found
 *
 * @example
 * stack_var sinteger offset
 * stack_var sinteger adjustment
 * offset = NAVIniFileGetSignedIntegerValue(ini, 'database.offset', -10)
 * adjustment = NAVIniFileGetSignedIntegerValue(ini, 'adjustment', 0)
 *
 * @note atoi() converts invalid strings to 0. Use NAVIniFileHasKey() to check existence first if needed.
 * @note NetLinx sinteger is 16-bit signed: -32768 to 32767
 */
define_function sinteger NAVIniFileGetSignedIntegerValue(_NAVIniFile iniFile, char dotPath[], sinteger defaultValue) {
    stack_var char value[NAV_INI_PARSER_MAX_VALUE_LENGTH]

    if (!NAVIniFileHasKey(iniFile, dotPath)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_INIFILEUTILS__,
                                    'NAVIniFileGetSignedIntegerValue',
                                    "'Key not found: ', dotPath, '. Returning default value (', itoa(defaultValue), ')'")

        return defaultValue
    }

    value = NAVIniFileGetValue(iniFile, dotPath)
    if (!length_array(value)) {
        return defaultValue
    }

    // Trim whitespace and validate it's a valid signed integer
    value = NAVTrimString(value)

    if (NAVRegexTest('/^[+-]?\d+$/', value)) {
        return atoi(value)
    }

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                __NAV_FOUNDATION_INIFILEUTILS__,
                                'NAVIniFileGetSignedIntegerValue',
                                "'Invalid signed integer value for key ', dotPath, ': ', value, '. Returning default value (', itoa(defaultValue), ')'")

    return defaultValue
}


/**
 * @function NAVIniFileGetLongValue
 * @public
 * @description Get a long integer property value using dot notation with a default fallback.
 *              Uses atol() for conversion - invalid strings convert to 0.
 *              Returns the default value if key doesn't exist.
 *
 * @param {_NAVIniFile} iniFile - The parsed INI file structure
 * @param {char[]} dotPath - The dot-notation path (e.g., "system.timestamp" or "counter")
 * @param {long} defaultValue - The default long integer value to return if not found
 *
 * @returns {long} The long integer value or defaultValue if not found
 *
 * @example
 * stack_var long timestamp
 * stack_var long counter
 * timestamp = NAVIniFileGetLongValue(ini, 'system.timestamp', 0)
 * counter = NAVIniFileGetLongValue(ini, 'counter', 1000000)
 *
 * @note atol() converts invalid strings to 0. Use NAVIniFileHasKey() to check existence first if needed.
 * @note NetLinx long is 32-bit unsigned: 0 to 4294967295
 */
define_function long NAVIniFileGetLongValue(_NAVIniFile iniFile, char dotPath[], long defaultValue) {
    stack_var char value[NAV_INI_PARSER_MAX_VALUE_LENGTH]

    if (!NAVIniFileHasKey(iniFile, dotPath)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_INIFILEUTILS__,
                                    'NAVIniFileGetLongValue',
                                    "'Key not found: ', dotPath, '. Returning default value (', itoa(defaultValue), ')'")

        return defaultValue
    }

    value = NAVIniFileGetValue(iniFile, dotPath)
    if (!length_array(value)) {
        return defaultValue
    }

    // Trim whitespace and validate it's a valid long integer
    value = NAVTrimString(value)

    if (NAVRegexTest('/^\d+$/', value)) {
        return atol(value)
    }

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                __NAV_FOUNDATION_INIFILEUTILS__,
                                'NAVIniFileGetLongValue',
                                "'Invalid long integer value for key ', dotPath, ': ', value, '. Returning default value (', itoa(defaultValue), ')'")

    return defaultValue
}


/**
 * @function NAVIniFileGetSignedLongValue
 * @public
 * @description Get a signed long integer property value using dot notation with a default fallback.
 *              Uses atol() for conversion - invalid strings convert to 0.
 *              Returns the default value if key doesn't exist.
 *
 * @param {_NAVIniFile} iniFile - The parsed INI file structure
 * @param {char[]} dotPath - The dot-notation path (e.g., "system.offset" or "delta")
 * @param {slong} defaultValue - The default signed long integer value to return if not found
 *
 * @returns {slong} The signed long integer value or defaultValue if not found
 *
 * @example
 * stack_var slong offset
 * stack_var slong delta
 * offset = NAVIniFileGetSignedLongValue(ini, 'system.offset', -1000000)
 * delta = NAVIniFileGetSignedLongValue(ini, 'delta', 0)
 *
 * @note atol() converts invalid strings to 0. Use NAVIniFileHasKey() to check existence first if needed.
 * @note NetLinx slong is 32-bit signed: -2147483648 to 2147483647
 */
define_function slong NAVIniFileGetSignedLongValue(_NAVIniFile iniFile, char dotPath[], slong defaultValue) {
    stack_var char value[NAV_INI_PARSER_MAX_VALUE_LENGTH]

    if (!NAVIniFileHasKey(iniFile, dotPath)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_INIFILEUTILS__,
                                    'NAVIniFileGetSignedLongValue',
                                    "'Key not found: ', dotPath, '. Returning default value (', itoa(defaultValue), ')'")

        return defaultValue
    }

    value = NAVIniFileGetValue(iniFile, dotPath)
    if (!length_array(value)) {
        return defaultValue
    }

    // Trim whitespace and validate it's a valid signed long integer
    value = NAVTrimString(value)

    if (NAVRegexTest('/^[+-]?\d+$/', value)) {
        return atol(value)
    }

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                __NAV_FOUNDATION_INIFILEUTILS__,
                                'NAVIniFileGetSignedLongValue',
                                "'Invalid signed long integer value for key ', dotPath, ': ', value, '. Returning default value (', itoa(defaultValue), ')'")

    return defaultValue
}


/**
 * @function NAVIniFileGetFloatValue
 * @public
 * @description Get a float property value using dot notation with a default fallback.
 *              Uses atof() for conversion - invalid strings convert to 0.0.
 *              Returns the default value if key doesn't exist.
 *
 * @param {_NAVIniFile} iniFile - The parsed INI file structure
 * @param {char[]} dotPath - The dot-notation path (e.g., "graphics.scale" or "threshold")
 * @param {float} defaultValue - The default float value to return if not found
 *
 * @returns {float} The float value or defaultValue if not found
 *
 * @example
 * stack_var float scale
 * stack_var float threshold
 * scale = NAVIniFileGetFloatValue(ini, 'graphics.scale', 1.0)
 * threshold = NAVIniFileGetFloatValue(ini, 'threshold', 0.5)
 *
 * @note atof() converts invalid strings to 0.0. Use NAVIniFileHasKey() to check existence first if needed.
 * @note Accepts decimal notation: "3.14", "-2.5", "42", ".5" (without leading zero), "-.25", "+1.5"
 */
define_function float NAVIniFileGetFloatValue(_NAVIniFile iniFile, char dotPath[], float defaultValue) {
    stack_var char value[NAV_INI_PARSER_MAX_VALUE_LENGTH]

    if (!NAVIniFileHasKey(iniFile, dotPath)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_INIFILEUTILS__,
                                    'NAVIniFileGetFloatValue',
                                    "'Key not found: ', dotPath, '. Returning default value (', ftoa(defaultValue), ')'")

        return defaultValue
    }

    value = NAVIniFileGetValue(iniFile, dotPath)
    if (!length_array(value)) {
        return defaultValue
    }

    // Trim whitespace and validate it's a valid float
    value = NAVTrimString(value)

    // Allow formats: 5, 5.0, .5, +5.0, -.5
    if (NAVRegexTest('/^[+-]?(\d+(\.\d*)?|\.\d+)$/', value)) {
        return atof(value)
    }

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                __NAV_FOUNDATION_INIFILEUTILS__,
                                'NAVIniFileGetFloatValue',
                                "'Invalid float value for key ', dotPath, ': ', value, '. Returning default value (', ftoa(defaultValue), ')'")

    return defaultValue
}


/**
 * @function NAVIniFileGetBooleanValue
 * @public
 * @description Get a boolean property value using dot notation with a default fallback.
 *              Recognizes multiple boolean representations (case-insensitive):
 *              - True values: "1", "true", "yes", "on"
 *              - False values: "0", "false", "no", "off"
 *              Returns the default value if key doesn't exist or value is invalid.
 *
 * @param {_NAVIniFile} iniFile - The parsed INI file structure
 * @param {char[]} dotPath - The dot-notation path (e.g., "database.enabled" or "debug")
 * @param {char} defaultValue - The default boolean value to return if not found or invalid
 *
 * @returns {char} The boolean value (true/false) or defaultValue if not found/invalid
 *
 * @example
 * stack_var char enabled
 * enabled = NAVIniFileGetBooleanValue(ini, 'database.enabled', false)
 * enabled = NAVIniFileGetBooleanValue(ini, 'debug', true)
 */
define_function char NAVIniFileGetBooleanValue(_NAVIniFile iniFile, char dotPath[], char defaultValue) {
    stack_var char value[NAV_INI_PARSER_MAX_VALUE_LENGTH]

    if (!NAVIniFileHasKey(iniFile, dotPath)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_INIFILEUTILS__,
                                    'NAVIniFileGetBooleanValue',
                                    "'Key not found: ', dotPath, '. Returning default value (', NAVBooleanToString(defaultValue), ')'")

        return defaultValue
    }

    value = NAVIniFileGetValue(iniFile, dotPath)
    if (!length_array(value)) {
        return defaultValue
    }

    // Validate it's a recognized boolean value, then convert
    if (NAVRegexTest('/^(1|true|yes|on|0|false|no|off)$/i', value)) {
        return NAVStringToBoolean(value)
    }

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                __NAV_FOUNDATION_INIFILEUTILS__,
                                'NAVIniFileGetBooleanValue',
                                "'Invalid boolean value for key ', dotPath, ': ', value, '. Returning default value (', NAVBooleanToString(defaultValue), ')'")

    return defaultValue
}


/**
 * @function NAVIniFileGetStringValue
 * @public
 * @description Get a string property value using dot notation with a default fallback.
 *              Returns the raw string value without any conversion or validation.
 *              Returns the default value if key doesn't exist or value is empty.
 *
 * @param {_NAVIniFile} iniFile - The parsed INI file structure
 * @param {char[]} dotPath - The dot-notation path (e.g., "database.host" or "name")
 * @param {char[]} defaultValue - The default string value to return if not found
 *
 * @returns {char[]} The string value or defaultValue if not found or empty
 *
 * @example
 * stack_var char hostname[128]
 * stack_var char username[64]
 * hostname = NAVIniFileGetStringValue(ini, 'database.host', 'localhost')
 * username = NAVIniFileGetStringValue(ini, 'username', 'admin')
 *
 * @note Unlike typed getters, this returns the raw string without trimming or validation.
 */
define_function char[NAV_INI_PARSER_MAX_VALUE_LENGTH] NAVIniFileGetStringValue(_NAVIniFile iniFile, char dotPath[], char defaultValue[]) {
    stack_var char value[NAV_INI_PARSER_MAX_VALUE_LENGTH]

    if (!NAVIniFileHasKey(iniFile, dotPath)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_INIFILEUTILS__,
                                    'NAVIniFileGetStringValue',
                                    "'Key not found: ', dotPath, '. Returning default value (', defaultValue, ')'")

        return defaultValue
    }

    value = NAVIniFileGetValue(iniFile, dotPath)
    // Return the value even if empty - empty string is valid for strings
    return value
}


/**
 * @function NAVIniFileGetCharValue
 * @public
 * @description Get a single character property value using dot notation with a default fallback.
 *              Returns the first character of the value string.
 *              Returns the default value if key doesn't exist, value is empty, or invalid.
 *
 * @param {_NAVIniFile} iniFile - The parsed INI file structure
 * @param {char[]} dotPath - The dot-notation path (e.g., "settings.mode" or "flag")
 * @param {char} defaultValue - The default character value to return if not found
 *
 * @returns {char} The first character of the value or defaultValue if not found/empty
 *
 * @example
 * stack_var char mode
 * stack_var char flag
 * mode = NAVIniFileGetCharValue(ini, 'settings.mode', 'A')
 * flag = NAVIniFileGetCharValue(ini, 'flag', 'X')
 *
 * @note Returns only the first character. For single-letter codes or flags.
 * @note Whitespace is trimmed before extracting the character.
 */
define_function char NAVIniFileGetCharValue(_NAVIniFile iniFile, char dotPath[], char defaultValue) {
    stack_var char value[NAV_INI_PARSER_MAX_VALUE_LENGTH]

    if (!NAVIniFileHasKey(iniFile, dotPath)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_INIFILEUTILS__,
                                    'NAVIniFileGetCharValue',
                                    "'Key not found: ', dotPath, '. Returning default value (', defaultValue, ')'")

        return defaultValue
    }

    value = NAVIniFileGetValue(iniFile, dotPath)
    if (!length_array(value)) {
        return defaultValue
    }

    // Trim whitespace and validate we have at least one character
    value = NAVTrimString(value)

    if (!length_array(value)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_INIFILEUTILS__,
                                    'NAVIniFileGetCharValue',
                                    "'Empty value after trimming for key ', dotPath, '. Returning default value (', defaultValue, ')'")

        return defaultValue
    }

    return value[1]  // Return first character (1-indexed in NetLinx)
}


#END_IF // __NAV_FOUNDATION_INIFILEUTILS__
