// #DEFINE TESTING_NAVCSVLEXER
#DEFINE TESTING_NAVCSVPARSER

// #DEFINE CSV_PARSER_DEBUG
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.CsvUtils.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_NAVCSVLEXER
#include 'NAVCsvLexer.axi'
#END_IF

#IF_DEFINED TESTING_NAVCSVPARSER
#include 'NAVCsvParser.axi'
#END_IF

define_function RunCsvUtilsTests() {
    #IF_DEFINED TESTING_NAVCSVLEXER
    TestNAVCsvLexerInit()
    TestNAVCsvLexerTokenize()
    TestNAVCsvLexerIsIdentifierChar()
    TestNAVCsvLexerTokenTypes()
    TestNAVCsvLexerWhitespaceHandling()
    TestNAVCsvLexerEdgeCases()
    TestNAVCsvLexerEpsilonFields()
    TestNAVCsvLexerSpecialCharsInQuotes()
    #END_IF

    #IF_DEFINED TESTING_NAVCSVPARSER
    TestNAVCsvParserInit()
    TestNAVCsvParserParse()
    TestNAVCsvParserWhitespaceHandling()
    TestNAVCsvParserEdgeCases()
    TestNAVCsvParserComplexScenarios()
    TestNAVCsvParserSpecialCharacters()
    TestNAVCsvParserRFC4180Compliance()
    #END_IF
}
