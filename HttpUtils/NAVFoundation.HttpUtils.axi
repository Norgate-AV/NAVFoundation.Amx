PROGRAM_NAME='NAVFoundation.HttpUtils'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Solutions Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#IF_NOT_DEFINED __NAV_FOUNDATION_HTTPUTILS__
#DEFINE __NAV_FOUNDATION_HTTPUTILS__ 'NAVFoundation.HttpUtils'


DEFINE_CONSTANT

constant char    NAV_HTTP_PROTOCOL_HTTP   "http"
constant char    NAV_HTTP_PROTOCOL_HTTPS   "https"

constant integer NAV_HTTP_METHOD_POST   1
constant integer NAV_HTTP_METHOD_GET   2
constant integer NAV_HTTP_METHOD_PUT   3
constant integer NAV_HTTP_METHOD_PATCH   4
constant integer NAV_HTTP_METHOD_DELETE   5

constant integer NAV_HTTP_STATUS_CODE_SUCCESS_OK 200
constant integer NAV_HTTP_STATUS_CODE_SUCCESS_CREATED 201
constant integer NAV_HTTP_STATUS_CODE_SUCCESS_ACCEPTED 202
constant integer NAV_HTTP_STATUS_CODE_ERROR_BAD_REQUEST 400
constant integer NAV_HTTP_STATUS_CODE_ERROR_UNAUTHORIZED 401
constant integer NAV_HTTP_STATUS_CODE_ERROR_FORBIDDEN 403
constant integer NAV_HTTP_STATUS_CODE_ERROR_NOT_FOUND 404
constant integer NAV_HTTP_STATUS_CODE_ERROR_SERVER_ERROR 500
constant integer NAV_HTTP_STATUS_CODE_ERROR_SERVER_TIMEOUT 504

constant integer NAV_HTTP_CONTENT_TYPE_APPLICATION_JSON 1
constant integer NAV_HTTP_CONTENT_TYPE_TEXT_PLAIN       2
constant integer NAV_HTTP_CONTENT_TYPE_TEXT_HTML       3
constant integer NAV_HTTP_CONTENT_TYPE_TEXT_CSV       4
constant integer NAV_HTTP_CONTENT_TYPE_TEXT_XML       5


DEFINE_TYPE

struct _NAVHttpMessageQuery {
    string key[NAV_MAX_BUFFER]
    string value[NAV_MAX_BUFFER]
}


struct _NAVHttpMessage {
    string header[NAV_MAX_BUFFER]
    string body[65534]

    string method[NAV_MAX_CHARS]
    string route[NAV_MAX_BUFFER]

    string host[NAV_MAX_CHARS]
    string userAgent[NAV_MAX_BUFFER]
    string server[NAV_MAX_BUFFER]
    string date[NAV_MAX_CHARS]
    string contentType[NAV_MAX_CHARS]
    string contentLength[NAV_MAX_CHARS]
    integer contentLength

    string statusCode[NAV_MAX_CHARS]
    integer statusCode
    string statusText[NAV_MAX_BUFFER]
}


define_function sinteger NAVHttpResizeStructureArrayQuery(byref _NAVHttpMessageQuery query[], integer newSize) {
    signed_integer result

    result = resizestructurearray(query, newSize)

    if(result != 0) {
        NAVErrorLog(NAV_LOG_TYPE_ERROR, NAV_LIBRARY_HTTP_UTILS, NAVFormatFunction(NAV_LIBRARY_HTTP_UTILS, "NAVHttpResizeStructureArrayQuery"), "Error resizing structure array : ", NAVGetResizeArrayError(result), "", "")
    }

    return(result)
}


define_function char[NAV_MAX_BUFFER] NAVHttpMessageGetDateNow() {
    string date[NAV_MAX_CHARS]
    string time[NAV_MAX_CHARS]
    string result[NAV_MAX_BUFFER]

    date = mid(day(), 1, 3) + ", " + itoa(getdatenum()) + " " + mid(month(), 1, 3) + " " + itoa(getyearnum())

    time = time() + " GMT"

    result = date + " " + time

    return(result)
}


define_function integer NAVHttpParseRequestQuery(string route, byref _NAVHttpMessageQuery query[]) {
    string routeCopy[NAV_MAX_BUFFER]
    string junk[NAV_MAX_BUFFER]
    dynamic string query[1][NAV_MAX_BUFFER]
    integer queryCount
    integer x

    if(!NAVContains(route, "?")) {
        return(0)
    }

    routeCopy = route

    junk = remove("?", routeCopy)

    queryCount = NAVSplitString(routeCopy, "&", query)
    NAVHttpResizeStructureArrayQuery(query, queryCount)

    for(x = 1 to queryCount) {

    }
}


