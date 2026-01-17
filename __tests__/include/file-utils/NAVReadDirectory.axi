PROGRAM_NAME='NAVReadDirectory'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVReadDirectory
constant char READ_DIRECTORY_TESTS[][255] = {
    '',                                 // Test 1: Empty path (becomes '/')
    '/',                               // Test 2: Root directory
    '/user',                           // Test 3: /user directory (has 4 items)
    '/user/logs',                      // Test 4: /user/logs directory (has 1 file)
    '/testdir',                        // Test 5: /testdir directory (has 3 items)
    '/testdir/nested',                 // Test 6: /testdir/nested (has 1 file)
    '/empty',                          // Test 7: Empty directory
    '/nonexistent',                    // Test 8: Non-existent directory
    '/user/config.txt',                // Test 9: File path (not a directory)
    'user',                            // Test 10: Relative path 'user'
    '/user/fake'                       // Test 11: Non-existent nested directory
}


constant slong READ_DIRECTORY_EXPECTED_COUNT[] = {
    0,      // Test 1: Empty path becomes '/', varies by system (check >= 0)
    0,      // Test 2: Root (varies, check >= 0)
    4,      // Test 3: /user has 4 items (config.txt, data.xml, noextension, logs/)
    1,      // Test 4: /user/logs has 1 file (error.log)
    3,      // Test 5: /testdir has 3 items (test.txt, file with spaces.txt, nested/)
    1,      // Test 6: /testdir/nested has 1 file (deep.txt)
    0,      // Test 7: /empty has 0 items
    0,      // Test 8: Non-existent directory returns 0 (FILE_PATH_NOT_LOADED)
    -5,     // Test 9: File path (Disk I/O error)
    4,      // Test 10: Relative 'user' → '/user' (4 items)
    0       // Test 11: Non-existent nested returns 0
}


DEFINE_VARIABLE

// Global variables for test data
volatile char READ_DIRECTORY_SETUP_REQUIRED = false

// Expected entities for each test case
volatile _NAVFileEntity READ_DIRECTORY_EXPECTED_ENTITIES[11][10]  // 11 tests, max 10 entities each
volatile integer READ_DIRECTORY_EXPECTED_ENTITY_COUNT[11]

/**
 * Initialize global test data arrays at runtime
 * Required because NetLinx cannot handle complex string expressions in constants
 *
 * Note: Update expected results based on actual directory structure
 * Expected structure based on TEST_FILESYSTEM_SETUP.md
 */
