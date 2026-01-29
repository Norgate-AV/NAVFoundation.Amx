#DEFINE TESTING_NAVGETNEWGUID
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_NAVGETNEWGUID
#include 'NAVGetNewGuid.axi'
#END_IF


define_function RunCoreTests() {
    #IF_DEFINED TESTING_NAVGETNEWGUID
    TestNAVGetNewGuid()
    #END_IF
}
