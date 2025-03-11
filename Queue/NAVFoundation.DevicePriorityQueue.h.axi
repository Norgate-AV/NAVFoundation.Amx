PROGRAM_NAME='NAVFoundation.DevicePriorityQueue.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_DEVICE_PRIORITY_QUEUE_H__
#DEFINE __NAV_FOUNDATION_DEVICE_PRIORITY_QUEUE_H__

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

constant long TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE = 501
constant long TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE_TIME = 2500

constant integer NAV_DEVICE_PRIORITY_QUEUE_MAX_FAILED_RESPONSE_COUNT = 3

constant integer NAV_DEVICE_PRIORITY_QUEUE_COMMAND_QUEUE_SIZE = 50
constant integer NAV_DEVICE_PRIORITY_QUEUE_QUERY_QUEUE_SIZE = 100


(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

struct _NAVDevicePriorityQueueFailedResponseTimeline {
    long Id
    long Time[1]
}


struct _NAVDevicePriorityQueue {
    _NAVQueue CommandQueue
    _NAVQueue QueryQueue

    _NAVDevicePriorityQueueFailedResponseTimeline FailedResponseTimeline

    integer Busy
    integer FailedCount
    integer MaxFailedCount
    integer Resend
    char LastMessage[NAV_MAX_BUFFER]
}


#END_IF  // __NAV_FOUNDATION_DEVICE_PRIORITY_QUEUE_H__
