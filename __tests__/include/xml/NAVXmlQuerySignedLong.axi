PROGRAM_NAME='NAVXmlQuerySignedLong'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_QUERY_SLONG_TEST_XML[10][512]
volatile char XML_QUERY_SLONG_TEST_QUERY[10][64]


define_function InitializeXmlQuerySignedLongTestData() {
    // Test 1: Positive value
    XML_QUERY_SLONG_TEST_XML[1] = '<value>1000000</value>'
    XML_QUERY_SLONG_TEST_QUERY[1] = '.'

    // Test 2: Negative value
    XML_QUERY_SLONG_TEST_XML[2] = '<data><balance>-500000</balance></data>'
    XML_QUERY_SLONG_TEST_QUERY[2] = '.balance'

    // Test 3: Nested negative value
    XML_QUERY_SLONG_TEST_XML[3] = '<root><account><deficit>-1000000</deficit></account></root>'
    XML_QUERY_SLONG_TEST_QUERY[3] = '.account.deficit'

    // Test 4: Element by index with negative
    XML_QUERY_SLONG_TEST_XML[4] = '<items><item>-100000</item><item>-200000</item><item>-300000</item></items>'
    XML_QUERY_SLONG_TEST_QUERY[4] = '.item[2]'

    // Test 5: Element in indexed parent with negative
    XML_QUERY_SLONG_TEST_XML[5] = '<root><data><offset>-50000</offset></data><data><offset>-100000</offset></data><data><offset>-150000</offset></data></root>'
    XML_QUERY_SLONG_TEST_QUERY[5] = '.data[3].offset'

    // Test 6: Deeply nested negative
    XML_QUERY_SLONG_TEST_XML[6] = '<root><financial><data><loss>-2000000</loss></data></financial></root>'
    XML_QUERY_SLONG_TEST_QUERY[6] = '.financial.data.loss'

    // Test 7: Zero value
    XML_QUERY_SLONG_TEST_XML[7] = '<data><net>0</net></data>'
    XML_QUERY_SLONG_TEST_QUERY[7] = '.net'

    // Test 8: Maximum positive value
    XML_QUERY_SLONG_TEST_XML[8] = '<data><maxValue>2147483647</maxValue></data>'
    XML_QUERY_SLONG_TEST_QUERY[8] = '.maxValue'

    // Test 9: Maximum negative value
    XML_QUERY_SLONG_TEST_XML[9] = '<data><minValue>-2147483648</minValue></data>'
    XML_QUERY_SLONG_TEST_QUERY[9] = '.minValue'

    // Test 10: Property after array index
    XML_QUERY_SLONG_TEST_XML[10] = '<root><transactions><transaction><amount>-12345</amount></transaction><transaction><amount>67890</amount></transaction></transactions></root>'
    XML_QUERY_SLONG_TEST_QUERY[10] = '.transactions.transaction[1].amount'

    set_length_array(XML_QUERY_SLONG_TEST_XML, 10)
    set_length_array(XML_QUERY_SLONG_TEST_QUERY, 10)
}


define_function TestNAVXmlQuerySignedLong() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlQuerySignedLong'")

    InitializeXmlQuerySignedLongTestData()

    for (x = 1; x <= length_array(XML_QUERY_SLONG_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var slong result
        stack_var slong expected

        if (!NAVXmlParse(XML_QUERY_SLONG_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVXmlQuerySignedLong(xml, XML_QUERY_SLONG_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        // NOTE: NetLinx compiler quirk - SLONG literal negative values
        // The NetLinx compiler does not properly handle literal negative values
        // with SLONG type (e.g., expected = -1000). This causes type conversion
        // warnings and incorrect values. To work around this, we initialize
        // expected to 0 and calculate negative values programmatically using
        // subtraction (e.g., expected = 0 - 1000 or expected - type_cast(1000)).
        expected = 0

        switch (x) {
            case 1: expected = type_cast(1000000)          // Test 1: Positive value
            case 2: expected = expected - type_cast(500000) // Test 2: Negative value
            case 3: expected = expected - type_cast(1000000) // Test 3: Nested negative
            case 4: expected = expected - type_cast(200000) // Test 4: Element by index
            case 5: expected = expected - type_cast(150000) // Test 5: Element in indexed parent
            case 6: expected = expected - type_cast(2000000) // Test 6: Deeply nested
            case 7: expected = 0                           // Test 7: Zero value
            case 8: expected = type_cast(2147483647)       // Test 8: Max positive
            case 9: expected = expected - type_cast(2147483648) // Test 9: Max negative
            case 10: expected = expected - type_cast(12345) // Test 10: Property after array
        }

        if (!NAVAssertSignedLongEqual('NAVXmlQuerySignedLong value',
                                      expected,
                                      result)) {
            NAVLogTestFailed(x,
                            itoa(expected),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlQuerySignedLong'")
}
