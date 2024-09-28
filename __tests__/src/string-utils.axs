PROGRAM_NAME='string-utils'

#DEFINE __MAIN__
#DEFINE TESTING_NAVGETSTRINGBETWEEN
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_NAVGETSTRINGBETWEEN
#include 'NAVGetStringBetween.axi'
#END_IF


DEFINE_DEVICE

dvTP    =   10001:1:0


DEFINE_CONSTANT

constant char SUBJECT[] = 'The quick brown fox jumps over the lazy dog'


define_function RunTests() {
    #IF_DEFINED TESTING_NAVGETSTRINGBETWEEN
    TestNAVGetStringBetween(SUBJECT)
    #END_IF
}


DEFINE_EVENT

button_event[dvTP, 1] {
    push: {
        RunTests()
    }
}