define_function NAVHttpMessageInit(byref _NAVHttpMessage message) {
    message.header = ""
    message.body = ""
    message.method = ""
    message.route = ""
    message.host = ""
    message.userAgent = "Crestron Electronics"
    message.server = "Crestron Electronics"
    message.contentLength = ""
    message.contentLength = 0
    message.contentType = ""
    message.statusCode = ""
    message.statusText = ""
    message.statusCode = 0

    message.date = NAVHttpMessageGetDateNow()
}


define_function char[NAV_MAX_BUFFER] NAVHttpGetStatusText(integer status) {
    cswitch(status) {
        case(NAV_HTTP_STATUS_CODE_SUCCESS_OK): { return("OK"); }
        case(NAV_HTTP_STATUS_CODE_SUCCESS_CREATED): { return("Created"); }
        case(NAV_HTTP_STATUS_CODE_SUCCESS_ACCEPTED): { return("Accepted"); }
        case(NAV_HTTP_STATUS_CODE_ERROR_BAD_REQUEST): { return("Bad Request"); }
        case(NAV_HTTP_STATUS_CODE_ERROR_UNAUTHORIZED): { return("Unauthorized"); }
        case(NAV_HTTP_STATUS_CODE_ERROR_FORBIDDEN): { return("Forbidden"); }
        case(NAV_HTTP_STATUS_CODE_ERROR_NOT_FOUND): { return("Not Found"); }
        case(NAV_HTTP_STATUS_CODE_ERROR_SERVER_ERROR): { return("Internal Server Error"); }
        case(NAV_HTTP_STATUS_CODE_ERROR_SERVER_TIMEOUT): { return("Gateway Timeout"); }
    }
}


define_function char[NAV_MAX_BUFFER] NAVHttpGetContentType(integer contentType) {
    cswitch(contentType) {
        case(NAV_HTTP_CONTENT_TYPE_APPLICATION_JSON): { return("application/json"); }
        case(NAV_HTTP_CONTENT_TYPE_TEXT_PLAIN): { return("text/plain"); }
        case(NAV_HTTP_CONTENT_TYPE_TEXT_HTML): { return("text/html"); }
        case(NAV_HTTP_CONTENT_TYPE_TEXT_CSV): { return("text/csv"); }
        case(NAV_HTTP_CONTENT_TYPE_TEXT_XML): { return("text/xml"); }
        default: { return(NAVHttpGetContentType(NAV_HTTP_CONTENT_TYPE_APPLICATION_JSON)); }
    }
}


define_function char[NAV_MAX_BUFFER] NAVHttpBuildUrl(string protocol, string host, string route) {
    string result[NAV_MAX_BUFFER]

    result = protocol + "://" + host + route

    return(result)
}


define_function char[NAV_MAX_BUFFER] NAVHttpBuildResponse(_NAVHttpMessage response) {
    string result[65534]

    result = result + "HTTP/1.1 " + response.statusCode + " " + response.statusText + "\n"
    result = result + "Date: " + response.date + "\n"
    result = result + "Server: " + response.server + "\n"
    result = result + "Content-Length: " + response.contentLength + "\n"
    result = result + "Content-Type: " + response.contentType + "\n"
    result = result + "Connection: Close\n\n"
    result = result + response.body

    return(result)
}


define_function char[NAV_MAX_BUFFER] NAVHttpBuildRequest(_NAVHttpMessage request) {
    string result[65534]

    request.contentLength = itoa(len(request.body))

    result = result + request.method + " " + request.route + " HTTP/1.1\n"
    result = result + "User-Agent: " + request.userAgent + "\n"
    result = result + "Host: " + request.host + "\n"

    if(len(request.contentLength)) {
        result = result + "Content-Length: " + request.contentLength + "\n"
    }

    if(len(request.contentType)) {
        result = result + "Content-Type: " + request.contentType + "\n"
    }

    result = result + "Connection: Close\n\n"

    if(len(request.body)) {
        result = result + request.body
    }

    return(result)
}


