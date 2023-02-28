PROGRAM_NAME='NAVFoundation.RmsBase'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_RMSBASE__
#DEFINE __NAV_FOUNDATION_RMSBASE__ 'NAVFoundation.RmsBase'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.RmsUtils.axi'
#include 'NAVFoundation.ArrayUtils.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'


DEFINE_DEVICE
#IF_NOT_DEFINED dvMaster
dvMaster                = 0:1:0
#END_IF

#IF_NOT_DEFINED vdvRMS
vdvRMS                  = 41001:1:0
#END_IF

#IF_NOT_DEFINED vdvRmsSourceUsage
vdvRMSSourceUsage       = 33000:1:0
#END_IF


DEFINE_CONSTANT


DEFINE_VARIABLE

volatile _NAVRmsClient rmsClient


#include 'RmsApi.axi'
#include 'RmsSourceUsage.axi'


// #DEFINE USING_NAV_RMS_ADAPTER_ONLINE_EVENT_CALLBACK
// define_function NAVRmsBaseAdapterOnlineEventCallback(tdata data) {}


// #DEFINE USING_NAV_RMS_ADAPTER_CONNECTION_INIT_EVENT_CALLBACK
// define_function NAVRmsBaseAdapterConnectionInitEventCallback(tdata data, _NAVRmsConnection connection) {}


DEFINE_START {
    RmsSourceUsageReset()
}


define_module 'RmsNetLinxAdapter_dr4_0_0' RmsNetLinxAdapterComm(vdvRMS)

define_module 'RmsControlSystemMonitor' RmsControlSystemMonitorComm(vdvRMS, dvMaster)
define_module 'RmsSystemPowerMonitor' RmsSystemPowerMonitorComm(vdvRMS, dvMaster)


DEFINE_EVENT

