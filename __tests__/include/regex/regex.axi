#DEFINE TESTING_REGEX_LEXER
#DEFINE TESTING_REGEX_PARSER
#DEFINE TESTING_REGEX_MATCHER
// #DEFINE REGEX_LEXER_DEBUG
// #DEFINE REGEX_PARSER_DEBUG
// #DEFINE REGEX_MATCHER_DEBUG
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_REGEX_LEXER
#include 'NAVRegexLexerBasic.axi'
#include 'NAVRegexLexerCharClasses.axi'
#include 'NAVRegexLexerCharClassEdgeCases.axi'
#include 'NAVRegexLexerBoundedQuantifiers.axi'
#include 'NAVRegexLexerGroups.axi'
#include 'NAVRegexLexerNamedGroups.axi'
#include 'NAVRegexLexerNonCapturingGroups.axi'
#include 'NAVRegexLexerHexEscapes.axi'
#include 'NAVRegexLexerEscapeSequences.axi'
#include 'NAVRegexLexerWordBoundaries.axi'
#include 'NAVRegexLexerNumericEscapes.axi'
#include 'NAVRegexLexerNamedBackreferences.axi'
#include 'NAVRegexLexerStringAnchors.axi'
#include 'NAVRegexLexerInlineFlags.axi'
#include 'NAVRegexLexerFlagToggles.axi'
#include 'NAVRegexLexerGlobalFlags.axi'
#include 'NAVRegexLexerPatternExtraction.axi'
#include 'NAVRegexLexerComments.axi'
#include 'NAVRegexLexerErrors.axi'
#include 'NAVRegexLexerGroupErrors.axi'
#include 'NAVRegexLexerLookaround.axi'
#END_IF

#IF_DEFINED TESTING_REGEX_PARSER
#include 'NAVRegexParserBasic.axi'
#include 'NAVRegexParserHelpers.axi'
#include 'NAVRegexParserFragmentBuilders.axi'
#include 'NAVRegexParserFragmentCloning.axi'
#include 'NAVRegexParserCharClass.axi'
#include 'NAVRegexParserConcatAlternation.axi'
#include 'NAVRegexParserQuantifiers.axi'
#include 'NAVRegexParserGroups.axi'
#include 'NAVRegexParserLookaround.axi'
#include 'NAVRegexParserFlags.axi'
#include 'NAVRegexParserScopedFlags.axi'
#include 'NAVRegexParserIntegration.axi'
#include 'NAVRegexParserAlternationIntegration.axi'
#include 'NAVRegexParserAlternationGroupContext.axi'
#include 'NAVRegexParserGroupsIntegration.axi'
#include 'NAVRegexParserRecursionDepth.axi'
#include 'NAVRegexParserTransitionValidity.axi'
#include 'NAVRegexParserStateData.axi'
#include 'NAVRegexParserEpsilonClosure.axi'
#include 'NAVRegexParserTransitionCount.axi'
#include 'NAVRegexParserQuantifierOrder.axi'
#include 'NAVRegexParserCaptureGroups.axi'
#include 'NAVRegexParserGroupOrder.axi'
#include 'NAVRegexParserCharClassValidation.axi'
#include 'NAVRegexParserNfaCompleteness.axi'
#include 'NAVRegexParserBackreferences.axi'
#include 'NAVRegexParserPythonBackreferences.axi'
#include 'NAVRegexParserAnchors.axi'
#include 'NAVRegexParserOctalEscapes.axi'
#include 'NAVRegexParserEscapeSequences.axi'
#include 'NAVRegexParserHexEscapes.axi'
#include 'NAVRegexParserLookarounds.axi'
#include 'NAVRegexParserNamedGroups.axi'
// #include 'NAVRegexParserDiagnose.axi'
#END_IF

