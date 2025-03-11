#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.StringUtils.axi'

define_function RunStringUtilsTests() {
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running String Utilities Tests ====='");

    // Test string manipulation functions
    TestStringFormat();
    TestStringSplit();
    TestStringReplace();
    TestStringTrim();
    TestStringCase();
    TestStringPadding();
    TestStringStartsEndsWith();

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'All String Utils tests completed'");
}

define_function TestStringFormat() {
    stack_var char result[256];

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing string formatting'");

    // Simple formatting
    result = NAVStringFormat("Hello %s!", "World");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Format 'Hello %s!' with 'World': '", result, "'");

    // Multiple placeholders
    result = NAVStringFormat("%s has %d apples", "John", 5);
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Format '%s has %d apples' with 'John', 5: '", result, "'");

    // Number formatting
    result = NAVStringFormat("Value: %.2f", 3.14159);
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Format 'Value: %.2f' with 3.14159: '", result, "'");
}

define_function TestStringSplit() {
    stack_var char parts[10][64];
    stack_var integer count;
    stack_var integer i;

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing string splitting'");

    // Split by comma
    count = NAVStringSplit("apple,banana,cherry", ",", parts);
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Split 'apple,banana,cherry' by ',': ", itoa(count), " parts'");

    for (i = 1; i <= count; i++) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'    Part ", itoa(i), ": '", parts[i], "'");
    }

    // Split by space
    count = NAVStringSplit("The quick brown fox", " ", parts);
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Split 'The quick brown fox' by ' ': ", itoa(count), " parts'");

    for (i = 1; i <= count; i++) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'    Part ", itoa(i), ": '", parts[i], "'");
    }
}

define_function TestStringReplace() {
    stack_var char result[256];

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing string replacement'");

    // Simple replacement
    result = NAVStringReplace("Hello World", "World", "Universe");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Replace 'World' with 'Universe' in 'Hello World': '", result, "'");

    // Multiple replacements
    result = NAVStringReplace("one two one two", "one", "first");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Replace 'one' with 'first' in 'one two one two': '", result, "'");

    // No match
    result = NAVStringReplace("Hello World", "xyz", "abc");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Replace 'xyz' with 'abc' in 'Hello World': '", result, "'");
}

define_function TestStringTrim() {
    stack_var char result[256];

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing string trimming'");

    // Trim spaces
    result = NAVStringTrim("  Hello World  ");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Trim '  Hello World  ': '", result, "'");

    // Trim left
    result = NAVStringTrimLeft("  Hello World  ");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  TrimLeft '  Hello World  ': '", result, "'");

    // Trim right
    result = NAVStringTrimRight("  Hello World  ");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  TrimRight '  Hello World  ': '", result, "'");
}

define_function TestStringCase() {
    stack_var char result[256];

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing string case conversion'");

    // To upper
    result = NAVStringToUpper("Hello World");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  ToUpper 'Hello World': '", result, "'");

    // To lower
    result = NAVStringToLower("Hello World");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  ToLower 'Hello World': '", result, "'");

    // Capitalize
    result = NAVStringCapitalize("hello world");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Capitalize 'hello world': '", result, "'");
}

define_function TestStringPadding() {
    stack_var char result[256];

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing string padding'");

    // Pad left
    result = NAVStringPadLeft("123", 5, '0');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  PadLeft '123' to length 5 with '0': '", result, "'");

    // Pad right
    result = NAVStringPadRight("Hello", 10, ' ');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  PadRight 'Hello' to length 10 with ' ': '", result, "'");
}

define_function TestStringStartsEndsWith() {
    stack_var integer result;

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing string starts/ends with'");

    // Starts with
    result = NAVStringStartsWith("Hello World", "Hello");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  'Hello World' starts with 'Hello': ", itoa(result), "'");

    result = NAVStringStartsWith("Hello World", "World");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  'Hello World' starts with 'World': ", itoa(result), "'");

    // Ends with
    result = NAVStringEndsWith("Hello World", "World");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  'Hello World' ends with 'World': ", itoa(result), "'");

    result = NAVStringEndsWith("Hello World", "Hello");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  'Hello World' ends with 'Hello': ", itoa(result), "'");
}
