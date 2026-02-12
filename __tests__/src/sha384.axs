PROGRAM_NAME='sha384'

#DEFINE __MAIN__
#include 'sha384.axi'

DEFINE_DEVICE

vdvTest = 33201:1:0

DEFINE_START {
    set_log_level(NAV_LOG_LEVEL_DEBUG)
}

DEFINE_EVENT

button_event[vdvTest, 1] {
    push: {
        NAVLogTestStart()
        RunSha384Tests()
        NAVLogTestEnd()
    }
}

channel_event[vdvTest, 1] {
    on: {
        NAVLogTestStart()
        RunSha384Tests()
        NAVLogTestEnd()
    }
}
