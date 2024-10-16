PROGRAM_NAME='string-utils'

#DEFINE __MAIN__
#DEFINE TESTING_NAVGETSTRINGBETWEEN
#DEFINE TESTING_NAVSTRINGSUBSTRING
#DEFINE TESTING_NAVSTRINGSLICE
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_NAVGETSTRINGBETWEEN
#include 'NAVGetStringBetween.axi'
#END_IF

#IF_DEFINED TESTING_NAVSTRINGSUBSTRING
#include 'NAVStringSubstring.axi'
#END_IF

#IF_DEFINED TESTING_NAVSTRINGSLICE
#include 'NAVStringSlice.axi'
#END_IF


DEFINE_DEVICE

dvTP    =   10001:1:0


define_function RunTests() {
    #IF_DEFINED TESTING_NAVGETSTRINGBETWEEN
    TestNAVGetStringBetween()
    #END_IF

    #IF_DEFINED TESTING_NAVSTRINGSUBSTRING
    TestNAVStringSubstring()
    #END_IF

    #IF_DEFINED TESTING_NAVSTRINGSLICE
    TestNAVStringSlice()
    #END_IF
}


DEFINE_EVENT

button_event[dvTP, 1] {
    push: {
        RunTests()
    }
}
