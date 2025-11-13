#DEFINE TESTING_NAVSNAPILEXER
#DEFINE SNAPI_LEXER_DEBUG
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_NAVSNAPILEXER
#include 'NAVSnapiLexer.axi'
#END_IF

define_function RunSnapiHelpersTests() {
    #IF_DEFINED TESTING_NAVSNAPILEXER
    TestNAVSnapiLexerBasic()
    #END_IF
}

