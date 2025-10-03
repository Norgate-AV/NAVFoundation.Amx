#DEFINE TESTING_NAVENCODINGBYTEORDER
#DEFINE TESTING_NAVENCODINGBYTEARRAY
#DEFINE TESTING_NAVENCODINGHEXSTRING
#DEFINE TESTING_NAVENCODINGINTEGRATION
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Encoding.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_NAVENCODINGBYTEORDER
#include 'NAVEncodingByteOrder.axi'
#END_IF

#IF_DEFINED TESTING_NAVENCODINGBYTEARRAY
#include 'NAVEncodingByteArray.axi'
#END_IF

#IF_DEFINED TESTING_NAVENCODINGHEXSTRING
#include 'NAVEncodingHexString.axi'
#END_IF

#IF_DEFINED TESTING_NAVENCODINGINTEGRATION
#include 'NAVEncodingIntegration.axi'
#END_IF

define_function RunEncodingTests() {
    NAVLog("'======================== Encoding Tests ========================'")

    // Byte order conversion tests
    #IF_DEFINED TESTING_NAVENCODINGBYTEORDER
    TestNAVNetworkToHostLong()
    TestNAVHostToNetworkShort()
    TestNAVToLittleEndian()
    TestNAVToBigEndian()
    TestByteOrderReversibility()
    #END_IF

    // Byte array conversion tests
    #IF_DEFINED TESTING_NAVENCODINGBYTEARRAY
    TestNAVIntegerToByteArrayLE()
    TestNAVIntegerToByteArrayBE()
    TestNAVIntegerToByteArray()
    TestNAVLongToByteArrayLE()
    TestNAVLongToByteArrayBE()
    TestNAVLongToByteArray()
    TestNAVCharToLong()
    TestNAVCharToLongPartial()
    TestMaximumValues()
    #END_IF

    // Hex string conversion tests
    #IF_DEFINED TESTING_NAVENCODINGHEXSTRING
    TestNAVByteArrayToHexString()
    TestNAVHexToString()
    TestNAVByteArrayToNetLinxHexString()
    TestNAVByteArrayToCStyleHexString()
    TestNAVByteArrayToHexStringWithOptions()
    TestNAVByteToHexString()
    TestHexStringFormattingVariety()
    #END_IF

    // Integration tests
    #IF_DEFINED TESTING_NAVENCODINGINTEGRATION
    TestRoundTripIntegerConversion()
    TestRoundTripLongConversion()
    TestByteOrderWithArrayConversion()
    TestFullEncodingWorkflow()
    TestCharToLongWithByteArrays()
    TestMultipleFormatConversions()
    TestEndiannessConsistency()
    #END_IF
}

