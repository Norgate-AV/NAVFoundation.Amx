#DEFINE TESTING_NAVAES128XTIME
#DEFINE TESTING_NAVAES128MULTIPLY
#DEFINE TESTING_NAVAES128MIXCOLUMNS
#DEFINE TESTING_NAVAES128SHIFTROWS
#DEFINE TESTING_NAVAES128SUBBYTES
#DEFINE TESTING_NAVAES128KEYEXPANSION
#DEFINE TESTING_NAVAES128ADDROUNDKEY
#DEFINE TESTING_NAVAES128STATETOBUFFER
#DEFINE TESTING_NAVAES128BUFFERTOSTATE
#DEFINE TESTING_NAVAES128PKCS7PAD
#DEFINE TESTING_NAVAES128PKCS7UNPAD
#DEFINE TESTING_NAVAES128CONTEXTINIT
#DEFINE TESTING_NAVAES128DERIVEKEY
#DEFINE TESTING_NAVAES128ECBENCRYPTBLOCK
#DEFINE TESTING_NAVAES128ECBENCRYPT
#DEFINE TESTING_NAVAES128INVSHIFTROWS
#DEFINE TESTING_NAVAES128INVSUBBYTES
#DEFINE TESTING_NAVAES128INVMIXCOLUMNS
#DEFINE TESTING_NAVAES128ECBDECRYPTBLOCK
#DEFINE TESTING_NAVAES128ECBDECRYPT
#DEFINE TESTING_NAVAES128ENDTOENDTESTS

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Encoding.axi'
#include 'NAVFoundation.Cryptography.Aes128.axi'
#include 'NAVAes128Shared.axi'

#IF_DEFINED TESTING_NAVAES128XTIME
#include 'NAVAes128XTime.axi'
#END_IF

#IF_DEFINED TESTING_NAVAES128MULTIPLY
#include 'NAVAes128Multiply.axi'
#END_IF

#IF_DEFINED TESTING_NAVAES128MIXCOLUMNS
#include 'NAVAes128MixColumns.axi'
#END_IF

#IF_DEFINED TESTING_NAVAES128SHIFTROWS
#include 'NAVAes128ShiftRows.axi'
#END_IF

#IF_DEFINED TESTING_NAVAES128SUBBYTES
#include 'NAVAes128SubBytes.axi'
#END_IF

#IF_DEFINED TESTING_NAVAES128KEYEXPANSION
#include 'NAVAes128KeyExpansion.axi'
#END_IF

#IF_DEFINED TESTING_NAVAES128ADDROUNDKEY
#include 'NAVAes128AddRoundKey.axi'
#END_IF

#IF_DEFINED TESTING_NAVAES128STATETOBUFFER
#include 'NAVAes128StateToBuffer.axi'
#END_IF

#IF_DEFINED TESTING_NAVAES128BUFFERTOSTATE
#include 'NAVAes128BufferToState.axi'
#END_IF

#IF_DEFINED TESTING_NAVAES128PKCS7PAD
#include 'NAVAes128PKCS7Pad.axi'
#END_IF

#IF_DEFINED TESTING_NAVAES128PKCS7UNPAD
#include 'NAVAes128PKCS7Unpad.axi'
#END_IF

#IF_DEFINED TESTING_NAVAES128CONTEXTINIT
#include 'NAVAes128ContextInit.axi'
#END_IF

#IF_DEFINED TESTING_NAVAES128DERIVEKEY
#include 'NAVAes128DeriveKey.axi'
#END_IF

#IF_DEFINED TESTING_NAVAES128ECBENCRYPTBLOCK
#include 'NAVAes128ECBEncryptBlock.axi'
#END_IF

#IF_DEFINED TESTING_NAVAES128ECBENCRYPT
#include 'NAVAes128ECBEncrypt.axi'
#END_IF

// Add the new inverse operation tests
#IF_DEFINED TESTING_NAVAES128INVSHIFTROWS
#include 'NAVAes128InvShiftRows.axi'
#END_IF

#IF_DEFINED TESTING_NAVAES128INVSUBBYTES
#include 'NAVAes128InvSubBytes.axi'
#END_IF

