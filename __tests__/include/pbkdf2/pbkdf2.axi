#DEFINE TESTING_NAVPBKDF2F
#DEFINE TESTING_NAVPBKDF2SHA1
#DEFINE TESTING_NAVPBKDF2GETRANDOMSALT
// #DEFINE TESTING_NAVPBKDF2BENCHMARKS  // Uncomment to run benchmarks (takes longer)
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Cryptography.Pbkdf2.axi'

// Include shared utilities for all PBKDF2 tests
#include 'NAVPbkdf2Shared.axi'

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

define_function RunPbkdf2Tests() {
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
