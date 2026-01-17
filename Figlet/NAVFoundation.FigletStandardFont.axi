PROGRAM_NAME='NAVFoundation.FigletStandardFont'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_FIGLET_STANDARD_FONT__
#DEFINE __NAV_FOUNDATION_FIGLET_STANDARD_FONT__ 'NAVFoundation.FigletStandardFont'

#include 'NAVFoundation.Figlet.h.axi'

DEFINE_CONSTANT

/**
 * Standard Figlet font - Space character (ASCII 32)
 */
constant char NAV_FIGLET_STANDARD_32[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '  ',
    '  ',
    '  ',
    '  ',
    '  ',
    '  '
}

/**
 * Standard Figlet font - Exclamation mark (ASCII 33)
 */
constant char NAV_FIGLET_STANDARD_33[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _ ',
    '| |',
    '| |',
    '|_|',
    '(_)',
    '   '
}

/**
 * Standard Figlet font - Double quote (ASCII 34)
 */
constant char NAV_FIGLET_STANDARD_34[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _ _ ',
    '( | )',
    ' V V ',
    '     ',
    '     ',
    '     '
}

/**
 * Standard Figlet font - Hash/Number sign (ASCII 35)
 */
constant char NAV_FIGLET_STANDARD_35[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '   _  _   ',
    ' _| || |_ ',
    '|_  __  _|',
    ' _| || |_ ',
    '|_  __  _|',
    '  |_||_|  '
}

/**
 * Standard Figlet font - Dollar sign (ASCII 36)
 */
constant char NAV_FIGLET_STANDARD_36[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '  _  ',
    ' | | ',
    '/ __)',
    '\__ \',
    '(   /',
    ' |_| '
}

/**
 * Standard Figlet font - Percent sign (ASCII 37)
 */
constant char NAV_FIGLET_STANDARD_37[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _  __',
    '(_)/ /',
    '  / / ',
    ' / /_ ',
    '/_/(_)',
    '      '
}

/**
 * Standard Figlet font - Ampersand (ASCII 38)
 */
constant char NAV_FIGLET_STANDARD_38[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '  ___   ',
    ' ( _ )  ',
    ' / _ \/\',
    '| (_>  <',
    ' \___/\/',
    '        '
}

/**
 * Standard Figlet font - Single quote (ASCII 39)
 */
constant char NAV_FIGLET_STANDARD_39[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _ ',
    '( )',
    '|/ ',
    '   ',
    '   ',
    '   '
}

/**
 * Standard Figlet font - Left parenthesis (ASCII 40)
 */
constant char NAV_FIGLET_STANDARD_40[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '  __',
    ' / /',
    '| | ',
    '| | ',
    '| | ',
    ' \_\'
}

/**
 * Standard Figlet font - Right parenthesis (ASCII 41)
 */
constant char NAV_FIGLET_STANDARD_41[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '__  ',
    '\ \ ',
    ' | |',
    ' | |',
    ' | |',
    '_/ '
}

/**
 * Standard Figlet font - Asterisk (ASCII 42)
 */
constant char NAV_FIGLET_STANDARD_42[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '     ',
    '__/\__',
    '\    /',
    '/_  _\',
    '  \/  ',
    '      '
}

/**
 * Standard Figlet font - Plus sign (ASCII 43)
 */
constant char NAV_FIGLET_STANDARD_43[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '        ',
    '   _    ',
    ' _| |_  ',
    '|_   _| ',
    '  |_|   ',
    '        '
}

/**
 * Standard Figlet font - Comma (ASCII 44)
 */
constant char NAV_FIGLET_STANDARD_44[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '   ',
    '   ',
    '   ',
    ' _ ',
    '( )',
    '|/ '
}

/**
 * Standard Figlet font - Minus/Hyphen (ASCII 45)
 */
constant char NAV_FIGLET_STANDARD_45[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '        ',
    '        ',
    ' ______ ',
    '|______|',
    '        ',
    '        '
}

/**
 * Standard Figlet font - Period/Dot (ASCII 46)
 */
constant char NAV_FIGLET_STANDARD_46[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '   ',
    '   ',
    '   ',
    ' _ ',
    '(_)',
    '   '
}

/**
 * Standard Figlet font - Forward slash (ASCII 47)
 */
constant char NAV_FIGLET_STANDARD_47[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '    __',
    '   / /',
    '  / / ',
    ' / /  ',
    '/_/   ',
    '      '
}

