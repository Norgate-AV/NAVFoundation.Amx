PROGRAM_NAME='NAVXmlQueryFloatArray'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_QUERY_FLOAT_ARRAY_TEST_XML[10][1024]
volatile char XML_QUERY_FLOAT_ARRAY_TEST_QUERY[10][64]


define_function InitializeXmlQueryFloatArrayTestData() {
    // Test 1: Simple root array
    XML_QUERY_FLOAT_ARRAY_TEST_XML[1] = '<items><item>1.5</item><item>2.5</item><item>3.5</item></items>'
    XML_QUERY_FLOAT_ARRAY_TEST_QUERY[1] = '.'

    // Test 2: Nested array property
    XML_QUERY_FLOAT_ARRAY_TEST_XML[2] = '<root><temperatures><temperature>20.5</temperature><temperature>21.3</temperature><temperature>19.8</temperature></temperatures></root>'
    XML_QUERY_FLOAT_ARRAY_TEST_QUERY[2] = '.temperatures'

    // Test 3: Deeply nested array
    XML_QUERY_FLOAT_ARRAY_TEST_XML[3] = '<root><data><values><value>10.1</value><value>20.2</value><value>30.3</value></values></data></root>'
    XML_QUERY_FLOAT_ARRAY_TEST_QUERY[3] = '.data.values'

    // Test 4: Array after index
    XML_QUERY_FLOAT_ARRAY_TEST_XML[4] = '<root><group><item>1.1</item><item>2.2</item></group><group><item>3.3</item><item>4.4</item><item>5.5</item></group></root>'
    XML_QUERY_FLOAT_ARRAY_TEST_QUERY[4] = '.group[2]'

    // Test 5: Array with zeros
    XML_QUERY_FLOAT_ARRAY_TEST_XML[5] = '<data><readings><reading>0.0</reading><reading>0.0</reading><reading>0.0</reading></readings></data>'
    XML_QUERY_FLOAT_ARRAY_TEST_QUERY[5] = '.readings'

    // Test 6: Array with negatives
    XML_QUERY_FLOAT_ARRAY_TEST_XML[6] = '<data><offsets><offset>-1.5</offset><offset>-2.5</offset><offset>-3.5</offset></offsets></data>'
    XML_QUERY_FLOAT_ARRAY_TEST_QUERY[6] = '.offsets'

    // Test 7: Large precision values
    XML_QUERY_FLOAT_ARRAY_TEST_XML[7] = '<values><value>123.456789</value><value>987.654321</value></values>'
    XML_QUERY_FLOAT_ARRAY_TEST_QUERY[7] = '.'

    // Test 8: Empty array
    XML_QUERY_FLOAT_ARRAY_TEST_XML[8] = '<empty></empty>'
    XML_QUERY_FLOAT_ARRAY_TEST_QUERY[8] = '.'

    // Test 9: Single element array
    XML_QUERY_FLOAT_ARRAY_TEST_XML[9] = '<data><single><value>42.42</value></single></data>'
    XML_QUERY_FLOAT_ARRAY_TEST_QUERY[9] = '.single'

    // Test 10: Array property after array index
    XML_QUERY_FLOAT_ARRAY_TEST_XML[10] = '<root><groups><group><vals><val>1.1</val><val>2.2</val></vals></group><group><vals><val>3.3</val><val>4.4</val></vals></group></groups></root>'
    XML_QUERY_FLOAT_ARRAY_TEST_QUERY[10] = '.groups.group[2].vals'

    set_length_array(XML_QUERY_FLOAT_ARRAY_TEST_XML, 10)
    set_length_array(XML_QUERY_FLOAT_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer XML_QUERY_FLOAT_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    3,  // Test 2
    3,  // Test 3
    3,  // Test 4
    3,  // Test 5
    3,  // Test 6
    2,  // Test 7
    0,  // Test 8 (empty)
    1,  // Test 9
    2   // Test 10
}

constant float XML_QUERY_FLOAT_ARRAY_EXPECTED[10][5] = {
    {1.5, 2.5, 3.5},                    // Test 1
    {20.5, 21.3, 19.8},                 // Test 2
    {10.1, 20.2, 30.3},                 // Test 3
    {3.3, 4.4, 5.5},                    // Test 4
    {0.0, 0.0, 0.0},                    // Test 5
    {-1.5, -2.5, -3.5},                 // Test 6
    {123.456789, 987.654321},           // Test 7
    {0.0},                              // Test 8 (empty)
    {42.42},                            // Test 9
    {3.3, 4.4}                          // Test 10
}


define_function TestNAVXmlQueryFloatArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlQueryFloatArray'")

    InitializeXmlQueryFloatArrayTestData()

    for (x = 1; x <= length_array(XML_QUERY_FLOAT_ARRAY_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var float result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVXmlParse(XML_QUERY_FLOAT_ARRAY_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVXmlQueryFloatArray(xml, XML_QUERY_FLOAT_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   XML_QUERY_FLOAT_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(XML_QUERY_FLOAT_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertFloatAlmostEqual("'Array element ', itoa(i)",
                                          XML_QUERY_FLOAT_ARRAY_EXPECTED[x][i],
                                          result[i],
                                          0.000001)) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', ftoa(XML_QUERY_FLOAT_ARRAY_EXPECTED[x][i])",
                                "'Element ', itoa(i), ': ', ftoa(result[i])")
                failed = true
                continue
            }
        }

        if (failed) {
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlQueryFloatArray'")
}
