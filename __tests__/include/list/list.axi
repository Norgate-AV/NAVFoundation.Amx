#DEFINE TESTING_NAVLISTINIT
#DEFINE TESTING_NAVLISTADD
#DEFINE TESTING_NAVLISTINSERT
#DEFINE TESTING_NAVLISTREMOVE
#DEFINE TESTING_NAVLISTACCESS
#DEFINE TESTING_NAVLISTQUERY
#DEFINE TESTING_NAVLISTCONVERSION
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.List.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_NAVLISTINIT
#include 'NAVListInit.axi'
#END_IF

#IF_DEFINED TESTING_NAVLISTADD
#include 'NAVListAdd.axi'
#END_IF

#IF_DEFINED TESTING_NAVLISTINSERT
#include 'NAVListInsert.axi'
#END_IF

#IF_DEFINED TESTING_NAVLISTREMOVE
#include 'NAVListRemove.axi'
#END_IF

#IF_DEFINED TESTING_NAVLISTACCESS
#include 'NAVListAccess.axi'
#END_IF

#IF_DEFINED TESTING_NAVLISTQUERY
#include 'NAVListQuery.axi'
#END_IF

#IF_DEFINED TESTING_NAVLISTCONVERSION
#include 'NAVListConversion.axi'
#END_IF


define_function RunListTests() {
    #IF_DEFINED TESTING_NAVLISTINIT
    TestNAVListInit()
    #END_IF

    #IF_DEFINED TESTING_NAVLISTADD
    TestNAVListAdd()
    #END_IF

    #IF_DEFINED TESTING_NAVLISTINSERT
    TestNAVListInsert()
    #END_IF

    #IF_DEFINED TESTING_NAVLISTREMOVE
    TestNAVListRemove()
    TestNAVListRemoveItem()
    #END_IF

    #IF_DEFINED TESTING_NAVLISTACCESS
    TestNAVListGet()
    TestNAVListSet()
    TestNAVListFirst()
    TestNAVListLast()
    TestNAVListPop()
    #END_IF

    #IF_DEFINED TESTING_NAVLISTQUERY
    TestNAVListSize()
    TestNAVListCapacity()
    TestNAVListIsEmpty()
    TestNAVListIsFull()
    TestNAVListContains()
    TestNAVListIndexOf()
    #END_IF

    #IF_DEFINED TESTING_NAVLISTCONVERSION
    TestNAVListClear()
    TestNAVListToArray()
    TestNAVListFromArray()
    #END_IF
}