/**
 * Standard Figlet font - Digit 0 (ASCII 48)
 */
constant char NAV_FIGLET_STANDARD_48[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '  ___  ',
    ' / _ \ ',
    '| | | |',
    '| |_| |',
    ' \___/ ',
    '       '
}

/**
 * Standard Figlet font - Digit 1 (ASCII 49)
 */
constant char NAV_FIGLET_STANDARD_49[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _ ',
    '/ |',
    '| |',
    '| |',
    '|_|',
    '   '
}

/**
 * Standard Figlet font - Digit 2 (ASCII 50)
 */
constant char NAV_FIGLET_STANDARD_50[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' ____  ',
    '|___ \ ',
    '  __) |',
    ' / __/ ',
    '|_____|',
    '       '
}

/**
 * Standard Figlet font - Digit 3 (ASCII 51)
 */
constant char NAV_FIGLET_STANDARD_51[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _____ ',
    '|___ / ',
    '  |_ \ ',
    ' ___) |',
    '|____/ ',
    '       '
}

/**
 * Standard Figlet font - Digit 4 (ASCII 52)
 */
constant char NAV_FIGLET_STANDARD_52[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _  _   ',
    '| || |  ',
    '| || |_ ',
    '|__   _|',
    '   |_|  ',
    '        '
}

/**
 * Standard Figlet font - Digit 5 (ASCII 53)
 */
constant char NAV_FIGLET_STANDARD_53[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' ____  ',
    '| ___| ',
    '|___ \ ',
    ' ___) |',
    '|____/ ',
    '       '
}

/**
 * Standard Figlet font - Digit 6 (ASCII 54)
 */
constant char NAV_FIGLET_STANDARD_54[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '  __   ',
    ' / /_  ',
    '| ''_ \ ',
    '| (_) |',
    ' \___/ ',
    '       '
}

/**
 * Standard Figlet font - Digit 7 (ASCII 55)
 */
constant char NAV_FIGLET_STANDARD_55[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _____ ',
    '|___  |',
    '   / / ',
    '  / /  ',
    ' /_/   ',
    '       '
}

/**
 * Standard Figlet font - Digit 8 (ASCII 56)
 */
constant char NAV_FIGLET_STANDARD_56[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '  ___  ',
    ' ( _ ) ',
    ' / _ \ ',
    '| (_) |',
    ' \___/ ',
    '       '
}

/**
 * Standard Figlet font - Digit 9 (ASCII 57)
 */
constant char NAV_FIGLET_STANDARD_57[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '  ___  ',
    ' / _ \ ',
    '| (_) |',
    ' \__, |',
    '   /_/ ',
    '       '
}

/**
 * Standard Figlet font - Colon (ASCII 58)
 */
constant char NAV_FIGLET_STANDARD_58[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '   ',
    ' _ ',
    '(_)',
    ' _ ',
    '(_)',
    '   '
}

/**
 * Standard Figlet font - Semicolon (ASCII 59)
 */
constant char NAV_FIGLET_STANDARD_59[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '   ',
    ' _ ',
    '(_)',
    ' _ ',
    '( )',
    '|/ '
}

/**
 * Standard Figlet font - Less than (ASCII 60)
 */
constant char NAV_FIGLET_STANDARD_60[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '   __',
    '  / /',
    ' / / ',
    '< <  ',
    ' \ \ ',
    '  \_\'
}

/**
 * Standard Figlet font - Equals sign (ASCII 61)
 */
constant char NAV_FIGLET_STANDARD_61[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '        ',
    ' ______ ',
    '|______|',
    '|______|',
    '        ',
    '        '
}

/**
 * Standard Figlet font - Greater than (ASCII 62)
 */
constant char NAV_FIGLET_STANDARD_62[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '__   ',
    '\ \  ',
    ' \ \ ',
    '  > >',
    ' / / ',
    '/_/  '
}

/**
 * Standard Figlet font - Question mark (ASCII 63)
 */
constant char NAV_FIGLET_STANDARD_63[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' ___  ',
    '|__ \ ',
    '  / / ',
    ' |_|  ',
    ' (_)  ',
    '      '
}

/**
 * Standard Figlet font - At sign (ASCII 64)
 */
