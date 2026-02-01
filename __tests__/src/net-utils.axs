PROGRAM_NAME='net-utils'

#DEFINE __MAIN__
#include 'net-utils.axi'

DEFINE_DEVICE

vdvTest = 33201:1:0

DEFINE_START {
    set_log_level(NAV_LOG_LEVEL_DEBUG)
}

DEFINE_EVENT

button_event[vdvTest, 1] {
    push: {
        NAVLogTestStart()
        RunNetUtilsTests()
        NAVLogTestEnd()
    }
}

channel_event[vdvTest, 1] {
    on: {
        NAVLogTestStart()
        RunNetUtilsTests()
        NAVLogTestEnd()
    }
}
