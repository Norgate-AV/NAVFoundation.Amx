#DEFINE TESTING_NAVCSVLEXER
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.CsvUtils.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_NAVCSVLEXER
#include 'NAVCsvLexer.axi'
#END_IF

define_function RunCsvUtilsTests() {
    #IF_DEFINED TESTING_NAVCSVLEXER
    TestNAVCsvLexerInit()
    TestNAVCsvLexerTokenize()
    TestNAVCsvLexerIsIdentifierChar()
    TestNAVCsvLexerTokenTypes()
    #END_IF
}
