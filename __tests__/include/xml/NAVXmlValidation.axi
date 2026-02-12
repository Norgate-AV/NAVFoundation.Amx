PROGRAM_NAME='NAVXmlValidation'

#include 'NAVFoundation.Xml.axi'


DEFINE_VARIABLE

volatile char XML_VALIDATION_TEST[10][512]


define_function InitializeXmlValidationTestData() {
    // Test 1: Valid simple element
    XML_VALIDATION_TEST[1] = '<root>value</root>'

    // Test 2: Invalid - missing closing tag
    XML_VALIDATION_TEST[2] = '<root>value'

    // Test 3: Valid nested structure
    XML_VALIDATION_TEST[3] = '<root><child>value</child></root>'

    // Test 4: Invalid - mismatched closing tag
    XML_VALIDATION_TEST[4] = '<root><child>value</root></child>'

    // Test 5: Invalid - malformed element name
    XML_VALIDATION_TEST[5] = '<123invalid>value</123invalid>'

    // Test 6: Valid self-closing element
    XML_VALIDATION_TEST[6] = '<root/>'

    // Test 7: Valid with attributes
    XML_VALIDATION_TEST[7] = '<root id="123" name="test">value</root>'

    // Test 8: Invalid - unclosed attribute quote
    XML_VALIDATION_TEST[8] = '<root attr="value>content</root>'

    // Test 9: Valid empty element
    XML_VALIDATION_TEST[9] = '<root></root>'

    // Test 10: Invalid - missing opening tag
    XML_VALIDATION_TEST[10] = 'value</root>'

    set_length_array(XML_VALIDATION_TEST, 10)
}


DEFINE_CONSTANT

// Expected validation results
constant char XML_VALIDATION_EXPECTED_VALID[10] = {
    true,   // Test 1: Valid
    false,  // Test 2: Invalid - missing closing tag
    true,   // Test 3: Valid
    false,  // Test 4: Invalid - mismatched tags
    false,  // Test 5: Invalid - malformed name
    true,   // Test 6: Valid
    true,   // Test 7: Valid
    false,  // Test 8: Invalid - unclosed quote
    true,   // Test 9: Valid
    false   // Test 10: Invalid - missing opening tag
}

// Whether parse error is expected
constant char XML_VALIDATION_EXPECTED_HAS_ERROR[10] = {
    false,  // Test 1: No error
    true,   // Test 2: Has error
    false,  // Test 3: No error
    true,   // Test 4: Has error
    true,   // Test 5: Has error
    false,  // Test 6: No error
    false,  // Test 7: No error
    true,   // Test 8: Has error
    false,  // Test 9: No error
    true    // Test 10: Has error
}


define_function TestNAVXmlValidation() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVXmlValidation'")

    InitializeXmlValidationTestData()

    for (x = 1; x <= length_array(XML_VALIDATION_TEST); x++) {
        stack_var _NAVXml xml
        stack_var char isValid
        stack_var char hasError

        // Parse the XML (will succeed or fail)
        isValid = NAVXmlParse(XML_VALIDATION_TEST[x], xml)

        // Test if validation result matches expectation
        if (!NAVAssertBooleanEqual('XML is valid',
                                    XML_VALIDATION_EXPECTED_VALID[x],
                                    isValid)) {
            NAVLogTestFailed(x,
                            itoa(XML_VALIDATION_EXPECTED_VALID[x]),
                            itoa(isValid))
            continue
        }

        // Test if error state matches expectation
        hasError = !isValid
        if (!NAVAssertBooleanEqual('Has error',
                                    XML_VALIDATION_EXPECTED_HAS_ERROR[x],
                                    hasError)) {
            NAVLogTestFailed(x,
                            itoa(XML_VALIDATION_EXPECTED_HAS_ERROR[x]),
                            itoa(hasError))
            continue
        }

        // If parse succeeded, verify we can get root node
        if (isValid) {
            stack_var _NAVXmlNode root
            if (!NAVXmlGetRootNode(xml, root)) {
                NAVLogTestFailed(x, 'Get root node', 'Failed')
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVXmlValidation'")
}
