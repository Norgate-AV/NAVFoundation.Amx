PROGRAM_NAME='NAVXmlArrayConverters'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_ARRAY_CONVERTER_TEST_XML[10][1024]
volatile char XML_ARRAY_CONVERTER_TEST_QUERY[10][64]


define_function InitializeXmlArrayConverterTestData() {
    // Test 1: NAVXmlQueryStringArray - basic conversion
    XML_ARRAY_CONVERTER_TEST_XML[1] = '<root><item>alpha</item><item>beta</item><item>gamma</item><item>delta</item><item>epsilon</item></root>'
    XML_ARRAY_CONVERTER_TEST_QUERY[1] = '.'

    // Test 2: NAVXmlQueryStringArray - empty result
    XML_ARRAY_CONVERTER_TEST_XML[2] = '<root></root>'
    XML_ARRAY_CONVERTER_TEST_QUERY[2] = '.'

    // Test 3: NAVXmlQueryIntegerArray - basic conversion
    XML_ARRAY_CONVERTER_TEST_XML[3] = '<root><value>100</value><value>200</value><value>300</value><value>400</value></root>'
    XML_ARRAY_CONVERTER_TEST_QUERY[3] = '.'

    // Test 4: NAVXmlQueryIntegerArray - invalid values (expects failure)
    XML_ARRAY_CONVERTER_TEST_XML[4] = '<root><value>123</value><value>invalid</value><value>456</value></root>'
    XML_ARRAY_CONVERTER_TEST_QUERY[4] = '.'

    // Test 5: NAVXmlQueryLongArray - basic conversion
    XML_ARRAY_CONVERTER_TEST_XML[5] = '<root><big>4294967295</big><big>2147483648</big><big>1234567890</big></root>'
    XML_ARRAY_CONVERTER_TEST_QUERY[5] = '.'

    // Test 6: NAVXmlQueryLongArray - empty result
    XML_ARRAY_CONVERTER_TEST_XML[6] = '<root></root>'
    XML_ARRAY_CONVERTER_TEST_QUERY[6] = '.'

    // Test 7: NAVXmlQueryFloatArray - basic conversion
    XML_ARRAY_CONVERTER_TEST_XML[7] = '<root><num>1.5</num><num>2.75</num><num>3.14159</num><num>-0.5</num></root>'
    XML_ARRAY_CONVERTER_TEST_QUERY[7] = '.'

    // Test 8: NAVXmlQueryFloatArray - integer values
    XML_ARRAY_CONVERTER_TEST_XML[8] = '<root><num>10</num><num>20</num><num>30</num></root>'
    XML_ARRAY_CONVERTER_TEST_QUERY[8] = '.'

    // Test 9: NAVXmlQueryBooleanArray - basic conversion
    XML_ARRAY_CONVERTER_TEST_XML[9] = '<root><flag>true</flag><flag>false</flag><flag>1</flag><flag>0</flag><flag>yes</flag><flag>no</flag></root>'
    XML_ARRAY_CONVERTER_TEST_QUERY[9] = '.'

    // Test 10: NAVXmlQueryBooleanArray - mixed valid/invalid (expects failure)
    XML_ARRAY_CONVERTER_TEST_XML[10] = '<root><flag>true</flag><flag>invalid</flag><flag>1</flag><flag>maybe</flag></root>'
    XML_ARRAY_CONVERTER_TEST_QUERY[10] = '.'

    set_length_array(XML_ARRAY_CONVERTER_TEST_XML, 10)
    set_length_array(XML_ARRAY_CONVERTER_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer XML_ARRAY_CONVERTER_EXPECTED_COUNT[10] = {
    5,  // Test 1
    0,  // Test 2
    4,  // Test 3
    0,  // Test 4 - query fails with invalid value
    3,  // Test 5
    0,  // Test 6
    4,  // Test 7
    3,  // Test 8
    6,  // Test 9
    0   // Test 10 - query fails with invalid value
}

constant char XML_ARRAY_CONVERTER_EXPECTED_STRING[10][6][64] = {
    {'alpha', 'beta', 'gamma', 'delta', 'epsilon'},  // Test 1
    {''},                                             // Test 2
    {''},                                             // Test 3
    {''},                                             // Test 4
    {''},                                             // Test 5
    {''},                                             // Test 6
    {''},                                             // Test 7
    {''},                                             // Test 8
    {''},                                             // Test 9
    {''}                                              // Test 10
}

constant integer XML_ARRAY_CONVERTER_EXPECTED_INTEGER[10][6] = {
    {0, 0, 0, 0, 0},          // Test 1
    {0},                       // Test 2
    {100, 200, 300, 400},      // Test 3
    {123, 0, 456},             // Test 4
    {0, 0, 0},                 // Test 5
    {0},                       // Test 6
    {0, 0, 0, 0},              // Test 7
    {0, 0, 0},                 // Test 8
    {0, 0, 0, 0, 0, 0},        // Test 9
    {0, 0, 0, 0}               // Test 10
}

constant long XML_ARRAY_CONVERTER_EXPECTED_LONG[10][6] = {
    {0, 0, 0, 0, 0},                      // Test 1
    {0},                                   // Test 2
    {0, 0, 0, 0},                          // Test 3
    {0, 0, 0},                             // Test 4
    {4294967295, 2147483648, 1234567890},  // Test 5
    {0},                                   // Test 6
    {0, 0, 0, 0},                          // Test 7
    {0, 0, 0},                             // Test 8
    {0, 0, 0, 0, 0, 0},                    // Test 9
    {0, 0, 0, 0}                           // Test 10
}

constant float XML_ARRAY_CONVERTER_EXPECTED_FLOAT[10][6] = {
    {0.0, 0.0, 0.0, 0.0, 0.0},             // Test 1
    {0.0},                                  // Test 2
    {0.0, 0.0, 0.0, 0.0},                   // Test 3
    {0.0, 0.0, 0.0},                        // Test 4
    {0.0, 0.0, 0.0},                        // Test 5
    {0.0},                                  // Test 6
    {1.5, 2.75, 3.14159, -0.5},             // Test 7
    {10.0, 20.0, 30.0},                     // Test 8
    {0.0, 0.0, 0.0, 0.0, 0.0, 0.0},         // Test 9
    {0.0, 0.0, 0.0, 0.0}                    // Test 10
}

constant char XML_ARRAY_CONVERTER_EXPECTED_BOOLEAN[10][6] = {
    {false, false, false, false, false},                // Test 1
    {false},                                             // Test 2
    {false, false, false, false},                        // Test 3
    {false, false, false},                               // Test 4
    {false, false, false},                               // Test 5
    {false},                                             // Test 6
    {false, false, false, false},                        // Test 7
    {false, false, false},                               // Test 8
    {true, false, true, false, true, false},             // Test 9
    {true, false, true, false}                           // Test 10
}


define_function TestNAVXmlArrayConverters() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlArrayConverters'")

    InitializeXmlArrayConverterTestData()

    for (x = 1; x <= length_array(XML_ARRAY_CONVERTER_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var char stringResult[100][256]
        stack_var integer integerResult[100]
        stack_var long longResult[100]
        stack_var float floatResult[100]
        stack_var char booleanResult[100]
        stack_var integer i
        stack_var char failed

        if (!NAVXmlParse(XML_ARRAY_CONVERTER_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        switch (x) {
            case 1: {
                // Test 1: NAVXmlQueryStringArray - basic conversion
                if (!NAVXmlQueryStringArray(xml, XML_ARRAY_CONVERTER_TEST_QUERY[x], stringResult)) {
                    NAVLogTestFailed(x, 'Query success', 'Query failed')
                    continue
                }

                if (!NAVAssertIntegerEqual('Array length',
                                           XML_ARRAY_CONVERTER_EXPECTED_COUNT[x],
                                           length_array(stringResult))) {
                    NAVLogTestFailed(x,
                                    itoa(XML_ARRAY_CONVERTER_EXPECTED_COUNT[x]),
                                    itoa(length_array(stringResult)))
                    continue
                }

                for (i = 1; i <= length_array(stringResult); i++) {
                    if (!NAVAssertStringEqual("'Array element ', itoa(i)",
                                              XML_ARRAY_CONVERTER_EXPECTED_STRING[x][i],
                                              stringResult[i])) {
                        NAVLogTestFailed(x,
                                        "'Element ', itoa(i), ': ', XML_ARRAY_CONVERTER_EXPECTED_STRING[x][i]",
                                        "'Element ', itoa(i), ': ', stringResult[i]")
                        failed = true
                        break
                    }
                }
            }
            case 2: {
                // Test 2: NAVXmlQueryStringArray - empty result
                if (!NAVXmlQueryStringArray(xml, XML_ARRAY_CONVERTER_TEST_QUERY[x], stringResult)) {
                    NAVLogTestFailed(x, 'Query success', 'Query failed')
                    continue
                }

                if (!NAVAssertIntegerEqual('Array length',
                                           XML_ARRAY_CONVERTER_EXPECTED_COUNT[x],
                                           length_array(stringResult))) {
                    NAVLogTestFailed(x,
                                    itoa(XML_ARRAY_CONVERTER_EXPECTED_COUNT[x]),
                                    itoa(length_array(stringResult)))
                    continue
                }
            }
            case 3: {
                // Test 3: NAVXmlQueryIntegerArray - basic conversion
                if (!NAVXmlQueryIntegerArray(xml, XML_ARRAY_CONVERTER_TEST_QUERY[x], integerResult)) {
                    NAVLogTestFailed(x, 'Query success', 'Query failed')
                    continue
                }

                if (!NAVAssertIntegerEqual('Array length',
                                           XML_ARRAY_CONVERTER_EXPECTED_COUNT[x],
                                           length_array(integerResult))) {
                    NAVLogTestFailed(x,
                                    itoa(XML_ARRAY_CONVERTER_EXPECTED_COUNT[x]),
                                    itoa(length_array(integerResult)))
                    continue
                }

                for (i = 1; i <= length_array(integerResult); i++) {
                    if (!NAVAssertIntegerEqual("'Array element ', itoa(i)",
                                               XML_ARRAY_CONVERTER_EXPECTED_INTEGER[x][i],
                                               integerResult[i])) {
                        NAVLogTestFailed(x,
                                        "'Element ', itoa(i), ': ', itoa(XML_ARRAY_CONVERTER_EXPECTED_INTEGER[x][i])",
                                        "'Element ', itoa(i), ': ', itoa(integerResult[i])")
                        failed = true
                        break
                    }
                }
            }
            case 4: {
                // Test 4: NAVXmlQueryIntegerArray - invalid values (expects failure)
                if (NAVXmlQueryIntegerArray(xml, XML_ARRAY_CONVERTER_TEST_QUERY[x], integerResult)) {
                    NAVLogTestFailed(x, 'Query failure', 'Query succeeded')
                    continue
                }
            }
            case 5: {
                // Test 5: NAVXmlQueryLongArray - basic conversion
                if (!NAVXmlQueryLongArray(xml, XML_ARRAY_CONVERTER_TEST_QUERY[x], longResult)) {
                    NAVLogTestFailed(x, 'Query success', 'Query failed')
                    continue
                }

                if (!NAVAssertIntegerEqual('Array length',
                                           XML_ARRAY_CONVERTER_EXPECTED_COUNT[x],
                                           length_array(longResult))) {
                    NAVLogTestFailed(x,
                                    itoa(XML_ARRAY_CONVERTER_EXPECTED_COUNT[x]),
                                    itoa(length_array(longResult)))
                    continue
                }

                for (i = 1; i <= length_array(longResult); i++) {
                    if (!NAVAssertLongEqual("'Array element ', itoa(i)",
                                            XML_ARRAY_CONVERTER_EXPECTED_LONG[x][i],
                                            longResult[i])) {
                        NAVLogTestFailed(x,
                                        "'Element ', itoa(i), ': ', itoa(XML_ARRAY_CONVERTER_EXPECTED_LONG[x][i])",
                                        "'Element ', itoa(i), ': ', itoa(longResult[i])")
                        failed = true
                        break
                    }
                }
            }
            case 6: {
                // Test 6: NAVXmlQueryLongArray - empty result
                if (!NAVXmlQueryLongArray(xml, XML_ARRAY_CONVERTER_TEST_QUERY[x], longResult)) {
                    NAVLogTestFailed(x, 'Query success', 'Query failed')
                    continue
                }

                if (!NAVAssertIntegerEqual('Array length',
                                           XML_ARRAY_CONVERTER_EXPECTED_COUNT[x],
                                           length_array(longResult))) {
                    NAVLogTestFailed(x,
                                    itoa(XML_ARRAY_CONVERTER_EXPECTED_COUNT[x]),
                                    itoa(length_array(longResult)))
                    continue
                }
            }
            case 7: {
                // Test 7: NAVXmlQueryFloatArray - basic conversion
                if (!NAVXmlQueryFloatArray(xml, XML_ARRAY_CONVERTER_TEST_QUERY[x], floatResult)) {
                    NAVLogTestFailed(x, 'Query success', 'Query failed')
                    continue
                }

                if (!NAVAssertIntegerEqual('Array length',
                                           XML_ARRAY_CONVERTER_EXPECTED_COUNT[x],
                                           length_array(floatResult))) {
                    NAVLogTestFailed(x,
                                    itoa(XML_ARRAY_CONVERTER_EXPECTED_COUNT[x]),
                                    itoa(length_array(floatResult)))
                    continue
                }

                for (i = 1; i <= length_array(floatResult); i++) {
                    if (!NAVAssertFloatEqual("'Array element ', itoa(i)",
                                             XML_ARRAY_CONVERTER_EXPECTED_FLOAT[x][i],
                                             floatResult[i])) {
                        NAVLogTestFailed(x,
                                        "'Element ', itoa(i), ': ', ftoa(XML_ARRAY_CONVERTER_EXPECTED_FLOAT[x][i])",
                                        "'Element ', itoa(i), ': ', ftoa(floatResult[i])")
                        failed = true
                        break
                    }
                }
            }
            case 8: {
                // Test 8: NAVXmlQueryFloatArray - integer values
                if (!NAVXmlQueryFloatArray(xml, XML_ARRAY_CONVERTER_TEST_QUERY[x], floatResult)) {
                    NAVLogTestFailed(x, 'Query success', 'Query failed')
                    continue
                }

                if (!NAVAssertIntegerEqual('Array length',
                                           XML_ARRAY_CONVERTER_EXPECTED_COUNT[x],
                                           length_array(floatResult))) {
                    NAVLogTestFailed(x,
                                    itoa(XML_ARRAY_CONVERTER_EXPECTED_COUNT[x]),
                                    itoa(length_array(floatResult)))
                    continue
                }

                for (i = 1; i <= length_array(floatResult); i++) {
                    if (!NAVAssertFloatEqual("'Array element ', itoa(i)",
                                             XML_ARRAY_CONVERTER_EXPECTED_FLOAT[x][i],
                                             floatResult[i])) {
                        NAVLogTestFailed(x,
                                        "'Element ', itoa(i), ': ', ftoa(XML_ARRAY_CONVERTER_EXPECTED_FLOAT[x][i])",
                                        "'Element ', itoa(i), ': ', ftoa(floatResult[i])")
                        failed = true
                        break
                    }
                }
            }
            case 9: {
                // Test 9: NAVXmlQueryBooleanArray - basic conversion
                if (!NAVXmlQueryBooleanArray(xml, XML_ARRAY_CONVERTER_TEST_QUERY[x], booleanResult)) {
                    NAVLogTestFailed(x, 'Query success', 'Query failed')
                    continue
                }

                if (!NAVAssertIntegerEqual('Array length',
                                           XML_ARRAY_CONVERTER_EXPECTED_COUNT[x],
                                           length_array(booleanResult))) {
                    NAVLogTestFailed(x,
                                    itoa(XML_ARRAY_CONVERTER_EXPECTED_COUNT[x]),
                                    itoa(length_array(booleanResult)))
                    continue
                }

                for (i = 1; i <= length_array(booleanResult); i++) {
                    if (!NAVAssertBooleanEqual("'Array element ', itoa(i)",
                                               XML_ARRAY_CONVERTER_EXPECTED_BOOLEAN[x][i],
                                               booleanResult[i])) {
                        NAVLogTestFailed(x,
                                        "'Element ', itoa(i), ': ', itoa(XML_ARRAY_CONVERTER_EXPECTED_BOOLEAN[x][i])",
                                        "'Element ', itoa(i), ': ', itoa(booleanResult[i])")
                        failed = true
                        break
                    }
                }
            }
            case 10: {
                // Test 10: NAVXmlQueryBooleanArray - mixed valid/invalid (expects failure)
                if (NAVXmlQueryBooleanArray(xml, XML_ARRAY_CONVERTER_TEST_QUERY[x], booleanResult)) {
                    NAVLogTestFailed(x, 'Query failure', 'Query succeeded')
                    continue
                }
            }
        }

        if (failed) {
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlArrayConverters'")
}