constant char NAV_FIGLET_STANDARD_64[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '   ____  ',
    '  / __ \ ',
    ' / / _` |',
    '| | (_| |',
    ' \ \__,_|',
    '  \____/ '
}

/**
 * Standard Figlet font - Uppercase A (ASCII 65)
 */
constant char NAV_FIGLET_STANDARD_65[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '    _    ',
    '   / \   ',
    '  / _ \  ',
    ' / ___ \ ',
    '/_/   \_\',
    '         '
}

/**
 * Standard Figlet font - Uppercase B (ASCII 66)
 */
constant char NAV_FIGLET_STANDARD_66[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' ____  ',
    '| __ ) ',
    '|  _ \ ',
    '| |_) |',
    '|____/ ',
    '       '
}

/**
 * Standard Figlet font - Uppercase C (ASCII 67)
 */
constant char NAV_FIGLET_STANDARD_67[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '  ____ ',
    ' / ___|',
    '| |    ',
    '| |___ ',
    ' \____|',
    '       '
}

/**
 * Standard Figlet font - Uppercase D (ASCII 68)
 */
constant char NAV_FIGLET_STANDARD_68[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' ____  ',
    '|  _ \ ',
    '| | | |',
    '| |_| |',
    '|____/ ',
    '       '
}

/**
 * Standard Figlet font - Uppercase E (ASCII 69)
 */
constant char NAV_FIGLET_STANDARD_69[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _____ ',
    '| ____|',
    '|  _|  ',
    '| |___ ',
    '|_____|',
    '       '
}

/**
 * Standard Figlet font - Uppercase F (ASCII 70)
 */
constant char NAV_FIGLET_STANDARD_70[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _____ ',
    '|  ___|',
    '| |_   ',
    '|  _|  ',
    '|_|    ',
    '       '
}

/**
 * Standard Figlet font - Uppercase G (ASCII 71)
 */
constant char NAV_FIGLET_STANDARD_71[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '  ____ ',
    ' / ___|',
    '| |  _ ',
    '| |_| |',
    ' \____|',
    '       '
}

/**
 * Standard Figlet font - Uppercase H (ASCII 72)
 */
constant char NAV_FIGLET_STANDARD_72[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _   _ ',
    '| | | |',
    '| |_| |',
    '|  _  |',
    '|_| |_|',
    '       '
}

/**
 * Standard Figlet font - Uppercase I (ASCII 73)
 */
constant char NAV_FIGLET_STANDARD_73[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' ___ ',
    '|_ _|',
    ' | | ',
    ' | | ',
    '|___|',
    '     '
}

/**
 * Standard Figlet font - Uppercase J (ASCII 74)
 */
constant char NAV_FIGLET_STANDARD_74[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '     _ ',
    '    | |',
    ' _  | |',
    '| |_| |',
    ' \___/ ',
    '       '
}

/**
 * Standard Figlet font - Uppercase K (ASCII 75)
 */
constant char NAV_FIGLET_STANDARD_75[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _  __',
    '| |/ /',
    '| '' / ',
    '| . \ ',
    '|_|\_\',
    '      '
}

/**
 * Standard Figlet font - Uppercase L (ASCII 76)
 */
constant char NAV_FIGLET_STANDARD_76[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _     ',
    '| |    ',
    '| |    ',
    '| |___ ',
    '|_____|',
    '       '
}

/**
 * Standard Figlet font - Uppercase M (ASCII 77)
 */
constant char NAV_FIGLET_STANDARD_77[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' __  __ ',
    '|  \/  |',
    '| |\/| |',
    '| |  | |',
    '|_|  |_|',
    '        '
}

/**
 * Standard Figlet font - Uppercase N (ASCII 78)
 */
constant char NAV_FIGLET_STANDARD_78[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _   _ ',
    '| \ | |',
    '|  \| |',
    '| |\  |',
    '|_| \_|',
    '       '
}

/**
 * Standard Figlet font - Uppercase O (ASCII 79)
 */
constant char NAV_FIGLET_STANDARD_79[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '  ___  ',
    ' / _ \ ',
    '| | | |',
    '| |_| |',
    ' \___/ ',
    '       '
}

/**
 * Standard Figlet font - Uppercase P (ASCII 80)
 */
constant char NAV_FIGLET_STANDARD_80[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' ____  ',
    '|  _ \ ',
    '| |_) |',
    '|  __/ ',
    '|_|    ',
    '       '
}

/**
 * Standard Figlet font - Uppercase Q (ASCII 81)
 */
