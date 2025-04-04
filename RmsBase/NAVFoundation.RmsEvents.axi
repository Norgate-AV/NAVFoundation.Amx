PROGRAM_NAME='NAVFoundation.RmsEvents'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_RMSEVENTS__
#DEFINE __NAV_FOUNDATION_RMSEVENTS__ 'NAVFoundation.RmsEvents'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.RmsUtils.axi'
#include 'NAVFoundation.ArrayUtils.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'


// #DEFINE USING_NAV_RMS_ADAPTER_ONLINE_EVENT_PRE_CLIENT_CONNECTION_INIT_CALLBACK
// define_function NAVRmsAdapterOnlineEventPreClientConnectionInitCallback(_NAVRmsClient client, tdata args) {}

// #DEFINE USING_NAV_RMS_CLIENT_CONNECTION_INIT_EVENT_CALLBACK
// define_function NAVRmsClientConnectionInitEventCallback(_NAVRmsClient client, tdata args) {}

// #DEFINE USING_NAV_RMS_ADAPTER_ONLINE_EVENT_POST_CLIENT_CONNECTION_INIT_CALLBACK
// define_function NAVRmsAdapterOnlineEventPostClientConnectionInitCallback(_NAVRmsClient client, tdata args) {}

// #DEFINE USING_NAV_RMS_ADAPTER_OFFLINE_EVENT_CALLBACK
// define_function NAVRmsAdapterOfflineEventCallback(_NAVRmsClient client, tdata args) {}

// #DEFINE USING_NAV_RMS_ADAPTER_ONERROR_EVENT_CALLBACK
// define_function NAVRmsAdapterOnErrorEventCallback(_NAVRmsClient client, tdata args) {}

// #DEFINE USING_NAV_RMS_CLIENT_EXCEPTION_EVENT_CALLBACK
// define_function NAVRmsClientExceptionEventCallback(_NAVRmsClient client, tdata args) {}

// #DEFINE USING_NAV_RMS_CLIENT_ONLINE_EVENT_CALLBACK
// define_function NAVRmsClientOnlineEventCallback(_NAVRmsClient client, tdata args) {}

// #DEFINE USING_NAV_RMS_CLIENT_OFFLINE_EVENT_CALLBACK
// define_function NAVRmsClientOfflineEventCallback(_NAVRmsClient client, tdata args) {}

// #DEFINE USING_NAV_RMS_CLIENT_REGISTERED_EVENT_CALLBACK
// define_function NAVRmsClientRegisteredEventCallback(_NAVRmsClient client, tdata args) {}

// #DEFINE USING_NAV_RMS_CLIENT_CONNECTION_STATE_TRANSITION_EVENT_CALLBACK
// define_function NAVRmsClientConnectionStateTransitionEventCallback(_NAVRmsClient client, tdata args) {}

// #DEFINE USING_NAV_RMS_CLIENT_VERSIONS_EVENT_CALLBACK
// define_function NAVRmsClientVersionsEventCallback(_NAVRmsClient client, tdata args) {}

// #DEFINE USING_NAV_RMS_CLIENT_SYSTEM_POWER_ON_EVENT_CALLBACK
// define_function NAVRmsClientSystemPowerOnEventCallback(_NAVRmsClient client, tdata args) {}

// #DEFINE USING_NAV_RMS_CLIENT_SYSTEM_POWER_OFF_EVENT_CALLBACK
// define_function NAVRmsClientSystemPowerOffEventCallback(_NAVRmsClient client, tdata args) {}

// #DEFINE USING_NAV_RMS_CLIENT_SERVER_INFO_EVENT_CALLBACK
// define_function NAVRmsClientServerInfoEventCallback(_NAVRmsClient client, tdata args) {}

// #DEFINE USING_NAV_RMS_CLIENT_LOCATION_EVENT_CALLBACK
// define_function NAVRmsClientLocationEventCallback(_NAVRmsClient client, tdata args) {}

// #DEFINE USING_NAV_RMS_CLIENT_ASSETS_REGISTER_EVENT_CALLBACK
// define_function NAVRmsClientAssetsRegisterEventCallback(_NAVRmsClient client, tdata args) {}

// #DEFINE USING_NAV_RMS_CLIENT_ASSET_REGISTERED_EVENT_CALLBACK
// define_function NAVRmsClientAssetRegisteredEventCallback(_NAVRmsClient client, _NAVRmsRegisteredAsset asset) {}

