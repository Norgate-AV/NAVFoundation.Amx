PROGRAM_NAME='NAVFoundation.Tui'

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


#IF_NOT_DEFINED __NAV_FOUNDATION_TUI__
#DEFINE __NAV_FOUNDATION_TUI__ 'NAVFoundation.Tui'

#include 'NAVFoundation.Tui.h.axi'
#include 'NAVFoundation.Core.h.axi'


define_function char[NAV_MAX_CHARS] NAVGetColor(char color[]) {
    return "NAV_ESC, color"
}


define_function char[NAV_MAX_BUFFER] NAVColorRed(char value[]) {
    return "NAVGetColor(NAV_ANSI_SGR_FOREGROUND_BRIGHT_RED), value, NAVGetColor(NAV_ANSI_SGR_RESET)"
}


define_function char[NAV_MAX_BUFFER] NAVColorGreen(char value[]) {
    return "NAVGetColor(NAV_ANSI_SGR_FOREGROUND_BRIGHT_GREEN), value, NAVGetColor(NAV_ANSI_SGR_RESET)"
}


define_function char[NAV_MAX_BUFFER] NAVColorYellow(char value[]) {
    return "NAVGetColor(NAV_ANSI_SGR_FOREGROUND_BRIGHT_YELLOW), value, NAVGetColor(NAV_ANSI_SGR_RESET)"
}


define_function char[NAV_MAX_BUFFER] NAVColorBlue(char value[]) {
    return "NAVGetColor(NAV_ANSI_SGR_FOREGROUND_BRIGHT_BLUE), value, NAVGetColor(NAV_ANSI_SGR_RESET)"
}


define_function char[NAV_MAX_BUFFER] NAVColorMagenta(char value[]) {
    return "NAVGetColor(NAV_ANSI_SGR_FOREGROUND_BRIGHT_MAGENTA), value, NAVGetColor(NAV_ANSI_SGR_RESET)"
}


define_function char[NAV_MAX_BUFFER] NAVColorCyan(char value[]) {
    return "NAVGetColor(NAV_ANSI_SGR_FOREGROUND_BRIGHT_CYAN), value, NAVGetColor(NAV_ANSI_SGR_RESET)"
}


define_function char[NAV_MAX_BUFFER] NAVColorWhite(char value[]) {
    return "NAVGetColor(NAV_ANSI_SGR_FOREGROUND_BRIGHT_WHITE), value, NAVGetColor(NAV_ANSI_SGR_RESET)"
}


define_function char[NAV_MAX_BUFFER] NAVColorBlack(char value[]) {
    return "NAVGetColor(NAV_ANSI_SGR_FOREGROUND_BRIGHT_BLACK), value, NAVGetColor(NAV_ANSI_SGR_RESET)"
}


#END_IF // __NAV_FOUNDATION_TUI__