constant char NAV_FIGLET_STANDARD_81[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '  ___  ',
    ' / _ \ ',
    '| | | |',
    '| |_| |',
    ' \__\_\',
    '       '
}

/**
 * Standard Figlet font - Uppercase R (ASCII 82)
 */
constant char NAV_FIGLET_STANDARD_82[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' ____  ',
    '|  _ \ ',
    '| |_) |',
    '|  _ < ',
    '|_| \_\',
    '       '
}

/**
 * Standard Figlet font - Uppercase S (ASCII 83)
 */
constant char NAV_FIGLET_STANDARD_83[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' ____  ',
    '/ ___| ',
    '\___ \ ',
    ' ___) |',
    '|____/ ',
    '       '
}

/**
 * Standard Figlet font - Uppercase T (ASCII 84)
 */
constant char NAV_FIGLET_STANDARD_84[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _____ ',
    '|_   _|',
    '  | |  ',
    '  | |  ',
    '  |_|  ',
    '       '
}

/**
 * Standard Figlet font - Uppercase U (ASCII 85)
 */
constant char NAV_FIGLET_STANDARD_85[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _   _ ',
    '| | | |',
    '| | | |',
    '| |_| |',
    ' \___/ ',
    '       '
}

/**
 * Standard Figlet font - Uppercase V (ASCII 86)
 */
constant char NAV_FIGLET_STANDARD_86[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '__     __',
    '\ \   / /',
    ' \ \ / / ',
    '  \ V /  ',
    '   \_/   ',
    '         '
}

/**
 * Standard Figlet font - Uppercase W (ASCII 87)
 */
constant char NAV_FIGLET_STANDARD_87[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '__        __',
    '\ \      / /',
    ' \ \ /\ / / ',
    '  \ V  V /  ',
    '   \_/\_/   ',
    '            '
}

/**
 * Standard Figlet font - Uppercase X (ASCII 88)
 */
constant char NAV_FIGLET_STANDARD_88[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '__  __',
    '\ \/ /',
    ' \  / ',
    ' /  \ ',
    '/_/\_\',
    '      '
}

/**
 * Standard Figlet font - Uppercase Y (ASCII 89)
 */
constant char NAV_FIGLET_STANDARD_89[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '__   __',
    '\ \ / /',
    ' \ V / ',
    '  | |  ',
    '  |_|  ',
    '       '
}

/**
 * Standard Figlet font - Uppercase Z (ASCII 90)
 */
constant char NAV_FIGLET_STANDARD_90[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _____',
    '|__  /',
    '  / / ',
    ' / /_ ',
    '/____|',
    '      '
}

/**
 * Standard Figlet font - Left square bracket (ASCII 91)
 */
constant char NAV_FIGLET_STANDARD_91[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' ___',
    '|  _|',
    '| |  ',
    '| |  ',
    '| |_ ',
    '|___|'
}

/**
 * Standard Figlet font - Backslash (ASCII 92)
 */
constant char NAV_FIGLET_STANDARD_92[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '__    ',
    '\ \   ',
    ' \ \  ',
    '  \ \ ',
    '   \_\',
    '      '
}

/**
 * Standard Figlet font - Right square bracket (ASCII 93)
 */
constant char NAV_FIGLET_STANDARD_93[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '___ ',
    '|_  |',
    '  | |',
    '  | |',
    ' _| |',
    '|___|'
}

/**
 * Standard Figlet font - Caret (ASCII 94)
 */
constant char NAV_FIGLET_STANDARD_94[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' /\ ',
    '|/\|',
    '    ',
    '    ',
    '    ',
    '    '
}

/**
 * Standard Figlet font - Underscore (ASCII 95)
 */
constant char NAV_FIGLET_STANDARD_95[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '        ',
    '        ',
    '        ',
    '        ',
    ' ______ ',
    '|______|'
}

/**
 * Standard Figlet font - Backtick (ASCII 96)
 */
constant char NAV_FIGLET_STANDARD_96[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _ ',
    '( )',
    ' \|',
    '   ',
    '   ',
    '   '
}

/**
 * Standard Figlet font - Lowercase a (ASCII 97)
 */
constant char NAV_FIGLET_STANDARD_97[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '       ',
    '  __ _ ',
    ' / _` |',
    '| (_| |',
    ' \__,_|',
    '       '
}

