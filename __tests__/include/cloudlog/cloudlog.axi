#DEFINE TESTING_NAVCLOUDLOGINIT
#DEFINE TESTING_NAVCLOUDLOGVALIDATE
#DEFINE TESTING_NAVCLOUDLOGJSONSERIALIZE

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.CloudLog.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_NAVCLOUDLOGINIT
#include 'NAVCloudLogInit.axi'
#END_IF

#IF_DEFINED TESTING_NAVCLOUDLOGVALIDATE
#include 'NAVCloudLogValidate.axi'
#END_IF

#IF_DEFINED TESTING_NAVCLOUDLOGJSONSERIALIZE
#include 'NAVCloudLogJsonSerialize.axi'
#END_IF


define_function RunCloudLogTests() {
    #IF_DEFINED TESTING_NAVCLOUDLOGINIT
    TestNAVCloudLogInit()
    #END_IF

    #IF_DEFINED TESTING_NAVCLOUDLOGVALIDATE
    TestNAVCloudLogValidate()
    #END_IF

    #IF_DEFINED TESTING_NAVCLOUDLOGJSONSERIALIZE
    TestNAVCloudLogJsonSerialize()
    #END_IF
}
