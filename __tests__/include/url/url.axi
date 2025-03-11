#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.URL.axi'

define_function RunUrlTests() {
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'===== Running URL Tests ====='");

    // Test URL parsing
    TestUrlParse();

    // Test URL component extraction
    TestUrlComponents();

    // Test URL encoding/decoding
    TestUrlEncoding();

    // Test URL query parameter handling
    TestUrlQueryParameters();

    // Test URL building
    TestUrlBuild();

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'All URL tests completed'");
}

define_function TestUrlParse() {
    stack_var NAVUrl parsedUrl;

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing URL parsing'");

    // Parse standard URL
    parsedUrl = NAVParseUrl('https://www.example.com:443/path/to/resource?query=value&param=123#fragment');
    PrintUrlDetails(parsedUrl, 'Standard URL');

    // Parse URL with authentication
    parsedUrl = NAVParseUrl('http://username:password@example.com/secure');
    PrintUrlDetails(parsedUrl, 'URL with authentication');

    // Parse URL with IP address
    parsedUrl = NAVParseUrl('https://192.168.1.1/admin');
    PrintUrlDetails(parsedUrl, 'URL with IP address');

    // Parse relative URL
    parsedUrl = NAVParseUrl('/relative/path?param=value');
    PrintUrlDetails(parsedUrl, 'Relative URL');

    // Parse file URL
    parsedUrl = NAVParseUrl('file:///C:/path/to/file.txt');
    PrintUrlDetails(parsedUrl, 'File URL');
}

define_function PrintUrlDetails(NAVUrl url, char description[]) {
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  ', description, ':'");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'    Scheme: ', url.scheme");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'    Username: ', url.username");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'    Password: ', url.password");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'    Host: ', url.host");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'    Port: ', itoa(url.port)");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'    Path: ', url.path");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'    Query: ', url.query");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'    Fragment: ', url.fragment");
}

define_function TestUrlComponents() {
    stack_var char url[256];
    stack_var char result[256];

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing URL component extraction'");

    url = 'https://www.example.com:443/path/to/resource?query=value&param=123#fragment';

    // Extract scheme
    result = NAVUrlGetScheme(url);
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Scheme from URL: '", result, "'");

    // Extract host
    result = NAVUrlGetHost(url);
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Host from URL: '", result, "'");

    // Extract path
    result = NAVUrlGetPath(url);
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Path from URL: '", result, "'");

    // Extract query
    result = NAVUrlGetQuery(url);
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Query from URL: '", result, "'");

    // Extract fragment
    result = NAVUrlGetFragment(url);
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Fragment from URL: '", result, "'");
}

define_function TestUrlEncoding() {
    stack_var char original[256];
    stack_var char encoded[256];
    stack_var char decoded[256];

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing URL encoding/decoding'");

    // Test with spaces and special characters
    original = 'Hello World! Special characters: @#$%^&*()';
    encoded = NAVUrlEncode(original);
    decoded = NAVUrlDecode(encoded);

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Original: '", original, "'");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Encoded: '", encoded, "'");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Decoded: '", decoded, "'");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Roundtrip successful: '", itoa(decoded == original), "'");

    // Test with already encoded string
    original = 'already%20encoded%20string';
    encoded = NAVUrlEncode(original);
    decoded = NAVUrlDecode(original);

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Original (encoded): '", original, "'");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Double encoded: '", encoded, "'");
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Decoded: '", decoded, "'");
}

define_function TestUrlQueryParameters() {
    stack_var char url[256];
    stack_var char result[256];

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing URL query parameters'");

    url = 'https://example.com/search?q=test&page=1&sort=desc';

    // Get specific parameter
    result = NAVUrlGetQueryParam(url, 'q');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Value of 'q' parameter: '", result, "'");

    result = NAVUrlGetQueryParam(url, 'page');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Value of 'page' parameter: '", result, "'");

    result = NAVUrlGetQueryParam(url, 'sort');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Value of 'sort' parameter: '", result, "'");

    result = NAVUrlGetQueryParam(url, 'nonexistent');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Value of nonexistent parameter: '", result, "'");

    // Add parameter to URL
    result = NAVUrlAddQueryParam(url, 'filter', 'new');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  URL after adding 'filter=new': '", result, "'");

    // Replace parameter
    result = NAVUrlReplaceQueryParam(url, 'page', '2');
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  URL after replacing 'page' with '2': '", result, "'");
}

define_function TestUrlBuild() {
    stack_var NAVUrl url;
    stack_var char result[256];

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing URL building'");

    // Build from components
    url.scheme = 'https';
    url.host = 'api.example.com';
    url.port = 443;
    url.path = '/v1/resources';
    url.query = 'filter=active&sort=name';

    result = NAVBuildUrl(url);
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Built URL: '", result, "'");

    // Build with authentication
    url.username = 'user';
    url.password = 'pass';
    url.port = 0; // default port

    result = NAVBuildUrl(url);
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Built URL with auth: '", result, "'");

    // Build with fragment
    url.username = '';
    url.password = '';
    url.fragment = 'section2';

    result = NAVBuildUrl(url);
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Built URL with fragment: '", result, "'");
}
