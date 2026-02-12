PROGRAM_NAME='NAVXmlQuerySignedLongArray'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_QUERY_SLONG_ARRAY_TEST_XML[10][1024]
volatile char XML_QUERY_SLONG_ARRAY_TEST_QUERY[10][64]


define_function InitializeXmlQuerySignedLongArrayTestData() {
    // Test 1: Simple root array with mixed signs
    XML_QUERY_SLONG_ARRAY_TEST_XML[1] = '<items><item>-100000</item><item>200000</item><item>-300000</item></items>'
    XML_QUERY_SLONG_ARRAY_TEST_QUERY[1] = '.'

    // Test 2: Nested array property with negatives
    XML_QUERY_SLONG_ARRAY_TEST_XML[2] = '<root><balances><balance>-500000</balance><balance>1000000</balance><balance>-250000</balance></balances></root>'
    XML_QUERY_SLONG_ARRAY_TEST_QUERY[2] = '.balances'

    // Test 3: Deeply nested array
    XML_QUERY_SLONG_ARRAY_TEST_XML[3] = '<root><financial><deltas><delta>-1000000</delta><delta>-500000</delta><delta>0</delta></deltas></financial></root>'
    XML_QUERY_SLONG_ARRAY_TEST_QUERY[3] = '.financial.deltas'

    // Test 4: Array after index
    XML_QUERY_SLONG_ARRAY_TEST_XML[4] = '<root><group><item>-100000</item><item>-200000</item></group><group><item>-300000</item><item>-400000</item><item>-500000</item></group></root>'
    XML_QUERY_SLONG_ARRAY_TEST_QUERY[4] = '.group[2]'

    // Test 5: Array with zeros
    XML_QUERY_SLONG_ARRAY_TEST_XML[5] = '<data><net><value>0</value><value>0</value><value>0</value></net></data>'
    XML_QUERY_SLONG_ARRAY_TEST_QUERY[5] = '.net'

    // Test 6: Large negative values
    XML_QUERY_SLONG_ARRAY_TEST_XML[6] = '<data><losses><loss>-2000000000</loss><loss>-1000000000</loss></losses></data>'
    XML_QUERY_SLONG_ARRAY_TEST_QUERY[6] = '.losses'

    // Test 7: Extreme values
    XML_QUERY_SLONG_ARRAY_TEST_XML[7] = '<values><value>2147483647</value><value>-2147483648</value></values>'
    XML_QUERY_SLONG_ARRAY_TEST_QUERY[7] = '.'

    // Test 8: Empty array
    XML_QUERY_SLONG_ARRAY_TEST_XML[8] = '<empty></empty>'
    XML_QUERY_SLONG_ARRAY_TEST_QUERY[8] = '.'

    // Test 9: Single negative element
    XML_QUERY_SLONG_ARRAY_TEST_XML[9] = '<data><single><value>-10000000</value></single></data>'
    XML_QUERY_SLONG_ARRAY_TEST_QUERY[9] = '.single'

    // Test 10: Array property after array index
    XML_QUERY_SLONG_ARRAY_TEST_XML[10] = '<root><transactions><transaction><amounts><amount>-100000</amount><amount>-200000</amount></amounts></transaction><transaction><amounts><amount>-300000</amount><amount>-400000</amount></amounts></transaction></transactions></root>'
    XML_QUERY_SLONG_ARRAY_TEST_QUERY[10] = '.transactions.transaction[2].amounts'

    set_length_array(XML_QUERY_SLONG_ARRAY_TEST_XML, 10)
    set_length_array(XML_QUERY_SLONG_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer XML_QUERY_SLONG_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    3,  // Test 2
    3,  // Test 3
    3,  // Test 4
    3,  // Test 5
    2,  // Test 6
    2,  // Test 7
    0,  // Test 8 (empty)
    1,  // Test 9
    2   // Test 10
}


define_function TestNAVXmlQuerySignedLongArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlQuerySignedLongArray'")

    InitializeXmlQuerySignedLongArrayTestData()

    for (x = 1; x <= length_array(XML_QUERY_SLONG_ARRAY_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var slong result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVXmlParse(XML_QUERY_SLONG_ARRAY_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVXmlQuerySignedLongArray(xml, XML_QUERY_SLONG_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   XML_QUERY_SLONG_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(XML_QUERY_SLONG_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        // NOTE: NetLinx compiler quirk - SLONG literal negative values
        // The NetLinx compiler does not properly handle literal negative values
        // with SLONG type. To work around this, we initialize expected to 0 and
        // calculate negative values programmatically using subtraction.
        for (i = 1; i <= length_array(result); i++) {
            stack_var slong expected
            expected = 0

            switch (x) {
                case 1: {
                    switch (i) {
                        case 1: expected = expected - type_cast(100000)
                        case 2: expected = type_cast(200000)
                        case 3: expected = expected - type_cast(300000)
                    }
                }
                case 2: {
                    switch (i) {
                        case 1: expected = expected - type_cast(500000)
                        case 2: expected = type_cast(1000000)
                        case 3: expected = expected - type_cast(250000)
                    }
                }
                case 3: {
                    switch (i) {
                        case 1: expected = expected - type_cast(1000000)
                        case 2: expected = expected - type_cast(500000)
                        case 3: expected = 0
                    }
                }
                case 4: {
                    switch (i) {
                        case 1: expected = expected - type_cast(300000)
                        case 2: expected = expected - type_cast(400000)
                        case 3: expected = expected - type_cast(500000)
                    }
                }
                case 5: {
                    expected = 0  // All zeros
                }
                case 6: {
                    switch (i) {
                        case 1: expected = expected - type_cast(2000000000)
                        case 2: expected = expected - type_cast(1000000000)
                    }
                }
                case 7: {
                    switch (i) {
                        case 1: expected = type_cast(2147483647)
                        case 2: expected = expected - type_cast(2147483648)
                    }
                }
                case 8: {
                    // Empty array - no elements to check
                }
                case 9: {
                    expected = expected - type_cast(10000000)
                }
                case 10: {
                    switch (i) {
                        case 1: expected = expected - type_cast(300000)
                        case 2: expected = expected - type_cast(400000)
                    }
                }
            }

            if (!NAVAssertSignedLongEqual("'Array element ', itoa(i)",
                                         expected,
                                         result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', itoa(expected)",
                                "'Element ', itoa(i), ': ', itoa(result[i])")

                failed = true
                continue
            }
        }

        if (failed) {
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlQuerySignedLongArray'")
}
