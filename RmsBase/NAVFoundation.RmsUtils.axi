PROGRAM_NAME='NAVFoundation.RmsUtils'

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
furnished to do so, subject to the following conditions:

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

#IF_NOT_DEFINED __NAV_FOUNDATION_RMSUTILS__
#DEFINE __NAV_FOUNDATION_RMSUTILS__ 'NAVFoundation.RmsUtils'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'


DEFINE_CONSTANT

constant char NAV_RMS_CLIENT_EVENT_SERVER_INFO[]                           = 'SERVER.INFO'
constant char NAV_RMS_CLIENT_REINITIALIZE[]                                = 'REINIT'


DEFINE_TYPE

struct _NAVRmsServerInformation {
    char AppVersion[NAV_MAX_CHARS]
    char DatabaseVersion[NAV_MAX_CHARS]
    integer MinPollTime
    integer MaxPollTime
    char TimesyncEnabled
    char SmtpEnabled
} // Total: 106 bytes


struct _NAVRmsLocation {
    char Id[NAV_MAX_CHARS]          // 50 bytes
    char Name[NAV_MAX_CHARS]        // 50 bytes
    char Owner[NAV_MAX_CHARS]       // 50 bytes
    char PhoneNumber[NAV_MAX_CHARS] // 50 bytes
    char Occupancy[NAV_MAX_CHARS]   // 50 bytes
    char PrestigeName[NAV_MAX_CHARS] // 50 bytes
    char Timezone[NAV_MAX_CHARS]    // 50 bytes
    char ClientDefaultLocation      // 1 byte
    char AssetLicensed              // 1 byte
}                                   // Total: 402 bytes (unchanged)


struct _NAVRmsAdapter {
    char IsOnline
} // Total: 1 byte


struct _NAVRmsConnection {
    char Name[NAV_MAX_CHARS]
    char Url[255]
    char Password[NAV_MAX_CHARS]
    char Enabled[5] // 'true' or 'false'
} // Total: 360 bytes


struct _NAVRmsException {
    char Message[255]           // 255 bytes (reduced from 1024)
    char ThrownByCommand[50]    // 50 bytes (reduced from 1024)
}                               // Total: 305 bytes (was 2048, saved 1743 bytes)


struct _NAVRmsConnectionState {
    char OldState[NAV_MAX_CHARS]
    char NewState[NAV_MAX_CHARS]
} // Total: 100 bytes


struct _NAVRmsHotlist {
    integer LocationId
    integer Count
    char ClientDefaultLocation
} // Total: 7 bytes


struct _NAVRmsMessage {
    char Type[NAV_MAX_CHARS]       // 50 bytes
    integer TimeOutSeconds         // 2 bytes
    char Modal                     // 1 byte
    char Title[50]                // 50 bytes
    char Body[255]                 // 255 bytes
    char ResponseMessage[255]      // 255 bytes
}                                  // Total: 613 bytes


struct _NAVRmsClient {
    dev Device                                    // 6 bytes
    char IsOnline                                 // 1 byte
    char IsRegistered                             // 1 byte
    char ClientKey[NAV_MAX_CHARS]                 // 50 bytes
    _NAVRmsServerInformation ServerInformation    // 106 bytes
    _NAVRmsLocation Location                      // 402 bytes
    _NAVRmsConnection Connection                  // 360 bytes
    _NAVRmsConnectionState ConnectionState        // 100 bytes
    _NAVKeyValuePair ConfigChange                 // 1074 bytes
    _NAVRmsHotlist Hotlist                        // 7 bytes
    _NAVRmsMessage Message                        // 613 bytes
    _NAVRmsException Exception                    // 305 bytes
}                                                 // Total: 4,025 bytes (was ~10785, saved ~6740 bytes)


