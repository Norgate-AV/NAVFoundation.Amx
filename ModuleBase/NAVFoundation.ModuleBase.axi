PROGRAM_NAME='NAVFoundation.ModuleBase'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_MODULEBASE__
#DEFINE __NAV_FOUNDATION_MODULEBASE__ 'NAVFoundation.ModuleBase'

#include 'NAVFoundation.ModuleBase.h.axi'

DEFINE_CONSTANT

// Required to handle events on 'vdvObject'
// #DEFINE USING_NAV_MODULE_BASE_CALLBACKS

// #DEFINE USING_NAV_MODULE_BASE_PROPERTY_EVENT_CALLBACK
// define_function NAVModulePropertyEventCallback(_NAVModulePropertyEvent event) {}

// #DEFINE USING_NAV_MODULE_BASE_PASSTHRU_EVENT_CALLBACK
// define_function NAVModulePassthruEventCallback(_NAVModulePassthruEvent event) {}


DEFINE_TYPE


DEFINE_VARIABLE

volatile _NAVModule module


define_function NAVModulePropertyEventInit(dev device, _NAVSnapiMessage message, _NAVModulePropertyEvent event) {
    event.Device = device
    event.FullMessage = message
    event.Name = message.Parameter[1]

    if (length_array(message.Parameter) < 2) {
        return
    }

    NAVArraySliceString(message.Parameter, 2, length_array(message.Parameter), event.Args)
}


define_function NAVModulePassthruEventInit(dev device, _NAVSnapiMessage message, _NAVModulePassthruEvent event) {
    event.Device = device
    event.FullMessage = message
    event.Payload = message.Parameter[1]
}


define_function NAVModuleInit(_NAVModule module) {
    module.RxBuffer.Semaphore = false

    module.Device.IsOnline = false
    module.Device.IsCommunicating = false
    module.Device.IsInitialized = false

    module.Device.SocketConnection.IsConnected = false
    module.Device.SocketConnection.IsAuthenticated = false

    module.Enabled = true
    module.CommandBusy = false
}


DEFINE_START {
    NAVModuleInit(module)
}


DEFINE_EVENT

#IF_DEFINED USING_NAV_MODULE_BASE_CALLBACKS
data_event[vdvObject] {
    command: {
        stack_var _NAVSnapiMessage message

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, NAVFormatStandardLogMessage(NAV_STANDARD_LOG_MESSAGE_TYPE_COMMAND_FROM, data.device, data.text))

        NAVParseSnapiMessage(data.text, message)

        switch (message.Header) {
            case NAV_MODULE_PROPERTY_EVENT: {
                #IF_DEFINED USING_NAV_MODULE_BASE_PROPERTY_EVENT_CALLBACK
                stack_var _NAVModulePropertyEvent event

                NAVModulePropertyEventInit(data.device, message, event)

                NAVModulePropertyEventCallback(event)
                #END_IF
            }
            case NAV_MODULE_PASSTHRU_EVENT: {
                #IF_DEFINED USING_NAV_MODULE_BASE_PASSTHRU_EVENT_CALLBACK
                stack_var _NAVModulePassthruEvent event

                NAVModulePassthruEventInit(data.device, message, event)

                NAVModulePassthruEventCallback(event)
                #END_IF
            }
        }
    }
}
#END_IF // USING_NAV_MODULE_BASE_CALLBACKS


#END_IF // __NAV_FOUNDATION_MODULEBASE__