// #DEFINE USING_NAV_RMS_CLIENT_ASSET_REGISTER_METADATA_CALLBACK
// define_function NAVRmsClientAssetRegisterMetadataCallback(_NAVRmsClient client, _NAVRmsRegisteredAsset asset) {}

// #DEFINE USING_NAV_RMS_CLIENT_ASSET_REGISTER_PARAMETERS_CALLBACK
// define_function NAVRmsClientAssetRegisterParametersCallback(_NAVRmsClient client, _NAVRmsRegisteredAsset asset) {}

// #DEFINE USING_NAV_RMS_CLIENT_ASSET_REGISTER_CONTROL_METHODS_CALLBACK
// define_function NAVRmsClientAssetRegisterControlMethodsCallback(_NAVRmsClient client, _NAVRmsRegisteredAsset asset) {}

// #DEFINE USING_NAV_RMS_CLIENT_ASSET_RELOCATED_EVENT_CALLBACK
// define_function NAVRmsClientAssetRelocatedEventCallback(_NAVRmsClient client, tdata args) {}

// #DEFINE USING_NAV_RMS_CLIENT_ASSET_METHOD_EXECUTE_EVENT_CALLBACK
// define_function NAVRmsClientAssetMethodExecuteEventCallback(_NAVRmsClient client, _NAVRmsAssetMethodExecuteEvent event) {}

// #DEFINE USING_NAV_RMS_CLIENT_CONFIG_CHANGE_EVENT_CALLBACK
// define_function NAVRmsClientConfigChangeEventCallback(_NAVRmsClient client, tdata args) {}

// #DEFINE USING_NAV_RMS_CLIENT_HOTLIST_COUNT_EVENT_CALLBACK
// define_function NAVRmsClientHotlistCountEventCallback(_NAVRmsClient client, tdata args) {}

// #DEFINE USING_NAV_RMS_CLIENT_MESSAGE_DISPLAY_EVENT_CALLBACK
// define_function NAVRmsClientMessageDisplayEventCallback(_NAVRmsClient client, tdata args) {}

// #DEFINE_USING_NAV_RMS_ADAPTER_BUTTON_PUSH_EVENT_CALLBACK
// define_function NAVRmsAdapterButtonPushEventCallback(_NAVRmsClient client, tbutton args) {}

// #DEFINE_USING_NAV_RMS_ADAPTER_BUTTON_RELEASE_EVENT_CALLBACK
// define_function NAVRmsAdapterButtonReleaseEventCallback(_NAVRmsClient client, tbutton args) {}

// #DEFINE_USING_NAV_RMS_ADAPTER_CHANNEL_ON_EVENT_CALLBACK
// define_function NAVRmsAdapterChannelOnEventCallback(_NAVRmsClient client, tchannel args) {}

// #DEFINE_USING_NAV_RMS_ADAPTER_CHANNEL_OFF_EVENT_CALLBACK
// define_function NAVRmsAdapterChannelOffEventCallback(_NAVRmsClient client, tchannel args) {}

// #DEFINE_USING_NAV_RMS_ADAPTER_LEVEL_EVENT_CALLBACK
// define_function NAVRmsAdapterLevelEventCallback(_NAVRmsClient client, tlevel args) {}


DEFINE_EVENT

