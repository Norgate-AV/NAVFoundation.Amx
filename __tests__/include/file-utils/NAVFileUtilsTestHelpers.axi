PROGRAM_NAME='NAVFileUtilsTestHelpers'

#IF_NOT_DEFINED __NAV_FILE_UTILS_TEST_HELPERS__
#DEFINE __NAV_FILE_UTILS_TEST_HELPERS__ 'NAVFileUtilsTestHelpers'

/**
 * Count lines in a file by reading them
 *
 * @param path The file path to count lines in
 * @return The number of lines in the file, or 0 if the file cannot be read
 */
define_function integer CountLinesInFile(char path[]) {
    stack_var char allLines[1000][NAV_MAX_BUFFER]
    stack_var slong result

    result = NAVFileReadLines(path, allLines)

    if (result < 0) {
        return 0
    }

    return type_cast(result)
}

#END_IF // __NAV_FILE_UTILS_TEST_HELPERS__