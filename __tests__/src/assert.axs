PROGRAM_NAME='assert'

#DEFINE __MAIN__
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVAssertTests.axi'

DEFINE_DEVICE

dvTP = 10001:1:0


define_function RunTests() {
    RunNAVAssertTests()
}


DEFINE_EVENT

button_event[dvTP, 1] {
    push: {
        RunTests()
    }
}