define_function InitializeReadDirectoryTestData() {
    // Test 3: /user directory - 4 items
    READ_DIRECTORY_EXPECTED_ENTITY_COUNT[3] = 4
    READ_DIRECTORY_EXPECTED_ENTITIES[3][1].Name = 'config'
    READ_DIRECTORY_EXPECTED_ENTITIES[3][1].BaseName = 'config.txt'
    READ_DIRECTORY_EXPECTED_ENTITIES[3][1].Extension = '.txt'
    READ_DIRECTORY_EXPECTED_ENTITIES[3][1].Path = '/user/config.txt'
    READ_DIRECTORY_EXPECTED_ENTITIES[3][1].Parent = '/user'
    READ_DIRECTORY_EXPECTED_ENTITIES[3][1].IsDirectory = false

    READ_DIRECTORY_EXPECTED_ENTITIES[3][2].Name = 'data'
    READ_DIRECTORY_EXPECTED_ENTITIES[3][2].BaseName = 'data.xml'
    READ_DIRECTORY_EXPECTED_ENTITIES[3][2].Extension = '.xml'
    READ_DIRECTORY_EXPECTED_ENTITIES[3][2].Path = '/user/data.xml'
    READ_DIRECTORY_EXPECTED_ENTITIES[3][2].Parent = '/user'
    READ_DIRECTORY_EXPECTED_ENTITIES[3][2].IsDirectory = false

    READ_DIRECTORY_EXPECTED_ENTITIES[3][3].Name = 'noextension'
    READ_DIRECTORY_EXPECTED_ENTITIES[3][3].BaseName = 'noextension'
    READ_DIRECTORY_EXPECTED_ENTITIES[3][3].Extension = ''
    READ_DIRECTORY_EXPECTED_ENTITIES[3][3].Path = '/user/noextension'
    READ_DIRECTORY_EXPECTED_ENTITIES[3][3].Parent = '/user'
    READ_DIRECTORY_EXPECTED_ENTITIES[3][3].IsDirectory = false

    READ_DIRECTORY_EXPECTED_ENTITIES[3][4].Name = 'logs'
    READ_DIRECTORY_EXPECTED_ENTITIES[3][4].BaseName = 'logs'
    READ_DIRECTORY_EXPECTED_ENTITIES[3][4].Extension = ''
    READ_DIRECTORY_EXPECTED_ENTITIES[3][4].Path = '/user/logs'
    READ_DIRECTORY_EXPECTED_ENTITIES[3][4].Parent = '/user'
    READ_DIRECTORY_EXPECTED_ENTITIES[3][4].IsDirectory = true

    // Test 4: /user/logs directory - 1 item
    READ_DIRECTORY_EXPECTED_ENTITY_COUNT[4] = 1
    READ_DIRECTORY_EXPECTED_ENTITIES[4][1].Name = 'error'
    READ_DIRECTORY_EXPECTED_ENTITIES[4][1].BaseName = 'error.log'
    READ_DIRECTORY_EXPECTED_ENTITIES[4][1].Extension = '.log'
    READ_DIRECTORY_EXPECTED_ENTITIES[4][1].Path = '/user/logs/error.log'
    READ_DIRECTORY_EXPECTED_ENTITIES[4][1].Parent = '/user/logs'
    READ_DIRECTORY_EXPECTED_ENTITIES[4][1].IsDirectory = false

    // Test 5: /testdir directory - 3 items
    READ_DIRECTORY_EXPECTED_ENTITY_COUNT[5] = 3
    READ_DIRECTORY_EXPECTED_ENTITIES[5][1].Name = 'test'
    READ_DIRECTORY_EXPECTED_ENTITIES[5][1].BaseName = 'test.txt'
    READ_DIRECTORY_EXPECTED_ENTITIES[5][1].Extension = '.txt'
    READ_DIRECTORY_EXPECTED_ENTITIES[5][1].Path = '/testdir/test.txt'
    READ_DIRECTORY_EXPECTED_ENTITIES[5][1].Parent = '/testdir'
    READ_DIRECTORY_EXPECTED_ENTITIES[5][1].IsDirectory = false

    READ_DIRECTORY_EXPECTED_ENTITIES[5][2].Name = 'file with spaces'
    READ_DIRECTORY_EXPECTED_ENTITIES[5][2].BaseName = 'file with spaces.txt'
    READ_DIRECTORY_EXPECTED_ENTITIES[5][2].Extension = '.txt'
    READ_DIRECTORY_EXPECTED_ENTITIES[5][2].Path = '/testdir/file with spaces.txt'
    READ_DIRECTORY_EXPECTED_ENTITIES[5][2].Parent = '/testdir'
    READ_DIRECTORY_EXPECTED_ENTITIES[5][2].IsDirectory = false

    READ_DIRECTORY_EXPECTED_ENTITIES[5][3].Name = 'nested'
    READ_DIRECTORY_EXPECTED_ENTITIES[5][3].BaseName = 'nested'
    READ_DIRECTORY_EXPECTED_ENTITIES[5][3].Extension = ''
    READ_DIRECTORY_EXPECTED_ENTITIES[5][3].Path = '/testdir/nested'
    READ_DIRECTORY_EXPECTED_ENTITIES[5][3].Parent = '/testdir'
    READ_DIRECTORY_EXPECTED_ENTITIES[5][3].IsDirectory = true

    // Test 6: /testdir/nested directory - 1 item
    READ_DIRECTORY_EXPECTED_ENTITY_COUNT[6] = 1
    READ_DIRECTORY_EXPECTED_ENTITIES[6][1].Name = 'deep'
    READ_DIRECTORY_EXPECTED_ENTITIES[6][1].BaseName = 'deep.txt'
    READ_DIRECTORY_EXPECTED_ENTITIES[6][1].Extension = '.txt'
    READ_DIRECTORY_EXPECTED_ENTITIES[6][1].Path = '/testdir/nested/deep.txt'
    READ_DIRECTORY_EXPECTED_ENTITIES[6][1].Parent = '/testdir/nested'
    READ_DIRECTORY_EXPECTED_ENTITIES[6][1].IsDirectory = false

    // Test 10: 'user' relative (same as test 3)
    READ_DIRECTORY_EXPECTED_ENTITY_COUNT[10] = 4
    READ_DIRECTORY_EXPECTED_ENTITIES[10][1].Name = 'config'
    READ_DIRECTORY_EXPECTED_ENTITIES[10][1].BaseName = 'config.txt'
    READ_DIRECTORY_EXPECTED_ENTITIES[10][1].Extension = '.txt'
    READ_DIRECTORY_EXPECTED_ENTITIES[10][1].Path = '/user/config.txt'
    READ_DIRECTORY_EXPECTED_ENTITIES[10][1].Parent = '/user'
    READ_DIRECTORY_EXPECTED_ENTITIES[10][1].IsDirectory = false

    READ_DIRECTORY_EXPECTED_ENTITIES[10][2].Name = 'data'
    READ_DIRECTORY_EXPECTED_ENTITIES[10][2].BaseName = 'data.xml'
    READ_DIRECTORY_EXPECTED_ENTITIES[10][2].Extension = '.xml'
    READ_DIRECTORY_EXPECTED_ENTITIES[10][2].Path = '/user/data.xml'
    READ_DIRECTORY_EXPECTED_ENTITIES[10][2].Parent = '/user'
    READ_DIRECTORY_EXPECTED_ENTITIES[10][2].IsDirectory = false

    READ_DIRECTORY_EXPECTED_ENTITIES[10][3].Name = 'noextension'
    READ_DIRECTORY_EXPECTED_ENTITIES[10][3].BaseName = 'noextension'
    READ_DIRECTORY_EXPECTED_ENTITIES[10][3].Extension = ''
    READ_DIRECTORY_EXPECTED_ENTITIES[10][3].Path = '/user/noextension'
    READ_DIRECTORY_EXPECTED_ENTITIES[10][3].Parent = '/user'
    READ_DIRECTORY_EXPECTED_ENTITIES[10][3].IsDirectory = false

    READ_DIRECTORY_EXPECTED_ENTITIES[10][4].Name = 'logs'
    READ_DIRECTORY_EXPECTED_ENTITIES[10][4].BaseName = 'logs'
    READ_DIRECTORY_EXPECTED_ENTITIES[10][4].Extension = ''
    READ_DIRECTORY_EXPECTED_ENTITIES[10][4].Path = '/user/logs'
    READ_DIRECTORY_EXPECTED_ENTITIES[10][4].Parent = '/user'
    READ_DIRECTORY_EXPECTED_ENTITIES[10][4].IsDirectory = true

    READ_DIRECTORY_SETUP_REQUIRED = true
}

