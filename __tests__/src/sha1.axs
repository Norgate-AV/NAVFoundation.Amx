PROGRAM_NAME='sha1'

#DEFINE __MAIN__
#include 'sha1.axi'

DEFINE_DEVICE

vdvTest = 33201:1:0

DEFINE_START {
    set_log_level(NAV_LOG_LEVEL_DEBUG)
}

DEFINE_EVENT

button_event[vdvTest, 1] {
    push: {
        NAVLogTestStart()
        RunSha1Tests()
        NAVLogTestEnd()
    }
}

channel_event[vdvTest, 1] {
    on: {
        NAVLogTestStart()
        RunSha1Tests()
        NAVLogTestEnd()
    }
}