/**
 * Standard Figlet font - Lowercase b (ASCII 98)
 */
constant char NAV_FIGLET_STANDARD_98[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _     ',
    '| |__  ',
    '| ''_ \ ',
    '| |_) |',
    '|_.__/ ',
    '       '
}

/**
 * Standard Figlet font - Lowercase c (ASCII 99)
 */
constant char NAV_FIGLET_STANDARD_99[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '      ',
    '  ___ ',
    ' / __|',
    '| (__ ',
    ' \___|',
    '      '
}

/**
 * Standard Figlet font - Lowercase d (ASCII 100)
 */
constant char NAV_FIGLET_STANDARD_100[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '     _ ',
    '  __| |',
    ' / _` |',
    '| (_| |',
    ' \__,_|',
    '       '
}

/**
 * Standard Figlet font - Lowercase e (ASCII 101)
 */
constant char NAV_FIGLET_STANDARD_101[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '      ',
    '  ___ ',
    ' / _ \',
    '|  __/',
    ' \___|',
    '      '
}

/**
 * Standard Figlet font - Lowercase f (ASCII 102)
 */
constant char NAV_FIGLET_STANDARD_102[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '  __ ',
    ' / _|',
    '| |_ ',
    '|  _|',
    '|_|  ',
    '     '
}

/**
 * Standard Figlet font - Lowercase g (ASCII 103)
 */
constant char NAV_FIGLET_STANDARD_103[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '       ',
    '  __ _ ',
    ' / _` |',
    '| (_| |',
    ' \__, |',
    ' |___/ '
}

/**
 * Standard Figlet font - Lowercase h (ASCII 104)
 */
constant char NAV_FIGLET_STANDARD_104[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _     ',
    '| |__  ',
    '| ''_ \ ',
    '| | | |',
    '|_| |_|',
    '       '
}

/**
 * Standard Figlet font - Lowercase i (ASCII 105)
 */
constant char NAV_FIGLET_STANDARD_105[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _ ',
    '(_)',
    '| |',
    '| |',
    '|_|',
    '   '
}

/**
 * Standard Figlet font - Lowercase j (ASCII 106)
 */
constant char NAV_FIGLET_STANDARD_106[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '    _ ',
    '   (_)',
    '   | |',
    '   | |',
    '  _/ |',
    ' |__/ '
}

/**
 * Standard Figlet font - Lowercase k (ASCII 107)
 */
constant char NAV_FIGLET_STANDARD_107[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _    ',
    '| | __',
    '| |/ /',
    '|   < ',
    '|_|\_\',
    '      '
}

/**
 * Standard Figlet font - Lowercase l (ASCII 108)
 */
constant char NAV_FIGLET_STANDARD_108[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _ ',
    '| |',
    '| |',
    '| |',
    '|_|',
    '   '
}

/**
 * Standard Figlet font - Lowercase m (ASCII 109)
 */
constant char NAV_FIGLET_STANDARD_109[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '            ',
    ' _ __ ___   ',
    '| ''_ ` _ \  ',
    '| | | | | | ',
    '|_| |_| |_| ',
    '            '
}

/**
 * Standard Figlet font - Lowercase n (ASCII 110)
 */
constant char NAV_FIGLET_STANDARD_110[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '       ',
    ' _ __  ',
    '| ''_ \ ',
    '| | | |',
    '|_| |_|',
    '       '
}

/**
 * Standard Figlet font - Lowercase o (ASCII 111)
 */
constant char NAV_FIGLET_STANDARD_111[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '       ',
    '  ___  ',
    ' / _ \ ',
    '| (_) |',
    ' \___/ ',
    '       '
}

/**
 * Standard Figlet font - Lowercase p (ASCII 112)
 */
constant char NAV_FIGLET_STANDARD_112[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '       ',
    ' _ __  ',
    '| ''_ \ ',
    '| |_) |',
    '| .__/ ',
    '|_|    '
}

/**
 * Standard Figlet font - Lowercase q (ASCII 113)
 */
constant char NAV_FIGLET_STANDARD_113[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '       ',
    '  __ _ ',
    ' / _` |',
    '| (_| |',
    ' \__, |',
    '    |_|'
}

/**
 * Standard Figlet font - Lowercase r (ASCII 114)
 */
constant char NAV_FIGLET_STANDARD_114[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '      ',
    ' _ __ ',
    '| ''__|',
    '| |   ',
    '|_|   ',
    '      '
}