define_function TestNAVReadDirectory() {
    stack_var integer x

    NAVLog("'***************** NAVReadDirectory *****************'")

    InitializeReadDirectoryTestData()

    for (x = 1; x <= length_array(READ_DIRECTORY_TESTS); x++) {
        stack_var slong expectedCount
        stack_var char testPath[255]
        stack_var char found
        stack_var integer i
        stack_var integer j
        stack_var _NAVFileEntity entities[255]
        stack_var slong result

        testPath = READ_DIRECTORY_TESTS[x]
        result = NAVReadDirectory(testPath, entities)
        expectedCount = READ_DIRECTORY_EXPECTED_COUNT[x]

        // Special cases: empty path and root directory count varies, just check success
        if (x == 1 || x == 2) {
            if (!NAVAssertTrue('Should return non-negative result', result >= 0)) {
                NAVLogTestFailed(x, "'success (>= 0)'", itoa(result))
                continue
            }

            NAVLogTestPassed(x)
            continue
        }

        if (!NAVAssertSignedLongEqual('Should return the correct entry count', expectedCount, result)) {
            NAVLogTestFailed(x, itoa(expectedCount), itoa(result))
            continue
        }

        // Verify entity contents for tests that have expected entities defined
        if (READ_DIRECTORY_EXPECTED_ENTITY_COUNT[x] > 0) {
            for (i = 1; i <= READ_DIRECTORY_EXPECTED_ENTITY_COUNT[x]; i++) {
                found = false

                // Search for this expected entity in the actual results
                for (j = 1; j <= type_cast(result); j++) {
                    if (entities[j].BaseName == READ_DIRECTORY_EXPECTED_ENTITIES[x][i].BaseName &&
                        entities[j].IsDirectory == READ_DIRECTORY_EXPECTED_ENTITIES[x][i].IsDirectory) {
                        found = true

                        // Assert all properties match
                        if (!NAVAssertStringEqual("'Name matches for ', READ_DIRECTORY_EXPECTED_ENTITIES[x][i].BaseName",
                                                  READ_DIRECTORY_EXPECTED_ENTITIES[x][i].Name,
                                                  entities[j].Name)) {
                            NAVLogTestFailed(x, READ_DIRECTORY_EXPECTED_ENTITIES[x][i].Name, entities[j].Name)
                        }

                        if (!NAVAssertStringEqual("'Extension matches for ', READ_DIRECTORY_EXPECTED_ENTITIES[x][i].BaseName",
                                                  READ_DIRECTORY_EXPECTED_ENTITIES[x][i].Extension,
                                                  entities[j].Extension)) {
                            NAVLogTestFailed(x, READ_DIRECTORY_EXPECTED_ENTITIES[x][i].Extension, entities[j].Extension)
                        }

                        if (!NAVAssertStringEqual("'Path matches for ', READ_DIRECTORY_EXPECTED_ENTITIES[x][i].BaseName",
                                                  READ_DIRECTORY_EXPECTED_ENTITIES[x][i].Path,
                                                  entities[j].Path)) {
                            NAVLogTestFailed(x, READ_DIRECTORY_EXPECTED_ENTITIES[x][i].Path, entities[j].Path)
                        }

                        if (!NAVAssertStringEqual("'Parent matches for ', READ_DIRECTORY_EXPECTED_ENTITIES[x][i].BaseName",
                                                  READ_DIRECTORY_EXPECTED_ENTITIES[x][i].Parent,
                                                  entities[j].Parent)) {
                            NAVLogTestFailed(x, READ_DIRECTORY_EXPECTED_ENTITIES[x][i].Parent, entities[j].Parent)
                        }

                        break
                    }
                }

                if (!found) {
                    NAVLog("'  Missing expected entity: ', READ_DIRECTORY_EXPECTED_ENTITIES[x][i].BaseName,
                            ' (IsDirectory: ', NAVBooleanToString(READ_DIRECTORY_EXPECTED_ENTITIES[x][i].IsDirectory), ')'")
                }

                if (!NAVAssertTrue("'Should contain ', READ_DIRECTORY_EXPECTED_ENTITIES[x][i].BaseName", found)) {
                    NAVLogTestFailed(x, "'entity found'", "'entity missing'")
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }
}
