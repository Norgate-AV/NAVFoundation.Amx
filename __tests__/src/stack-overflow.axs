PROGRAM_NAME='stack-overflow'

#DEFINE __MAIN__
#include 'stack-overflow.axi'

DEFINE_DEVICE

dvTP    =   10001:1:0

DEFINE_EVENT

button_event[dvTP, 1] {
    push: {
        set_log_level(NAV_LOG_LEVEL_DEBUG)
        RunStackOverflowTests()
    }
}