/**
 * Standard Figlet font - Lowercase s (ASCII 115)
 */
constant char NAV_FIGLET_STANDARD_115[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '     ',
    ' ___ ',
    '/ __|',
    '\__ \',
    '|___/',
    '     '
}

/**
 * Standard Figlet font - Lowercase t (ASCII 116)
 */
constant char NAV_FIGLET_STANDARD_116[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _   ',
    '| |_ ',
    '| __|',
    '| |_ ',
    ' \__|',
    '     '
}

/**
 * Standard Figlet font - Lowercase u (ASCII 117)
 */
constant char NAV_FIGLET_STANDARD_117[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '       ',
    ' _   _ ',
    '| | | |',
    '| |_| |',
    ' \__,_|',
    '       '
}

/**
 * Standard Figlet font - Lowercase v (ASCII 118)
 */
constant char NAV_FIGLET_STANDARD_118[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '       ',
    '__   __',
    '\ \ / /',
    ' \ V / ',
    '  \_/  ',
    '       '
}

/**
 * Standard Figlet font - Lowercase w (ASCII 119)
 */
constant char NAV_FIGLET_STANDARD_119[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '          ',
    '__      __',
    '\ \ /\ / /',
    ' \ V  V / ',
    '  \_/\_/  ',
    '          '
}

/**
 * Standard Figlet font - Lowercase x (ASCII 120)
 */
constant char NAV_FIGLET_STANDARD_120[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '      ',
    '__  __',
    '\ \/ /',
    ' >  < ',
    '/_/\_\',
    '      '
}

/**
 * Standard Figlet font - Lowercase y (ASCII 121)
 */
constant char NAV_FIGLET_STANDARD_121[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '       ',
    ' _   _ ',
    '| | | |',
    '| |_| |',
    ' \__, |',
    ' |___/ '
}

/**
 * Standard Figlet font - Lowercase z (ASCII 122)
 */
constant char NAV_FIGLET_STANDARD_122[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '     ',
    ' ____',
    '|_  /',
    ' / / ',
    '/___|',
    '     '
}

/**
 * Standard Figlet font - Left curly brace (ASCII 123)
 */
constant char NAV_FIGLET_STANDARD_123[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '   __',
    '  / /',
    ' | | ',
    '< <  ',
    ' | | ',
    '  \_\'
}

/**
 * Standard Figlet font - Vertical bar (ASCII 124)
 */
constant char NAV_FIGLET_STANDARD_124[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' _ ',
    '| |',
    '| |',
    '| |',
    '| |',
    '|_|'
}

/**
 * Standard Figlet font - Right curly brace (ASCII 125)
 */
constant char NAV_FIGLET_STANDARD_125[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    '__   ',
    '\ \  ',
    ' | | ',
    '  > >',
    ' | | ',
    '/_/  '
}

/**
 * Standard Figlet font - Tilde (ASCII 126)
 */
constant char NAV_FIGLET_STANDARD_126[NAV_FIGLET_FONT_HEIGHT][NAV_FIGLET_MAX_CHAR_WIDTH] = {
    ' /\/|',
    '|/\/ ',
    '     ',
    '     ',
    '     ',
    '     '
}


/**
 * Gets the visual width of a character in the Standard Figlet font
 *
 * @param c The character to get the width for (ASCII 32-126)
 * @return The width of the character in columns, or 2 for unknown characters
 */
