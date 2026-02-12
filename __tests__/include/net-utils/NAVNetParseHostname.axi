PROGRAM_NAME='NAVNetParseHostname.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// All hostname test cases
constant char NAV_NET_PARSE_HOSTNAME_TESTS[][255] = {
    // Valid hostnames
    'example.com',              // 1: Simple two-label hostname
    'subdomain.example.com',    // 2: Three-label hostname
    'my-device.local',          // 3: Hostname with hyphen
    'localhost',                // 4: Single-label hostname
    'server1',                  // 5: Single-label with number
    'web-01.prod.example.com',  // 6: Multiple hyphens and labels
    'a.b.c.d.e.f.g',            // 7: Many labels
    'test123',                  // 8: Alphanumeric single label
    '123test',                  // 9: Starting with number
    'test123.example.com',      // 10: Label starting with number
    '123.456.789',              // 11: All numeric labels
    'a',                        // 12: Single character
    'a.b',                      // 13: Single character labels
    'test-hyphen-middle',       // 14: Multiple hyphens in label
    'a-b-c-d-e',                // 15: Many hyphens
    ' example.com',             // 16: Leading whitespace (trimmed)
    'example.com ',             // 17: Trailing whitespace (trimmed)
    '  example.com  ',          // 18: Both whitespace (trimmed)
    'TEST.EXAMPLE.COM',         // 19: Uppercase (valid)
    'Test.Example.Com',         // 20: Mixed case (valid)

    // Invalid hostnames
    '',                         // 21: Empty string
    '-example.com',             // 22: Leading hyphen
    'example-.com',             // 23: Label ending with hyphen
    '.example.com',             // 24: Leading dot
    'example.com.',             // 25: Trailing dot
    'ex ample.com',             // 26: Space in hostname
    'example..com',             // 27: Consecutive dots
    '....',                     // 28: Only dots
    '----',                     // 29: Only hyphens
    'example.com-',             // 30: Trailing hyphen
    '-localhost',               // 31: Single label with leading hyphen
    'localhost-',               // 32: Single label with trailing hyphen
    'host name.com',            // 33: Space in label
    'host@name.com',            // 34: Invalid character (@)
    'host#name.com',            // 35: Invalid character (#)
    'host$name.com',            // 36: Invalid character ($)
    'host%name.com',            // 37: Invalid character (%)
    'host&name.com',            // 38: Invalid character (&)
    'host*name.com',            // 39: Invalid character (*)
    'host+name.com',            // 40: Invalid character (+)
    'host=name.com',            // 41: Invalid character (=)
    'host/name.com',            // 42: Invalid character (/)
    'host\name.com',            // 43: Invalid character (\)
    'host|name.com',            // 44: Invalid character (|)
    'host:name.com',            // 45: Invalid character (:) - IPv6-like
    'host;name.com',            // 46: Invalid character (;)
    'host,name.com',            // 47: Invalid character (,)
    'host?.com',                // 48: Invalid character (?)
    'host!.com',                // 49: Invalid character (!)
    '   ',                      // 50: Whitespace only
    {' ', ' ', $09, ' ', ' '},  // 51: Tabs and spaces
    '.host.com',                // 52: Leading dot (duplicate test for clarity)
    'host.com.',                // 53: Trailing dot (duplicate test for clarity)
    'host..name.com',           // 54: Double dot in middle
    'a..b..c',                  // 55: Multiple double dots
    'host.-name.com',           // 56: Label starting with hyphen after dot
    'host.name-.com',           // 57: Label ending with hyphen before dot
    '..',                       // 58: Two dots only
    '...',                      // 59: Three dots only
    {'h', 'o', 's', 't', $0A, '.', 'c', 'o', 'm'},  // 60: Newline in hostname
    {'h', 'o', 's', 't', $09, '.', 'c', 'o', 'm'},  // 61: Tab in hostname
    {'h', 'o', 's', 't', $0D, '.', 'c', 'o', 'm'},  // 62: Carriage return
    'a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.u.v.w.x.y.z.a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.u.v.w.x.y.z.a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.u.v.w.x.y.z.a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.u.v.w.x.y.z.a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.toolong', // 63: Exceeds 253 characters (254 chars)
    'this-is-a-very-long-label-that-exceeds-sixty-three-characters-maximum.com', // 64: Label exceeds 63 characters
    '-',                        // 65: Single hyphen
    '.',                        // 66: Single dot
    'host._name.com',           // 67: Underscore (not allowed in hostnames per RFC)
    'host.name_.com',           // 68: Trailing underscore in label
    '_hostname.com',            // 69: Leading underscore
    'hostname_.com'             // 70: Trailing underscore before dot
}

// Expected results: true = should parse successfully, false = should fail
constant char NAV_NET_PARSE_HOSTNAME_EXPECTED_RESULT[] = {
    // Valid (1-20)
    true, true, true, true, true, true, true, true, true, true,
    true, true, true, true, true, true, true, true, true, true,
    // Invalid (21-70)
    false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false
}

