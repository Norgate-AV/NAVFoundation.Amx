PROGRAM_NAME='NAVSplitString'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char SPLIT_STRING_TEST[][][NAV_MAX_BUFFER] = {
    { 'The quick brown fox jumps over the lazy dog', ' ' },
    { 'The,quick,brown,fox,jumps,over,the,lazy,dog', ',' },
    { 'The-quick-brown-fox-jumps-over-the-lazy-dog', '-' }
}

constant char SPLIT_STRING_EXPECTED[][][NAV_MAX_BUFFER] = {
    {
        'The',
        'quick',
        'brown',
        'fox',
        'jumps',
        'over',
        'the',
        'lazy',
        'dog'
    },
    {
        'The',
        'quick',
        'brown',
        'fox',
        'jumps',
        'over',
        'the',
        'lazy',
        'dog'
    },
    {
        'The',
        'quick',
        'brown',
        'fox',
        'jumps',
        'over',
        'the',
        'lazy',
        'dog'
    }
}


define_function TestNAVSplitString() {
    stack_var integer x

    NAVLog("'***************** NAVSplitString *****************'")

    for (x = 1; x <= length_array(SPLIT_STRING_TEST); x++) {
        stack_var integer count
        stack_var char separator[5]
        stack_var char result[100][NAV_MAX_BUFFER]
        stack_var char failed

        separator = SPLIT_STRING_TEST[x][2]
        count = NAVSplitString(SPLIT_STRING_TEST[x][1], separator, result)

        if (count != length_array(SPLIT_STRING_EXPECTED[x])) {
            NAVLogTestFailed(x, itoa(length_array(SPLIT_STRING_EXPECTED[x])), itoa(count))
            continue
        }

        {
            stack_var integer z

            for (z = 1; z <= count; z++) {
                if (result[z] != SPLIT_STRING_EXPECTED[x][z]) {
                    NAVLogTestFailed(x, SPLIT_STRING_EXPECTED[x][z], result[z])
                    failed = true
                    break
                }
            }
        }

        if (failed) {
            continue
        }

        NAVLogTestPassed(x)
    }
}
