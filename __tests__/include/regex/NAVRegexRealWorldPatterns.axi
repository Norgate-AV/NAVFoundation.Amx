PROGRAM_NAME='NAVRegexRealWorldPatterns'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Real-world regex patterns of varying complexity
constant char REGEX_REAL_WORLD_PATTERN[][255] = {
    // Email validation
    '/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/',           // 1: Email (strict)
    '/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/i',          // 2: Email (case-insensitive)

    // Hostnames & Domains
    '/^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$/',              // 3: Hostname (single label)
    '/^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$/',  // 4: FQDN (domain name)
    '/^(www\.)?[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(\.[a-zA-Z]{2,})?$/',    // 5: Domain with optional www

    // Phone numbers
    '/^\d{3}-\d{3}-\d{4}$/',                                        // 6: Phone US format (dashes)
    '/^\(\d{3}\)\s*\d{3}-\d{4}$/',                                  // 7: Phone US format (parens)

    // IP addresses
    '/^(\d{1,3}\.){3}\d{1,3}$/',                                    // 8: IPv4 address (basic)
    '/^((25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)\.){3}(25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)$/',  // 9: IPv4 (strict)
    '/^[0-9a-fA-F:]+$/',                                            // 10: IPv6 (simplified)

    // URLs
    '/^https?:\/\/[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(\/[^\s]*)?$/',      // 11: URL (HTTP/HTTPS)
    '/^https?:\/\/[a-zA-Z0-9.-]+(:\d{1,5})?(\/[^\s]*)?$/',         // 12: URL with optional port
    '/^(ftp|http|https):\/\/[^\s]+$/',                              // 13: URL (FTP/HTTP/HTTPS)

    // Port numbers
    '/^\d{1,5}$/',                                                  // 14: Port number (basic)
    '/^(6553[0-5]|655[0-2]\d|65[0-4]\d{2}|6[0-4]\d{3}|[1-5]\d{4}|[1-9]\d{0,3}|0)$/',  // 15: Port (0-65535)

    // Dates
    '/^\d{4}-\d{2}-\d{2}$/',                                        // 16: Date ISO (YYYY-MM-DD)
    '/^\d{1,2}\/\d{1,2}\/\d{2,4}$/',                                // 17: Date US format (M/D/Y)

    // Time
    '/^([01]\d|2[0-3]):[0-5]\d(:[0-5]\d)?$/',                       // 18: Time 24h (HH:MM or HH:MM:SS)
    '/^(0?[1-9]|1[0-2]):[0-5]\d\s*(AM|PM)$/i',                      // 19: Time 12h with AM/PM

    // Color codes
    '/^#[0-9a-fA-F]{6}$/',                                          // 20: Hex color
    '/^rgb\(\s*\d{1,3}\s*,\s*\d{1,3}\s*,\s*\d{1,3}\s*\)$/',        // 21: RGB color

    // UUID
    '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i',  // 22: UUID

    // MAC address
    '/^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$/',                   // 23: MAC address (colon/dash)
    '/^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$/',                      // 24: MAC address (colon only)
    '/^[0-9A-Fa-f]{12}$/',                                          // 25: MAC address (no separators)

    // Credit card (basic)
    '/^\d{4}(-\d{4}){3}$/',                                         // 26: Credit card with dashes

    // Username validation
    '/^[a-zA-Z0-9_-]{3,16}$/',                                      // 27: Username (3-16 chars)

    // Password strength (complex)
    '/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/',                      // 28: Password (lowercase, uppercase, digit, 8+ chars)

    // HTML tags
    '/<([a-z]+)[^>]*>(.*?)<\/\1>/i',                                // 29: HTML tag with content (backreference)

    // Quoted strings
    '/"(?:[^"\\]|\\.)*"/',                                          // 30: Double-quoted string with escapes

    // AMX device-port-system
    '/^\d{1,5}:\d{1,5}:\d{1,5}$/',                                  // 31: AMX D:P:S format

    // Netlinx IP format
    '/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d{1,5}:\d{1,5}$/',      // 32: NetLinx IP:Port:System

    // Host:Port combinations
    '/^[a-zA-Z0-9.-]+:\d{1,5}$/',                                   // 33: Hostname:Port
    '/^(\d{1,3}\.){3}\d{1,3}:\d{1,5}$/',                            // 34: IP:Port

    // CSV field
    '/"(?:[^"]|"")*"|[^,]+/',                                       // 35: CSV field (quoted or unquoted)

    // Version number
    '/^v?\d+\.\d+(\.\d+)?(-[a-zA-Z0-9]+)?$/',                       // 36: Semantic version

    // File path (Windows-style)
    '/^[a-zA-Z]:\\(?:[^\\/:*?"<>|\r\n]+\\)*[^\\/:*?"<>|\r\n]*$/',  // 37: Windows path

    // Repeated words (backreference)
    '/\b(\w+)\s+\1\b/',                                             // 38: Duplicate word detection

    // Balanced parentheses (simple)
    '/\((?:[^()]|\([^()]*\))*\)/',                                  // 39: Nested parens (one level)

    // AMX feedback format
    '/^FEEDBACK-\[([^\]]+)\]:(.+)$/',                               // 40: Custom feedback format

    // Temperature with units
    '/^-?\d+(\.\d+)?\s*[CF]$/',                                     // 41: Temperature (C or F)

    // Percentage
    '/^\d{1,3}(\.\d+)?%$/',                                         // 42: Percentage (0-100%)

    // AMX level event
    '/^LEVEL-\d+,(\d+)$/',                                          // 43: Level event format

    // Complex log pattern
    '/^\[(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2}:\d{2})\]\s+(\w+):\s+(.+)$/'  // 44: Log entry
}

