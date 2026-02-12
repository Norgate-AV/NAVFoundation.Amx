PROGRAM_NAME='NAVBase64UrlEncodePadded'

DEFINE_CONSTANT

// Expected Base64Url encoding WITH padding
constant char BASE64URL_EXPECTED_PADDED[][2048] = {
    '',
    'YQ==',
    'YWJj',
    'YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXo=',
    'QUJDREVGR0hJSktMTU5PUFFSU1RVVldYWVphYmNkZWZnaGlqa2xtbm9wcXJzdHV2d3h5ejAxMjM0NTY3ODk=',
    'MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTIzNDU2Nzg5MDEyMzQ1Njc4OTA=',
    'VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZw==',
    'VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZy4=',
    'AAECA__-_fw=',
    'f4CBkKCwwNDg',
    'c3ViamVjdHM_',
    '-_8=',
    '____',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
    'eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ=='
}

define_function TestNAVBase64UrlEncodePadded() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVBase64UrlEncodePadded')

    for (x = 1; x <= length_array(BASE64URL_TEST); x++) {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVBase64UrlEncodePadded(BASE64URL_TEST[x])

        if (!NAVAssertStringEqual('Should match expected Base64Url encoding (padded)', BASE64URL_EXPECTED_PADDED[x], result)) {
            NAVLogTestFailed(x, BASE64URL_EXPECTED_PADDED[x], result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVBase64UrlEncodePadded')
}