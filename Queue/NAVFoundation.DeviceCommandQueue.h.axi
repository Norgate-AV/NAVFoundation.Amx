PROGRAM_NAME='NAVFoundation.DeviceCommandQueue.h'

#IF_NOT_DEFINED __NAV_FOUNDATION_DEVICE_COMMAND_QUEUE_H__
#DEFINE __NAV_FOUNDATION_DEVICE_COMMAND_QUEUE_H__

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Queue.h.axi'

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT


(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

struct _NAVDeviceCommandQueue {
    integer Busy
    integer FailedCount
    integer Resend
    char LastMessage[NAV_MAX_BUFFER]
    _NAVQueue Commands
    _NAVQueue Queries
}


#END_IF  // __NAV_FOUNDATION_DEVICE_COMMAND_QUEUE_H__
