#DEFINE TESTING_NAVHTTPREQUESTINIT
#DEFINE TESTING_NAVHTTPBUILDREQUEST
#DEFINE TESTING_NAVHTTPREQUESTHEADERS
#DEFINE TESTING_NAVHTTPRESPONSEPARSE
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.HttpUtils.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVHttpTestShared.axi'

#IF_DEFINED TESTING_NAVHTTPREQUESTINIT
#include 'NAVHttpRequestInit.axi'
#END_IF

#IF_DEFINED TESTING_NAVHTTPBUILDREQUEST
#include 'NAVHttpBuildRequest.axi'
#END_IF

#IF_DEFINED TESTING_NAVHTTPREQUESTHEADERS
#include 'NAVHttpRequestHeaders.axi'
#END_IF

#IF_DEFINED TESTING_NAVHTTPRESPONSEPARSE
#include 'NAVHttpResponseParse.axi'
#END_IF

define_function RunHttpUtilsTests() {
    #IF_DEFINED TESTING_NAVHTTPREQUESTINIT
    TestNAVHttpRequestInit()
    #END_IF

    #IF_DEFINED TESTING_NAVHTTPBUILDREQUEST
    TestNAVHttpBuildRequest()
    #END_IF

    #IF_DEFINED TESTING_NAVHTTPREQUESTHEADERS
    TestNAVHttpRequestAddHeader()
    TestNAVHttpRequestUpdateHeader()
    TestNAVHttpHeaderHelpers()
    TestNAVHttpResponseAddHeader()
    TestNAVHttpResponseUpdateHeader()
    TestNAVHttpHeaderEdgeCases()
    TestNAVHttpHeaderValidation()
    #END_IF

    #IF_DEFINED TESTING_NAVHTTPRESPONSEPARSE
    TestNAVHttpParseResponse()
    TestNAVHttpParseStatusLine()
    TestNAVHttpParseHeaders()
    #END_IF
}
