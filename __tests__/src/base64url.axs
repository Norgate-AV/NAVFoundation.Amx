PROGRAM_NAME='base64url'

#DEFINE __MAIN__
#include 'base64url.axi'

DEFINE_DEVICE

vdvTest = 33201:1:0

DEFINE_START {
    set_log_level(NAV_LOG_LEVEL_DEBUG)
}

DEFINE_EVENT

button_event[vdvTest, 1] {
    push: {
        NAVLogTestStart()
        RunBase64UrlTests()
        NAVLogTestEnd()
    }
}

channel_event[vdvTest, 1] {
    on: {
        NAVLogTestStart()
        RunBase64UrlTests()
        NAVLogTestEnd()
    }
}