constant char REGEX_REAL_WORLD_INPUT[][255] = {
    'user@example.com',                                             // 1: Email
    'User@Example.COM',                                             // 2: Email case-insensitive
    'server01',                                                     // 3: Hostname
    'mail.example.com',                                             // 4: FQDN
    'www.example.com',                                              // 5: Domain with www
    '555-123-4567',                                                 // 6: Phone (dashes)
    '(555) 123-4567',                                               // 7: Phone (parens)
    '192.168.1.1',                                                  // 8: IPv4 basic
    '192.168.0.1',                                                  // 9: IPv4 strict
    '2001:0db8:85a3::8a2e:0370:7334',                               // 10: IPv6
    'https://www.example.com/path',                                 // 11: URL
    'http://localhost:8080/api',                                    // 12: URL with port
    'ftp://files.example.com/download',                             // 13: FTP URL
    '8080',                                                         // 14: Port basic
    '443',                                                          // 15: Port strict
    '2025-11-01',                                                   // 16: Date ISO
    '11/01/2025',                                                   // 17: Date US
    '14:30:00',                                                     // 18: Time 24h
    '2:30 PM',                                                      // 19: Time 12h
    '#FF5733',                                                      // 20: Hex color
    'rgb(255, 87, 51)',                                             // 21: RGB color
    '550e8400-e29b-41d4-a716-446655440000',                         // 22: UUID
    '00:1A:2B:3C:4D:5E',                                            // 23: MAC (colon)
    '00:1A:2B:3C:4D:5E',                                            // 24: MAC (colon only)
    '001A2B3C4D5E',                                                 // 25: MAC (no separator)
    '1234-5678-9012-3456',                                          // 26: Credit card
    'user_name123',                                                 // 27: Username
    'Pass1234',                                                     // 28: Password
    '<div>Hello World</div>',                                       // 29: HTML tag
    '"Hello \"World\""',                                            // 30: Quoted string
    '10001:1:1',                                                    // 31: AMX D:P:S
    '192.168.1.100:1319:1',                                         // 32: NetLinx IP:Port:System
    'example.com:8080',                                             // 33: Hostname:Port
    '192.168.1.1:80',                                               // 34: IP:Port
    '"field,with,comma"',                                           // 35: CSV field
    'v1.2.3-beta',                                                  // 36: Version
    'C:\Users\Test\file.txt',                                       // 37: Windows path
    'the the cat',                                                  // 38: Duplicate words
    '(outer (inner) text)',                                         // 39: Balanced parens
    'FEEDBACK-[Zone1]:Volume=50',                                   // 40: AMX feedback
    '72.5 F',                                                       // 41: Temperature
    '85.5%',                                                        // 42: Percentage
    'LEVEL-1,255',                                                  // 43: AMX level
    '[2025-11-01 14:30:45] INFO: System started'                    // 44: Log entry
}

