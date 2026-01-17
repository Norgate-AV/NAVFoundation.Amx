PROGRAM_NAME='figlet'

#DEFINE __MAIN__
#include 'figlet.axi'

DEFINE_DEVICE

dvTP    =   10001:1:0
vdvTest =   33201:1:0

DEFINE_EVENT

// button_event[dvTP, 1] {
//     push: {
//         set_log_level(NAV_LOG_LEVEL_DEBUG)
//         RunFigletTests()
//     }
// }

channel_event[vdvTest, 1] {
    on: {
        set_log_level(NAV_LOG_LEVEL_DEBUG)
        RunFigletTests()
    }
}
