PROGRAM_NAME='json'

#DEFINE __MAIN__
#include 'json.axi'

DEFINE_DEVICE

vdvTEST = 33201:1:0

DEFINE_START {
    set_log_level(NAV_LOG_LEVEL_DEBUG)
}

DEFINE_EVENT

button_event[vdvTest, 1] {
    push: {
        NAVLogTestStart()
        RunJsonTests()
        NAVLogTestEnd()
    }
}

channel_event[vdvTest, 1] {
    on: {
        NAVLogTestStart()
        RunJsonTests()
        NAVLogTestEnd()
    }
}
