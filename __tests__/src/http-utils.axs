PROGRAM_NAME='http-utils'

#DEFINE __MAIN__
#include 'http-utils.axi'

DEFINE_DEVICE

vdvTEST = 33201:1:0

DEFINE_START {
    set_log_level(NAV_LOG_LEVEL_DEBUG)
}

DEFINE_EVENT

button_event[vdvTest, 1] {
    push: {
        NAVLogTestStart()
        RunHttpUtilsTests()
        NAVLogTestEnd()
    }
}

channel_event[vdvTest, 1] {
    on: {
        NAVLogTestStart()
        RunHttpUtilsTests()
        NAVLogTestEnd()
    }
}
