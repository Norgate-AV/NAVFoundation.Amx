PROGRAM_NAME='NAVFoundation.Figlet.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_FIGLET_H__
#DEFINE __NAV_FOUNDATION_FIGLET_H__ 'NAVFoundation.Figlet.h'

DEFINE_CONSTANT

// =============================================================================
// Font Type Constants
// =============================================================================
// Font identifiers follow the pattern: NAV_FIGLET_FONT_<NAME>
// Values 1-99 are reserved for built-in fonts
// Values 100+ are reserved for custom/user-defined fonts
//
// When adding a new font:
// 1. Add a new NAV_FIGLET_FONT_<NAME> constant
// 2. Add corresponding dimension constants (HEIGHT, MAX_WIDTH)
// 3. Add font data arrays (NAV_FIGLET_<NAME>_<ASCII>)
// 4. Update NAVFigletWithFont() validation logic
// 5. Add font-specific helper functions if dimensions differ
// =============================================================================

/**
 * Font type: Standard Figlet font
 *
 * The default font used by the original Figlet tool.
 * Features 6-line height characters with CONTROLLED_SMUSHING layout mode
 * using rules 1-4 (equal char, underscore, hierarchy, opposite pairs).
 */
constant integer NAV_FIGLET_FONT_STANDARD = 1

// Reserved for future fonts: 2-99

/**
 * Default font type used by NAVFiglet()
 */
constant integer NAV_FIGLET_FONT_DEFAULT = NAV_FIGLET_FONT_STANDARD

// =============================================================================
// Font Dimension Constants - Standard Font
// =============================================================================
// Note: When adding fonts with different dimensions, use the pattern:
//   NAV_FIGLET_<FONTNAME>_HEIGHT
//   NAV_FIGLET_<FONTNAME>_MAX_CHAR_WIDTH
// =============================================================================

/**
 * The height of the Standard Figlet font in lines
 */
constant integer NAV_FIGLET_FONT_HEIGHT = 6

/**
 * The maximum width of a single character in the Standard Figlet font
 */
constant integer NAV_FIGLET_MAX_CHAR_WIDTH = 12

#END_IF // __NAV_FOUNDATION_FIGLET_H__
