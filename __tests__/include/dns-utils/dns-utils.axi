// #DEFINE TESTING_NAVDNSDOMAINNAMECODEC
#DEFINE TESTING_NAVDNSHEADER
// #DEFINE TESTING_NAVDNSQUERY
// #DEFINE TESTING_NAVDNSRESPONSEPARSE
// #DEFINE TESTING_NAVDNSUTILITY
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.DnsUtils.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Testing.axi'
#include 'DnsUtilsShared.axi'

#IF_DEFINED TESTING_NAVDNSDOMAINNAMECODEC
#include 'NAVDnsDomainNameCodec.axi'
#END_IF

#IF_DEFINED TESTING_NAVDNSHEADER
#include 'NAVDnsHeader.axi'
#END_IF

#IF_DEFINED TESTING_NAVDNSQUERY
#include 'NAVDnsQuery.axi'
#END_IF

#IF_DEFINED TESTING_NAVDNSRESPONSEPARSE
#include 'NAVDnsResponseParse.axi'
#END_IF

#IF_DEFINED TESTING_NAVDNSUTILITY
#include 'NAVDnsUtility.axi'
#END_IF

define_function RunDnsUtilsTests() {
    #IF_DEFINED TESTING_NAVDNSDOMAINNAMECODEC
    TestNAVDnsDomainNameEncode()
    TestNAVDnsDomainNameEncodeInvalid()
    TestNAVDnsDomainNameDecodeSimple()
    TestNAVDnsDomainNameDecodeCompression()
    TestNAVDnsDomainNameRoundTrip()
    #END_IF

    #IF_DEFINED TESTING_NAVDNSHEADER
    TestNAVDnsHeaderInit()
    TestNAVDnsHeaderFlags()
    TestNAVDnsHeaderEncode()
    TestNAVDnsHeaderDecode()
    TestNAVDnsHeaderRoundTrip()
    #END_IF

    #IF_DEFINED TESTING_NAVDNSQUERY
    TestNAVDnsQueryInit()
    TestNAVDnsQueryAddQuestion()
    TestNAVDnsQueryAddMultipleQuestions()
    TestNAVDnsQueryBuild()
    TestNAVDnsQueryCreate()
    TestNAVDnsQueryAdditionalTypes()
    #END_IF

    #IF_DEFINED TESTING_NAVDNSRESPONSEPARSE
    TestNAVDnsResponseInit()
    TestNAVDnsResponseParseARecord()
    TestNAVDnsResponseParseAAAARecord()
    TestNAVDnsResponseParseCNAMERecord()
    TestNAVDnsResponseParseMXRecords()
    TestNAVDnsResponseParsePTRRecord()
    TestNAVDnsResponseParseErrors()
    TestNAVDnsResponseParseFullSections()
    #END_IF

    #IF_DEFINED TESTING_NAVDNSUTILITY
    TestNAVDnsValidateDomainNameValid()
    TestNAVDnsValidateDomainNameInvalid()
    TestNAVDnsTypeToString()
    TestNAVDnsClassToString()
    TestNAVDnsResponseCodeToString()
    TestNAVDnsGenerateTransactionId()
    TestNAVDnsResponseHasError()
    TestNAVDnsResponseGetFirstAnswer()
    TestNAVDnsIntegrationRoundTrip()
    TestNAVDnsValidationEdgeCases()
    TestNAVDnsTransactionIdMatching()
    #END_IF
}