#IF_DEFINED TESTING_REGEX_MATCHER
#include 'NAVRegexMatcherBasic.axi'
#include 'NAVRegexMatcherMatchGlobal.axi'
#include 'NAVRegexMatcherAnchors.axi'
#include 'NAVRegexMatcherStringAnchors.axi'
#include 'NAVRegexMatcherWordBoundary.axi'
#include 'NAVRegexMatcherQuantifiers.axi'
#include 'NAVRegexMatcherBoundedQuantifiers.axi'
#include 'NAVRegexMatcherBoundedQuantifierGroups.axi'
#include 'NAVRegexMatcherCharClasses.axi'
#include 'NAVRegexMatcherEscapedChars.axi'
#include 'NAVRegexMatcherSpecialEscapes.axi'
#include 'NAVRegexMatcherSpecialEscapesInClasses.axi'
#include 'NAVRegexMatcherHexEscapes.axi'
#include 'NAVRegexMatcherOctalEscapes.axi'
#include 'NAVRegexMatcherGroups.axi'
#include 'NAVRegexMatcherNonCapturingGroups.axi'
#include 'NAVRegexMatcherNamedGroups.axi'
#include 'NAVRegexMatcherBackreference.axi'
#include 'NAVRegexMatcherNamedBackreference.axi'
#include 'NAVRegexMatcherPythonBackreferences.axi'
#include 'NAVRegexMatcherBackreferenceCaseInsensitive.axi'
#include 'NAVRegexMatcherLookaround.axi'
#include 'NAVRegexMatcherInlineFlags.axi'
#include 'NAVRegexMatcherGlobalFlags.axi'
#include 'NAVRegexMatcherGlobalMaxCount.axi'
#include 'NAVRegexMatcherMultilineLineEndings.axi'
#include 'NAVRegexMatcherLargeInput.axi'
#include 'NAVRegexMatcherMaxGroups.axi'
#include 'NAVRegexMatcherCharClassCaseInsensitive.axi'
#include 'NAVRegexApiTest.axi'
#include 'NAVRegexApiCompile.axi'
#include 'NAVRegexApiCompiled.axi'
#include 'NAVRegexApiCompiledGlobal.axi'
#include 'NAVRegexRealWorldPatterns.axi'
#include 'NAVRegexRealWorldProtocols.axi'
#include 'NAVRegexMatcherComplexEdgeCases.axi'
#include 'NAVRegexNamedGroupHelpers.axi'
#include 'NAVRegexSplit.axi'
#include 'NAVRegexTemplateParser.axi'
#include 'NAVRegexReplace.axi'
#include 'NAVRegexReplaceErrorHandling.axi'
#END_IF

