#DEFINE TESTING_NAVREADDIRECTORY
#DEFINE TESTING_NAVFILEEXISTS
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.FileUtils.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_NAVFILEEXISTS
#include 'NAVFileExists.axi'
#END_IF

#IF_DEFINED TESTING_NAVREADDIRECTORY
#include 'NAVReadDirectory.axi'
#END_IF

define_function RunFileUtilsTests() {
    #IF_DEFINED TESTING_NAVREADDIRECTORY
    TestNAVReadDirectory()
    #END_IF

    #IF_DEFINED TESTING_NAVFILEEXISTS
    TestNAVFileExists()
    #END_IF
}
