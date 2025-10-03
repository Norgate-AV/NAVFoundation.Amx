PROGRAM_NAME='NAVStringCaseConversion'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char CASE_CONVERSION_TEST[][NAV_MAX_BUFFER] = {
    'the quick brown fox',
    'THE QUICK BROWN FOX',
    'The Quick Brown Fox',
    'the-quick-brown-fox',
    'the_quick_brown_fox',
    'theQuickBrownFox',
    'TheQuickBrownFox',
    'the quick-brown_fox',
    'the.quick.brown.fox',
    'the   quick   brown   fox'
}

constant char PASCAL_CASE_EXPECTED[][NAV_MAX_BUFFER] = {
    'TheQuickBrownFox',
    'TheQuickBrownFox',
    'TheQuickBrownFox',
    'TheQuickBrownFox',
    'TheQuickBrownFox',
    'TheQuickBrownFox',
    'TheQuickBrownFox',
    'TheQuickBrownFox',
    'TheQuickBrownFox',
    'TheQuickBrownFox'
}

constant char CAMEL_CASE_EXPECTED[][NAV_MAX_BUFFER] = {
    'theQuickBrownFox',
    'theQuickBrownFox',
    'theQuickBrownFox',
    'theQuickBrownFox',
    'theQuickBrownFox',
    'theQuickBrownFox',
    'theQuickBrownFox',
    'theQuickBrownFox',
    'theQuickBrownFox',
    'theQuickBrownFox'
}

constant char SNAKE_CASE_EXPECTED[][NAV_MAX_BUFFER] = {
    'the_quick_brown_fox',
    'the_quick_brown_fox',
    'the_quick_brown_fox',
    'the_quick_brown_fox',
    'the_quick_brown_fox',
    'the_quick_brown_fox',
    'the_quick_brown_fox',
    'the_quick_brown_fox',
    'the_quick_brown_fox',
    'the_quick_brown_fox'
}

constant char KEBAB_CASE_EXPECTED[][NAV_MAX_BUFFER] = {
    'the-quick-brown-fox',
    'the-quick-brown-fox',
    'the-quick-brown-fox',
    'the-quick-brown-fox',
    'the-quick-brown-fox',
    'the-quick-brown-fox',
    'the-quick-brown-fox',
    'the-quick-brown-fox',
    'the-quick-brown-fox',
    'the-quick-brown-fox'
}

constant char TRAIN_CASE_EXPECTED[][NAV_MAX_BUFFER] = {
    'The-Quick-Brown-Fox',
    'The-Quick-Brown-Fox',
    'The-Quick-Brown-Fox',
    'The-Quick-Brown-Fox',
    'The-Quick-Brown-Fox',
    'The-Quick-Brown-Fox',
    'The-Quick-Brown-Fox',
    'The-Quick-Brown-Fox',
    'The-Quick-Brown-Fox',
    'The-Quick-Brown-Fox'
}

constant char SCREAM_KEBAB_CASE_EXPECTED[][NAV_MAX_BUFFER] = {
    'THE-QUICK-BROWN-FOX',
    'THE-QUICK-BROWN-FOX',
    'THE-QUICK-BROWN-FOX',
    'THE-QUICK-BROWN-FOX',
    'THE-QUICK-BROWN-FOX',
    'THE-QUICK-BROWN-FOX',
    'THE-QUICK-BROWN-FOX',
    'THE-QUICK-BROWN-FOX',
    'THE-QUICK-BROWN-FOX',
    'THE-QUICK-BROWN-FOX'
}


define_function TestNAVStringPascalCase() {
    stack_var integer x

    NAVLog("'***************** NAVStringPascalCase *****************'")

    for (x = 1; x <= length_array(CASE_CONVERSION_TEST); x++) {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = PASCAL_CASE_EXPECTED[x]
        result = NAVStringPascalCase(CASE_CONVERSION_TEST[x])

        if (!NAVAssertStringEqual('Pascal Case Test', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVStringCamelCase() {
    stack_var integer x

    NAVLog("'***************** NAVStringCamelCase *****************'")

    for (x = 1; x <= length_array(CASE_CONVERSION_TEST); x++) {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = CAMEL_CASE_EXPECTED[x]
        result = NAVStringCamelCase(CASE_CONVERSION_TEST[x])

        if (!NAVAssertStringEqual('Camel Case Test', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVStringSnakeCase() {
    stack_var integer x

    NAVLog("'***************** NAVStringSnakeCase *****************'")

    for (x = 1; x <= length_array(CASE_CONVERSION_TEST); x++) {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = SNAKE_CASE_EXPECTED[x]
        result = NAVStringSnakeCase(CASE_CONVERSION_TEST[x])

        if (!NAVAssertStringEqual('Snake Case Test', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVStringKebabCase() {
    stack_var integer x

    NAVLog("'***************** NAVStringKebabCase *****************'")

    for (x = 1; x <= length_array(CASE_CONVERSION_TEST); x++) {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = KEBAB_CASE_EXPECTED[x]
        result = NAVStringKebabCase(CASE_CONVERSION_TEST[x])

        if (!NAVAssertStringEqual('Kebab Case Test', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVStringTrainCase() {
    stack_var integer x

    NAVLog("'***************** NAVStringTrainCase *****************'")

    for (x = 1; x <= length_array(CASE_CONVERSION_TEST); x++) {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = TRAIN_CASE_EXPECTED[x]
        result = NAVStringTrainCase(CASE_CONVERSION_TEST[x])

        if (!NAVAssertStringEqual('Train Case Test', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVStringScreamKebabCase() {
    stack_var integer x

    NAVLog("'***************** NAVStringScreamKebabCase *****************'")

    for (x = 1; x <= length_array(CASE_CONVERSION_TEST); x++) {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = SCREAM_KEBAB_CASE_EXPECTED[x]
        result = NAVStringScreamKebabCase(CASE_CONVERSION_TEST[x])

        if (!NAVAssertStringEqual('Scream Kebab Case Test', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}
