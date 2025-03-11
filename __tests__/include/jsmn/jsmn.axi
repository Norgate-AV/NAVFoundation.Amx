#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Json.axi'

DEFINE_CONSTANT
// Test JSON inputs
constant char TEST_JSON_SIMPLE[] = '{"name":"John", "age":30, "car":null}';
constant char TEST_JSON_NESTED[] = '{"person":{"name":"John", "age":30, "address":{"city":"New York", "zip":"10001"}}}';
constant char TEST_JSON_ARRAY[] = '{"people":[{"name":"John", "age":30},{"name":"Jane", "age":25}]}';
constant char TEST_JSON_COMPLEX[] = '{
  "firstName": "John",
  "lastName": "Smith",
  "isAlive": true,
  "age": 27,
  "address": {
    "streetAddress": "21 2nd Street",
    "city": "New York",
    "state": "NY",
    "postalCode": "10021-3100"
  },
  "phoneNumbers": [
    {
      "type": "home",
      "number": "212 555-1234"
    },
    {
      "type": "office",
      "number": "646 555-4567"
    }
  ],
  "children": [],
  "spouse": null
}';

define_function RunJsmnTests() {
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running JSMN JSON Parser Tests ====='");

    // Simple JSON parsing
    TestJsonParsing(TEST_JSON_SIMPLE, 'Simple JSON');

    // Nested JSON parsing
    TestJsonParsing(TEST_JSON_NESTED, 'Nested JSON');

    // Array JSON parsing
    TestJsonParsing(TEST_JSON_ARRAY, 'Array JSON');

    // Complex JSON parsing
    TestJsonParsing(TEST_JSON_COMPLEX, 'Complex JSON');

    // Value extraction tests
    TestValueExtraction();

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'All JSMN tests completed'");
}

define_function TestJsonParsing(char jsonString[], char testName[]) {
    stack_var NAVJsonParser parser;
    stack_var integer result;
    stack_var integer i;

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing ', testName");

    // Initialize parser and parse JSON
    NAVJsonParserInit(parser, 64); // Allow for up to 64 tokens
    result = NAVJsonParse(parser, jsonString);

    if (result < 0) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Failed to parse JSON: Error code ', itoa(result)");
        return;
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Successfully parsed JSON'");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Tokens found: ', itoa(result)");

    // Log the first few tokens to verify parsing
    for (i = 1; i <= min_value(result, 5); i++) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Token ', itoa(i), ': type=', itoa(parser.tokens[i].type),
                    ', start=', itoa(parser.tokens[i].start),
                    ', end=', itoa(parser.tokens[i].end),
                    ', size=', itoa(parser.tokens[i].size)");
    }
}

define_function TestValueExtraction() {
    stack_var char result[256];
    stack_var integer intResult;
    stack_var double doubleResult;
    stack_var integer boolResult;

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing value extraction'");

    // Test string extraction
    result = NAVJsonGetString(TEST_JSON_SIMPLE, 'name');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  String value for key "name": ', result");
    if (result == 'John') {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  String extraction test passed'");
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  String extraction test failed'");
    }

    // Test integer extraction
    intResult = NAVJsonGetInteger(TEST_JSON_SIMPLE, 'age');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Integer value for key "age": ', itoa(intResult)");
    if (intResult == 30) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Integer extraction test passed'");
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Integer extraction test failed'");
    }

    // Test nested value extraction
    result = NAVJsonGetString(TEST_JSON_NESTED, 'person.name');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Nested string value for key "person.name": ', result");
    if (result == 'John') {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Nested string extraction test passed'");
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Nested string extraction test failed'");
    }

    // Test array extraction
    result = NAVJsonGetString(TEST_JSON_ARRAY, 'people[0].name');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Array string value for key "people[0].name": ', result");
    if (result == 'John') {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Array extraction test passed'");
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Array extraction test failed'");
    }

    // Test null value handling
    result = NAVJsonGetString(TEST_JSON_SIMPLE, 'car');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Null value test for key "car": ', result");

    // Test complex nested extraction
    result = NAVJsonGetString(TEST_JSON_COMPLEX, 'phoneNumbers[1].type');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Complex nested value for key "phoneNumbers[1].type": ', result");
    if (result == 'office') {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Complex nested extraction test passed'");
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Complex nested extraction test failed'");
    }
}