define_function RunRegexTests() {
    #IF_DEFINED TESTING_REGEX_LEXER
    TestNAVRegexLexerBasic()
    TestNAVRegexLexerCharClasses()
    TestNAVRegexLexerCharClassEdgeCases()
    TestNAVRegexLexerBoundedQuantifiers()
    TestNAVRegexLexerBoundedQuantifiersValues()
    TestNAVRegexLexerGroups()
    TestNAVRegexLexerGroupsMetadata()
    TestNAVRegexLexerNamedGroups()
    TestNAVRegexLexerNamedGroupsMetadata()
    TestNAVRegexLexerNonCapturingGroups()
    TestNAVRegexLexerHexEscapes()
    TestNAVRegexLexerHexEscapesValues()
    TestNAVRegexLexerHexEscapesErrors()
    TestNAVRegexLexerEscapeSequences()
    TestNAVRegexLexerEscapeSequencesValues()
    TestNAVRegexLexerEscapeSequencesCharClasses()
    TestNAVRegexLexerWordBoundaries()
    TestNAVRegexLexerNumericEscapes()
    TestNAVRegexLexerNumericEscapesDigits()
    TestNAVRegexLexerNumericEscapesLeadingZero()
    TestNAVRegexLexerNamedBackreferences()
    TestNAVRegexLexerNamedBackreferencesNames()
    TestNAVRegexLexerStringAnchors()
    TestNAVRegexLexerInlineFlags()
    TestNAVRegexLexerFlagToggles()
    TestNAVRegexLexerFlagTogglesFlagEnabled()
    TestNAVRegexLexerGlobalFlags()
    TestNAVRegexLexerPatternExtraction()
    TestNAVRegexLexerComments()
    TestNAVRegexLexerErrors()
    TestNAVRegexLexerGroupErrors()
    TestNAVRegexLexerLookaround()
    #END_IF

    #IF_DEFINED TESTING_REGEX_PARSER
    // TestNAVRegexParserDiagnose()
    TestNAVRegexParserBasic()
    TestNAVRegexParserStateManagement()
    TestNAVRegexParserTransitionManagement()
    TestNAVRegexParserFragmentPatching()
    TestNAVRegexParserFragmentBuilders()
    TestNAVRegexParserFragmentCloning()
    TestNAVRegexParserFragmentBoundaryDetection()
    TestNAVRegexParserFragmentCloningMultiple()
    TestNAVRegexParserFragmentCloningEdgeCases()
    TestNAVRegexParserCharClass()
    TestNAVRegexParserConcatenation()
    TestNAVRegexParserAlternation()
    TestNAVRegexParserZeroOrOne()
    TestNAVRegexParserZeroOrMore()
    TestNAVRegexParserOneOrMore()
    TestNAVRegexParserBoundedQuantifier()
    TestNAVRegexParserGroups()
    TestNAVRegexParserLookaround()
    TestNAVRegexParserFlags()
    TestNAVRegexParserScopedFlags()
    TestNAVRegexParserIntegration()
    TestNAVRegexParserAlternationIntegration()
    TestNAVRegexParserAlternationGroupContext()
    TestNAVRegexParserGroupsIntegration()
    TestNAVRegexParserRecursionDepth()
    TestNAVRegexParserTransitionValidity()
    TestNAVRegexParserStateData()
    TestNAVRegexParserEpsilonClosure()
    TestNAVRegexParserTransitionCount()
    TestNAVRegexParserQuantifierOrder()
    TestNAVRegexParserCaptureGroups()
    TestNAVRegexParserGroupNumberingOrder()
    TestNAVRegexParserCharClassValidation()
    TestNAVRegexParserNfaCompleteness()
    TestNAVRegexParserBackreferences()
    TestNAVRegexParserPythonBackreferences()
    TestNAVRegexParserBackreferenceErrors()
    TestNAVRegexParserAnchors()
    TestNAVRegexParserAnchorErrors()
    TestNAVRegexParserAnchorCombinations()
    TestNAVRegexParserOctalEscapes()
    TestNAVRegexParserEscapeSequences()
    TestNAVRegexParserHexEscapes()
    TestNAVRegexParserLookarounds()
    TestNAVRegexParserNamedGroups()
    #END_IF

    #IF_DEFINED TESTING_REGEX_MATCHER
    TestNAVRegexMatcherBasic()
    TestNAVRegexMatcherMatchGlobal()
    TestNAVRegexMatcherAnchors()
    TestNAVRegexMatcherStringAnchors()
    TestNAVRegexMatcherWordBoundary()
    TestNAVRegexMatcherQuantifiers()
    TestNAVRegexMatcherBoundedQuantifiers()
    TestNAVRegexMatcherBoundedQuantifierGroups()
    TestNAVRegexMatcherCharClasses()
    TestNAVRegexMatcherEscapedChars()
    TestNAVRegexMatcherSpecialEscapes()
    TestNAVRegexMatcherSpecialEscapesInClasses()
    TestNAVRegexMatcherHexEscapes()
    TestNAVRegexMatcherOctalEscapes()
    TestNAVRegexMatcherGroups()
    TestNAVRegexMatcherNonCapturingGroups()
    TestNAVRegexMatcherNamedGroups()
    TestNAVRegexMatcherBackreference()
    TestNAVRegexMatcherNamedBackreference()
    TestNAVRegexMatcherPythonBackreferences()
    TestNAVRegexMatcherBackreferenceCaseInsensitive()
    TestNAVRegexMatcherLookaround()
    TestNAVRegexMatcherInlineFlags()
    TestNAVRegexMatcherGlobalFlagsMatchAll()
    TestNAVRegexMatcherGlobalFlagsMatch()
    TestNAVRegexMatcherGlobalMaxCount()
    TestNAVRegexMatcherMultilineLineEndings()
    TestNAVRegexMatcherLargeInput()
    TestNAVRegexMatcherMaxGroups()
    TestNAVRegexMatcherCharClassCaseInsensitive()
    TestNAVRegexApiTest()
    TestNAVRegexApiCompile()
    TestNAVRegexApiCompiled()
    TestNAVRegexApiCompiledReuse()
    TestNAVRegexApiCompiledGlobal()
    TestNAVRegexApiCompiledGlobalReuse()
    TestNAVRegexRealWorldPatterns()
    TestNAVRegexRealWorldProtocols()
    TestNAVRegexMatcherComplexEdgeCases()
    TestNAVRegexGetNamedGroupFromMatch()
    TestNAVRegexGetNamedGroupFromMatchCollection()
    TestNAVRegexGetNamedGroupTextFromMatch()
    TestNAVRegexGetNamedGroupTextFromMatchCollection()
    TestNAVRegexHasNamedGroupInMatch()
    TestNAVRegexHasNamedGroupInMatchCollection()
    TestNAVRegexSplit()
    TestNAVRegexSplitEmptyInput()
    TestNAVRegexSplitArrayTooSmall()
    TestNAVRegexTemplateParser()
    TestNAVRegexTemplateParserDetails()
    TestNAVRegexReplace()
    TestNAVRegexReplaceAll()
    TestNAVRegexReplaceEdgeCases()
    TestNAVRegexReplaceErrorHandling()
    TestNAVRegexSplitErrorHandling()
    #END_IF
}
