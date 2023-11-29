PROGRAM_NAME='NAVFoundation.EnovaDxXBase'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_ENOVA_DXX_BASE__
#DEFINE __NAV_FOUNDATION_ENOVA_DXX_BASE__ 'NAVFoundation.EnovaDxXBase'


DEFINE_DEVICE

dvEnovaDxXPort_1    =   5002:1:0
dvEnovaDxXPort_2    =   5002:2:0
dvEnovaDxXPort_3    =   5002:3:0
dvEnovaDxXPort_4    =   5002:4:0
dvEnovaDxXPort_5    =   5002:5:0
dvEnovaDxXPort_6    =   5002:6:0
dvEnovaDxXPort_7    =   5002:7:0
dvEnovaDxXPort_8    =   5002:8:0
dvEnovaDxXPort_9    =   5002:9:0
dvEnovaDxXPort_10   =   5002:10:0
dvEnovaDxXPort_11   =   5002:11:0
dvEnovaDxXPort_12   =   5002:12:0
dvEnovaDxXPort_13   =   5002:13:0
dvEnovaDxXPort_14   =   5002:14:0


DEFINE_CONSTANT

constant dev DVA_ENOVA_DXX[]    =   {
                                        dvEnovaDxXPort_1,
                                        dvEnovaDxXPort_2,
                                        dvEnovaDxXPort_3,
                                        dvEnovaDxXPort_4,
                                        dvEnovaDxXPort_5,
                                        dvEnovaDxXPort_6,
                                        dvEnovaDxXPort_7,
                                        dvEnovaDxXPort_8,
                                        dvEnovaDxXPort_9,
                                        dvEnovaDxXPort_10,
                                        dvEnovaDxXPort_11,
                                        dvEnovaDxXPort_12,
                                        dvEnovaDxXPort_13,
                                        dvEnovaDxXPort_14
                                    }


#include 'NAVFoundation.EnovaDxX.axi'


#END_IF