// Expected label counts for valid tests (only first 20)
constant integer NAV_NET_PARSE_HOSTNAME_EXPECTED_LABEL_COUNTS[] = {
    2,  // 1: example.com
    3,  // 2: subdomain.example.com
    2,  // 3: my-device.local
    1,  // 4: localhost
    1,  // 5: server1
    4,  // 6: web-01.prod.example.com
    7,  // 7: a.b.c.d.e.f.g
    1,  // 8: test123
    1,  // 9: 123test
    3,  // 10: test123.example.com
    3,  // 11: 123.456.789
    1,  // 12: a
    2,  // 13: a.b
    1,  // 14: test-hyphen-middle
    1,  // 15: a-b-c-d-e
    2,  // 16: ' example.com' (trimmed)
    2,  // 17: 'example.com ' (trimmed)
    2,  // 18: '  example.com  ' (trimmed)
    3,  // 19: TEST.EXAMPLE.COM
    3   // 20: Test.Example.Com
}

// Expected first labels for valid tests (to verify parsing)
constant char NAV_NET_PARSE_HOSTNAME_EXPECTED_FIRST_LABELS[][64] = {
    'example',          // 1
    'subdomain',        // 2
    'my-device',        // 3
    'localhost',        // 4
    'server1',          // 5
    'web-01',           // 6
    'a',                // 7
    'test123',          // 8
    '123test',          // 9
    'test123',          // 10
    '123',              // 11
    'a',                // 12
    'a',                // 13
    'test-hyphen-middle', // 14
    'a-b-c-d-e',        // 15
    'example',          // 16 (trimmed)
    'example',          // 17 (trimmed)
    'example',          // 18 (trimmed)
    'TEST',             // 19
    'Test'              // 20
}

// Expected normalized strings for valid tests (expected Hostname field)
constant char NAV_NET_PARSE_HOSTNAME_EXPECTED_STRINGS[][255] = {
    'example.com',
    'subdomain.example.com',
    'my-device.local',
    'localhost',
    'server1',
    'web-01.prod.example.com',
    'a.b.c.d.e.f.g',
    'test123',
    '123test',
    'test123.example.com',
    '123.456.789',
    'a',
    'a.b',
    'test-hyphen-middle',
    'a-b-c-d-e',
    'example.com',      // whitespace trimmed
    'example.com',      // whitespace trimmed
    'example.com',      // whitespace trimmed
    'TEST.EXAMPLE.COM',
    'Test.Example.Com'
}


define_function TestNAVNetParseHostname() {
    stack_var integer x
    stack_var integer validCount

    NAVLogTestSuiteStart('NAVNetParseHostname')

    validCount = 0

    for (x = 1; x <= length_array(NAV_NET_PARSE_HOSTNAME_TESTS); x++) {
        stack_var char result
        stack_var _NAVHostname hostname
        stack_var char shouldPass

        shouldPass = NAV_NET_PARSE_HOSTNAME_EXPECTED_RESULT[x]
        result = NAVNetParseHostname(NAV_NET_PARSE_HOSTNAME_TESTS[x], hostname)

        // Check if result matches expectation
        if (!NAVAssertBooleanEqual('Should parse with the expected result', shouldPass, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(shouldPass), NAVBooleanToString(result))
            continue
        }

        if (!shouldPass) {
            // If should fail, no further checks needed
            NAVLogTestPassed(x)
            continue
        }

        // If should pass, validate label count, first label, and string
        {
            stack_var char failed

            validCount++
            failed = false

            // Check label count
            if (!NAVAssertIntegerEqual('Should have the correct label count', NAV_NET_PARSE_HOSTNAME_EXPECTED_LABEL_COUNTS[validCount], hostname.LabelCount)) {
                NAVLogTestFailed(x, itoa(NAV_NET_PARSE_HOSTNAME_EXPECTED_LABEL_COUNTS[validCount]), itoa(hostname.LabelCount))
                failed = true
            }

            if (failed) {
                continue
            }

            // Check first label
            if (!NAVAssertStringEqual('Should have the correct first label', NAV_NET_PARSE_HOSTNAME_EXPECTED_FIRST_LABELS[validCount], hostname.Labels[1])) {
                NAVLogTestFailed(x, NAV_NET_PARSE_HOSTNAME_EXPECTED_FIRST_LABELS[validCount], hostname.Labels[1])
                failed = true
            }

            if (failed) {
                continue
            }

            // Check normalized string
            if (!NAVAssertStringEqual('Should result in the correct normalized hostname', NAV_NET_PARSE_HOSTNAME_EXPECTED_STRINGS[validCount], hostname.Hostname)) {
                NAVLogTestFailed(x, NAV_NET_PARSE_HOSTNAME_EXPECTED_STRINGS[validCount], hostname.Hostname)
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVNetParseHostname')
}
