#DEFINE TESTING_NAVPARSEURL
#DEFINE TESTING_NAVURLENCODEDECODE
#DEFINE TESTING_NAVURLCASENORMALIZATION
#DEFINE TESTING_NAVURLPATHNORMALIZATION
#DEFINE TESTING_NAVURLREFERENCERESOLUTION
#DEFINE TESTING_NAVURLPERCENTENCODINGNORMALIZATION
#DEFINE TESTING_NAVURLVALIDATION
#DEFINE TESTING_NAVPARSEURLMALFORMEDDIAGNOSTIC
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Url.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_NAVPARSEURL
#include 'NAVParseUrl.axi'
#END_IF

#IF_DEFINED TESTING_NAVPARSEURLMALFORMEDDIAGNOSTIC
#include 'NAVParseUrlMalformedDiagnostic.axi'
#END_IF

#IF_DEFINED TESTING_NAVURLENCODEDECODE
#include 'NAVUrlEncodeDecode.axi'
#END_IF

#IF_DEFINED TESTING_NAVURLCASENORMALIZATION
#include 'NAVUrlCaseNormalization.axi'
#END_IF

#IF_DEFINED TESTING_NAVURLPATHNORMALIZATION
#include 'NAVUrlPathNormalization.axi'
#END_IF

#IF_DEFINED TESTING_NAVURLREFERENCERESOLUTION
#include 'NAVUrlReferenceResolution.axi'
#END_IF

#IF_DEFINED TESTING_NAVURLPERCENTENCODINGNORMALIZATION
#include 'NAVUrlPercentEncodingNormalization.axi'
#END_IF

#IF_DEFINED TESTING_NAVURLVALIDATION
#include 'NAVUrlValidation.axi'
#END_IF

define_function RunUrlTests() {
    #IF_DEFINED TESTING_NAVURLENCODEDECODE
    TestNAVUrlEncode()
    TestNAVUrlDecode()
    TestNAVUrlRoundTrip()
    #END_IF

    #IF_DEFINED TESTING_NAVURLCASENORMALIZATION
    TestNAVUrlCaseNormalization()
    TestNAVUrlCaseNormalizationIPv6()
    TestNAVUrlPathCaseSensitivity()
    #END_IF

    #IF_DEFINED TESTING_NAVURLPATHNORMALIZATION
    TestNAVUrlPathNormalization()
    TestNAVUrlNormalizePathFunction()
    #END_IF

    #IF_DEFINED TESTING_NAVPARSEURL
    TestNAVParseUrl()
    TestNAVBuildUrlWithUserInfo()
    TestNAVUrlGetDefaultPort()
    #END_IF

    #IF_DEFINED TESTING_NAVPARSEURLMALFORMEDDIAGNOSTIC
    TestMalformedUrlDiagnostic()
    #END_IF

    #IF_DEFINED TESTING_NAVURLREFERENCERESOLUTION
    TestNAVResolveUrl()
    #END_IF

    #IF_DEFINED TESTING_NAVURLPERCENTENCODINGNORMALIZATION
    TestNAVUrlNormalizePercentEncoding()
    #END_IF

    #IF_DEFINED TESTING_NAVURLVALIDATION
    // Test invalid URLs (should be rejected)
    TestNAVParseUrlValidation_Invalid()

    // Test valid URLs (should be accepted)
    TestNAVParseUrlValidation_Valid()

    // Test helper functions
    TestNAVUrlIsValidPort()
    TestNAVUrlIsValidScheme()
    TestNAVUrlHasInvalidCharacters()
    #END_IF
}
