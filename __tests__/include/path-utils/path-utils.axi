#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.PathUtils.axi'

define_function RunPathUtilsTests() {
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running Path Utilities Tests ====='");

    // Test path operations
    TestPathJoin();
    TestPathNormalize();
    TestPathGetDirectory();
    TestPathGetFilename();
    TestPathGetExtension();

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'All Path Utils tests completed'");
}

define_function TestPathJoin() {
    stack_var char result[NAV_MAX_PATH];

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing path joining'");

    // Basic path joining
    result = NAVPathJoin('C:\Users', 'John');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Join 'C:\Users' + 'John': '", result, "'");

    // Path joining with slash at end of first part
    result = NAVPathJoin('C:\Users\', 'John');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Join 'C:\Users\' + 'John': '", result, "'");

    // Path joining with slash at start of second part
    result = NAVPathJoin('C:\Users', '\John');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Join 'C:\Users' + '\John': '", result, "'");

    // Three-part path joining
    result = NAVPathJoin(NAVPathJoin('C:', 'Users'), 'John');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Join 'C:' + 'Users' + 'John': '", result, "'");
}

define_function TestPathNormalize() {
    stack_var char result[NAV_MAX_PATH];

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing path normalization'");

    // Remove redundant separators
    result = NAVPathNormalize('C:\\Users\\\\John\\\Documents');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Normalize 'C:\\Users\\\\John\\\Documents': '", result, "'");

    // Handle dot notation
    result = NAVPathNormalize('C:\Users\John\.\Documents');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Normalize 'C:\Users\John\.\Documents': '", result, "'");

    // Handle dotdot notation
    result = NAVPathNormalize('C:\Users\John\..\Admin\Documents');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Normalize 'C:\Users\John\..\Admin\Documents': '", result, "'");

    // Complex path with multiple notation types
    result = NAVPathNormalize('C:\Users\.\John\..\Admin\.\Documents\\Work');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Normalize 'C:\Users\.\John\..\Admin\.\Documents\\Work': '", result, "'");
}

define_function TestPathGetDirectory() {
    stack_var char result[NAV_MAX_PATH];

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing directory extraction'");

    // Basic directory extraction
    result = NAVPathGetDirectory('C:\Users\John\Documents\file.txt');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Directory of 'C:\Users\John\Documents\file.txt': '", result, "'");

    // Path with trailing separator
    result = NAVPathGetDirectory('C:\Users\John\Documents\');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Directory of 'C:\Users\John\Documents\': '", result, "'");

    // Root directory
    result = NAVPathGetDirectory('C:\file.txt');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Directory of 'C:\file.txt': '", result, "'");
}

define_function TestPathGetFilename() {
    stack_var char result[NAV_MAX_FILENAME];

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing filename extraction'");

    // Basic filename extraction
    result = NAVPathGetFilename('C:\Users\John\Documents\file.txt');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Filename of 'C:\Users\John\Documents\file.txt': '", result, "'");

    // Path with no directory
    result = NAVPathGetFilename('file.txt');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Filename of 'file.txt': '", result, "'");

    // Path with trailing separator
    result = NAVPathGetFilename('C:\Users\John\Documents\');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Filename of 'C:\Users\John\Documents\': '", result, "'");
}

define_function TestPathGetExtension() {
    stack_var char result[NAV_MAX_EXTENSION];

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing extension extraction'");

    // Basic extension extraction
    result = NAVPathGetExtension('C:\Users\John\Documents\file.txt');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Extension of 'C:\Users\John\Documents\file.txt': '", result, "'");

    // Multiple extensions
    result = NAVPathGetExtension('archive.tar.gz');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Extension of 'archive.tar.gz': '", result, "'");

    // No extension
    result = NAVPathGetExtension('C:\Users\John\Documents\README');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Extension of 'C:\Users\John\Documents\README': '", result, "'");
}
