#DEFINE TESTING_NAVHASHTABLEINIT
#DEFINE TESTING_NAVHASHTABLEADDITEM
#DEFINE TESTING_NAVHASHTABLEGETITEMVALUE
#DEFINE TESTING_NAVHASHTABLEITEMREMOVE
#DEFINE TESTING_NAVHASHTABLECONTAINSKEY
#DEFINE TESTING_NAVHASHTABLECLEAR
#DEFINE TESTING_NAVHASHTABLECOLLISION
#DEFINE TESTING_NAVHASHTABLEPERFORMANCE
#DEFINE TESTING_NAVHASHTABLEBOUNDARY
#DEFINE TESTING_NAVHASHTABLEINTEGRITY
#DEFINE TESTING_NAVHASHTABLEREGRESSION
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.HashTable.axi'
#include 'NAVFoundation.HashTableUtils.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'


#IF_DEFINED TESTING_NAVHASHTABLEINIT
#include 'NAVHashTableInit.axi'
#END_IF

#IF_DEFINED TESTING_NAVHASHTABLEADDITEM
#include 'NAVHashTableAddItem.axi'
#END_IF

#IF_DEFINED TESTING_NAVHASHTABLEGETITEMVALUE
#include 'NAVHashTableGetItemValue.axi'
#END_IF

#IF_DEFINED TESTING_NAVHASHTABLEITEMREMOVE
#include 'NAVHashTableItemRemove.axi'
#END_IF

#IF_DEFINED TESTING_NAVHASHTABLECONTAINSKEY
#include 'NAVHashTableContainsKey.axi'
#END_IF

#IF_DEFINED TESTING_NAVHASHTABLECLEAR
#include 'NAVHashTableClear.axi'
#END_IF

#IF_DEFINED TESTING_NAVHASHTABLECOLLISION
#include 'NAVHashTableCollision.axi'
#END_IF

#IF_DEFINED TESTING_NAVHASHTABLEPERFORMANCE
#include 'NAVHashTablePerformance.axi'
#END_IF

#IF_DEFINED TESTING_NAVHASHTABLEBOUNDARY
#include 'NAVHashTableBoundary.axi'
#END_IF

#IF_DEFINED TESTING_NAVHASHTABLEINTEGRITY
#include 'NAVHashTableIntegrity.axi'
#END_IF

#IF_DEFINED TESTING_NAVHASHTABLEREGRESSION
#include 'NAVHashTableRegression.axi'
#END_IF


define_function RunHashTableTests() {
    #IF_DEFINED TESTING_NAVHASHTABLEINIT
    TestNAVHashTableInit()
    TestNAVHashTableInitialization()
    TestNAVHashTableInitialState()
    #END_IF

    #IF_DEFINED TESTING_NAVHASHTABLEADDITEM
    TestNAVHashTableAddItem()
    TestNAVHashTableAddItemValidation()
    TestNAVHashTableAddItemUpdate()
    TestNAVHashTableAddItemEmptyKey()
    #END_IF

    #IF_DEFINED TESTING_NAVHASHTABLEGETITEMVALUE
    TestNAVHashTableGetItemValue()
    TestNAVHashTableGetItemValueMultiple()
    TestNAVHashTableGetItemValueEmptyKey()
    TestNAVHashTableGetItemValueNotFound()
    #END_IF

    #IF_DEFINED TESTING_NAVHASHTABLEITEMREMOVE
    TestNAVHashTableItemRemove()
    TestNAVHashTableItemRemoveValidation()
    TestNAVHashTableItemRemoveVerification()
    TestNAVHashTableItemRemoveEmptyKey()
    TestNAVHashTableItemRemoveNotFound()
    #END_IF

    #IF_DEFINED TESTING_NAVHASHTABLECONTAINSKEY
    TestNAVHashTableContainsKey()
    TestNAVHashTableContainsKeyMultiple()
    TestNAVHashTableContainsKeyNotFound()
    TestNAVHashTableContainsKeyEmpty()
    TestNAVHashTableContainsKeyAfterRemoval()
    #END_IF

    #IF_DEFINED TESTING_NAVHASHTABLECLEAR
    TestNAVHashTableClear()
    TestNAVHashTableClearMultiple()
    TestNAVHashTableClearVerification()
    TestNAVHashTableClearEmpty()
    TestNAVHashTableClearAndReuse()
    #END_IF

    #IF_DEFINED TESTING_NAVHASHTABLECOLLISION
    TestNAVHashTableCollision()
    TestNAVHashTableCollisionMultiple()
    TestNAVHashTableCollisionRemoval()
    TestNAVHashTableCollisionDuplicateKey()
    TestNAVHashTableCollisionContains()
    #END_IF

    #IF_DEFINED TESTING_NAVHASHTABLEPERFORMANCE
    TestNAVHashTablePerformanceLarge()
    TestNAVHashTableStressOperations()
    TestNAVHashTableMemoryUsage()
    #END_IF

    #IF_DEFINED TESTING_NAVHASHTABLEBOUNDARY
    TestNAVHashTableLongKeys()
    TestNAVHashTableLongValues()
    TestNAVHashTableSpecialCharacters()
    TestNAVHashTableMaxCapacity()
    TestNAVHashTableNumericKeys()
    #END_IF

    #IF_DEFINED TESTING_NAVHASHTABLEINTEGRITY
    TestNAVHashTableDataPersistence()
    TestNAVHashTableHashDistribution()
    TestNAVHashTableCollisionRobustness()
    TestNAVHashTableConcurrentOperations()
    #END_IF

    #IF_DEFINED TESTING_NAVHASHTABLEREGRESSION
    TestNAVHashTableRegressionSlotValidation()
    TestNAVHashTableRegressionEmptyHandling()
    TestNAVHashTableErrorRecovery()
    TestNAVHashTablePartialOperations()
    TestNAVHashTableMultipleClearRegression()
    #END_IF
}