#IF_DEFINED USING_RMS
data_event[vdvRms] {
    online: {
        NAVRmsClientInit(rmsClient, data)

        #IF_DEFINED USING_NAV_RMS_ADAPTER_ONLINE_EVENT_PRE_CLIENT_CONNECTION_INIT_CALLBACK
        NAVRmsAdapterOnlineEventPreClientConnectionInitCallback(rmsClient, data)
        #END_IF

        #IF_DEFINED USING_NAV_RMS_CLIENT_CONNECTION_INIT_EVENT_CALLBACK
        NAVRmsClientConnectionInitEventCallback(rmsClient, data)
        NAVRmsAdapterConnectionInit(rmsClient)
        #ELSE
        #warn 'USING_NAV_RMS_CLIENT_CONNECTION_INIT_EVENT_CALLBACK not defined'
        #warn 'RMS Client will not be configured and will not connect to the RMS Server!!!'
        #END_IF

        #IF_DEFINED USING_NAV_RMS_ADAPTER_ONLINE_EVENT_POST_CLIENT_CONNECTION_INIT_CALLBACK
        NAVRmsAdapterOnlineEventPostClientConnectionInitCallback(rmsClient, data)
        #END_IF

        NAVErrorLog(NAV_LOG_LEVEL_INFO,
                    "'RMS Adapter [', NAVDeviceToString(data.device), '] Adapter Device Online'")
    }
    offline: {
        #IF_DEFINED USING_NAV_RMS_ADAPTER_OFFLINE_EVENT_CALLBACK
        NAVRmsAdapterOfflineEventCallback(rmsClient, data)
        #END_IF

        NAVErrorLog(NAV_LOG_LEVEL_INFO,
                    "'RMS Adapter [', NAVDeviceToString(data.device), '] Adapter Device Offline'")
    }
    onerror: {
        #IF_DEFINED USING_NAV_RMS_ADAPTER_ONERROR_EVENT_CALLBACK
        NAVRmsAdapterOnErrorEventCallback(rmsClient, data)
        #END_IF

        NAVErrorLog(NAV_LOG_LEVEL_INFO,
                    "'RMS Adapter [', NAVDeviceToString(data.device), '] Adapter Device OnError: ', data.text")
    }
    command: {
        stack_var _NAVSnapiMessage message

        NAVParseSnapiMessage(data.text, message)

        switch (upper_string(message.Header)) {
            // Client Exception Notifications
            case RMS_EVENT_EXCEPTION: {
                rmsClient.Exception.Message = message.Parameter[1]

                if (length_array(message.Parameter[2])) {
                    rmsClient.Exception.ThrownByCommand = message.Parameter[2]
                }

                #IF_DEFINED USING_NAV_RMS_CLIENT_EXCEPTION_EVENT_CALLBACK
                NAVRmsClientExceptionEventCallback(rmsClient, data)
                #END_IF

                NAVRmsExceptionLog(rmsClient.Exception, data)
            }

            // Client Event Notifications
            case RMS_EVENT_CLIENT_ONLINE: {
                rmsClient.IsOnline = true

                #IF_DEFINED USING_NAV_RMS_CLIENT_ONLINE_EVENT_CALLBACK
                NAVRmsClientOnlineEventCallback(rmsClient, data)
                #END_IF

                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Client [', NAVDeviceToString(data.device), '] Client Online'")
            }
            case RMS_EVENT_CLIENT_REGISTERED: {
                rmsClient.IsRegistered = true

                #IF_DEFINED USING_NAV_RMS_CLIENT_REGISTERED_EVENT_CALLBACK
                NAVRmsClientRegisteredEventCallback(rmsClient, data)
                #END_IF

                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Client [', NAVDeviceToString(data.device), '] Client Registered'")
            }
            case RMS_EVENT_CLIENT_OFFLINE: {
                rmsClient.IsOnline = false

                #IF_DEFINED USING_NAV_RMS_CLIENT_OFFLINE_EVENT_CALLBACK
                NAVRmsClientOfflineEventCallback(rmsClient, data)
                #END_IF

                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Client [', NAVDeviceToString(data.device), '] Client Offline'")
            }
            case RMS_EVENT_CLIENT_STATE_TRANSITION: {
                rmsClient.ConnectionState.OldState = message.Parameter[1]
                rmsClient.ConnectionState.NewState = message.Parameter[2]

                #IF_DEFINED USING_NAV_RMS_CLIENT_CONNECTION_STATE_TRANSITION_EVENT_CALLBACK
                NAVRmsClientConnectionStateTransitionEventCallback(rmsClient, data)
                #END_IF

                NAVRmsClientConnectionStateLog(rmsClient.ConnectionState, data)
            }
            case RMS_EVENT_VERSION_REQUEST: {
                #IF_DEFINED USING_NAV_RMS_CLIENT_VERSIONS_EVENT_CALLBACK
                NAVRmsClientVersionsEventCallback(rmsClient, data)
                #END_IF

                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Client [', NAVDeviceToString(data.device), '] Version Information Request'")
            }
            case RMS_EVENT_SYSTEM_POWER_ON: {
                #IF_DEFINED USING_NAV_RMS_CLIENT_SYSTEM_POWER_ON_EVENT_CALLBACK
                NAVRmsClientSystemPowerOnEventCallback(rmsClient, data)
                #END_IF

                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Client [', NAVDeviceToString(data.device), '] System Power On'")
            }
            case RMS_EVENT_SYSTEM_POWER_OFF: {
                #IF_DEFINED USING_NAV_RMS_CLIENT_SYSTEM_POWER_OFF_EVENT_CALLBACK
                NAVRmsClientSystemPowerOffEventCallback(rmsClient, data)
                #END_IF

                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Client [', NAVDeviceToString(data.device), '] System Power Off'")
            }
            case NAV_RMS_CLIENT_EVENT_SERVER_INFO: {
                rmsClient.ServerInformation.AppVersion = message.Parameter[1]
                rmsClient.ServerInformation.DatabaseVersion = message.Parameter[2]
                rmsClient.ServerInformation.TimesyncEnabled = NAVStringToBoolean(message.Parameter[3])
                rmsClient.ServerInformation.SmtpEnabled = NAVStringToBoolean(message.Parameter[4])

                // message.Parameter[5] is undocumented. It is a Boolean string value.

                rmsClient.ServerInformation.MinPollTime = atoi(message.Parameter[6])
                rmsClient.ServerInformation.MaxPollTime = atoi(message.Parameter[7])

                #IF_DEFINED USING_NAV_RMS_CLIENT_SERVER_INFO_EVENT_CALLBACK
                NAVRmsClientServerInfoEventCallback(rmsClient, data)
                #END_IF

                NAVRmsClientServerInformationLog(rmsClient.ServerInformation, data)
            }

            // Client Location Event Notifications
            case RMS_EVENT_LOCATION_INFORMATION: {
                rmsClient.Location.ClientDefaultLocation = NAVStringToBoolean(message.Parameter[1])
                rmsClient.Location.Id = message.Parameter[2]
                rmsClient.Location.Name = message.Parameter[3]
                rmsClient.Location.Owner = message.Parameter[4]
                rmsClient.Location.PhoneNumber = message.Parameter[5]
                rmsClient.Location.Occupancy = message.Parameter[6]
                rmsClient.Location.PrestigeName = message.Parameter[7]
                rmsClient.Location.Timezone = message.Parameter[8]
                rmsClient.Location.AssetLicensed = NAVStringToBoolean(message.Parameter[9])

                #IF_DEFINED USING_NAV_RMS_CLIENT_LOCATION_EVENT_CALLBACK
                NAVRmsClientLocationEventCallback(rmsClient, data)
                #END_IF

                NAVRmsClientLocationLog(rmsClient.Location, data)
            }

            // Client Config Change Event Notifications
            case RMS_EVENT_CONFIGURATION_CHANGE: {
                rmsClient.ConfigChange.Key = message.Parameter[1]
                rmsClient.ConfigChange.Value = message.Parameter[2]

                #IF_DEFINED USING_NAV_RMS_CLIENT_CONFIG_CHANGE_EVENT_CALLBACK
                NAVRmsClientConfigChangeEventCallback(rmsClient, data)
                #END_IF

                NAVRmsClientConfigChangeLog(rmsClient.ConfigChange, data)
            }

            // Asset Registration Event Notifications
            case RMS_EVENT_ASSETS_REGISTER: {
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Client [', NAVDeviceToString(data.device), '] Assets Register Request'")

                #IF_DEFINED USING_NAV_RMS_CLIENT_ASSETS_REGISTER_EVENT_CALLBACK
                NAVRmsClientAssetsRegisterEventCallback(rmsClient, data)
                #END_IF
            }
            case RMS_EVENT_ASSET_REGISTERED: {
                stack_var _NAVRmsRegisteredAsset asset

                asset.Key = message.Parameter[1]
                asset.Id = message.Parameter[2]
                asset.NewRegistration = NAVStringToBoolean(message.Parameter[3])
                NAVStringToDevice(message.Parameter[4], asset.Device)

                if (asset.Device == 0:1:0) {
                    rmsClient.ClientKey = asset.Key
                }

                NAVRmsClientAssetRegisteredLog(asset, data)

                #IF_DEFINED USING_NAV_RMS_CLIENT_ASSET_REGISTERED_EVENT_CALLBACK
                NAVRmsClientAssetRegisteredEventCallback(rmsClient, asset)
                #END_IF

                #IF_DEFINED USING_NAV_RMS_CLIENT_ASSET_REGISTER_METADATA_CALLBACK
                NAVRmsClientAssetRegisterMetadataCallback(rmsClient, asset)
                #END_IF

                #IF_DEFINED USING_NAV_RMS_CLIENT_ASSET_REGISTER_PARAMETERS_CALLBACK
                NAVRmsClientAssetRegisterParametersCallback(rmsClient, asset)
                #END_IF

                #IF_DEFINED USING_NAV_RMS_CLIENT_ASSET_REGISTER_CONTROL_METHODS_CALLBACK
                NAVRmsClientAssetRegisterControlMethodsCallback(rmsClient, asset)
                #END_IF
            }
            case RMS_EVENT_ASSET_RELOCATED: {
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Client [', NAVDeviceToString(data.device), '] Asset Location Change: '")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Client [', NAVDeviceToString(data.device), ']   Asset Client Key: ', message.Parameter[1]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Client [', NAVDeviceToString(data.device), ']   Asset ID: ', message.Parameter[2]")
                NAVErrorLog(NAV_LOG_LEVEL_INFO,
                            "'RMS Client [', NAVDeviceToString(data.device), ']   New Location ID: ', message.Parameter[3]")

                #IF_DEFINED USING_NAV_RMS_CLIENT_ASSET_RELOCATED_EVENT_CALLBACK
                NAVRmsClientAssetRelocatedEventCallback(rmsClient, data)
                #END_IF
            }

            // Asset Parameter Event Notifications
            // case RMS_EVENT_ASSET_PARAM_UPDATE: {
            //     NAVErrorLog(NAV_LOG_LEVEL_INFO,
            //                 "'RMS Client [', NAVDeviceToString(data.device), '] Asset Parameter Update: '")
            //     NAVErrorLog(NAV_LOG_LEVEL_INFO,
            //                 "'RMS Client [', NAVDeviceToString(data.device), ']   Asset Client Key: ', message.Parameter[1]")
            //     NAVErrorLog(NAV_LOG_LEVEL_INFO,
            //                 "'RMS Client [', NAVDeviceToString(data.device), ']   Parameter Key: ', message.Parameter[2]")
            //     NAVErrorLog(NAV_LOG_LEVEL_INFO,
            //                 "'RMS Client [', NAVDeviceToString(data.device), ']   Change Operator: ', message.Parameter[3]")
            //     NAVErrorLog(NAV_LOG_LEVEL_INFO,
            //                 "'RMS Client [', NAVDeviceToString(data.device), ']   Change Value: ', message.Parameter[4]")
            // }
            // case RMS_EVENT_ASSET_PARAM_VALUE: {
            //     NAVErrorLog(NAV_LOG_LEVEL_INFO,
            //                 "'RMS Client [', NAVDeviceToString(data.device), '] Asset Parameter Value: '")
            //     NAVErrorLog(NAV_LOG_LEVEL_INFO,
            //                 "'RMS Client [', NAVDeviceToString(data.device), ']   Asset Client Key: ', message.Parameter[1]")
            //     NAVErrorLog(NAV_LOG_LEVEL_INFO,
            //                 "'RMS Client [', NAVDeviceToString(data.device), ']   Parameter Key: ', message.Parameter[2]")
            //     NAVErrorLog(NAV_LOG_LEVEL_INFO,
            //                 "'RMS Client [', NAVDeviceToString(data.device), ']   Parameter Name: ', message.Parameter[3]")
            //     NAVErrorLog(NAV_LOG_LEVEL_INFO,
            //                 "'RMS Client [', NAVDeviceToString(data.device), ']   Parameter Value: ', message.Parameter[4]")
            // }
            // case RMS_EVENT_ASSET_PARAM_RESET: {
            //     NAVErrorLog(NAV_LOG_LEVEL_INFO,
            //                 "'RMS Client [', NAVDeviceToString(data.device), '] Asset Parameter Reset: '")
            //     NAVErrorLog(NAV_LOG_LEVEL_INFO,
            //                 "'RMS Client [', NAVDeviceToString(data.device), ']   Asset Client Key: ', message.Parameter[1]")
            //     NAVErrorLog(NAV_LOG_LEVEL_INFO,
            //                 "'RMS Client [', NAVDeviceToString(data.device), ']   Parameter Key: ', message.Parameter[2]")
            //     NAVErrorLog(NAV_LOG_LEVEL_INFO,
            //                 "'RMS Client [', NAVDeviceToString(data.device), ']   Parameter Name: ', message.Parameter[3]")
            //     NAVErrorLog(NAV_LOG_LEVEL_INFO,
            //                 "'RMS Client [', NAVDeviceToString(data.device), ']   Parameter Value: ', message.Parameter[4]")
            // }

            // Asset Control Methods Event Notifications
            case RMS_EVENT_ASSET_METHOD_EXECUTE: {
                stack_var _NAVRmsAssetMethodExecuteEvent event

                event.AssetKey = message.Parameter[1]
                event.Method = message.Parameter[2]

                if (length_array(message.Parameter) > 2) {
                    NAVArraySliceString(message.Parameter, 3, length_array(message.Parameter), event.Parameter)
                }

                NAVRmsClientAssetMethodExecuteLog(event, data)

                #IF_DEFINED USING_NAV_RMS_CLIENT_ASSET_METHOD_EXECUTE_EVENT_CALLBACK
                NAVRmsClientAssetMethodExecuteEventCallback(rmsClient, event)
                #END_IF
            }

            // Hotlist Event Notifications
            case RMS_EVENT_HOTLIST_RECORD_COUNT: {
                rmsClient.Hotlist.ClientDefaultLocation = NAVStringToBoolean(message.Parameter[1])
                rmsClient.Hotlist.LocationId = atoi(message.Parameter[2])
                rmsClient.Hotlist.Count = atoi(message.Parameter[3])

                #IF_DEFINED USING_NAV_RMS_CLIENT_HOTLIST_COUNT_EVENT_CALLBACK
                NAVRmsClientHotlistCountEventCallback(rmsClient, data)
                #END_IF

                NAVRmsHotlistLog(rmsClient.Hotlist, data)
            }

            // Messaging Event Notifications
            case RMS_EVENT_DISPLAY_MESSAGE: {
                rmsClient.Message.Type = message.Parameter[1]
                rmsClient.Message.Title = message.Parameter[2]
                rmsClient.Message.Body = message.Parameter[3]
                rmsClient.Message.TimeOutSeconds = atoi(message.Parameter[4])
                rmsClient.Message.Modal = NAVStringToBoolean(message.Parameter[5])
                rmsClient.Message.ResponseMessage = message.Parameter[6]

                #IF_DEFINED USING_NAV_RMS_CLIENT_MESSAGE_DISPLAY_EVENT_CALLBACK
                NAVRmsClientMessageDisplayEventCallback(rmsClient, data)
                #END_IF

                NAVRmsMessageDisplayLog(rmsClient.Message, data)
            }
        }
    }
}


