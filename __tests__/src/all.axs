PROGRAM_NAME='all'

#DEFINE __MAIN__
#DEFINE TESTING_AES128

#include 'NAVFoundation.Core.axi'

#IF_DEFINED TESTING_AES128
#include 'aes128.axi'
#END_IF


DEFINE_DEVICE

dvTP    =   10001:1:0


define_function RunAllTests() {
    #IF_DEFINED TESTING_NAVAES128
    NAVLog("'***************** NAV AES128 *****************'")
    RunAes128Tests()
    #END_IF
}


DEFINE_EVENT

button_event[dvTP, 1] {
    push: {
        set_log_level(NAV_LOG_LEVEL_DEBUG)
        RunAllTests()
    }
}
