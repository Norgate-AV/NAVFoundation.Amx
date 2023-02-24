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
#DEFINE __NAV_FOUNDATION_RMSBASE__

#include 'NAVFoundation.Core.axi'


DEFINE_DEVICE
dvMaster                = 0:1:0

#IF_NOT_DEFINED vdvRMS
vdvRMS                  = 41001:1:0
#END_IF

#IF_NOT_DEFINED vdvRmsSourceUsage
vdvRMSSourceUsage       = 33000:1:0
#END_IF


DEFINE_CONSTANT


DEFINE_TYPE


DEFINE_VARIABLE


#include 'RmsApi.axi'
#include 'RmsSourceUsage.axi'


DEFINE_START {
    RmsSourceUsageReset()
}


define_module 'RmsNetLinxAdapter_dr4_0_0' RmsNetLinxAdapterComm(vdvRMS)

define_module 'RmsControlSystemMonitor' RmsControlSystemMonitorComm(vdvRMS, dvMaster)
define_module 'RmsSystemPowerMonitor' RmsSystemPowerMonitorComm(vdvRMS, dvMaster)


DEFINE_EVENT

data_event[vdvRms] {
    online: {
        NAVCommand(data.device, "'CONFIG.CLIENT.NAME-', config.RoomName")
        NAVCommand(data.device, "'CONFIG.SERVER.URL-', config.RmsConnection.Url")
        NAVCommand(data.device, "'CONFIG.SERVER.PASSWORD-', config.RmsConnection.Password")
        NAVCommand(data.device, "'CONFIG.CLIENT.ENABLED-', config.RmsConnection.Enabled")
        NAVCommand(data.device, "'CLIENT.REINIT'")

        NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Adapter Device Online'")
    }
    offline: {
        NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Adapter Device Offline'")
    }
    onerror: {
        NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Adapter Device OnError: ', data.text")
    }
    awake: {
        NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Adapter Device Awake'")
    }
    standby: {
        NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Adapter Device Standby'")
    }
    command: {
        stack_var char header[NAV_MAX_CHARS]
        stack_var char param[10][NAV_MAX_CHARS]
        stack_var integer x

        header = DuetParseCmdHeader(data.text)

        for (x = 1; x <= max_length_array(param); x++) {
            param[x] = DuetParseCmdParam(data.text)
        }

        switch (upper_string(header)) {
            // Client Exception Notifications
            case 'EXCEPTION': {
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Exception: ', param[1]")

                if (length_array(param[2])) {
                    NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Thrown by Command Header: ', param[2]")
                }
            }

            // Client Event Notifications
            case 'CLIENT.ONLINE': {
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Client Online'")
            }
            case 'CLIENT.REGISTERED': {
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Client Registered'")
            }
            case 'CLIENT.OFFLINE': {
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Client Offline'")
            }
            case 'CLIENT.CONNECTION.STATE.TRANSITION': {
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Connection State Transition: '")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Old State: ', param[1]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   New State: ', param[2]")
            }
            case 'VERSIONS': {
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Versions'")
            }
            case 'SYSTEM.POWER.ON': {
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' System Power On'")
            }
            case 'SYSTEM.POWER.OFF': {
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' System Power Off'")
            }
            case 'SERVER.INFO': {
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Server Info: '")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   App Version: ', param[1]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Database Version: ', param[2]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Timesync Enabled: ', param[3]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Smtp Enabled: ', param[4]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Min Poll Time: ', param[5]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Max Poll Time: ', param[6]")
            }

            // Client Location Event Notifications
            case 'LOCATION': {
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Location: '")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Client Default Location: ', param[1]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   ID: ', param[2]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Name: ', param[3]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Owner: ', param[4]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Phone Number: ', param[5]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Occupancy: ', param[6]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Prestige Name: ', param[7]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Timezone: ', param[8]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Asset Licensed: ', param[9]")
            }

            // Client Config Change Event Notifications
            case 'CONFIG.CHANGE': {
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Config Change: '")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Key: ', param[1]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Value: ', param[2]")
            }

            // Asset Registration Event Notifications
            case 'ASSET.REGISTER': {
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Asset Register'")
            }
            case 'ASSET.REGISTERED': {
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Asset Registered: '")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Asset Client Key: ', param[1]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Asset ID: ', param[2]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   New Registration: ', param[3]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Asset DPS: ', param[4]") 
            }
            case 'ASSSET.LOCATION.CHANGE': {
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Asset Location Change: '")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Asset Client Key: ', param[1]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Asset ID: ', param[2]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   New Location ID: ', param[3]")
            }

            // Asset Parameter Event Notifications
            case 'ASSET.PARAM.UPDATE': {
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Asset Parameter Update: '")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Asset Client Key: ', param[1]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Parameter Key: ', param[2]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Change Operator: ', param[3]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Change Value: ', param[4]")
            }
            case 'ASSET.PARAM.VALUE': {
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Asset Parameter Value: '")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Asset Client Key: ', param[1]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Parameter Key: ', param[2]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Parameter Name: ', param[3]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Parameter Value: ', param[4]")
            }
            case 'ASSET.PARAM.RESET': {
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Asset Parameter Reset: '")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Asset Client Key: ', param[1]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Parameter Key: ', param[2]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Parameter Name: ', param[3]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Parameter Value: ', param[4]")
            }

            // Asset Control Methods Event Notifications
            case 'ASSET.METHOD.EXECUTE': {
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Asset Method Execute: '")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Asset Client Key: ', param[1]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Method Key: ', param[2]")
                
                // Loop through the parameters
                for (x = 3; x <= max_length_array(param); x++) {
                    stack_var integer index

                    if (param[x] == '') {
                        break
                    }

                    index = x - 2
                    NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Method Argument ', itoa(index), ': ', param[x]")
                }
            }

            // Hotlist Event Notifications
            case 'HOTLIST.COUNT': {
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Hotlist Count: '")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Client Default Location: ', param[1]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Location ID: ', param[2]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Record Count: ', param[3]")
            }

            // Messaging Event Notifications
            case 'MESSAGE.DISPLAY': {
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), ' Message Display: '")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Type: ', param[1]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Title: ', param[2]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Body: ', param[3]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Timeout Seconds: ', param[4]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Modal: ', param[5]")
                NAVLog("'RMS Adapter ', NAVConvertDPSToAscii(data.device), '   Response Message: ', param[6]")
            }

            default: {
                if (length_array(data.text)) {
                    NAVLog("'Command from RMS Adapter ', NAVConvertDPSToAscii(data.device), '-[', data.text, ']'")
                }
            }
        }
    }
    string: {
        NAVLog("'String from RMS Adapter ', NAVConvertDPSToAscii(data.device), '-[', data.text, ']'")
    }
}

#END_IF // __NAV_FOUNDATION_RMSBASE__