button_event[vdvRMS, 0] {
    push: {
        #IF_DEFINED USING_NAV_RMS_ADAPTER_BUTTON_PUSH_EVENT_CALLBACK
        NAVRmsAdapterButtonPushEventCallback(rmsClient, button)
        #END_IF
    }
    release: {
        #IF_DEFINED USING_NAV_RMS_ADAPTER_BUTTON_RELEASE_EVENT_CALLBACK
        NAVRmsAdapterButtonReleaseEventCallback(rmsClient, button)
        #END_IF
    }
}


channel_event[vdvRMS, 0] {
    on: {
        #IF_DEFINED USING_NAV_RMS_ADAPTER_CHANNEL_ON_EVENT_CALLBACK
        NAVRmsAdapterChannelOnEventCallback(rmsClient, channel)
        #END_IF
    }
    off: {
        #IF_DEFINED USING_NAV_RMS_ADAPTER_CHANNEL_OFF_EVENT_CALLBACK
        NAVRmsAdapterChannelOffEventCallback(rmsClient, channel)
        #END_IF
    }
}


level_event[vdvRMS, 0] {
    #IF_DEFINED USING_NAV_RMS_ADAPTER_LEVEL_EVENT_CALLBACK
    NAVRmsAdapterLevelEventCallback(rmsClient, level)
    #END_IF
}
#END_IF


#END_IF // __NAV_FOUNDATION_RMSEVENTS__
