PROGRAM_NAME='NAVFoundation.Regex'

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

/**
 *  Largely based on the tiny-regex-c library
 *  https://github.com/kokke/tiny-regex-c
 *
 *  Adapted for use in NetLinx
 */


#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX__
#DEFINE __NAV_FOUNDATION_REGEX__ 'NAVFoundation.Regex'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Regex.h.axi'
#include 'NAVFoundation.Regex.Compiler.axi'
#include 'NAVFoundation.Regex.Matcher.axi'
#include 'NAVFoundation.Regex.Helpers.axi'


define_function char NAVRegexTest(char buffer[], char pattern[]) {
    stack_var _NAVRegexParser parser
    stack_var _NAVRegexMatchResult match

    if (!NAVRegexCompile(pattern, parser)) {
        return false
    }

    return NAVRegexMatchCompiled(parser, buffer, match)
}


define_function char NAVRegexMatch(char pattern[], char subject[], _NAVRegexMatchResult match) {
    stack_var _NAVRegexParser parser

    if (!NAVRegexCompile(pattern, parser)) {
        return false
    }

    #IF_DEFINED REGEX_MATCHER_DEBUG
    NAVLog("'[ Match ]: Pattern compiled with ', itoa(parser.count), ' tokens'")
    NAVRegexPrintState(parser)
    #END_IF

    if (NAVRegexMatchCompiled(parser, subject, match)) {
        #WARN 'May need to move this to the NAVRegexMatchCompiled function'
        // May move this to the NAVRegexMatchCompiled function?
        // The below needs to be done if the MatchCompiled function
        // is used directly as well as the Match function.
        // So it probably make more sense to do it in the MatchCompiled function

        // match.matches[match.current].end = match.matches[match.current].start + match.matches[match.current].length
        NAVRegexMatchSetEnd(parser, 'Match', match, NAVRegexMatchGetEnd(match))
        // match.matches[match.current].text = NAVStringSlice(buffer, match.matches[match.current].start, match.matches[match.current].end)
        NAVRegexMatchSetText(parser, 'Match', match, NAVRegexMatchGetTextFromBuffer(match, subject))

        match.count++
        match.current++

        // If global flag is set, continue matching after the current match
        // Maybe switch to a while loop here?
        // In this case we would need to return as array of matches
        // meaning the function signature would need to change
        // So perhaps a separate function for global matching?
        // However, the flag is set in the regex pattern, so it seems
        // silly to have to remember to use a different API. Maybe
        // instead the match result should always be an array of matches
        // with a count?

        return true
    }

    return false
}


#END_IF // __NAV_FOUNDATION_REGEX__
