PROGRAM_NAME='NAVFoundation.Url.h'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Services Limited

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

#IF_NOT_DEFINED __NAV_FOUNDATION_URL_H__
#DEFINE __NAV_FOUNDATION_URL_H__ 'NAVFoundation.Url.h'


DEFINE_CONSTANT

constant char NAV_URL_SCHEME_HTTP[]      = 'http'
constant char NAV_URL_SCHEME_HTTPS[]     = 'https'
constant char NAV_URL_SCHEME_FTP[]       = 'ftp'
constant char NAV_URL_SCHEME_SFTP[]      = 'sftp'
constant char NAV_URL_SCHEME_FILE[]      = 'file'
constant char NAV_URL_SCHEME_MAILTO[]    = 'mailto'
constant char NAV_URL_SCHEME_RTSP[]      = 'rtsp'
constant char NAV_URL_SCHEME_RTSPS[]     = 'rtsps'
constant char NAV_URL_SCHEME_WS[]        = 'ws'
constant char NAV_URL_SCHEME_WSS[]       = 'wss'
constant char NAV_URL_SCHEME_S3[]        = 's3'

constant char NAV_URL_SCHEME_TOKEN[]     = '://'
constant char NAV_URL_PORT_TOKEN[]       = ':'
constant char NAV_URL_PATH_TOKEN[]       = '/'
constant char NAV_URL_QUERY_TOKEN[]      = '?'
constant char NAV_URL_FRAGMENT_TOKEN[]   = '#'

constant integer NAV_URL_MAX_QUERIES      = 30


DEFINE_TYPE

struct _NAVUrl {
    char Scheme[16];
    char Host[512];
    integer Port;
    char Path[256];
    _NAVKeyStringValuePair Queries[NAV_URL_MAX_QUERIES];
    char Fragment[256];
}


#END_IF // __NAV_FOUNDATION_URL_H__
