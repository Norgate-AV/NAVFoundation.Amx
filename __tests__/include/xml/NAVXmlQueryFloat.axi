PROGRAM_NAME='NAVXmlQueryFloat'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_QUERY_FLOAT_TEST_XML[10][512]
volatile char XML_QUERY_FLOAT_TEST_QUERY[10][64]


define_function InitializeXmlQueryFloatTestData() {
    // Test 1: Simple root number
    XML_QUERY_FLOAT_TEST_XML[1] = '<value>42.5</value>'
    XML_QUERY_FLOAT_TEST_QUERY[1] = '.'

    // Test 2: Element property
    XML_QUERY_FLOAT_TEST_XML[2] = '<product><price>19.99</price></product>'
    XML_QUERY_FLOAT_TEST_QUERY[2] = '.price'

    // Test 3: Nested element property
    XML_QUERY_FLOAT_TEST_XML[3] = '<root><product><cost>99.95</cost></product></root>'
    XML_QUERY_FLOAT_TEST_QUERY[3] = '.product.cost'

    // Test 4: Element by index
    XML_QUERY_FLOAT_TEST_XML[4] = '<items><item>10.5</item><item>20.25</item><item>30.75</item></items>'
    XML_QUERY_FLOAT_TEST_QUERY[4] = '.item[2]'

    // Test 5: Element in indexed parent
    XML_QUERY_FLOAT_TEST_XML[5] = '<root><data><value>1.1</value></data><data><value>2.2</value></data><data><value>3.3</value></data></root>'
    XML_QUERY_FLOAT_TEST_QUERY[5] = '.data[3].value'

    // Test 6: Deeply nested property
    XML_QUERY_FLOAT_TEST_XML[6] = '<root><data><readings><temperature>23.5</temperature></readings></data></root>'
    XML_QUERY_FLOAT_TEST_QUERY[6] = '.data.readings.temperature'

    // Test 7: Zero value
    XML_QUERY_FLOAT_TEST_XML[7] = '<data><count>0.0</count></data>'
    XML_QUERY_FLOAT_TEST_QUERY[7] = '.count'

    // Test 8: Negative value
    XML_QUERY_FLOAT_TEST_XML[8] = '<weather><temperature>-15.5</temperature></weather>'
    XML_QUERY_FLOAT_TEST_QUERY[8] = '.temperature'

    // Test 9: Large value
    XML_QUERY_FLOAT_TEST_XML[9] = '<measurement><distance>12345.6789</distance></measurement>'
    XML_QUERY_FLOAT_TEST_QUERY[9] = '.distance'

    // Test 10: Property after array index
    XML_QUERY_FLOAT_TEST_XML[10] = '<root><items><item><weight>1.5</weight></item><item><weight>2.7</weight></item></items></root>'
    XML_QUERY_FLOAT_TEST_QUERY[10] = '.items.item[1].weight'

    set_length_array(XML_QUERY_FLOAT_TEST_XML, 10)
    set_length_array(XML_QUERY_FLOAT_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant float XML_QUERY_FLOAT_EXPECTED[10] = {
    42.5,      // Test 1
    19.99,     // Test 2
    99.95,     // Test 3
    20.25,     // Test 4
    3.3,       // Test 5
    23.5,      // Test 6
    0.0,       // Test 7
    -15.5,     // Test 8
    12345.6789,// Test 9
    1.5        // Test 10
}


define_function TestNAVXmlQueryFloat() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlQueryFloat'")

    InitializeXmlQueryFloatTestData()

    for (x = 1; x <= length_array(XML_QUERY_FLOAT_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var float result

        if (!NAVXmlParse(XML_QUERY_FLOAT_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVXmlQueryFloat(xml, XML_QUERY_FLOAT_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertFloatAlmostEqual('NAVXmlQueryFloat value',
                                       XML_QUERY_FLOAT_EXPECTED[x],
                                       result,
                                       0.000001)) {
            NAVLogTestFailed(x,
                            ftoa(XML_QUERY_FLOAT_EXPECTED[x]),
                            ftoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlQueryFloat'")
}
