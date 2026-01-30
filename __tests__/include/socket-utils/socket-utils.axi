#DEFINE TESTING_NAVSOCKETGETEXPONENTIALBACKOFF
#DEFINE TESTING_NAVSOCKETGETCONNECTIONINTERVAL
#include 'NAVFoundation.SocketUtils.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_NAVSOCKETGETEXPONENTIALBACKOFF
#include 'NAVSocketGetExponentialBackoff.axi'
#END_IF

#IF_DEFINED TESTING_NAVSOCKETGETCONNECTIONINTERVAL
#include 'NAVSocketGetConnectionInterval.axi'
#END_IF


define_function RunSocketUtilsTests() {
    #IF_DEFINED TESTING_NAVSOCKETGETEXPONENTIALBACKOFF
    TestNAVSocketGetExponentialBackoff()
    #END_IF

    #IF_DEFINED TESTING_NAVSOCKETGETCONNECTIONINTERVAL
    TestNAVSocketGetConnectionInterval()
    #END_IF
}
