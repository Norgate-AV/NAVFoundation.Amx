PROGRAM_NAME='net-utils'

#DEFINE __MAIN__
#include 'net-utils.axi'

DEFINE_DEVICE

vdvTEST = 33201:1:0

DEFINE_EVENT

button_event[vdvTest, 1] {
    push: {
        set_log_level(NAV_LOG_LEVEL_DEBUG)
        RunNetUtilsTests()
    }
}

channel_event[vdvTest, 1] {
    on: {
        set_log_level(NAV_LOG_LEVEL_DEBUG)
        RunNetUtilsTests()
    }
}
