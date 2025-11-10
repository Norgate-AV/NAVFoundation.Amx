PROGRAM_NAME='NAVRegexRealWorldProtocols'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Real-world protocol patterns from various sources
constant char REGEX_REAL_WORLD_PROTOCOL_PATTERN[][255] = {
    '/^\x02(?<query>Q\w+):(?<data>.+)\x03$/'  // Panasonic Display Query Response Pattern
}

constant char REGEX_REAL_WORLD_PROTOCOL_INPUT[][][255] = {
    {
        // Panasonic Display Query Responses
        {$02, 'Q', 'P', 'W', ':', '1', $03},
        {$02, 'Q', 'P', 'W', ':', '0', $03},
        {$02, 'Q', 'M', 'I', ':', 'H', 'D', '1', $03},
        {$02, 'Q', 'M', 'I', ':', 'H', 'D', '2', $03},
        {$02, 'Q', 'A', 'V', ':', '5', '0', $03}
    }
}

constant char REGEX_REAL_WORLD_PROTOCOL_EXPECTED_MATCH[][][255] = {
    {
        {$02, 'Q', 'P', 'W', ':', '1', $03},
        {$02, 'Q', 'P', 'W', ':', '0', $03},
        {$02, 'Q', 'M', 'I', ':', 'H', 'D', '1', $03},
        {$02, 'Q', 'M', 'I', ':', 'H', 'D', '2', $03},
        {$02, 'Q', 'A', 'V', ':', '5', '0', $03}
    }
}

constant char REGEX_REAL_WORLD_PROTOCOL_SHOULD_MATCH[][] = {
    {
        true,
        true,
        true,
        true,
        true
    }
}

// Expected group count (excluding full match)
constant integer REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_COUNT[][] = {
    {
        2,
        2,
        2,
        2,
        2
    }
}

// Expected group values for each pattern and input
constant char REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUPS[][][2][255] = {
    {
        // Pattern 1 - Panasonic Display Query Response
        {
            // Input 1: QPW:1
            { 'QPW' },  // query group
            { '1' }     // data group
        },
        {
            // Input 2: QPW:0
            { 'QPW' },  // query group
            { '0' }     // data group
        },
        {
            // Input 3: QMI:HD1
            { 'QMI' },  // query group
            { 'HD1' }   // data group
        },
        {
            // Input 4: QMI:HD2
            { 'QMI' },  // query group
            { 'HD2' }   // data group
        },
        {
            // Input 5: QAV:50
            { 'QAV' },  // query group
            { '50' }    // data group
        }
    }
}

// Expected group names
constant char REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_NAMES[][2][255] = {
    {
        'query',
        'data'
    }
}

/**
 * @function TestNAVRegexRealWorldProtocols
 * @public
 * @description Tests real-world protocol patterns commonly used in AMX programming.
 */
