PROGRAM_NAME='NAVFoundation.RmsBase'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2010-2026 Norgate AV

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
#include 'NAVFoundation.RmsEvents.axi'


DEFINE_START {
    RmsSourceUsageReset()
}


define_module 'RmsNetLinxAdapter_dr4_0_0' RmsNetLinxAdapterComm(vdvRMS)
define_module 'RmsControlSystemMonitor' RmsControlSystemMonitorComm(vdvRMS, dvMaster)


#END_IF // __NAV_FOUNDATION_RMSBASE__
