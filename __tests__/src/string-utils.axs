PROGRAM_NAME='string-utils'

#DEFINE __MAIN__
#include 'string-utils.axi'

DEFINE_DEVICE

dvTP    =   10001:1:0

DEFINE_EVENT

button_event[dvTP, 1] {
    push: {
        set_log_level(NAV_LOG_LEVEL_DEBUG)
        RunStringUtilsTests()
    }
}
