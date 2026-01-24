PROGRAM_NAME='websocket'

#DEFINE __MAIN__
#include 'websocket.axi'

DEFINE_DEVICE

vdvTEST = 33201:1:0

DEFINE_START {
    set_log_level(NAV_LOG_LEVEL_DEBUG)
}

DEFINE_EVENT

button_event[vdvTest, 1] {
    push: {
        NAVLogTestStart()
        RunWebSocketTests()
        NAVLogTestEnd()
    }
}

channel_event[vdvTest, 1] {
    on: {
        NAVLogTestStart()
        RunWebSocketTests()
        NAVLogTestEnd()
    }
}
