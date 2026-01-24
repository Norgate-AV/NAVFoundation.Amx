PROGRAM_NAME='websocket-example'
(***********************************************************)
(* WebSocket Client Example                               *)
(* --------------------------------------------------------*)
(* This example demonstrates the WebSocket callback API:   *)
(*   - Automatic handshake handling with callbacks         *)
(*   - Auto ping/pong responses                            *)
(*   - Message callbacks for text/binary frames            *)
(*   - Connection state callbacks                          *)
(*   - Error handling callbacks                            *)
(*   - Large data transfer testing                         *)
(*                                                         *)
(* Test Server:                                            *)
(*   deno run --allow-net __tests__/include/websocket/server.js *)
(*                                                         *)
(* Button Events:                                          *)
(*   Button 1: Send echo command                           *)
(*   Button 2: Request large data test                     *)
(*   Button 3: Request burst test                          *)
(*   Button 4: Request server status                       *)
(*   Button 5: Disconnect                                  *)
(*   Button 6: Reconnect                                   *)
(***********************************************************)

#DEFINE __MAIN__

// Enable WebSocket callbacks
#DEFINE USING_NAV_WEBSOCKET_ON_OPEN_CALLBACK
#DEFINE USING_NAV_WEBSOCKET_ON_MESSAGE_CALLBACK
#DEFINE USING_NAV_WEBSOCKET_ON_CLOSE_CALLBACK
#DEFINE USING_NAV_WEBSOCKET_ON_ERROR_CALLBACK
#DEFINE USING_NAV_ERRORLOG_EVENT_CALLBACK

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.SocketUtils.axi'
#include 'NAVFoundation.WebSocket.axi'
#include 'NAVFoundation.TimelineUtils.axi'

DEFINE_DEVICE

dvWebSocketClient = 0:11:0

vdvTEST = 33201:1:0


DEFINE_CONSTANT

constant char WEBSOCKET_SERVER_URL[] = 'ws://192.168.10.157:8080'

constant long TL_HEARTBEAT = 1
constant long TL_WEBSOCKET_CHECK = 2

constant long TL_HEARTBEAT_INTERVAL[] = { 5000 }  // 5 seconds
constant long TL_WEBSOCKET_CHECK_INTERVAL[] = { 5000 }  // 5 seconds


DEFINE_VARIABLE

volatile _NAVWebSocket ws


// =============================================================================
// WebSocket Callbacks
// =============================================================================

/**
 * Called when WebSocket handshake completes successfully
 */
define_function NAVWebSocketOnOpenCallback(_NAVWebSocket ws, _NAVWebSocketOnOpenResult result) {
    NAVLog("'WebSocket connected to ', ws.Url.Host, ':', itoa(ws.Url.Port)")

    // Send initial echo command
    wait 5 {
        NAVErrorLog(NAV_LOG_LEVEL_INFO, 'Connected to WebSocket server')
        NAVTimelineStart(TL_HEARTBEAT,
                         TL_HEARTBEAT_INTERVAL,
                         TIMELINE_ABSOLUTE,
                         TIMELINE_REPEAT)
    }
}

/**
 * Called when a text or binary message is received
 */
define_function NAVWebSocketOnMessageCallback(_NAVWebSocket ws, _NAVWebSocketOnMessageResult result) {

}

/**
 * Called when WebSocket connection closes
 */
define_function NAVWebSocketOnCloseCallback(_NAVWebSocket ws, _NAVWebSocketOnCloseResult result) {
    NAVLog("'WebSocket connection to ', ws.Url.Host, ' closed: code=', itoa(result.StatusCode), ', reason=', result.Reason")
    NAVTimelineStop(TL_HEARTBEAT)
}

/**
 * Called when a protocol error occurs
 */
define_function NAVWebSocketOnErrorCallback(_NAVWebSocket ws, _NAVWebSocketOnErrorResult result) {
    NAVLog("'WebSocket error on ', ws.Url.Host, ': ', result.Message, ' (code: ', itoa(result.ErrorCode), ')'")
}


// =============================================================================
// WebSocket Helper Functions
// =============================================================================

define_function WebSocketClientConnect(char url[]) {
    if (!NAVWebSocketConnect(ws, url)) {
        NAVLog("'Failed to connect to WebSocket: ', url")
        return
    }

    NAVLog("'Connecting to WebSocket server at ', ws.Url.Host, ':', itoa(ws.Url.Port)")
}

define_function WebSocketClientDisconnect() {
    NAVWebSocketClose(ws)
}


define_function MaintainWebSocketConnection() {
    if (!NAVWebSocketIsOpen(ws)) {
        NAVLog('WebSocket not connected, attempting reconnect...')
        WebSocketClientConnect(WEBSOCKET_SERVER_URL)
    }
}


#IF_DEFINED USING_NAV_ERRORLOG_EVENT_CALLBACK
define_function NAVErrorLogEventCallback(long level, char message[]) {
    if (level > NAV_LOG_LEVEL_INFO) {
        return
    }

    if (!NAVWebSocketIsOpen(ws)) {
        return
    }

    NAVWebSocketSend(ws, "'{"level": "', NAVGetLogLevel(level), '", "message": "', message, '"}'")
}
#END_IF


DEFINE_START {
    // set_log_level(NAV_LOG_LEVEL_DEBUG)

    // Initialize WebSocket context
    NAVWebSocketInit(ws, dvWebSocketClient)

    // Initialize buffer
    create_buffer dvWebSocketClient, ws.RxBuffer.Data

    // Auto-connect to test server
    wait 20 {
        WebSocketClientConnect(WEBSOCKET_SERVER_URL)
        NAVTimelineStart(TL_WEBSOCKET_CHECK,
                         TL_WEBSOCKET_CHECK_INTERVAL,
                         TIMELINE_ABSOLUTE,
                         TIMELINE_REPEAT)
    }
}

DEFINE_EVENT

button_event[vdvTest, 1] {
    push: {

    }
}

button_event[vdvTest, 5] {
    push: {
        // Disconnect
        WebSocketClientDisconnect()
        NAVTimelineStop(TL_WEBSOCKET_CHECK)
    }
}

button_event[vdvTest, 6] {
    push: {
        // Reconnect
        WebSocketClientConnect(WEBSOCKET_SERVER_URL)
        NAVTimelineStart(TL_WEBSOCKET_CHECK,
                         TL_WEBSOCKET_CHECK_INTERVAL,
                         TIMELINE_ABSOLUTE,
                         TIMELINE_REPEAT)
    }
}

data_event[dvWebSocketClient] {
    online: {
        NAVWebSocketOnConnect(ws)
    }
    offline: {
        NAVWebSocketOnDisconnect(ws)
        NAVTimelineStop(TL_HEARTBEAT)
    }
    onerror: {
        NAVWebSocketOnError(ws)
        NAVLog("'Socket error: ', NAVGetSocketError(type_cast(data.number))")
    }
    string: {
        // Process incoming data - state machine handles everything
        NAVWebSocketProcessBuffer(ws)
    }
}


timeline_event[TL_HEARTBEAT] {
    NAVErrorLog(NAV_LOG_LEVEL_INFO, 'NetLinx Heartbeat')
}

timeline_event[TL_WEBSOCKET_CHECK] {
    MaintainWebSocketConnection()
}

