PROGRAM_NAME='pbkdf2'

#DEFINE __MAIN__
#DEFINE TESTING_NAVPBKDF2HMACSHA1
#DEFINE TESTING_NAVPBKDF2F
#DEFINE TESTING_NAVPBKDF2SHA1
#DEFINE TESTING_NAVPBKDF2GETRANDOMSALT
#DEFINE TESTING_NAVPBKDF2BENCHMARKS  // Uncomment to run benchmarks (takes longer)
// #DEFINE NAV_KDF_PRODUCTION_BENCHMARKS
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Pbkdf2.axi'

// Include shared utilities for all PBKDF2 tests
#include 'NAVPbkdf2Shared.axi'

// Include individual test files with updated names
#IF_DEFINED TESTING_NAVPBKDF2HMACSHA1
#include 'NAVPbkdf2HmacSha1.axi'
#END_IF

#IF_DEFINED TESTING_NAVPBKDF2F
#include 'NAVPbkdf2F.axi'
#END_IF

#IF_DEFINED TESTING_NAVPBKDF2SHA1
#include 'NAVPbkdf2Sha1.axi'
#END_IF

#IF_DEFINED TESTING_NAVPBKDF2GETRANDOMSALT
#include 'NAVPbkdf2GetRandomSalt.axi'
#END_IF

#IF_DEFINED TESTING_NAVPBKDF2BENCHMARKS
#include 'NAVPbkdf2Benchmarks.axi'
#END_IF


DEFINE_DEVICE

dvTP = 10001:1:0


define_function RunTests() {
    #IF_DEFINED TESTING_NAVPBKDF2HMACSHA1
    RunNAVPbkdf2HmacSha1Tests()
    #END_IF

    #IF_DEFINED TESTING_NAVPBKDF2F
    RunNAVPbkdf2FTests()
    #END_IF

    #IF_DEFINED TESTING_NAVPBKDF2SHA1
    RunNAVPbkdf2Sha1Tests()
    #END_IF

    #IF_DEFINED TESTING_NAVPBKDF2GETRANDOMSALT
    RunNAVPbkdf2GetRandomSaltTests()
    #END_IF

    #IF_DEFINED TESTING_NAVPBKDF2DERIVEAES128KEY
    RunNAVPbkdf2DeriveAes128KeyTests()
    #END_IF

    #IF_DEFINED TESTING_NAVPBKDF2BENCHMARKS
    RunNAVPbkdf2BenchmarkTests()
    #END_IF
}


DEFINE_EVENT

button_event[dvTP, 1] {
    push: {
        RunTests()
    }
}
