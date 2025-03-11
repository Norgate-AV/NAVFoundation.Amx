PROGRAM_NAME='base32'

#DEFINE __MAIN__
#include 'base32.axi'

DEFINE_DEVICE

dvTP    =   10001:1:0

DEFINE_EVENT

button_event[dvTP, 1] {
    push: {
        set_log_level(NAV_LOG_LEVEL_DEBUG)
        RunBase32Tests()
    }
}