define_function integer NAVFigletStandardGetCharWidth(char c) {
    switch (c) {
        case 32: return 2
        case 33: return 3
        case 34: return 5
        case 35: return 10
        case 36: return 5
        case 37: return 6
        case 38: return 8
        case 39: return 3
        case 40: return 4
        case 41: return 4
        case 42: return 6
        case 43: return 8
        case 44: return 3
        case 45: return 8
        case 46: return 3
        case 47: return 6
        case 48: return 7
        case 49: return 3
        case 50: return 7
        case 51: return 7
        case 52: return 8
        case 53: return 7
        case 54: return 7
        case 55: return 7
        case 56: return 7
        case 57: return 7
        case 58: return 3
        case 59: return 3
        case 60: return 4
        case 61: return 8
        case 62: return 5
        case 63: return 6
        case 64: return 9
        case 65: return 9
        case 66: return 7
        case 67: return 7
        case 68: return 7
        case 69: return 7
        case 70: return 7
        case 71: return 7
        case 72: return 7
        case 73: return 5
        case 74: return 7
        case 75: return 6
        case 76: return 7
        case 77: return 8
        case 78: return 7
        case 79: return 7
        case 80: return 7
        case 81: return 7
        case 82: return 7
        case 83: return 7
        case 84: return 7
        case 85: return 7
        case 86: return 9
        case 87: return 12
        case 88: return 6
        case 89: return 7
        case 90: return 6
        case 91: return 4
        case 92: return 6
        case 93: return 4
        case 94: return 4
        case 95: return 8
        case 96: return 3
        case 97: return 7
        case 98: return 7
        case 99: return 6
        case 100: return 7
        case 101: return 6
        case 102: return 5
        case 103: return 7
        case 104: return 7
        case 105: return 3
        case 106: return 6
        case 107: return 6
        case 108: return 3
        case 109: return 12
        case 110: return 7
        case 111: return 7
        case 112: return 7
        case 113: return 7
        case 114: return 6
        case 115: return 5
        case 116: return 5
        case 117: return 7
        case 118: return 7
        case 119: return 10
        case 120: return 6
        case 121: return 7
        case 122: return 5
        case 123: return 4
        case 124: return 3
        case 125: return 5
        case 126: return 5
        default: return 2
    }
}

/**
 * Gets a specific line of a character from the Standard Figlet font
 *
 * @param c The character to get the line for (ASCII 32-126)
 * @param line The line number (1-6) to retrieve
 * @return The character's line representation, or '  ' for unknown characters
 */