constant char REGEX_REAL_WORLD_EXPECTED_MATCH[][255] = {
    'user@example.com',                                             // 1
    'User@Example.COM',                                             // 2
    'server01',                                                     // 3
    'mail.example.com',                                             // 4
    'www.example.com',                                              // 5
    '555-123-4567',                                                 // 6
    '(555) 123-4567',                                               // 7
    '192.168.1.1',                                                  // 8
    '192.168.0.1',                                                  // 9
    '2001:0db8:85a3::8a2e:0370:7334',                               // 10
    'https://www.example.com/path',                                 // 11
    'http://localhost:8080/api',                                    // 12
    'ftp://files.example.com/download',                             // 13
    '8080',                                                         // 14
    '443',                                                          // 15
    '2025-11-01',                                                   // 16
    '11/01/2025',                                                   // 17
    '14:30:00',                                                     // 18
    '2:30 PM',                                                      // 19
    '#FF5733',                                                      // 20
    'rgb(255, 87, 51)',                                             // 21
    '550e8400-e29b-41d4-a716-446655440000',                         // 22
    '00:1A:2B:3C:4D:5E',                                            // 23
    '00:1A:2B:3C:4D:5E',                                            // 24
    '001A2B3C4D5E',                                                 // 25
    '1234-5678-9012-3456',                                          // 26
    'user_name123',                                                 // 27
    'Pass1234',                                                     // 28
    '<div>Hello World</div>',                                       // 29
    '"Hello \"World\""',                                            // 30
    '10001:1:1',                                                    // 31
    '192.168.1.100:1319:1',                                         // 32
    'example.com:8080',                                             // 33
    '192.168.1.1:80',                                               // 34
    '"field,with,comma"',                                           // 35
    'v1.2.3-beta',                                                  // 36
    'C:\Users\Test\file.txt',                                       // 37
    'the the',                                                      // 38
    '(outer (inner) text)',                                         // 39
    'FEEDBACK-[Zone1]:Volume=50',                                   // 40
    '72.5 F',                                                       // 41
    '85.5%',                                                        // 42
    'LEVEL-1,255',                                                  // 43
    '[2025-11-01 14:30:45] INFO: System started'                    // 44
}

constant integer REGEX_REAL_WORLD_EXPECTED_START[] = {
    1,  // 1
    1,  // 2
    1,  // 3
    1,  // 4
    1,  // 5
    1,  // 6
    1,  // 7
    1,  // 8
    1,  // 9
    1,  // 10
    1,  // 11
    1,  // 12
    1,  // 13
    1,  // 14
    1,  // 15
    1,  // 16
    1,  // 17
    1,  // 18
    1,  // 19
    1,  // 20
    1,  // 21
    1,  // 22
    1,  // 23
    1,  // 24
    1,  // 25
    1,  // 26
    1,  // 27
    1,  // 28
    1,  // 29
    1,  // 30
    1,  // 31
    1,  // 32
    1,  // 33
    1,  // 34
    1,  // 35
    1,  // 36
    1,  // 37
    1,  // 38
    1,  // 39
    1,  // 40
    1,  // 41
    1,  // 42
    1,  // 43
    1   // 44
}

constant char REGEX_REAL_WORLD_SHOULD_MATCH[] = {
    true,   // 1
    true,   // 2
    true,   // 3
    true,   // 4
    true,   // 5
    true,   // 6
    true,   // 7
    true,   // 8
    true,   // 9
    true,   // 10
    true,   // 11
    true,   // 12
    true,   // 13
    true,   // 14
    true,   // 15
    true,   // 16
    true,   // 17
    true,   // 18
    true,   // 19
    true,   // 20
    true,   // 21
    true,   // 22
    true,   // 23
    true,   // 24
    true,   // 25
    true,   // 26
    true,   // 27
    true,   // 28
    true,   // 29
    true,   // 30
    true,   // 31
    true,   // 32
    true,   // 33
    true,   // 34
    true,   // 35
    true,   // 36
    true,   // 37
    true,   // 38
    true,   // 39
    true,   // 40
    true,   // 41
    true,   // 42
    true,   // 43
    true    // 44
}