#IF_DEFINED TESTING_NAVAES128INVMIXCOLUMNS
#include 'NAVAes128InvMixColumns.axi'
#END_IF

#IF_DEFINED TESTING_NAVAES128DECRYPT
#include 'NAVAes128Decrypt.axi'
#END_IF

#IF_DEFINED TESTING_NAVAES128ECBDECRYPTBLOCK
#include 'NAVAes128ECBDecryptBlock.axi'
#END_IF

#IF_DEFINED TESTING_NAVAES128ECBDECRYPT
#include 'NAVAes128ECBDecrypt.axi'
#END_IF

#IF_DEFINED TESTING_NAVAES128ENDTOENDTESTS
#include 'NAVAes128EndToEndTests.axi'
#END_IF


define_function RunAes128Tests() {
    #IF_DEFINED TESTING_NAVAES128XTIME
    RunNAVAes128XTimeTests()
    #END_IF

    #IF_DEFINED TESTING_NAVAES128MULTIPLY
    RunNAVAes128MultiplyTests()
    #END_IF

    #IF_DEFINED TESTING_NAVAES128MIXCOLUMNS
    RunNAVAes128MixColumnsTests()
    #END_IF

    #IF_DEFINED TESTING_NAVAES128SHIFTROWS
    RunNAVAes128ShiftRowsTests()
    #END_IF

    #IF_DEFINED TESTING_NAVAES128SUBBYTES
    RunNAVAes128SubBytesTests()
    #END_IF

    #IF_DEFINED TESTING_NAVAES128KEYEXPANSION
    RunNAVAes128KeyExpansionTests()
    #END_IF

    #IF_DEFINED TESTING_NAVAES128ADDROUNDKEY
    RunNAVAes128AddRoundKeyTests()
    #END_IF

    #IF_DEFINED TESTING_NAVAES128STATETOBUFFER
    RunNAVAes128StateToBufferTests()
    #END_IF

    #IF_DEFINED TESTING_NAVAES128BUFFERTOSTATE
    RunNAVAes128BufferToStateTests()
    #END_IF

    #IF_DEFINED TESTING_NAVAES128PKCS7PAD
    RunNAVAes128PKCS7PadTests()
    #END_IF

    #IF_DEFINED TESTING_NAVAES128PKCS7UNPAD
    RunNAVAes128PKCS7UnpadTests()
    #END_IF

    #IF_DEFINED TESTING_NAVAES128CONTEXTINIT
    RunNAVAes128ContextInitTests()
    #END_IF

    #IF_DEFINED TESTING_NAVAES128DERIVEKEY
    RunNAVAes128DeriveKeyTests()
    #END_IF

    // Add the new inverse operation test runners
    #IF_DEFINED TESTING_NAVAES128INVSHIFTROWS
    RunNAVAes128InvShiftRowsTests()
    #END_IF

    #IF_DEFINED TESTING_NAVAES128INVSUBBYTES
    RunNAVAes128InvSubBytesTests()
    #END_IF

    #IF_DEFINED TESTING_NAVAES128INVMIXCOLUMNS
    RunNAVAes128InvMixColumnsTests()
    #END_IF

    #IF_DEFINED TESTING_NAVAES128ECBENCRYPTBLOCK
    RunNAVAes128ECBEncryptBlockTests()
    #END_IF

    #IF_DEFINED TESTING_NAVAES128ECBENCRYPT
    RunNAVAes128ECBEncryptTests()
    #END_IF

    #IF_DEFINED TESTING_NAVAES128DECRYPT
    RunNAVAes128DecryptTests()
    #END_IF

    #IF_DEFINED TESTING_NAVAES128ECBDECRYPTBLOCK
    RunNAVAes128ECBDecryptBlockTests()
    #END_IF

    #IF_DEFINED TESTING_NAVAES128ECBDECRYPT
    RunNAVAes128ECBDecryptTests()
    #END_IF

    #IF_DEFINED TESTING_NAVAES128ENDTOENDTESTS
    RunNAVAes128EndToEndTests()
    #END_IF
}
