PROGRAM_NAME='jsmn'

#DEFINE __MAIN__
#include 'jsmn.axi'
#include 'jsmnex.axi'

DEFINE_DEVICE

vdvTEST = 33201:1:0

DEFINE_START {
    set_log_level(NAV_LOG_LEVEL_DEBUG)
}

DEFINE_EVENT

button_event[vdvTest, 1] {
    push: {
        NAVLogTestStart()
        RunJsmnTests()
        RunJsmnExTests()
        NAVLogTestEnd()
    }
}

channel_event[vdvTest, 1] {
    on: {
        NAVLogTestStart()
        RunJsmnTests()
        RunJsmnExTests()
        NAVLogTestEnd()
    }
}
