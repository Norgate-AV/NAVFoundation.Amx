PROGRAM_NAME='NAVXmlLargeArrays'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_LARGE_ARRAY_TEST_XML[10][15000]


define_function InitializeXmlLargeArrayTestData() {
    stack_var integer i
    stack_var char tempXml[15000]

    // Test 1: Array with 50 elements
    tempXml = '<root><items>'
    for (i = 1; i <= 50; i++) {
        tempXml = "tempXml, '<item>', itoa(i), '</item>'"
    }
    tempXml = "tempXml, '</items></root>'"
    XML_LARGE_ARRAY_TEST_XML[1] = tempXml

    // Test 2: Array with 75 elements
    tempXml = '<root><values>'
    for (i = 1; i <= 75; i++) {
        tempXml = "tempXml, '<value>', itoa(i * 10), '</value>'"
    }
    tempXml = "tempXml, '</values></root>'"
    XML_LARGE_ARRAY_TEST_XML[2] = tempXml

    // Test 3: Array with 100 elements
    tempXml = '<root><numbers>'
    for (i = 1; i <= 100; i++) {
        tempXml = "tempXml, '<number>', itoa(i), '</number>'"
    }
    tempXml = "tempXml, '</numbers></root>'"
    XML_LARGE_ARRAY_TEST_XML[3] = tempXml

    // Test 4: Large array, query middle element (element 25 of 50)
    tempXml = '<root><entries>'
    for (i = 1; i <= 50; i++) {
        tempXml = "tempXml, '<entry>entry', itoa(i), '</entry>'"
    }
    tempXml = "tempXml, '</entries></root>'"
    XML_LARGE_ARRAY_TEST_XML[4] = tempXml

    // Test 5: Large array, query last element
    tempXml = '<root><records>'
    for (i = 1; i <= 60; i++) {
        tempXml = "tempXml, '<record>rec', itoa(i), '</record>'"
    }
    tempXml = "tempXml, '</records></root>'"
    XML_LARGE_ARRAY_TEST_XML[5] = tempXml

    // Test 6: Large array with attributes
    tempXml = '<root><devices>'
    for (i = 1; i <= 40; i++) {
        tempXml = "tempXml, '<device id="', itoa(i), '">Device ', itoa(i), '</device>'"
    }
    tempXml = "tempXml, '</devices></root>'"
    XML_LARGE_ARRAY_TEST_XML[6] = tempXml

    // Test 7: Large array with empty elements
    tempXml = '<root><tags>'
    for (i = 1; i <= 45; i++) {
        tempXml = "tempXml, '<tag/>'"
    }
    tempXml = "tempXml, '</tags></root>'"
    XML_LARGE_ARRAY_TEST_XML[7] = tempXml

    // Test 8: Large array with nested elements
    tempXml = '<root><users>'
    for (i = 1; i <= 30; i++) {
        tempXml = "tempXml, '<user><id>', itoa(i), '</id><name>User', itoa(i), '</name></user>'"
    }
    tempXml = "tempXml, '</users></root>'"
    XML_LARGE_ARRAY_TEST_XML[8] = tempXml

    // Test 9: Mixed large array
    tempXml = '<root><mixed>'
    for (i = 1; i <= 50; i++) {
        if (i % 2 == 0) {
            tempXml = "tempXml, '<even>', itoa(i), '</even>'"
        } else {
            tempXml = "tempXml, '<odd>', itoa(i), '</odd>'"
        }
    }
    tempXml = "tempXml, '</mixed></root>'"
    XML_LARGE_ARRAY_TEST_XML[9] = tempXml

    // Test 10: Large array with long text content
    tempXml = '<root><descriptions>'
    for (i = 1; i <= 35; i++) {
        tempXml = "tempXml, '<description>This is a longer text description for item number ', itoa(i), '</description>'"
    }
    tempXml = "tempXml, '</descriptions></root>'"
    XML_LARGE_ARRAY_TEST_XML[10] = tempXml

    set_length_array(XML_LARGE_ARRAY_TEST_XML, 10)
}


DEFINE_CONSTANT

// Test configurations: which element to query and expected value
constant char XML_LARGE_ARRAY_TEST_QUERY[10][64] = {
    '.items.item[50]',          // Test 1: Last element of 50
    '.values.value[38]',        // Test 2: Element 38 of 75
    '.numbers.number[100]',     // Test 3: Last element of 100
    '.entries.entry[25]',       // Test 4: Middle element of 50
    '.records.record[60]',      // Test 5: Last element of 60
    '.devices.device[20]',      // Test 6: Element 20 of 40
    '.tags.tag[45]',            // Test 7: Last empty element
    '.users.user[15].id',       // Test 8: Nested query - ID of user 15
    '.mixed.even[10]',          // Test 9: 10th even element (element 20)
    '.descriptions.description[10]' // Test 10: 10th description
}

constant char XML_LARGE_ARRAY_TEST_EXPECTED[10][128] = {
    '50',                       // Test 1
    '380',                      // Test 2: 38 * 10
    '100',                      // Test 3
    'entry25',                  // Test 4
    'rec60',                    // Test 5
    'Device 20',                // Test 6
    '',                         // Test 7: Empty element
    '15',                       // Test 8
    '20',                       // Test 9: 10th even = 20
    'This is a longer text description for item number 10' // Test 10
}


define_function TestNAVXmlLargeArrays() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlLargeArrays'")

    InitializeXmlLargeArrayTestData()

    for (x = 1; x <= length_array(XML_LARGE_ARRAY_TEST_XML); x++) {
        stack_var _NAVXml xml
        stack_var char result[256]

        if (!NAVXmlParse(XML_LARGE_ARRAY_TEST_XML[x], xml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVXmlQueryString(xml, XML_LARGE_ARRAY_TEST_QUERY[x], result)) {
            if (length_array(XML_LARGE_ARRAY_TEST_EXPECTED[x]) == 0) {
                // Expected empty result (empty element)
                NAVLogTestPassed(x)
                continue
            } else {
                NAVLogTestFailed(x, 'Query success', 'Query failed')
                continue
            }
        }

        if (!NAVAssertStringEqual('Queried value',
                                  XML_LARGE_ARRAY_TEST_EXPECTED[x],
                                  result)) {
            NAVLogTestFailed(x,
                            XML_LARGE_ARRAY_TEST_EXPECTED[x],
                            result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlLargeArrays'")
}