struct _NAVRmsMonitorAssetProperties {
    char MonitorAssetName[NAV_MAX_CHARS]              // 50 bytes
    char MonitorAssetDescription[255]                 // 255 bytes
    char MonitorAssetManufacturerName[NAV_MAX_CHARS]  // 50 bytes
    char MonitorAssetManufacturerURL[255]             // 255 bytes
    char MonitorAssetModelName[NAV_MAX_CHARS]         // 50 bytes
    char MonitorAssetModelURL[255]                    // 255 bytes
    char MonitorAssetSerialNumber[NAV_MAX_CHARS]      // 50 bytes
    char MonitorAssetFirmwareVersion[NAV_MAX_CHARS]   // 50 bytes
} // Total: 965 bytes


struct _NAVRmsSource {
    dev Device              // 6 bytes
    char Name[NAV_MAX_CHARS] // 50 bytes
    char Description[255]   // 255 bytes
} // Total: 311 bytes


struct _NAVRmsRegisteredAsset {
    dev Device                    // 6 bytes
    char Key[NAV_MAX_CHARS]       // 50 bytes
    char Id[NAV_MAX_CHARS]        // 50 bytes
    char NewRegistration          // 1 byte
} // Total: 107 bytes


struct _NAVRmsAssetMethodExecuteEvent {
    char AssetKey[NAV_MAX_CHARS]
    char Method[NAV_MAX_CHARS]
    char Parameter[20][NAV_MAX_CHARS]
} // Total: 1,051 bytes


define_function NAVRmsClientInit(_NAVRmsClient client, tdata args) {
    client.Device = args.device
}


define_function NAVRmsConnectionCopy(_NAVRmsConnection source, _NAVRmsConnection destination) {
    destination.Name = source.Name
    destination.Url = source.Url
    destination.Password = source.Password
    destination.Enabled = source.Enabled
}


define_function NAVRmsServerInformationCopy(_NAVRmsServerInformation source, _NAVRmsServerInformation destination) {
    destination.AppVersion = source.AppVersion
    destination.DatabaseVersion = source.DatabaseVersion
    destination.TimesyncEnabled = source.TimesyncEnabled
    destination.SmtpEnabled = source.SmtpEnabled
    destination.MinPollTime = source.MinPollTime
    destination.MaxPollTime = source.MaxPollTime
}


define_function NAVRmsLocationCopy(_NAVRmsLocation source, _NAVRmsLocation destination) {
    destination.ClientDefaultLocation = source.ClientDefaultLocation
    destination.Id = source.Id
    destination.Name = source.Name
    destination.Owner = source.Owner
    destination.PhoneNumber = source.PhoneNumber
    destination.Occupancy = source.Occupancy
    destination.PrestigeName = source.PrestigeName
    destination.Timezone = source.Timezone
    destination.AssetLicensed = source.AssetLicensed
}


define_function NAVRmsMessageCopy(_NAVRmsMessage source, _NAVRmsMessage destination) {
    destination.Type = source.Type
    destination.Title = source.Title
    destination.Body = source.Body
    destination.TimeOutSeconds = source.TimeOutSeconds
    destination.Modal = source.Modal
    destination.ResponseMessage = source.ResponseMessage
}


define_function NAVRmsAdapterConnectionUpdate(dev device, _NAVRmsConnection connection) {
    if (!device_id(device)) {
        return
    }

    NAVCommand(device, "'CONFIG.CLIENT.NAME-', connection.Name")
    NAVCommand(device, "'CONFIG.SERVER.URL-', connection.Url")
    NAVCommand(device, "'CONFIG.SERVER.PASSWORD-', connection.Password")
    NAVCommand(device, "'CONFIG.CLIENT.ENABLED-', connection.Enabled")

    NAVCommand(device, NAV_RMS_CLIENT_REINITIALIZE)
}


define_function NAVRmsAdapterConnectionInit(_NAVRmsClient client) {
    NAVRmsAdapterConnectionUpdate(client.Device, client.Connection)
}


define_function NAVRmsExceptionCopy(_NAVRmsException source, _NAVRmsException destination) {
    destination.Message = source.Message
    destination.ThrownByCommand = source.ThrownByCommand
}


