PROGRAM_NAME='NAVDateTimeGetGmtOffset'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Note: This test validates the GMT offset returned by NAVDateTimeGetGmtOffset()
// The actual value depends on the system's timezone configuration set via clkmgr_set_timezone()
//
// Common timezone offsets:
// UTC+00:00 = 0 minutes (GMT, London winter)
// UTC+01:00 = 60 minutes (London summer/BST, Paris winter)
// UTC-05:00 = -300 minutes (New York winter/EST)
// UTC-04:00 = -240 minutes (New York summer/EDT)
// UTC+10:00 = 600 minutes (Sydney winter)
// UTC+11:00 = 660 minutes (Sydney summer)

define_function TestNAVDateTimeGetGmtOffset() {
    stack_var sinteger offset

    NAVLog("'***************** NAVDateTimeGetGmtOffset *****************'")

    // Get the current GMT offset
    offset = NAVDateTimeGetGmtOffset()

    // Log the result for information
    NAVLog("'Current GMT Offset: ', itoa(offset), ' minutes'")

    // Validate that offset is within reasonable bounds
    // Valid timezone offsets range from UTC-12:00 to UTC+14:00
    // In minutes: -720 to +840
    if (!NAVAssertTrue('GMT offset should be within valid range (-720 to +840)',
                       (offset >= -720 && offset <= 840))) {
        NAVLogTestFailed(1, '-720 to +840', itoa(offset))
        return
    }

    // If offset is not zero, validate it's a reasonable increment
    // Most timezones are in 15-minute increments (some are 30 or 60)
    if (offset != 0) {
        if (!NAVAssertTrue('GMT offset should be in 15-minute increments',
                          ((offset % 15) == 0))) {
            NAVLogTestFailed(2, 'multiple of 15', itoa(offset))
            return
        }
    }

    NAVLog("'Test 1 passed'")
    NAVLog("'Test 2 passed'")

    // Additional informational output
    if (offset == 0) {
        NAVLog("'System is configured for UTC (GMT+00:00)'")
    }
    else if (offset > 0) {
        NAVLog("'System is configured for UTC+', format('%02d', offset / 60), ':', format('%02d', offset % 60)")
    }
    else {
        NAVLog("'System is configured for UTC', format('%03d', offset / 60), ':', format('%02d', -(offset % 60))")
    }
}