define_function char[NAV_MAX_BUFFER] NAVHttpRequestGetMethod(integer method) {
    switch(method) {
        case(NAV_HTTP_METHOD_POST): {
            return("POST")
        }
        case(NAV_HTTP_METHOD_GET): {
            return("GET")
        }
        case(NAV_HTTP_METHOD_PUT): {
            return("PUT")
        }
        case(NAV_HTTP_METHOD_PATCH): {
            return("PATCH")
        }
        case(NAV_HTTP_METHOD_DELETE): {
            return("DELETE")
        }
    }
}


define_function NAVHttpParseRequestHeader(byref string buffer, byref _NAVHttpMessage request) {
    signed_integer count
    dynamic string result[1][NAV_MAX_CHARS]
    string error[NAV_MAX_BUFFER]
    string header[NAV_MAX_BUFFER]

    if(!len(buffer)) {
        NAVErrorLog(NAV_LOG_TYPE_ERROR, NAVFormatFunction(NAV_LIBRARY_HTTP_UTILS, "NAVHttpParseRequestHeader"), "Received an empty buffer argument. Exiting.", "", "", "", "")
        return
    }

    //NAVErrorLog(NAV_LOG_TYPE_NOTICE, NAVFormatFunction(NAV_LIBRARY_HTTP_UTILS, "NAVHttpParseRequestHeader"), "Starting", "", "", "", "")

    header = remove("\n\n", buffer)

    if(!len(header)) {
        NAVErrorLog(NAV_LOG_TYPE_ERROR, NAVFormatFunction(NAV_LIBRARY_HTTP_UTILS, "NAVHttpParseRequestHeader"), "Unable to remove the full header. Exiting.", "", "", "", "")
        return
    }

    request.header = NAVStripCharsFromRight(header, 2)

    request.method = NAVStripCharsFromRight(remove(" ", request.header), 1)
    request.route = NAVStripCharsFromRight(remove(" HTTP/", request.header), 6)
    request.route = NAVFindAndReplace(request.route, "%20", " ")

    request.host = NAVTrimString(NAVGetStringBetween(request.header, "Host:", "\n"))
    if(NAVContains(request.host, ":")) {
        request.host = NAVStripCharsFromRight(request.host, len(request.host) - NAVIndexOf(request.host, ":") + 1)
    }

    request.userAgent = NAVTrimString(NAVGetStringBetween(request.header, "User-Agent:", "\n"))
    request.contentType = NAVTrimString(NAVGetStringBetween(request.header, "Content-Type:", "\n"))
    request.contentLength = NAVTrimString(NAVGetStringBetween(request.header, "Content-Length:", "\n"))
    if(len(request.contentLength)) {
        request.contentLength = atoi(request.contentLength)
    }

    //NAVErrorLog(NAV_LOG_TYPE_NOTICE, NAVFormatFunction(NAV_LIBRARY_HTTP_UTILS, "NAVHttpParseRequestHeader"), "Ending", "", "", "", "")
}


define_function NAVHttpParseResponseHeader(string buffer, byref _NAVHttpMessage response) {
    signed_integer count
    dynamic string result[1][NAV_MAX_CHARS]
    string error[NAV_MAX_BUFFER]
    string header[NAV_MAX_BUFFER]

    if(!len(buffer)) {
        return
    }

    //NAVErrorLog(NAV_LOG_TYPE_NOTICE, NAVFormatFunction(NAV_LIBRARY_HTTP_UTILS, "NAVHttpParseResponseHeader"), "Starting", "", "", "", "")

    header = remove("\n\n", buffer)

    if(!len(header)) {
        return
    }

    response.header = NAVStripCharsFromRight(header, 2)

    count = NAVSplitString(mid(response.header, 1, NAVIndexOf(response.header, "\n")), " ", result)

    if(count <= 0) {

        error = NAVFormatFunction("NAVFoundation.StringUtils", "NAVSplitString") + " returned an empty array. Exiting."

        NAVErrorLog(NAV_LOG_TYPE_ERROR, NAVFormatFunction(NAV_LIBRARY_HTTP_UTILS, "NAVHttpParseResponseHeader"), error, "", "", "", "")
        return
    }

    NAVTrimStringArray(result)

    //NAVErrorLog(NAV_LOG_TYPE_NOTICE, NAVFormatFunction(NAV_LIBRARY_HTTP_UTILS, "NAVHttpParseResponseHeader"), "NAVSplitString Success : ", NAVFormatArrayString(result), "", "", "")

    response.statusCode = result[2]
    response.statusCode = atoi(response.statusCode)
    response.statusText = NAVHttpGetStatusText(response.statusCode)

    response.date = NAVTrimString(NAVGetStringBetween(response.header, "Date:", "\n"))
    response.server = NAVTrimString(NAVGetStringBetween(response.header, "Server:", "\n"))
    response.contentType = NAVTrimString(NAVGetStringBetween(response.header, "Content-Type:", "\n"))
    response.contentLength = NAVTrimString(NAVGetStringBetween(response.header, "Content-Length:", "\n"))
    if(len(response.contentLength)) {
        response.contentLength = atoi(response.contentLength)
    }

    //NAVErrorLog(NAV_LOG_TYPE_NOTICE, NAVFormatFunction(NAV_LIBRARY_HTTP_UTILS, "NAVHttpParseResponseHeader"), "Ending", "", "", "", "")
}


