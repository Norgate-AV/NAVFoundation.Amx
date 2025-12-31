#DEFINE TESTING_NAVFIGLET

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Figlet.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_NAVFIGLET
#include 'NAVFiglet.axi'
#END_IF

define_function RunFigletTests() {
    #IF_DEFINED TESTING_NAVFIGLET
    TestNAVFiglet()
    #END_IF
}