data_event[vdvRms] {
    online: {
        #IF_DEFINED USING_NAV_RMS_ADAPTER_ONLINE_EVENT_CALLBACK
        NAVRmsBaseAdapterOnlineEventCallback(data)
        #END_IF

        #IF_DEFINED USING_NAV_RMS_ADAPTER_CONNECTION_INIT_EVENT_CALLBACK
        stack_var _NAVRmsConnection connection

        NAVRmsBaseAdapterConnectionInitEventCallback(data, connection)
        NAVRmsConnectionCopy(connection, rmsClient.Connection)

        NAVCommand(data.device, "'CONFIG.CLIENT.NAME-', rmsClient.Connection.Name")
        NAVCommand(data.device, "'CONFIG.SERVER.URL-', rmsClient.Connection.Url")
        NAVCommand(data.device, "'CONFIG.SERVER.PASSWORD-', rmsClient.Connection.Password")
        NAVCommand(data.device, "'CONFIG.CLIENT.ENABLED-', rmsClient.Connection.Enabled")
        NAVCommand(data.device, "'CLIENT.REINIT'")
        #END_IF

        NAVErrorLog(NAV_LOG_LEVEL_INFO,
                    "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Adapter Device Online'")
    }
    offline: {
        NAVErrorLog(NAV_LOG_LEVEL_INFO,
                    "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Adapter Device Offline'")
    }
    onerror: {
        NAVErrorLog(NAV_LOG_LEVEL_INFO,
                    "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Adapter Device OnError: ', data.text")
    }
    awake: {
        NAVErrorLog(NAV_LOG_LEVEL_INFO,
                    "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Adapter Device Awake'")
    }
    standby: {
        NAVErrorLog(NAV_LOG_LEVEL_INFO,
                    "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Adapter Device Standby'")
    }
    string: {
        NAVErrorLog(NAV_LOG_LEVEL_INFO,
                    "'String from RMS Adapter ', NAVConvertDPSToAscii(data.device), '-[', data.text, ']'")
    }
    command: {
        stack_var integer x
        stack_var _NAVSnapiMessage message

        NAVParseSnapiMessage(data.text, message)

        switch (upper_string(message.Header)) {
            // Client Exception Notifications
            case 'EXCEPTION': {
                NAVErrorLog(NAV_LOG_LEVEL_ERROR,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Exception: ', message.Parameter[1]")

                if (length_array(message.Parameter[2])) {
                    NAVErrorLog(NAV_LOG_LEVEL_ERROR,
                                "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Thrown by Command Header: ', NAVStripRight(message.Parameter[2], 1)")
                }
            }

            // Client Event Notifications
            case 'CLIENT.ONLINE': {
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Client Online'")
            }
            case 'CLIENT.REGISTERED': {
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Client Registered'")
            }
            case 'CLIENT.OFFLINE': {
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Client Offline'")
            }
            case 'CLIENT.CONNECTION.STATE.TRANSITION': {
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Connection State Transition: '")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Old State: ', message.Parameter[1]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   New State: ', message.Parameter[2]")
            }
            case 'VERSIONS': {
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Versions'")
            }
            case 'SYSTEM.POWER.ON': {
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' System Power On'")
            }
            case 'SYSTEM.POWER.OFF': {
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' System Power Off'")
            }
            case 'SERVER.INFO': {
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Server Info: '")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   App Version: ', message.Parameter[1]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Database Version: ', message.Parameter[2]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Timesync Enabled: ', message.Parameter[3]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Smtp Enabled: ', message.Parameter[4]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Min Poll Time: ', message.Parameter[5]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Max Poll Time: ', message.Parameter[6]")
            }

            // Client Location Event Notifications
            case 'LOCATION': {
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Location: '")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Client Default Location: ', message.Parameter[1]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   ID: ', message.Parameter[2]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Name: ', message.Parameter[3]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Owner: ', message.Parameter[4]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Phone Number: ', message.Parameter[5]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Occupancy: ', message.Parameter[6]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Prestige Name: ', message.Parameter[7]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Timezone: ', message.Parameter[8]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Asset Licensed: ', message.Parameter[9]")
            }

            // Client Config Change Event Notifications
            case 'CONFIG.CHANGE': {
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Config Change: '")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Key: ', message.Parameter[1]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Value: ', message.Parameter[2]")
            }

            // Asset Registration Event Notifications
            case 'ASSET.REGISTER': {
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Asset Register'")
            }
            case 'ASSET.REGISTERED': {
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Asset Registered: '")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Asset Client Key: ', message.Parameter[1]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Asset ID: ', message.Parameter[2]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   New Registration: ', message.Parameter[3]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Asset DPS: ', message.Parameter[4]")
            }
            case 'ASSSET.LOCATION.CHANGE': {
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Asset Location Change: '")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Asset Client Key: ', message.Parameter[1]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Asset ID: ', message.Parameter[2]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   New Location ID: ', message.Parameter[3]")
            }

            // Asset Parameter Event Notifications
            case 'ASSET.PARAM.UPDATE': {
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Asset Parameter Update: '")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Asset Client Key: ', message.Parameter[1]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Parameter Key: ', message.Parameter[2]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Change Operator: ', message.Parameter[3]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Change Value: ', message.Parameter[4]")
            }
            case 'ASSET.PARAM.VALUE': {
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Asset Parameter Value: '")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Asset Client Key: ', message.Parameter[1]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Parameter Key: ', message.Parameter[2]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Parameter Name: ', message.Parameter[3]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Parameter Value: ', message.Parameter[4]")
            }
            case 'ASSET.PARAM.RESET': {
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Asset Parameter Reset: '")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Asset Client Key: ', message.Parameter[1]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Parameter Key: ', message.Parameter[2]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Parameter Name: ', message.Parameter[3]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Parameter Value: ', message.Parameter[4]")
            }

            // Asset Control Methods Event Notifications
            case 'ASSET.METHOD.EXECUTE': {
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Asset Method Execute: '")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Asset Client Key: ', message.Parameter[1]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Method Key: ', message.Parameter[2]")

                // Loop through the parameters
                for (x = 3; x <= length_array(message.Parameter); x++) {
                    stack_var integer index

                    if (message.Parameter[x] == '') {
                        break
                    }

                    index = x - 2
                    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                                "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Method Argument ', itoa(index), ': ', message.Parameter[x]")
                }
            }

            // Hotlist Event Notifications
            case 'HOTLIST.COUNT': {
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Hotlist Count: '")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Client Default Location: ', message.Parameter[1]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Location ID: ', message.Parameter[2]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Record Count: ', message.Parameter[3]")
            }

            // Messaging Event Notifications
            case 'MESSAGE.DISPLAY': {
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Message Display: '")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Type: ', message.Parameter[1]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Title: ', message.Parameter[2]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Body: ', message.Parameter[3]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Timeout Seconds: ', message.Parameter[4]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Modal: ', message.Parameter[5]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Response Message: ', message.Parameter[6]")
            }

            default: {
                if (length_array(data.text)) {
                    NAVErrorLog(NAV_LOG_LEVEL_INFO,
                                "'Command from RMS Adapter ', NAVConvertDPSToAscii(data.device), '-[', data.text, ']'")
                }
            }
        }
    }
}

#END_IF // __NAV_FOUNDATION_RMSBASE__
