define_function ParseJson(char json[]) {
    stack_var JsmnParser parser
    stack_var JsmnToken tokens[NAV_MAX_JSMN_TOKENS]
    stack_var sinteger tokenCount
    stack_var integer x

    NAVLog('Initialising parser...')
    jsmn_init(parser)

    NAVLog('Parsing JSON...')
    NAVLog("'Length: ', itoa(length_array(json))")

    tokenCount = jsmn_parse(parser, json, tokens)

    if (tokenCount < 0) {
        NAVLog('Error parsing JSON')
        return
    }

    if (tokenCount == 0) {
        NAVLog('No tokens found')
        return
    }

    NAVLog("'Token count: ', itoa(tokenCount)")

    // for (x = 2; x <= type_cast(tokenCount); x++) {
    //     stack_var JsmnToken token
    //     stack_var char tokenValue[NAV_MAX_BUFFER]

    //     token = tokens[x]
    //     tokenValue = jsmn_get_token(json, token)

    //     NAVLog("'Token ', itoa(x), ' Type: ', jsmn_token_type_to_string(token.type)")
    //     // NAVLog("'Token ', itoa(x), ' Start: ', itoa(token.start)")
    //     // NAVLog("'Token ', itoa(x), ' End: ', itoa(token.end)")
    //     // NAVLog("'Token ', itoa(x), ' Size: ', itoa(token.size)")
    //     NAVLog("'Token ', itoa(x), ' Value: ', tokenValue")
    // }
}
