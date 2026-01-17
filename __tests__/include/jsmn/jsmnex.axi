#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Jsmn.axi'

DEFINE_VARIABLE

volatile char JSMNEX_TEST[32][2048]
volatile char JSMNEX_TEST_ENABLED[32]

DEFINE_CONSTANT

// Test counts represent expected token count
constant sinteger JSMNEX_EXPECTED_COUNT[] = {
    17,     // Test 1: Complex object with various types (including "metadata" key and empty object)
    1,      // Test 2: Empty object
    1,      // Test 3: Empty array
    2,      // Test 4: Simple array with one element
    3,      // Test 5: Object with string value
    3,      // Test 6: Object with number value
    3,      // Test 7: Object with boolean true
    3,      // Test 8: Object with boolean false
    3,      // Test 9: Object with null value
    4,      // Test 10: Array with multiple primitives
    5       // Test 11: Nested object (root, "outer" key, inner object, "inner" key, "value")
}

// Expected extracted values for each token in each test
constant char JSMNEX_EXPECTED_VALUE[32][32][2048] = {
    // Test 1: Complex object - all token values (17 tokens)
    {
        '{"name":"John","age":30,"city":"New York","active":true,"balance":123.45,"tags":["dev","admin"],"metadata":{}}',
        'name', 'John', 'age', '30', 'city', 'New York', 'active', 'true',
        'balance', '123.45', 'tags', '["dev","admin"]', 'dev', 'admin', 'metadata', '{}'
    },
    // Test 2: Empty object
    {'{}'},
    // Test 3: Empty array
    {'[]'},
    // Test 4: Simple array
    {'[42]', '42'},
    // Test 5: Object with string
    {'{"key":"value"}', 'key', 'value'},
    // Test 6: Object with number
    {'{"count":100}', 'count', '100'},
    // Test 7: Object with boolean true
    {'{"enabled":true}', 'enabled', 'true'},
    // Test 8: Object with boolean false
    {'{"disabled":false}', 'disabled', 'false'},
    // Test 9: Object with null
    {'{"data":null}', 'data', 'null'},
    // Test 10: Array with primitives
    {'[1,2,3]', '1', '2', '3'},
    // Test 11: Nested object (5 tokens)
    {'{"outer":{"inner":"value"}}', 'outer', '{"inner":"value"}', 'inner', 'value'}
}


DEFINE_FUNCTION InitializeJsmnExTestData() {
    // Test 1: Complex object with various types
    JSMNEX_TEST_ENABLED[1] = true
    JSMNEX_TEST[1] = '{"name":"John","age":30,"city":"New York","active":true,"balance":123.45,"tags":["dev","admin"],"metadata":{}}'

    // Test 2: Empty object
    JSMNEX_TEST_ENABLED[2] = true
    JSMNEX_TEST[2] = '{}'

    // Test 3: Empty array
    JSMNEX_TEST_ENABLED[3] = true
    JSMNEX_TEST[3] = '[]'

    // Test 4: Simple array
    JSMNEX_TEST_ENABLED[4] = true
    JSMNEX_TEST[4] = '[42]'

    // Test 5: Object with string
    JSMNEX_TEST_ENABLED[5] = true
    JSMNEX_TEST[5] = '{"key":"value"}'

    // Test 6: Object with number
    JSMNEX_TEST_ENABLED[6] = true
    JSMNEX_TEST[6] = '{"count":100}'

    // Test 7: Object with boolean true
    JSMNEX_TEST_ENABLED[7] = true
    JSMNEX_TEST[7] = '{"enabled":true}'

    // Test 8: Object with boolean false
    JSMNEX_TEST_ENABLED[8] = true
    JSMNEX_TEST[8] = '{"disabled":false}'

    // Test 9: Object with null
    JSMNEX_TEST_ENABLED[9] = true
    JSMNEX_TEST[9] = '{"data":null}'

    // Test 10: Array with primitives
    JSMNEX_TEST_ENABLED[10] = true
    JSMNEX_TEST[10] = '[1,2,3]'

    // Test 11: Nested object
    JSMNEX_TEST_ENABLED[11] = true
    JSMNEX_TEST[11] = '{"outer":{"inner":"value"}}'
}


DEFINE_FUNCTION RunJsmnExTests() {
    stack_var integer x

    NAVLogTestSuiteStart('JSMN Extended')

    InitializeJsmnExTestData()

    for (x = 1; x <= max_length_array(JSMNEX_TEST); x++) {
        stack_var JsmnParser parser
        stack_var JsmnToken tokens[NAV_MAX_JSMN_TOKENS]
        stack_var sinteger result
        stack_var integer count
        stack_var char failed

        if (!JSMNEX_TEST_ENABLED[x]) {
            continue
        }

        jsmn_init(parser)
        result = jsmn_parse(parser, JSMNEX_TEST[x], length_array(JSMNEX_TEST[x]), tokens, max_length_array(tokens))

        // Verify token count
        if (!NAVAssertSignedIntegerEqual('Should match expected count result', JSMNEX_EXPECTED_COUNT[x], result)) {
            NAVLogTestFailed(x, itoa(JSMNEX_EXPECTED_COUNT[x]), itoa(result))
            continue
        }

        if (JSMNEX_EXPECTED_COUNT[x] <= 0) {
            NAVLogTestPassed(x)
            continue
        }

        count = type_cast(result)

        {
            stack_var integer z

            for (z = 1; z <= count; z++) {
                stack_var char extracted_value[2048]

                // Extract value using jsmnex_get_token_value
                extracted_value = jsmnex_get_token_value(JSMNEX_TEST[x], tokens[z])

                // Validate extracted value matches expected
                if (!NAVAssertStringEqual("'Token ', itoa(z), ' extracted value'", JSMNEX_EXPECTED_VALUE[x][z], extracted_value)) {
                    NAVLogTestFailed(x, JSMNEX_EXPECTED_VALUE[x][z], extracted_value)
                    failed = true
                    break
                }
            }

            if (failed) {
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('JSMN Extended')
}