define_function NAVHttpPrintRequest(_NAVHttpMessage request) {
    trace("Method: %s\n", request.method)
    trace("Route: %s\n", request.route)
    trace("Host: %s\n", request.host)
    trace("User-Agent: %s\n", request.userAgent)

    if(len(request.contentType)) {
        trace("Content-Type: %s\n", request.contentType)
    }

    if(request.contentLength > 0) {
        trace("Content-Length: %s\n", request.contentLength)
    }

    if(len(request.body)) {
        trace("Body: %s\n", request.body)
    }
}


define_function NAVHttpPrintResponse(_NAVHttpMessage response) {
    trace("Status Code: %s\n", response.statusCode)
    trace("Status Text: %s\n", response.statusText)
    trace("Date: %s\n", response.date)
    trace("Server: %s\n", response.server)

    if(len(response.contentType)) {
        trace("Content-Type: %s\n", response.contentType)
    }

    if(response.contentLength > 0) {
        trace("Content-Length: %s\n", response.contentLength)
    }

    if(len(response.body)) {
        trace("Body: %s\n", response.body)
    }
}


define_function char[NAV_MAX_BUFFER] NAVHttpResponse(integer statusCode, integer contentType, string body) {
    _NAVHttpMessage response

    NAVHttpMessageInit(response)

    response.statusCode = itoa(statusCode)
    response.statusText = NAVHttpGetStatusText(statusCode)
    //response.server = "Crestron Electronics"

    if(contentType > 0 && len(body)) {
        response.contentType = NAVHttpGetContentType(contentType)
        response.contentLength = itoa(len(body))
        response.body = body
    }

    return(NAVHttpBuildResponse(response))
}




define_function integer NAVHttpParseRouteQueries() {

}


define_function NAVHttpParseUrl(string url, string host, string route) {
    string protocol[NAV_MAX_CHARS]
    string urlCopy[NAV_MAX_BUFFER]
    integer routeStart

    urlCopy = url

    protocol = NAVStripCharsFromRight(remove("://", urlCopy), 3)

    if(!NAVContains(urlCopy, "/")) {
        host = urlCopy
        route = "/"
        return
    }


    routeStart = NAVIndexOf(urlCopy, "/") - 1

    if(routeStart > 0) {
        host = removebylength(routeStart, urlCopy)
    }

    route = urlCopy
}


define_function integer NAVHttpParseRouteParams(string buffer, byref string params[]) {
    return(NAVSplitString(buffer, "/", params))
}


define_function char[NAV_MAX_BUFFER] NAVHttpRequest(integer method, string url, integer contentType, string body) {
    _NAVHttpMessage request

    NAVHttpMessageInit(request)

    request.method = NAVHttpRequestGetMethod(method)
    NAVHttpParseUrl(url, request.host, request.route)
    //request.userAgent = "Crestron Electronics"

    if(contentType > 0 && len(body)) {
        request.contentType = NAVHttpGetContentType(contentType)
        request.contentLength = itoa(len(body))
        request.body = body
    }

    return(NAVHttpBuildRequest(request))
}


define_function char[NAV_MAX_BUFFER] NAVHttpRequestGetRoute(string request) {
    string url[NAV_MAX_BUFFER]
    string host[NAV_MAX_BUFFER]
    string route[NAV_MAX_BUFFER]

    url = NAVGetStringBetween(request, " ", " HTTP/1.1")

    NAVHttpParseUrl(url, host, route)

    return(route)
}


define_function NAVHttpGet(string rL, string body) {

}


define_function NAVHttpPost(string rL, string body) {

}


define_function NAVHttpPut(string rL, string body) {

}


define_function NAVHttpPatch(string rL, string body) {

}


define_function NAVHttpDelete(string rL, string body) {

}


#END_IF  // __NAV_FOUNDATION_HTTPUTILS__
