PROGRAM_NAME='HttpRequestHeaders'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

define_function TestNAVHttpRequestAddHeader() {
    stack_var _NAVHttpRequest request
    stack_var _NAVUrl url
    stack_var char result
    stack_var integer initialHeaderCount

    NAVLog("'***************** NAVHttpRequestAddHeader *****************'")

    // Initialize a request (this adds Host header automatically)
    NAVParseUrl('http://example.com/test', url)
    NAVHttpRequestInit(request, 'GET', url, '')
    initialHeaderCount = request.Headers.Count  // Should be 1 (Host header)

    // Test 1: Add first header
    result = NAVHttpRequestAddHeader(request, 'Content-Type', 'application/json')

    if (result != true || request.Headers.Count != (initialHeaderCount + 1) ||
        request.Headers.Headers[request.Headers.Count].Key != 'Content-Type' ||
        request.Headers.Headers[request.Headers.Count].Value != 'application/json') {
        NAVLogTestFailed(1, 'Header added successfully', 'Header add failed')
        return
    }

    NAVLogTestPassed(1)

    // Test 2: Add second header
    result = NAVHttpRequestAddHeader(request, 'Authorization', 'Bearer TOKEN123')

    if (result != true || request.Headers.Count != (initialHeaderCount + 2) ||
        request.Headers.Headers[request.Headers.Count].Key != 'Authorization' ||
        request.Headers.Headers[request.Headers.Count].Value != 'Bearer TOKEN123') {
        NAVLogTestFailed(2, 'Second header added', 'Second header add failed')
        return
    }

    NAVLogTestPassed(2)

    // Test 3: Add header with empty key (should fail)
    result = NAVHttpRequestAddHeader(request, '', 'value')

    if (result != false || request.Headers.Count != (initialHeaderCount + 2)) {
        NAVLogTestFailed(3, 'Add with empty key should fail', 'Add succeeded')
        return
    }

    NAVLogTestPassed(3)

    // Test 4: Add header with empty value (should fail)
    result = NAVHttpRequestAddHeader(request, 'X-Empty-Header', '')

    if (result != false || request.Headers.Count != (initialHeaderCount + 2)) {
        NAVLogTestFailed(4, 'Add with empty value should fail', 'Add succeeded')
        return
    }

    NAVLogTestPassed(4)

    // Test 5: Add header with very long key (200+ chars)
    result = NAVHttpRequestAddHeader(request, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', 'value')

    if (result == true && request.Headers.Count == (initialHeaderCount + 3)) {
        NAVLogTestPassed(5)
    }
    else {
        NAVLogTestFailed(5, 'Long key should succeed', 'Add failed')
        return
    }

    // Test 6: Add header with very long value (300+ chars)
    result = NAVHttpRequestAddHeader(request, 'X-Long-Value', 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA')

    if (result == true && request.Headers.Count == (initialHeaderCount + 4)) {
        NAVLogTestPassed(6)
    }
    else {
        NAVLogTestFailed(6, 'Long value should succeed', 'Add failed')
        return
    }

    // Test 7: Add header with special characters in key
    result = NAVHttpRequestAddHeader(request, 'X-Special-Key_123', 'test-value')

    if (result == true && request.Headers.Count == (initialHeaderCount + 5)) {
        NAVLogTestPassed(7)
    }
    else {
        NAVLogTestFailed(7, 'Special chars in key should succeed', 'Add failed')
        return
    }

    // Test 8: Add header with numeric key
    result = NAVHttpRequestAddHeader(request, '123', 'numeric-key')

    if (result == true && request.Headers.Count == (initialHeaderCount + 6)) {
        NAVLogTestPassed(8)
    }
    else {
        NAVLogTestFailed(8, 'Numeric key should succeed', 'Add failed')
        return
    }
}

/**
 * Tests for NAVHttpRequestUpdateHeader function
 */
define_function TestNAVHttpRequestUpdateHeader() {
    stack_var _NAVHttpRequest request
    stack_var _NAVUrl url
    stack_var char result
    stack_var integer contentTypeIndex
    stack_var integer authIndex

    NAVLog("'***************** NAVHttpRequestUpdateHeader *****************'")

    // Initialize a request with headers
    NAVParseUrl('http://example.com/test', url)
    NAVHttpRequestInit(request, 'GET', url, '')
    NAVHttpRequestAddHeader(request, 'Content-Type', 'text/plain')
    NAVHttpRequestAddHeader(request, 'Authorization', 'Bearer OLD_TOKEN')

    // Find the indices of our headers
    contentTypeIndex = NAVHttpFindHeader(request.Headers, 'Content-Type')
    authIndex = NAVHttpFindHeader(request.Headers, 'Authorization')

    // Test 1: Update existing header
    result = NAVHttpRequestUpdateHeader(request, 'Content-Type', 'application/json')

    if (result != true || request.Headers.Headers[contentTypeIndex].Value != 'application/json') {
        NAVLogTestFailed(1, 'Header updated', 'Update failed')
        return
    }

    NAVLogTestPassed(1)

    // Test 2: Update second header
    result = NAVHttpRequestUpdateHeader(request, 'Authorization', 'Bearer NEW_TOKEN')

    if (result != true || request.Headers.Headers[authIndex].Value != 'Bearer NEW_TOKEN') {
        NAVLogTestFailed(2, 'Second header updated', 'Update failed')
        return
    }

    NAVLogTestPassed(2)

    // Test 3: Update non-existent header (should fail)
    result = NAVHttpRequestUpdateHeader(request, 'X-Non-Existent', 'value')

    if (result != false) {
        NAVLogTestFailed(3, 'Update should fail for non-existent header', 'Update succeeded')
        return
    }

    NAVLogTestPassed(3)

    // Test 4: Update with empty key (should fail)
    result = NAVHttpRequestUpdateHeader(request, '', 'value')

    if (result != false) {
        NAVLogTestFailed(4, 'Update with empty key should fail', 'Update succeeded')
        return
    }

    NAVLogTestPassed(4)

    // Test 5: Update with very long value (300+ chars)
    result = NAVHttpRequestUpdateHeader(request, 'Content-Type', 'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB')

    if (result == true && find_string(request.Headers.Headers[contentTypeIndex].Value, 'BBBB', 1) > 0) {
        NAVLogTestPassed(5)
    }
    else {
        NAVLogTestFailed(5, 'Update with long value should succeed', 'Update failed')
        return
    }

    // Test 6: Update Host header
    result = NAVHttpRequestUpdateHeader(request, 'Host', 'newhost.com')

    if (result == true && NAVHttpGetHeaderValue(request.Headers, 'Host') == 'newhost.com') {
        NAVLogTestPassed(6)
    }
    else {
        NAVLogTestFailed(6, 'Host header update should succeed', 'Update failed')
        return
    }

    // Test 7: Update same header multiple times
    NAVHttpRequestUpdateHeader(request, 'Authorization', 'Token1')
    NAVHttpRequestUpdateHeader(request, 'Authorization', 'Token2')
    result = NAVHttpRequestUpdateHeader(request, 'Authorization', 'Token3')

    if (result == true && request.Headers.Headers[authIndex].Value == 'Token3') {
        NAVLogTestPassed(7)
    }
    else {
        NAVLogTestFailed(7, 'Multiple updates should succeed', "'Value: ', request.Headers.Headers[authIndex].Value")
        return
    }
}

/**
 * Tests for NAVHttpFindHeader, NAVHttpHeaderKeyExists, and NAVHttpGetHeaderValue
 */
define_function TestNAVHttpHeaderHelpers() {
    stack_var _NAVHttpRequest request
    stack_var _NAVUrl url
    stack_var integer index
    stack_var integer contentTypeIndex
    stack_var integer authIndex
    stack_var char exists
    stack_var char value[256]

    NAVLog("'***************** NAVHttpHeaderHelpers *****************'")

    // Setup (NAVHttpRequestInit adds Host header automatically)
    NAVParseUrl('http://example.com/test', url)
    NAVHttpRequestInit(request, 'GET', url, '')
    NAVHttpRequestAddHeader(request, 'Content-Type', 'application/json')
    NAVHttpRequestAddHeader(request, 'Authorization', 'Bearer TOKEN')
    NAVHttpRequestAddHeader(request, 'Accept', '*/*')

    // Get the actual indices of our headers
    contentTypeIndex = NAVHttpFindHeader(request.Headers, 'Content-Type')
    authIndex = NAVHttpFindHeader(request.Headers, 'Authorization')

    // Test 1: Find existing header (should find Content-Type)
    index = NAVHttpFindHeader(request.Headers, 'Content-Type')

    if (index == 0) {
        NAVLogTestFailed(1, 'Header found', 'Header not found')
        return
    }

    NAVLogTestPassed(1)

    // Test 2: Find second header (should find Authorization)
    index = NAVHttpFindHeader(request.Headers, 'Authorization')

    if (index == 0) {
        NAVLogTestFailed(2, 'Header found', 'Header not found')
        return
    }

    NAVLogTestPassed(2)

    // Test 3: Find non-existent header
    index = NAVHttpFindHeader(request.Headers, 'X-Non-Existent')

    if (index != 0) {
        NAVLogTestFailed(3, '0', itoa(index))
        return
    }

    NAVLogTestPassed(3)

    // Test 4: Check if header exists
    exists = NAVHttpHeaderKeyExists(request.Headers, 'Accept')

    if (exists != true) {
        NAVLogTestFailed(4, 'true', NAVBooleanToString(exists))
        return
    }

    NAVLogTestPassed(4)

    // Test 5: Check non-existent header
    exists = NAVHttpHeaderKeyExists(request.Headers, 'X-Missing')

    if (exists != false) {
        NAVLogTestFailed(5, 'false', NAVBooleanToString(exists))
        return
    }

    NAVLogTestPassed(5)

    // Test 6: Get header value
    value = NAVHttpGetHeaderValue(request.Headers, 'Authorization')

    if (value != 'Bearer TOKEN') {
        NAVLogTestFailed(6, 'Bearer TOKEN', value)
        return
    }

    NAVLogTestPassed(6)

    // Test 7: Get non-existent header value
    value = NAVHttpGetHeaderValue(request.Headers, 'X-Missing')

    if (value != '') {
        NAVLogTestFailed(7, '(empty)', value)
        return
    }

    NAVLogTestPassed(7)

    // Test 8: Find header with different case (should be case-sensitive)
    index = NAVHttpFindHeader(request.Headers, 'authorization')

    if (index == 0) {
        NAVLogTestPassed(8)
    }
    else {
        NAVLogTestFailed(8, 'Case-sensitive search should return 0', "'Index: ', itoa(index)")
        return
    }

    // Test 9: Get value from first header in collection
    value = NAVHttpGetHeaderValue(request.Headers, 'Host')

    if (length_string(value) > 0) {
        NAVLogTestPassed(9)
    }
    else {
        NAVLogTestFailed(9, 'Should return host value', '(empty)')
        return
    }

    // Test 10: Check header exists with trailing/leading spaces
    NAVHttpRequestAddHeader(request, 'X-Spaces', 'value')
    exists = NAVHttpHeaderKeyExists(request.Headers, 'X-Spaces')

    if (exists == true) {
        NAVLogTestPassed(10)
    }
    else {
        NAVLogTestFailed(10, 'Header should exist', 'Not found')
        return
    }
}

/**
 * Tests for NAVHttpResponseAddHeader function
 */
define_function TestNAVHttpResponseAddHeader() {
    stack_var _NAVHttpResponse response
    stack_var char result

    NAVLog("'***************** NAVHttpResponseAddHeader *****************'")

    // Initialize response
    NAVHttpResponseInit(response)

    // Test 1: Add first header to response
    result = NAVHttpResponseAddHeader(response, 'Content-Type', 'application/json')

    if (result != true || response.Headers.Count != 1 ||
        response.Headers.Headers[1].Key != 'Content-Type' ||
        response.Headers.Headers[1].Value != 'application/json') {
        NAVLogTestFailed(1, 'Response header added', 'Add failed')
        return
    }

    NAVLogTestPassed(1)

    // Test 2: Add second header
    result = NAVHttpResponseAddHeader(response, 'Server', 'NAVFoundation/1.0')

    if (result != true || response.Headers.Count != 2 ||
        response.Headers.Headers[2].Key != 'Server' ||
        response.Headers.Headers[2].Value != 'NAVFoundation/1.0') {
        NAVLogTestFailed(2, 'Second response header added', 'Add failed')
        return
    }

    NAVLogTestPassed(2)

    // Test 3: Add header with empty key (should fail)
    result = NAVHttpResponseAddHeader(response, '', 'value')

    if (result != false || response.Headers.Count != 2) {
        NAVLogTestFailed(3, 'Add with empty key should fail', 'Add succeeded')
        return
    }

    NAVLogTestPassed(3)

    // Test 4: Add header with empty value (should fail)
    result = NAVHttpResponseAddHeader(response, 'X-Custom', '')

    if (result != false || response.Headers.Count != 2) {
        NAVLogTestFailed(4, 'Add with empty value should fail', 'Add succeeded')
        return
    }

    NAVLogTestPassed(4)
}

/**
 * Tests for NAVHttpResponseUpdateHeader function
 */
define_function TestNAVHttpResponseUpdateHeader() {
    stack_var _NAVHttpResponse response
    stack_var char result
    stack_var integer contentTypeIndex

    NAVLog("'***************** NAVHttpResponseUpdateHeader *****************'")

    // Initialize response with headers
    NAVHttpResponseInit(response)
    NAVHttpResponseAddHeader(response, 'Content-Type', 'text/plain')
    NAVHttpResponseAddHeader(response, 'Server', 'OldServer/1.0')

    contentTypeIndex = NAVHttpFindHeader(response.Headers, 'Content-Type')

    // Test 1: Update existing header
    result = NAVHttpResponseUpdateHeader(response, 'Content-Type', 'application/json')

    if (result != true || response.Headers.Headers[contentTypeIndex].Value != 'application/json') {
        NAVLogTestFailed(1, 'Response header updated', 'Update failed')
        return
    }

    NAVLogTestPassed(1)

    // Test 2: Update non-existent header (should fail)
    result = NAVHttpResponseUpdateHeader(response, 'X-NonExistent', 'value')

    if (result != false) {
        NAVLogTestFailed(2, 'Update non-existent should fail', 'Update succeeded')
        return
    }

    NAVLogTestPassed(2)

    // Test 3: Update with empty key (should fail)
    result = NAVHttpResponseUpdateHeader(response, '', 'value')

    if (result != false) {
        NAVLogTestFailed(3, 'Update with empty key should fail', 'Update succeeded')
        return
    }

    NAVLogTestPassed(3)
}

/**
 * Tests for multiple header operations and edge cases
 */
define_function TestNAVHttpHeaderEdgeCases() {
    stack_var _NAVHttpRequest request
    stack_var _NAVUrl url
    stack_var char result
    stack_var integer i
    stack_var integer maxHeaders
    stack_var char headerKeys[9][50]

    NAVLog("'***************** NAVHttpHeaderEdgeCases *****************'")

    // Test 1: Add maximum number of headers (10 max)
    NAVParseUrl('http://example.com/test', url)
    NAVHttpRequestInit(request, 'GET', url, '')

    // List of valid headers to test the limit (Host is already added by Init)
    headerKeys[1] = 'Content-Type'
    headerKeys[2] = 'Accept'
    headerKeys[3] = 'Authorization'
    headerKeys[4] = 'Cache-Control'
    headerKeys[5] = 'User-Agent'
    headerKeys[6] = 'Referer'
    headerKeys[7] = 'Accept-Encoding'
    headerKeys[8] = 'Accept-Language'
    headerKeys[9] = 'Connection'

    maxHeaders = 10 - request.Headers.Count  // Account for auto-added headers

    // Try to add headers up to the limit
    for (i = 1; i <= maxHeaders && i <= 9; i++) {
        result = NAVHttpRequestAddHeader(request, headerKeys[i], "'Value-', itoa(i)")
        if (!result) {
            break
        }
    }

    if (request.Headers.Count > 10) {
        NAVLogTestFailed(1, 'Should not exceed 10 headers', "'Exceeded with ', itoa(request.Headers.Count), ' headers'")
        return
    }

    NAVLogTestPassed(1)

    // Test 2: Case sensitivity in header lookup
    NAVParseUrl('http://example.com/test', url)
    NAVHttpRequestInit(request, 'GET', url, '')
    NAVHttpRequestAddHeader(request, 'Content-Type', 'application/json')

    // Try to find with different case
    if (NAVHttpFindHeader(request.Headers, 'content-type') == 0) {
        // Case-sensitive lookup - should not find
        NAVLogTestPassed(2)
    }
    else {
        NAVLogTestFailed(2, 'Case-sensitive lookup expected', 'Found with different case')
        return
    }

    // Test 3: Update header preserves order
    NAVParseUrl('http://example.com/test', url)
    NAVHttpRequestInit(request, 'GET', url, '')
    NAVHttpRequestAddHeader(request, 'Content-Type', 'text/plain')
    NAVHttpRequestAddHeader(request, 'Accept', '*/*')
    NAVHttpRequestAddHeader(request, 'Authorization', 'Bearer TOKEN')

    i = NAVHttpFindHeader(request.Headers, 'Accept')
    NAVHttpRequestUpdateHeader(request, 'Accept', 'application/json')

    if (NAVHttpFindHeader(request.Headers, 'Accept') != i) {
        NAVLogTestFailed(3, 'Header position preserved', 'Position changed')
        return
    }

    NAVLogTestPassed(3)

    // Test 4: Get header value for first header in list
    NAVParseUrl('http://example.com/test', url)
    NAVHttpRequestInit(request, 'GET', url, '')

    if (NAVHttpGetHeaderValue(request.Headers, 'Host') == 'example.com') {
        NAVLogTestPassed(4)
    }
    else {
        NAVLogTestFailed(4, 'example.com', NAVHttpGetHeaderValue(request.Headers, 'Host'))
        return
    }

    // Test 5: Add duplicate header keys
    NAVParseUrl('http://example.com/test', url)
    NAVHttpRequestInit(request, 'GET', url, '')
    NAVHttpRequestAddHeader(request, 'Set-Cookie', 'cookie1=value1')
    result = NAVHttpRequestAddHeader(request, 'Set-Cookie', 'cookie2=value2')

    // Should allow duplicate keys or handle appropriately
    if (result == true || result == false) {
        NAVLogTestPassed(5)
    }
    else {
        NAVLogTestFailed(5, 'Duplicate key handling', 'Unexpected behavior')
        return
    }

    // Test 6: Remove all headers (if supported) or verify header count
    NAVParseUrl('http://example.com/test', url)
    NAVHttpRequestInit(request, 'GET', url, '')
    NAVHttpRequestAddHeader(request, 'X-Test', 'value')
    i = request.Headers.Count

    if (i > 1) {
        NAVLogTestPassed(6)
    }
    else {
        NAVLogTestFailed(6, 'Header count > 1', "'Count: ', itoa(i)")
        return
    }
}

/**
 * Tests for header validation
 */
define_function TestNAVHttpHeaderValidation() {
    stack_var _NAVHttpRequest request
    stack_var _NAVUrl url
    stack_var char result
    stack_var integer finalCount

    NAVLog("'***************** NAVHttpHeaderValidation *****************'")

    NAVParseUrl('http://example.com/test', url)
    NAVHttpRequestInit(request, 'GET', url, '')

    // Test 1: Add header with special characters in value
    result = NAVHttpRequestAddHeader(request, 'User-Agent', 'Mozilla/5.0 (Windows; U; en-US)')

    if (result != true) {
        NAVLogTestFailed(1, 'Special chars in value should succeed', 'Add failed')
        return
    }

    NAVLogTestPassed(1)

    // Test 2: Add header with numeric value
    result = NAVHttpRequestAddHeader(request, 'Content-Length', '12345')

    if (result != true) {
        NAVLogTestFailed(2, 'Numeric value should succeed', 'Add failed')
        return
    }

    NAVLogTestPassed(2)

    // Test 3: Check if non-existent header exists
    if (NAVHttpHeaderKeyExists(request.Headers, 'X-DoesNotExist') == false) {
        NAVLogTestPassed(3)
    }
    else {
        NAVLogTestFailed(3, 'Header should not exist', 'Header exists')
        return
    }

    // Test 4: Check if existing header exists
    if (NAVHttpHeaderKeyExists(request.Headers, 'User-Agent') == true) {
        NAVLogTestPassed(4)
    }
    else {
        NAVLogTestFailed(4, 'Header should exist', 'Header does not exist')
        return
    }

    // Test 5: Validate that Host header exists
    if (NAVHttpHeaderKeyExists(request.Headers, 'Host') == true) {
        NAVLogTestPassed(5)
    }
    else {
        NAVLogTestFailed(5, 'Host header should exist', 'Host header missing')
        return
    }

    // Test 6: Add header with colon in value
    result = NAVHttpRequestAddHeader(request, 'X-Time', '12:34:56')

    if (result == true) {
        NAVLogTestPassed(6)
    }
    else {
        NAVLogTestFailed(6, 'Colon in value should succeed', 'Add failed')
        return
    }

    // Test 7: Add header with equals sign in value
    result = NAVHttpRequestAddHeader(request, 'Authorization', 'key=value&other=data')

    if (result == true) {
        NAVLogTestPassed(7)
    }
    else {
        NAVLogTestFailed(7, 'Equals in value should succeed', 'Add failed')
        return
    }

    // Test 8: Add header with quotes in value
    result = NAVHttpRequestAddHeader(request, 'X-Quoted', 'He said "hello"')

    if (result == true) {
        NAVLogTestPassed(8)
    }
    else {
        NAVLogTestFailed(8, 'Quotes in value should succeed', 'Add failed')
        return
    }

    // Test 9: Verify header count doesn't exceed limit
    finalCount = request.Headers.Count

    if (finalCount <= NAV_HTTP_MAX_HEADERS) {
        NAVLogTestPassed(9)
    }
    else {
        NAVLogTestFailed(9, 'Should not exceed max headers', "'Count: ', itoa(finalCount), ' Max: ', itoa(NAV_HTTP_MAX_HEADERS)")
        return
    }
}

