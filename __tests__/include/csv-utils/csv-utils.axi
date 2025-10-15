#DEFINE TESTING_NAVCSVLEXER
#DEFINE TESTING_NAVCSVPARSER
#DEFINE TESTING_NAVCSVPARSER_COMPREHENSIVE
#DEFINE TESTING_NAVCSVUTILS
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.CsvUtils.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_NAVCSVLEXER
#include 'NAVCsvLexer.axi'
#include 'NAVCsvLexerBackslashEscapes.axi'
#END_IF

#IF_DEFINED TESTING_NAVCSVPARSER
#include 'NAVCsvParser.axi'
#END_IF

#IF_DEFINED TESTING_NAVCSVPARSER_COMPREHENSIVE
#include 'NAVCsvParserComprehensive.axi'
#END_IF

#IF_DEFINED TESTING_NAVCSVUTILS
#include 'NAVCsvUtilsParse.axi'
#include 'NAVCsvUtilsSerialize.axi'
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
    TestNAVCsvLexerBackslashEscapes()
    #END_IF

    #IF_DEFINED TESTING_NAVCSVPARSER
    NAVLog("'========================================='")
    NAVLog("'STANDARD CSV PARSER TEST SUITE (26 tests)'")
    NAVLog("'========================================='")
    TestNAVCsvParserInit()
    TestNAVCsvParserParse()
    TestNAVCsvParserWhitespaceHandling()
    TestNAVCsvParserEdgeCases()
    TestNAVCsvParserComplexScenarios()
    TestNAVCsvParserSpecialCharacters()
    TestNAVCsvParserRFC4180Compliance()
    NAVLog("'========================================='")
    NAVLog("''")
    #END_IF

    #IF_DEFINED TESTING_NAVCSVPARSER_COMPREHENSIVE
    TestAllComprehensive()
    #END_IF

    #IF_DEFINED TESTING_NAVCSVUTILS
    NAVLog("'========================================='")
    NAVLog("'HIGH-LEVEL CSV UTILS TEST SUITE (22 tests)'")
    NAVLog("'========================================='")
    TestNAVCsvUtilsParse()
    TestNAVCsvUtilsSerialize()
    NAVLog("'========================================='")
    NAVLog("''")
    #END_IF
}