define_function char[NAV_FIGLET_MAX_CHAR_WIDTH] NAVFigletStandardGetCharLine(char c, integer line) {
    stack_var char result[NAV_FIGLET_MAX_CHAR_WIDTH]

    switch (c) {
        case 32: result = NAV_FIGLET_STANDARD_32[line]
        case 33: result = NAV_FIGLET_STANDARD_33[line]
        case 34: result = NAV_FIGLET_STANDARD_34[line]
        case 35: result = NAV_FIGLET_STANDARD_35[line]
        case 36: result = NAV_FIGLET_STANDARD_36[line]
        case 37: result = NAV_FIGLET_STANDARD_37[line]
        case 38: result = NAV_FIGLET_STANDARD_38[line]
        case 39: result = NAV_FIGLET_STANDARD_39[line]
        case 40: result = NAV_FIGLET_STANDARD_40[line]
        case 41: result = NAV_FIGLET_STANDARD_41[line]
        case 42: result = NAV_FIGLET_STANDARD_42[line]
        case 43: result = NAV_FIGLET_STANDARD_43[line]
        case 44: result = NAV_FIGLET_STANDARD_44[line]
        case 45: result = NAV_FIGLET_STANDARD_45[line]
        case 46: result = NAV_FIGLET_STANDARD_46[line]
        case 47: result = NAV_FIGLET_STANDARD_47[line]
        case 48: result = NAV_FIGLET_STANDARD_48[line]
        case 49: result = NAV_FIGLET_STANDARD_49[line]
        case 50: result = NAV_FIGLET_STANDARD_50[line]
        case 51: result = NAV_FIGLET_STANDARD_51[line]
        case 52: result = NAV_FIGLET_STANDARD_52[line]
        case 53: result = NAV_FIGLET_STANDARD_53[line]
        case 54: result = NAV_FIGLET_STANDARD_54[line]
        case 55: result = NAV_FIGLET_STANDARD_55[line]
        case 56: result = NAV_FIGLET_STANDARD_56[line]
        case 57: result = NAV_FIGLET_STANDARD_57[line]
        case 58: result = NAV_FIGLET_STANDARD_58[line]
        case 59: result = NAV_FIGLET_STANDARD_59[line]
        case 60: result = NAV_FIGLET_STANDARD_60[line]
        case 61: result = NAV_FIGLET_STANDARD_61[line]
        case 62: result = NAV_FIGLET_STANDARD_62[line]
        case 63: result = NAV_FIGLET_STANDARD_63[line]
        case 64: result = NAV_FIGLET_STANDARD_64[line]
        case 65: result = NAV_FIGLET_STANDARD_65[line]
        case 66: result = NAV_FIGLET_STANDARD_66[line]
        case 67: result = NAV_FIGLET_STANDARD_67[line]
        case 68: result = NAV_FIGLET_STANDARD_68[line]
        case 69: result = NAV_FIGLET_STANDARD_69[line]
        case 70: result = NAV_FIGLET_STANDARD_70[line]
        case 71: result = NAV_FIGLET_STANDARD_71[line]
        case 72: result = NAV_FIGLET_STANDARD_72[line]
        case 73: result = NAV_FIGLET_STANDARD_73[line]
        case 74: result = NAV_FIGLET_STANDARD_74[line]
        case 75: result = NAV_FIGLET_STANDARD_75[line]
        case 76: result = NAV_FIGLET_STANDARD_76[line]
        case 77: result = NAV_FIGLET_STANDARD_77[line]
        case 78: result = NAV_FIGLET_STANDARD_78[line]
        case 79: result = NAV_FIGLET_STANDARD_79[line]
        case 80: result = NAV_FIGLET_STANDARD_80[line]
        case 81: result = NAV_FIGLET_STANDARD_81[line]
        case 82: result = NAV_FIGLET_STANDARD_82[line]
        case 83: result = NAV_FIGLET_STANDARD_83[line]
        case 84: result = NAV_FIGLET_STANDARD_84[line]
        case 85: result = NAV_FIGLET_STANDARD_85[line]
        case 86: result = NAV_FIGLET_STANDARD_86[line]
        case 87: result = NAV_FIGLET_STANDARD_87[line]
        case 88: result = NAV_FIGLET_STANDARD_88[line]
        case 89: result = NAV_FIGLET_STANDARD_89[line]
        case 90: result = NAV_FIGLET_STANDARD_90[line]
        case 91: result = NAV_FIGLET_STANDARD_91[line]
        case 92: result = NAV_FIGLET_STANDARD_92[line]
        case 93: result = NAV_FIGLET_STANDARD_93[line]
        case 94: result = NAV_FIGLET_STANDARD_94[line]
        case 95: result = NAV_FIGLET_STANDARD_95[line]
        case 96: result = NAV_FIGLET_STANDARD_96[line]
        case 97: result = NAV_FIGLET_STANDARD_97[line]
        case 98: result = NAV_FIGLET_STANDARD_98[line]
        case 99: result = NAV_FIGLET_STANDARD_99[line]
        case 100: result = NAV_FIGLET_STANDARD_100[line]
        case 101: result = NAV_FIGLET_STANDARD_101[line]
        case 102: result = NAV_FIGLET_STANDARD_102[line]
        case 103: result = NAV_FIGLET_STANDARD_103[line]
        case 104: result = NAV_FIGLET_STANDARD_104[line]
        case 105: result = NAV_FIGLET_STANDARD_105[line]
        case 106: result = NAV_FIGLET_STANDARD_106[line]
        case 107: result = NAV_FIGLET_STANDARD_107[line]
        case 108: result = NAV_FIGLET_STANDARD_108[line]
        case 109: result = NAV_FIGLET_STANDARD_109[line]
        case 110: result = NAV_FIGLET_STANDARD_110[line]
        case 111: result = NAV_FIGLET_STANDARD_111[line]
        case 112: result = NAV_FIGLET_STANDARD_112[line]
        case 113: result = NAV_FIGLET_STANDARD_113[line]
        case 114: result = NAV_FIGLET_STANDARD_114[line]
        case 115: result = NAV_FIGLET_STANDARD_115[line]
        case 116: result = NAV_FIGLET_STANDARD_116[line]
        case 117: result = NAV_FIGLET_STANDARD_117[line]
        case 118: result = NAV_FIGLET_STANDARD_118[line]
        case 119: result = NAV_FIGLET_STANDARD_119[line]
        case 120: result = NAV_FIGLET_STANDARD_120[line]
        case 121: result = NAV_FIGLET_STANDARD_121[line]
        case 122: result = NAV_FIGLET_STANDARD_122[line]
        case 123: result = NAV_FIGLET_STANDARD_123[line]
        case 124: result = NAV_FIGLET_STANDARD_124[line]
        case 125: result = NAV_FIGLET_STANDARD_125[line]
        case 126: result = NAV_FIGLET_STANDARD_126[line]
        default: result = '  '
    }

    // Return without trimming - trailing spaces are needed for overlap calculation
    return result
}

#END_IF // __NAV_FOUNDATION_FIGLET_STANDARD_FONT__