/**
 * @function TestNAVRegexRealWorldPatterns
 * @public
 * @description Tests real-world regex patterns commonly used.
 *
 * Validates:
 * - Email validation patterns
 * - Phone number formats (US)
 * - IP addresses
 * - URLs (HTTP/HTTPS)
 * - Date formats (ISO, US)
 * - Time formats (12h/24h)
 * - Color codes (hex, RGB)
 * - UUIDs
 * - MAC addresses
 * - Credit card numbers
 * - Username/password validation
 * - HTML tags with backreferences
 * - Quoted strings with escapes
 * - AMX-specific formats (D:P:S, IP:Port:System, feedback, levels)
 * - CSV fields
 * - Version numbers
 * - File paths
 * - Duplicate word detection
 * - Balanced parentheses
 * - Temperature values
 * - Percentages
 * - Log entry parsing
 */
define_function TestNAVRegexRealWorldPatterns() {
    stack_var integer x

    NAVLog("'***************** NAVRegex - Real-World Patterns *****************'")

    for (x = 1; x <= length_array(REGEX_REAL_WORLD_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection

        NAVStopwatchStart()

        // Execute match using simple API
        if (REGEX_REAL_WORLD_SHOULD_MATCH[x]) {
            if (!NAVAssertTrue('Should match pattern', NAVRegexMatch(REGEX_REAL_WORLD_PATTERN[x], REGEX_REAL_WORLD_INPUT[x], collection))) {
                NAVLogTestFailed(x, 'match success', 'match failed')
                NAVLog("'  Pattern: ', REGEX_REAL_WORLD_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_REAL_WORLD_INPUT[x]")
                NAVStopwatchStop()
                continue
            }
        }
        else {
            if (!NAVAssertFalse('Should NOT match pattern', NAVRegexMatch(REGEX_REAL_WORLD_PATTERN[x], REGEX_REAL_WORLD_INPUT[x], collection))) {
                NAVLogTestFailed(x, 'no match', 'matched')
                NAVLog("'  Pattern: ', REGEX_REAL_WORLD_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_REAL_WORLD_INPUT[x]")
                NAVStopwatchStop()
                continue
            }
            NAVLogTestPassed(x)
            NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
            continue
        }

        // Verify match status
        if (!NAVAssertIntegerEqual('Match status should be SUCCESS', MATCH_STATUS_SUCCESS, collection.status)) {
            NAVLogTestFailed(x, 'SUCCESS', itoa(collection.status))
            NAVStopwatchStop()
            continue
        }

        // Verify match count (should be 1)
        if (!NAVAssertIntegerEqual('Match count should be 1', 1, collection.count)) {
            NAVLogTestFailed(x, '1', itoa(collection.count))
            NAVStopwatchStop()
            continue
        }

        // Verify hasMatch flag
        if (!NAVAssertTrue('Result should have match', collection.matches[1].hasMatch)) {
            NAVLogTestFailed(x, 'hasMatch=true', 'hasMatch=false')
            NAVStopwatchStop()
            continue
        }

        // Verify matched text
        if (!NAVAssertStringEqual('Matched text should be correct', REGEX_REAL_WORLD_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
            NAVLogTestFailed(x, REGEX_REAL_WORLD_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
            NAVLog("'  Pattern: ', REGEX_REAL_WORLD_PATTERN[x]")
            NAVLog("'  Input:   ', REGEX_REAL_WORLD_INPUT[x]")
            NAVStopwatchStop()
            continue
        }

        // Verify match start position
        if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_REAL_WORLD_EXPECTED_START[x], type_cast(collection.matches[1].fullMatch.start))) {
            NAVLogTestFailed(x, itoa(REGEX_REAL_WORLD_EXPECTED_START[x]), itoa(type_cast(collection.matches[1].fullMatch.start)))
            NAVStopwatchStop()
            continue
        }

        // Verify match length
        if (!NAVAssertIntegerEqual('Match length should be correct', length_array(REGEX_REAL_WORLD_EXPECTED_MATCH[x]), type_cast(collection.matches[1].fullMatch.length))) {
            NAVLogTestFailed(x, itoa(length_array(REGEX_REAL_WORLD_EXPECTED_MATCH[x])), itoa(type_cast(collection.matches[1].fullMatch.length)))
            NAVStopwatchStop()
            continue
        }

        NAVLogTestPassed(x)

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}

