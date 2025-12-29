PROGRAM_NAME='NAVFoundation.RegexHelpers'

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

/**
 * Regex Helper Functions
 *
 * This module provides shared helper functions for working with regex
 * match results, particularly for accessing named capture groups.
 *
 * These functions are used by multiple regex modules (Regex.axi,
 * RegexTemplate.axi) and are extracted here to avoid circular dependencies.
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX_HELPERS__
#DEFINE __NAV_FOUNDATION_REGEX_HELPERS__ 'NAVFoundation.RegexHelpers'

#include 'NAVFoundation.RegexMatcher.h.axi'


// ============================================================================
// NAMED GROUP ACCESSOR FUNCTIONS
// ============================================================================

/**
 * @function NAVRegexGetNamedGroupFromMatch
 * @public
 * @description Get a named capture group from a single match.
 *
 * Searches the groups in the match for the named group.
 * This is the primitive function used by NAVRegexGetNamedGroupFromMatchCollection.
 *
 * For numbered groups, access directly via match.groups[i].
 *
 * @param {_NAVRegexMatchResult} match - The match to search
 * @param {char[]} name - Name of the group to find
 * @param {_NAVRegexGroup} group - Output: the found group (with full details)
 *
 * @returns {char} TRUE if named group found in match, FALSE otherwise
 */
define_function char NAVRegexGetNamedGroupFromMatch(_NAVRegexMatchResult match,
                                                     char name[],
                                                     _NAVRegexGroup group) {
    stack_var integer i

    // Search all groups in this match
    for (i = 1; i <= match.groupCount; i++) {
        if (match.groups[i].isCaptured &&
            match.groups[i].name == name) {
            // Found it - copy to output parameter
            group = match.groups[i]
            return true
        }
    }

    // Not found
    return false
}


/**
 * @function NAVRegexGetNamedGroupFromMatchCollection
 * @public
 * @description Get a named capture group from any match in the collection.
 *
 * Searches all matches in the collection for the first occurrence of the
 * named group. Since group names are unique within a pattern, no match
 * index is needed - the function searches the entire collection.
 *
 * This function uses NAVRegexGetNamedGroupFromMatch() internally to search
 * each match in the collection.
 *
 * For numbered groups, access directly via collection.matches[i].groups[j].
 *
 * @param {_NAVRegexMatchCollection} collection - The match collection to search
 * @param {char[]} name - Name of the group to find
 * @param {_NAVRegexGroup} group - Output: the found group (with full details)
 *
 * @returns {char} TRUE if named group found in any match, FALSE otherwise
 */
define_function char NAVRegexGetNamedGroupFromMatchCollection(_NAVRegexMatchCollection collection,
                                                               char name[],
                                                               _NAVRegexGroup group) {
    stack_var integer i

    // Search all matches in the collection
    for (i = 1; i <= collection.count; i++) {
        // Use FromMatch helper for each match
        if (NAVRegexGetNamedGroupFromMatch(collection.matches[i], name, group)) {
            return true
        }
    }

    // Not found in any match
    return false
}


/**
 * @function NAVRegexGetNamedGroupTextFromMatch
 * @public
 * @description Get just the text of a named capture group from a single match.
 *
 * Convenience wrapper around NAVRegexGetNamedGroupFromMatch for the common case
 * where you only need the captured text, not the position metadata.
 *
 * For numbered groups, access directly via match.groups[i].text.
 *
 * @param {_NAVRegexMatchResult} match - The match to search
 * @param {char[]} name - Name of the group to find
 * @param {char[]} text - Output: the captured text (empty if not found)
 *
 * @returns {char} TRUE if named group found, FALSE otherwise
 */
define_function char NAVRegexGetNamedGroupTextFromMatch(_NAVRegexMatchResult match,
                                                         char name[],
                                                         char text[]) {
    stack_var _NAVRegexGroup group

    if (NAVRegexGetNamedGroupFromMatch(match, name, group)) {
        text = group.text
        return true
    }

    text = ''
    return false
}


/**
 * @function NAVRegexGetNamedGroupTextFromMatchCollection
 * @public
 * @description Get just the text of a named capture group from a match collection.
 *
 * Convenience wrapper around NAVRegexGetNamedGroupFromMatchCollection for the common case
 * where you only need the captured text, not the position metadata.
 *
 * Searches all matches in the collection for the first occurrence of the
 * named group. For numbered groups, access directly via
 * collection.matches[i].groups[j].text.
 *
 * @param {_NAVRegexMatchCollection} collection - The match collection to search
 * @param {char[]} name - Name of the group to find
 * @param {char[]} text - Output: the captured text (empty if not found)
 *
 * @returns {char} TRUE if named group found, FALSE otherwise
 */
define_function char NAVRegexGetNamedGroupTextFromMatchCollection(_NAVRegexMatchCollection collection,
                                                                   char name[],
                                                                   char text[]) {
    stack_var _NAVRegexGroup group

    if (NAVRegexGetNamedGroupFromMatchCollection(collection, name, group)) {
        text = group.text
        return true
    }

    text = ''
    return false
}


/**
 * @function NAVRegexHasNamedGroupInMatch
 * @public
 * @description Check if a single match has a specific named group.
 *
 * Quick existence check without retrieving the group data.
 * Useful for conditional logic based on optional groups.
 *
 * @param {_NAVRegexMatchResult} match - The match to check
 * @param {char[]} name - Name of the group to check for
 *
 * @returns {char} TRUE if named group exists and was captured, FALSE otherwise
 */
define_function char NAVRegexHasNamedGroupInMatch(_NAVRegexMatchResult match,
                                                   char name[]) {
    stack_var _NAVRegexGroup group
    return NAVRegexGetNamedGroupFromMatch(match, name, group)
}


/**
 * @function NAVRegexHasNamedGroupInMatchCollection
 * @public
 * @description Check if any match in the collection has a specific named group.
 *
 * Quick existence check without retrieving the group data.
 * Useful for conditional logic based on optional groups.
 *
 * @param {_NAVRegexMatchCollection} collection - The match collection to check
 * @param {char[]} name - Name of the group to check for
 *
 * @returns {char} TRUE if named group exists and was captured, FALSE otherwise
 */
define_function char NAVRegexHasNamedGroupInMatchCollection(_NAVRegexMatchCollection collection,
                                                             char name[]) {
    stack_var _NAVRegexGroup group
    return NAVRegexGetNamedGroupFromMatchCollection(collection, name, group)
}


#END_IF // __NAV_FOUNDATION_REGEX_HELPERS__
