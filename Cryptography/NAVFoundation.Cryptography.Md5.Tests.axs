DEFINE_CONSTANT

constant char MD5_TEST_STRINGS[][NAV_MAX_BUFFER] =  {
                                                        'The quick brown fox jumps over the lazy dog',
                                                        '(username:password)',
                                                        'strong',
                                                        'weak'
                                                    }

constant char MD5_TEST_HASHES[][NAV_MAX_BUFFER] =  {
    '9e107d9d372bb6826bd81d3542a419d6',
    '150cbdd17787593d7409aa5f871c0a6d',
    '6f7f9432d35dea629c8384dab312259a',
    '7ecc19e1a0be36ba2c6f05d06b5d3058'
}


define_function TestMd5(char value[][], char expected[][]) {
    stack_var integer x
    stack_var char hash[32]

    NAVLog('')
    for (x = 1; x <= length_array(value); x++) {
        NAVLog("'MD5 Hash of "', value[x], '" is:'")

        hash = NAVGetMd5Hash(value[x])
        NAVLog(hash)

        if (hash != expected[x]) {
            NAVLog("NAV_TAB, 'Test failed'")
            NAVLog("NAV_TAB, 'Expected: ', expected[x]")
            NAVLog("NAV_TAB, 'Actual: ', hash")
            NAVLog('')
            continue
        }

        NAVLog("NAV_TAB, 'Test Passed'")
        NAVLog('')
    }
}
