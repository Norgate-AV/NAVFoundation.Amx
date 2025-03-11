PROGRAM_NAME='all'

#DEFINE __MAIN__
#DEFINE TESTING_AES128
#DEFINE TESTING_SHA1
#DEFINE TESTING_SHA256
#DEFINE TESTING_SHA512
#DEFINE TESTING_MD5
#DEFINE TESTING_BASE64
#DEFINE TESTING_BASE32
#DEFINE TESTING_INT64
#DEFINE TESTING_PBKDF2
#DEFINE TESTING_ASSERT
#DEFINE TESTING_HTTP
#DEFINE TESTING_JSMN
#DEFINE TESTING_PATH_UTILS
#DEFINE TESTING_STRING_UTILS
#DEFINE TESTING_URL
// #DEFINE TESTING_REGEX

#include 'NAVFoundation.Core.axi'

#IF_DEFINED TESTING_AES128
#include 'aes128.axi'
#END_IF

#IF_DEFINED TESTING_SHA1
#include 'sha1.axi'
#END_IF

#IF_DEFINED TESTING_SHA256
#include 'sha256.axi'
#END_IF

#IF_DEFINED TESTING_SHA512
#include 'sha512.axi'
#END_IF

#IF_DEFINED TESTING_MD5
#include 'md5.axi'
#END_IF

#IF_DEFINED TESTING_BASE64
#include 'base64.axi'
#END_IF

#IF_DEFINED TESTING_BASE32
#include 'base32.axi'
#END_IF

#IF_DEFINED TESTING_INT64
#include 'int64.axi'
#END_IF

#IF_DEFINED TESTING_PBKDF2
#include 'pbkdf2.axi'
#END_IF

#IF_DEFINED TESTING_ASSERT
#include 'assert.axi'
#END_IF

#IF_DEFINED TESTING_HTTP
#include 'http.axi'
#END_IF

#IF_DEFINED TESTING_JSMN
#include 'jsmn.axi'
#END_IF

#IF_DEFINED TESTING_PATH_UTILS
#include 'path-utils.axi'
#END_IF

#IF_DEFINED TESTING_STRING_UTILS
#include 'string-utils.axi'
#END_IF

#IF_DEFINED TESTING_URL
#include 'url.axi'
#END_IF

#IF_DEFINED TESTING_REGEX
#include 'regex.axi'
#END_IF

DEFINE_DEVICE

dvTP    =   10001:1:0


define_function RunAllTests() {
    #IF_DEFINED TESTING_AES128
    NAVLog("'***************** NAV AES128 *****************'")
    RunAes128Tests()
    #END_IF

    #IF_DEFINED TESTING_SHA1
    NAVLog("'***************** NAV SHA1 *****************'")
    RunSha1Tests()
    #END_IF

    #IF_DEFINED TESTING_SHA256
    NAVLog("'***************** NAV SHA256 *****************'")
    RunSha256Tests()
    #END_IF

    #IF_DEFINED TESTING_SHA512
    NAVLog("'***************** NAV SHA512 *****************'")
    RunSha512Tests()
    #END_IF

    #IF_DEFINED TESTING_MD5
    NAVLog("'***************** NAV MD5 *****************'")
    RunMd5Tests()
    #END_IF

    #IF_DEFINED TESTING_BASE64
    NAVLog("'***************** NAV BASE64 *****************'")
    RunBase64Tests()
    #END_IF

    #IF_DEFINED TESTING_BASE32
    NAVLog("'***************** NAV BASE32 *****************'")
    RunBase32Tests()
    #END_IF

    #IF_DEFINED TESTING_INT64
    NAVLog("'***************** NAV INT64 *****************'")
    RunInt64Tests()
    #END_IF

    #IF_DEFINED TESTING_PBKDF2
    NAVLog("'***************** NAV PBKDF2 *****************'")
    RunPbkdf2Tests()
    #END_IF

    #IF_DEFINED TESTING_ASSERT
    NAVLog("'***************** NAV ASSERT *****************'")
    RunAssertTests()
    #END_IF

    #IF_DEFINED TESTING_HTTP
    NAVLog("'***************** NAV HTTP *****************'")
    RunHttpTests()
    #END_IF

    #IF_DEFINED TESTING_JSMN
    NAVLog("'***************** NAV JSMN *****************'")
    RunJsmnTests()
    #END_IF

    #IF_DEFINED TESTING_PATH_UTILS
    NAVLog("'***************** NAV PATH UTILS *****************'")
    RunPathUtilsTests()
    #END_IF

    #IF_DEFINED TESTING_STRING_UTILS
    NAVLog("'***************** NAV STRING UTILS *****************'")
    RunStringUtilsTests()
    #END_IF

    #IF_DEFINED TESTING_URL
    NAVLog("'***************** NAV URL *****************'")
    RunUrlTests()
    #END_IF

    #IF_DEFINED TESTING_REGEX
    NAVLog("'***************** NAV REGEX *****************'")
    RunRegexTests()
    #END_IF
}


DEFINE_EVENT

button_event[dvTP, 1] {
    push: {
        set_log_level(NAV_LOG_LEVEL_DEBUG)
        RunAllTests()
    }
}
