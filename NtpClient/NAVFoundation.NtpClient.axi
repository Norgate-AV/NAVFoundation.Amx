PROGRAM_NAME='NAVFoundation.NtpClient'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_NTP_CLIENT__
#DEFINE __NAV_FOUNDATION_NTP_CLIENT__ 'NAVFoundation.NtpClient'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.DateTimeUtils.axi'
#include 'NAVFoundation.Encoding.axi'


DEFINE_CONSTANT

constant char NAV_DEFAULT_NTP_HOST_ADDRESS[] = 'uk.pool.ntp.org'
constant integer NAV_NTP_PORT = 123

constant long NTP_SYNC_INTERVAL_1_MIN = 60000
constant long NTP_SYNC_INTERVAL_5_MINS = 300000
constant long NTP_SYNC_INTERVAL_DEFAULT = NTP_SYNC_INTERVAL_5_MINS

constant long NAV_DEFAULT_NTP_CLIENT_TIMEOUT = 1000

constant integer NAV_NTP_PACKET_SIZE = 48
constant double NAV_NTP_TIMESTAMP_DELTA = 2208988800


DEFINE_TYPE

struct _NAVNtpPacket {
    char LiVnMode;              // Eight bits. li, vn, and mode.
                                // li.   Two bits.   Leap indicator.
                                // vn.   Three bits. Version number of the protocol.
                                // mode. Three bits. Client will pick mode 3 for client.

    char Stratum;               // Eight bits. Stratum level of the local clock.
    char Poll;                  // Eight bits. Maximum interval between successive messages.
    char Precision;             // Eight bits. Precision of the local clock.

    long RootDelay;             // 32 bits. Total round trip delay time.
    long RootDispersion;        // 32 bits. Max error aloud from primary clock source.
    long ReferenceId;           // 32 bits. Reference clock identifier.

    long ReferenceTimestampS;   // 32 bits. Reference time-stamp seconds.
    long ReferenceTimestampF;   // 32 bits. Reference time-stamp fraction of a second.

    long OriginateTimestampS;   // 32 bits. Originate time-stamp seconds.
    long OriginateTimestampF;   // 32 bits. Originate time-stamp fraction of a second.

    long ReceiveTimestampS;     // 32 bits. Received time-stamp seconds.
    long ReceiveTimestampF;     // 32 bits. Received time-stamp fraction of a second.

    long TransmitTimestampS;    // 32 bits and the most important field the client cares about. Transmit time-stamp seconds.
    long TransmitTimestampF;    // 32 bits. Transmit time-stamp fraction of a second.

    // Total: 384 bits or 48 bytes.
}


struct _NAVNtpClient {
    dev Device
    integer Socket

    _NAVSocketConnection SocketConnection
    _NAVNtpPacket Packet

    long SyncInterval[1]
    long TimeOut[1]
}


define_function NAVNtpPacketInit(_NAVNtpPacket packet) {
    packet.LiVnMode = $1B
    packet.Stratum = 0
    packet.Poll = 0
    packet.Precision = 0
    packet.RootDelay = 0
    packet.RootDispersion = 0
    packet.ReferenceId = 0
    packet.ReferenceTimestampS = 0
    packet.ReferenceTimestampF = 0
    packet.OriginateTimestampS = 0
    packet.OriginateTimestampF = 0
    packet.ReceiveTimestampS = 0
    packet.ReceiveTimestampF = 0
    packet.TransmitTimestampS = 0
    packet.TransmitTimestampF = 0
}


define_function NAVNtpClientSocketConnectionInit(_NAVSocketConnection connection) {
    connection.Address = NAV_DEFAULT_NTP_HOST_ADDRESS
    connection.Port = NAV_NTP_PORT
}


define_function NAVNtpClientInit(_NAVNtpClient client, dev device) {
    client.Device = device
    client.Socket = client.Device.PORT

    client.SyncInterval[1] = NTP_SYNC_INTERVAL_DEFAULT
    set_length_array(client.SyncInterval, 1)

    client.TimeOut[1] = NAV_DEFAULT_NTP_CLIENT_TIMEOUT
    set_length_array(client.TimeOut, 1)

    NAVNtpClientSocketConnectionInit(client.SocketConnection)
    NAVNtpPacketInit(client.Packet)
}