define_function NAVRmsExceptionLog(_NAVRmsException exception, tdata args) {
    NAVErrorLog(NAV_LOG_LEVEL_ERROR,
                "'RMS Client [', NAVDeviceToString(args.device), '] Exception: ', exception.Message")

    if (!length_array(exception.ThrownByCommand)) {
        return
    }

    NAVErrorLog(NAV_LOG_LEVEL_ERROR,
                "'RMS Client [', NAVDeviceToString(args.device), '] Thrown By Command: ', exception.ThrownByCommand")
}


define_function NAVRmsClientServerInformationLog(_NAVRmsServerInformation server, tdata args) {
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), '] Server Info: '")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   App Version: ', server.AppVersion")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Database Version: ', server.DatabaseVersion")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Timesync Enabled: ', NAVBooleanToString(server.TimesyncEnabled)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Smtp Enabled: ', NAVBooleanToString(server.SmtpEnabled)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Min Poll Time: ', itoa(server.MinPollTime)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Max Poll Time: ', itoa(server.MaxPollTime)")
}


define_function NAVRmsClientLocationLog(_NAVRmsLocation location, tdata args) {
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), '] Location: '")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Client Default Location: ', NAVBooleanToString(location.ClientDefaultLocation)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Id: ', location.Id")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Name: ', location.Name")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Owner: ', location.Owner")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Phone Number: ', location.PhoneNumber")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Occupancy: ', location.Occupancy")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Prestige Name: ', location.PrestigeName")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Timezone: ', location.Timezone")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Asset Licensed: ', NAVBooleanToString(location.AssetLicensed)")
}


define_function NAVRmsClientConnectionStateLog(_NAVRmsConnectionState state, tdata args) {
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), '] Connection State Transition: '")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Old State: ', state.OldState")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   New State: ', state.NewState")
}


define_function NAVRmsClientConfigChangeLog(_NAVKeyValuePair config, tdata args) {
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), '] Config Change: '")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Key: ', config.Key")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Value: ', config.Value")
}


define_function NAVRmsHotlistLog(_NAVRmsHotlist hotlist, tdata args) {
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), '] Hotlist: '")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Client Default Location: ', NAVBooleanToString(hotlist.ClientDefaultLocation)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Location ID: ', itoa(hotlist.LocationId)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Count: ', itoa(hotlist.Count)")
}


define_function NAVRmsMessageDisplayLog(_NAVRmsMessage message, tdata args) {
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), '] Message Display: '")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Type: ', message.Type")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Title: ', message.Title")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Body: ', message.Body")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Timeout seconds: ', itoa(message.TimeOutSeconds)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Modal: ', NAVBooleanToString(message.Modal)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Response Message: ', message.ResponseMessage")
}


define_function NAVRmsClientAssetRegisteredLog(_NAVRmsRegisteredAsset asset, tdata args) {
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), '] Asset Registered: '")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Asset Client Key: ', asset.Key")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Asset ID: ', asset.Id")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   New Registration: ', NAVBooleanToString(asset.NewRegistration)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Asset DPS: ', NAVDeviceToString(asset.Device)")
}


define_function NAVRmsClientAssetMethodExecuteLog(_NAVRmsAssetMethodExecuteEvent event, tdata args) {
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), '] Asset Method Execute: '")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Asset Client Key: ', event.AssetKey")
    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                "'RMS Client [', NAVDeviceToString(args.device), ']   Method Key: ', event.Method")

    {
        // Loop through the parameters
        stack_var integer x

        for (x = 3; x <= length_array(event.Parameter); x++) {
            stack_var integer index

            if (event.Parameter[x] == '') {
                break
            }

            index = x - 2
            NAVErrorLog(NAV_LOG_LEVEL_INFO,
                        "'RMS Client [', NAVDeviceToString(args.device), ']   Method Argument ', itoa(index), ': ', event.Parameter[x]")
        }
    }
}


#END_IF // __NAV_FOUNDATION_RMSUTILS__
