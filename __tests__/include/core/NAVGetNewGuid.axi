PROGRAM_NAME='NAVGetNewGuid'

#include 'NAVFoundation.Core.axi'


DEFINE_VARIABLE

volatile char GUID_TEST_GUIDS[100][NAV_MAX_CHARS]


DEFINE_CONSTANT

constant integer GUID_TEST_COUNT = 10

constant char GUID_TEST_DESCRIPTIONS[GUID_TEST_COUNT][255] = {
    'GUID is not empty',
    'GUID has correct length (36)',
    'GUID has hyphens at positions 9, 14, 19, 24',
    'GUID version digit is 4 (position 15)',
    'GUID variant is valid (8-B at position 20)',
    'GUID contains only valid hex and hyphens',
    'All generated GUIDs are unique',
    'GUID contains no null characters',
    'GUID format is consistent across generations',
    'GUID uses lowercase hex only'
}


define_function TestNAVGetNewGuid() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVGetNewGuid'")

    // Generate test data once for uniqueness testing
    for (x = 1; x <= 100; x++) {
        GUID_TEST_GUIDS[x] = NAVGetNewGuid()
    }

    // Run all tests in a single loop
    for (x = 1; x <= GUID_TEST_COUNT; x++) {
        stack_var char guid[NAV_MAX_CHARS]
        stack_var char failed
        stack_var integer y

        guid = NAVGetNewGuid()

        switch (x) {
            case 1: { // GUID is not empty
                if (!NAVAssertTrue('GUID is not empty',
                                  length_array(guid) > 0)) {
                    failed = true
                }
            }
            case 2: { // GUID has correct length (36)
                if (!NAVAssertIntegerEqual('GUID has correct length',
                                          36,
                                          length_array(guid))) {
                    failed = true
                }
            }
            case 3: { // GUID has hyphens at correct positions
                if (!NAVAssertTrue('GUID has hyphens at correct positions',
                                  guid[9] == '-' && guid[14] == '-' && guid[19] == '-' && guid[24] == '-')) {
                    failed = true
                }
            }
            case 4: { // GUID version digit is '4'
                if (!NAVAssertCharEqual('GUID version is 4',
                                       '4',
                                       guid[15])) {
                    failed = true
                }
            }
            case 5: { // GUID variant is valid
                if (!NAVAssertTrue('GUID variant is valid',
                                  guid[20] == '8' || guid[20] == '9' || guid[20] == 'a' || guid[20] == 'b')) {
                    failed = true
                }
            }
            case 6: { // GUID contains only valid hex and hyphens
                for (y = 1; y <= length_array(guid); y++) {
                    if (y == 9 || y == 14 || y == 19 || y == 24) {
                        if (!NAVAssertCharEqual('GUID has hyphen at correct position',
                                               '-',
                                               guid[y])) {
                            failed = true
                            break
                        }
                    }
                    else {
                        if (!NAVAssertTrue('GUID character is valid hex',
                                          (guid[y] >= '0' && guid[y] <= '9') || (guid[y] >= 'a' && guid[y] <= 'f'))) {
                            failed = true
                            break
                        }
                    }
                }
            }
            case 7: { // All generated GUIDs are unique
                stack_var integer z
                for (y = 1; y <= 100; y++) {
                    for (z = y + 1; z <= 100; z++) {
                        if (!NAVAssertTrue('GUIDs are unique',
                                          GUID_TEST_GUIDS[y] != GUID_TEST_GUIDS[z])) {
                            failed = true
                            break
                        }
                    }
                    if (failed) break
                }
            }
            case 8: { // GUID contains no null characters
                for (y = 1; y <= length_array(guid); y++) {
                    if (!NAVAssertTrue('GUID has no null characters',
                                      guid[y] != 0)) {
                        failed = true
                        break
                    }
                }
            }
            case 9: { // GUID format is consistent
                for (y = 1; y <= 10; y++) {
                    stack_var char testGuid[NAV_MAX_CHARS]
                    testGuid = NAVGetNewGuid()

                    if (!NAVAssertIntegerEqual('Consistent GUID length',
                                              36,
                                              length_array(testGuid))) {
                        failed = true
                        break
                    }

                    if (!NAVAssertTrue('Consistent GUID format',
                                      testGuid[9] == '-' && testGuid[14] == '-' &&
                                      testGuid[19] == '-' && testGuid[24] == '-' &&
                                      testGuid[15] == '4')) {
                        failed = true
                        break
                    }
                }
            }
            case 10: { // GUID uses lowercase hex only
                for (y = 1; y <= length_array(guid); y++) {
                    if (!NAVAssertTrue('GUID uses lowercase hex only',
                                      !(guid[y] >= 'A' && guid[y] <= 'F'))) {
                        failed = true
                        break
                    }
                }
            }
        }

        if (failed) {
            NAVLogTestFailed(x, GUID_TEST_DESCRIPTIONS[x], guid)
        }
        else {
            NAVLogTestPassed(x)
        }
    }

    NAVLogTestSuiteEnd("'NAVGetNewGuid'")
}