define_function char[NAV_NTP_PACKET_SIZE] NAVGetNtpPacketByteArray(_NAVNtpPacket packet) {
    return "
        packet.LiVnMode & $FF,
        packet.Stratum & $FF,
        packet.Poll & $FF,
        packet.Precision & $FF,
        NAVLongToByteArray(packet.RootDelay),
        NAVLongToByteArray(packet.RootDispersion),
        NAVLongToByteArray(packet.ReferenceId),
        NAVLongToByteArray(packet.ReferenceTimestampS),
        NAVLongToByteArray(packet.ReferenceTimestampF),
        NAVLongToByteArray(packet.OriginateTimestampS),
        NAVLongToByteArray(packet.OriginateTimestampF),
        NAVLongToByteArray(packet.ReceiveTimestampS),
        NAVLongToByteArray(packet.ReceiveTimestampF),
        NAVLongToByteArray(packet.TransmitTimestampS),
        NAVLongToByteArray(packet.TransmitTimestampF)
    "
}


define_function NAVNtpPacketSetTransmitTimestamp(_NAVNtpPacket packet) {
    // stack_var long seconds
    // stack_var long fraction

    // seconds = (long) (time() + NTP_TIMESTAMP_DELTA)
    // fraction = (long) (4294967296.0 * (time() + NTP_TIMESTAMP_DELTA - seconds))

    // packet.TransmitTimestampS = ntohl(seconds)
    // packet.TransmitTimestampF = ntohl(fraction)
}


define_function NAVNtpResponseToPacket(char data[], _NAVNtpPacket packet) {
    packet.LiVnMode = data[1]
    packet.Stratum = data[2]
    packet.Poll = data[3]
    packet.Precision = data[4]

    packet.RootDelay = (data[5] << 24 | data[6] << 16 | data[7] << 8 | data[8])
    packet.RootDispersion = (data[9] << 24 | data[10] << 16 | data[11] << 8 | data[12])
    packet.ReferenceId = (data[13] << 24 | data[14] << 16 | data[15] << 8 | data[16])
    packet.ReferenceTimestampS = (data[17] << 24 | data[18] << 16 | data[19] << 8 | data[20])
    packet.ReferenceTimestampF = (data[21] << 24 | data[22] << 16 | data[23] << 8 | data[24])
    packet.OriginateTimestampS = (data[25] << 24 | data[26] << 16 | data[27] << 8 | data[28])
    packet.OriginateTimestampF = (data[29] << 24 | data[30] << 16 | data[31] << 8 | data[32])
    packet.ReceiveTimestampS = (data[33] << 24 | data[34] << 16 | data[35] << 8 | data[36])
    packet.ReceiveTimestampF = (data[37] << 24 | data[38] << 16 | data[39] << 8 | data[40])
    packet.TransmitTimestampS = (data[41] << 24 | data[42] << 16 | data[43] << 8 | data[44])
    packet.TransmitTimestampF = (data[45] << 24 | data[46] << 16 | data[47] << 8 | data[48])
}


define_function NAVNtpSyncClock(long epoch) {
    stack_var _NAVTimespec timespec
    stack_var long localEpoch
    stack_var long difference

    NAVDateTimeGetTimespecNow(timespec)
    localEpoch = NAVDateTimeGetEpoch(timespec)

    if (epoch == localEpoch) {
        // Local clock is in sync with NTP clock
        // Nothing to do
        return
    }

    if (epoch > localEpoch) {
        // Local clock is behind NTP clock
        difference = epoch - localEpoch
    }

    if (epoch < localEpoch) {
        // Local clock is ahead of NTP clock
        difference = localEpoch - epoch
    }

    if (difference < 10) {
        // If the difference is less than 10 seconds,
        // we can ignore it
        return
    }

    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Epoch difference => ', itoa(difference)")
    NAVErrorLog(NAV_LOG_LEVEL_INFO, "'Setting clock from NTP'")
    NAVDateTimeSetClockFromEpoch(epoch)
}


#END_IF
