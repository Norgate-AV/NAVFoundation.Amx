#DEFINE TESTING_NAVREADDIRECTORY
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.FileUtils.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_NAVREADDIRECTORY
#include 'NAVReadDirectory.axi'
#END_IF

define_function RunFileUtilsTests() {
    #IF_DEFINED TESTING_NAVREADDIRECTORY
    TestNAVReadDirectory()
    #IF_DEFINED TESTING_NAVFILEFUNCTION
    TestNAVFileFunction()
    #END_IF
}