define_function TestNAVRegexRealWorldProtocols() {
    stack_var integer x
    stack_var integer y
    stack_var integer patternTestPassed

    NAVLog("'***************** NAVRegex - Real-World Protocol Patterns *****************'")

    for (x = 1; x <= length_array(REGEX_REAL_WORLD_PROTOCOL_PATTERN); x++) {
        stack_var _NAVRegexNFA nfa

        patternTestPassed = true  // Assume pass until an input fails

        // Verify pattern compiles successfully
        if (!NAVAssertTrue('Pattern should compile successfully', NAVRegexCompile(REGEX_REAL_WORLD_PROTOCOL_PATTERN[x], nfa))) {
            NAVLog("'  Pattern ', itoa(x), ' failed to compile: ', REGEX_REAL_WORLD_PROTOCOL_PATTERN[x]")
            patternTestPassed = false
            continue  // Skip to next pattern if compilation fails
        }

        NAVLog("'Testing pattern ', itoa(x), ': ', REGEX_REAL_WORLD_PROTOCOL_PATTERN[x]")

        for (y = 1; y <= length_array(REGEX_REAL_WORLD_PROTOCOL_INPUT[x]); y++) {
            stack_var _NAVRegexMatchCollection collection

            NAVStopwatchStart()

            // Execute match using simple API
            if (REGEX_REAL_WORLD_PROTOCOL_SHOULD_MATCH[x][y]) {
                if (!NAVAssertTrue('Should match pattern', NAVRegexMatchCompiled(nfa, REGEX_REAL_WORLD_PROTOCOL_INPUT[x][y], collection))) {
                    NAVLog("'  Input ', itoa(y), ' failed: expected match, got no match'")
                    NAVLog("'  Pattern: ', REGEX_REAL_WORLD_PROTOCOL_PATTERN[x]")
                    NAVLog("'  Input:   ', REGEX_REAL_WORLD_PROTOCOL_INPUT[x][y]")
                    NAVStopwatchStop()
                    patternTestPassed = false
                    continue
                }
            }
            else {
                if (!NAVAssertFalse('Should NOT match pattern', NAVRegexMatchCompiled(nfa, REGEX_REAL_WORLD_PROTOCOL_INPUT[x][y], collection))) {
                    NAVLog("'  Input ', itoa(y), ' failed: expected no match, got match'")
                    NAVLog("'  Pattern: ', REGEX_REAL_WORLD_PROTOCOL_PATTERN[x]")
                    NAVLog("'  Input:   ', REGEX_REAL_WORLD_PROTOCOL_INPUT[x][y]")
                    NAVStopwatchStop()
                    patternTestPassed = false
                    continue
                }
                // This input doesn't match - just log timing and continue to next input
                NAVLog("'  Input ', itoa(y), ' (no match expected) completed in ', itoa(NAVStopwatchStop()), 'ms'")
                continue
            }

            // Verify match status
            if (!NAVAssertIntegerEqual('Match status should be SUCCESS', MATCH_STATUS_SUCCESS, collection.status)) {
                NAVLog("'  Input ', itoa(y), ' failed: match status = ', itoa(collection.status), ' (expected SUCCESS)'")
                NAVStopwatchStop()
                patternTestPassed = false
                continue
            }

            // Verify match count (should be 1)
            if (!NAVAssertIntegerEqual('Match count should be 1', 1, collection.count)) {
                NAVLog("'  Input ', itoa(y), ' failed: match count = ', itoa(collection.count), ' (expected 1)'")
                NAVStopwatchStop()
                patternTestPassed = false
                continue
            }

            // Verify hasMatch flag
            if (!NAVAssertTrue('Result should have match', collection.matches[1].hasMatch)) {
                NAVLog("'  Input ', itoa(y), ' failed: hasMatch = false (expected true)'")
                NAVStopwatchStop()
                patternTestPassed = false
                continue
            }

            // Verify matched text
            if (!NAVAssertStringEqual('Matched text should be correct', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_MATCH[x][y], collection.matches[1].fullMatch.text)) {
                NAVLog("'  Input ', itoa(y), ' failed: matched text incorrect'")
                NAVLog("'  Pattern:  ', REGEX_REAL_WORLD_PROTOCOL_PATTERN[x]")
                NAVStopwatchStop()
                patternTestPassed = false
                continue
            }

            // Verify fullMatch length
            if (!NAVAssertIntegerEqual('Full match length should be correct', length_array(REGEX_REAL_WORLD_PROTOCOL_EXPECTED_MATCH[x][y]), type_cast(collection.matches[1].fullMatch.length))) {
                NAVLog("'  Input ', itoa(y), ' failed: fullMatch.length = ', itoa(type_cast(collection.matches[1].fullMatch.length)), ' (expected ', itoa(length_array(REGEX_REAL_WORLD_PROTOCOL_EXPECTED_MATCH[x][y])), ')'")
                NAVStopwatchStop()
                patternTestPassed = false
                continue
            }

            // Verify group count
            if (!NAVAssertIntegerEqual('Group count should be correct', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_COUNT[x][y], collection.matches[1].groupCount)) {
                NAVLog("'  Input ', itoa(y), ' failed: group count = ', itoa(collection.matches[1].groupCount), ' (expected ', itoa(REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_COUNT[x][y]), ')'")
                NAVStopwatchStop()
                patternTestPassed = false
                continue
            }

            // Verify each capture group
            {
                stack_var integer g
                for (g = 1; g <= REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_COUNT[x][y]; g++) {
                    // Verify group name
                    if (!NAVAssertStringEqual('Group name should be correct', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_NAMES[x][g], collection.matches[1].groups[g].name)) {
                        NAVLog("'  Input ', itoa(y), ' failed: group[', itoa(g), '].name = ', collection.matches[1].groups[g].name, ' (expected ', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_NAMES[x][g], ')'")
                        NAVStopwatchStop()
                        patternTestPassed = false
                        break
                    }

                    // Verify group value
                    if (!NAVAssertStringEqual('Group value should be correct', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUPS[x][y][g], collection.matches[1].groups[g].text)) {
                        NAVLog("'  Input ', itoa(y), ' failed: group[', itoa(g), '].text = ', collection.matches[1].groups[g].text, ' (expected ', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUPS[x][y][g], ')'")
                        NAVStopwatchStop()
                        patternTestPassed = false
                        break
                    }

                    // Verify group length
                    if (!NAVAssertIntegerEqual('Group length should be correct', length_array(REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUPS[x][y][g]), type_cast(collection.matches[1].groups[g].length))) {
                        NAVLog("'  Input ', itoa(y), ' failed: group[', itoa(g), '].length = ', itoa(type_cast(collection.matches[1].groups[g].length)), ' (expected ', itoa(length_array(REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUPS[x][y][g])), ')'")
                        NAVStopwatchStop()
                        patternTestPassed = false
                        break
                    }
                }

                // If group verification failed, skip to next input
                if (g <= REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_COUNT[x]) {
                    continue
                }
            }

            // Verify named group retrieval using helper functions
            {
                stack_var integer g
                stack_var _NAVRegexGroup retrievedGroup
                stack_var char retrievedText[255]

                for (g = 1; g <= REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_COUNT[x]; g++) {
                    // Verify group exists using NAVRegexHasNamedGroupInMatch
                    if (!NAVAssertTrue('Named group should exist in match', NAVRegexHasNamedGroupInMatch(collection.matches[1], REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_NAMES[x][g]))) {
                        NAVLog("'  Input ', itoa(y), ' failed: NAVRegexHasNamedGroupInMatch(', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_NAMES[x][g], ') returned false'")
                        NAVStopwatchStop()
                        patternTestPassed = false
                        break
                    }

                    // Verify group exists using NAVRegexHasNamedGroupInMatchCollection
                    if (!NAVAssertTrue('Named group should exist in collection', NAVRegexHasNamedGroupInMatchCollection(collection, REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_NAMES[x][g]))) {
                        NAVLog("'  Input ', itoa(y), ' failed: NAVRegexHasNamedGroupInMatchCollection(', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_NAMES[x][g], ') returned false'")
                        NAVStopwatchStop()
                        patternTestPassed = false
                        break
                    }

                    // Verify NAVRegexGetNamedGroupFromMatch retrieves correct group
                    if (!NAVAssertTrue('Should retrieve group from match', NAVRegexGetNamedGroupFromMatch(collection.matches[1], REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_NAMES[x][g], retrievedGroup))) {
                        NAVLog("'  Input ', itoa(y), ' failed: NAVRegexGetNamedGroupFromMatch(', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_NAMES[x][g], ') returned false'")
                        NAVStopwatchStop()
                        patternTestPassed = false
                        break
                    }

                    if (!NAVAssertStringEqual('Retrieved group text should match', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUPS[x][y][g], retrievedGroup.text)) {
                        NAVLog("'  Input ', itoa(y), ' failed: NAVRegexGetNamedGroupFromMatch(', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_NAMES[x][g], ').text = ', retrievedGroup.text, ' (expected ', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUPS[x][y][g], ')'")
                        NAVStopwatchStop()
                        patternTestPassed = false
                        break
                    }

                    // Verify NAVRegexGetNamedGroupFromMatchCollection retrieves correct group
                    if (!NAVAssertTrue('Should retrieve group from collection', NAVRegexGetNamedGroupFromMatchCollection(collection, REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_NAMES[x][g], retrievedGroup))) {
                        NAVLog("'  Input ', itoa(y), ' failed: NAVRegexGetNamedGroupFromMatchCollection(', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_NAMES[x][g], ') returned false'")
                        NAVStopwatchStop()
                        patternTestPassed = false
                        break
                    }

                    if (!NAVAssertStringEqual('Retrieved group text should match', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUPS[x][y][g], retrievedGroup.text)) {
                        NAVLog("'  Input ', itoa(y), ' failed: NAVRegexGetNamedGroupFromMatchCollection(', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_NAMES[x][g], ').text = ', retrievedGroup.text, ' (expected ', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUPS[x][y][g], ')'")
                        NAVStopwatchStop()
                        patternTestPassed = false
                        break
                    }

                    // Verify NAVRegexGetNamedGroupTextFromMatch retrieves correct text
                    if (!NAVAssertTrue('Should retrieve group text from match', NAVRegexGetNamedGroupTextFromMatch(collection.matches[1], REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_NAMES[x][g], retrievedText))) {
                        NAVLog("'  Input ', itoa(y), ' failed: NAVRegexGetNamedGroupTextFromMatch(', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_NAMES[x][g], ') returned false'")
                        NAVStopwatchStop()
                        patternTestPassed = false
                        break
                    }

                    if (!NAVAssertStringEqual('Retrieved text should match', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUPS[x][y][g], retrievedText)) {
                        NAVLog("'  Input ', itoa(y), ' failed: NAVRegexGetNamedGroupTextFromMatch(', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_NAMES[x][g], ') = ', retrievedText, ' (expected ', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUPS[x][y][g], ')'")
                        NAVStopwatchStop()
                        patternTestPassed = false
                        break
                    }

                    // Verify NAVRegexGetNamedGroupTextFromMatchCollection retrieves correct text
                    if (!NAVAssertTrue('Should retrieve group text from collection', NAVRegexGetNamedGroupTextFromMatchCollection(collection, REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_NAMES[x][g], retrievedText))) {
                        NAVLog("'  Input ', itoa(y), ' failed: NAVRegexGetNamedGroupTextFromMatchCollection(', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_NAMES[x][g], ') returned false'")
                        NAVStopwatchStop()
                        patternTestPassed = false
                        break
                    }

                    if (!NAVAssertStringEqual('Retrieved text should match', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUPS[x][y][g], retrievedText)) {
                        NAVLog("'  Input ', itoa(y), ' failed: NAVRegexGetNamedGroupTextFromMatchCollection(', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_NAMES[x][g], ') = ', retrievedText, ' (expected ', REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUPS[x][y][g], ')'")
                        NAVStopwatchStop()
                        patternTestPassed = false
                        break
                    }
                }

                // If helper verification failed, skip to next input
                if (g <= REGEX_REAL_WORLD_PROTOCOL_EXPECTED_GROUP_COUNT[x]) {
                    continue
                }
            }

            NAVLog("'  Input ', itoa(y), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
        }

        // Report test result for this pattern based on all inputs
        if (patternTestPassed) {
            NAVLogTestPassed(x)
        }
    }
}

