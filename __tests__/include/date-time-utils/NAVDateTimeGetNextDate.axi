PROGRAM_NAME='NAVDateTimeGetNextDate'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test data for GetNextDate function
// Input dates in MM/DD/YYYY format
constant char NEXT_DATE_TEST[][10] = {
    '01/01/2023',   // Mid-year, regular day
    '01/31/2023',   // End of January (regular year)
    '02/28/2023',   // End of February (regular year)
    '02/28/2024',   // End of February (leap year)
    '02/29/2024',   // Leap day
    '03/31/2023',   // End of March
    '04/30/2023',   // End of April (30-day month)
    '05/31/2023',   // End of May
    '06/30/2023',   // End of June (30-day month)
    '07/31/2023',   // End of July
    '08/31/2023',   // End of August
    '09/30/2023',   // End of September (30-day month)
    '10/31/2023',   // End of October
    '11/30/2023',   // End of November (30-day month)
    '12/30/2023',   // Second to last day of year
    '12/31/2023',   // Last day of year (regular year)
    '12/31/2024',   // Last day of year (leap year)
    '06/15/2023',   // Mid-month, mid-year
    '02/27/2024',   // Day before leap day
    '03/01/2024',   // Day after leap day
    '12/31/1999',   // Century transition
    '12/31/2000',   // Leap year century transition
    '01/15/2023',   // Random mid-month date
    '07/04/2023',   // Random holiday date
    '11/23/2023'    // Random late-year date
}

constant char NEXT_DATE_EXPECTED[][10] = {
    '01/02/2023',   // Next day in January
    '02/01/2023',   // Roll to February
    '03/01/2023',   // Roll to March (regular year)
    '02/29/2024',   // Leap day
    '03/01/2024',   // Roll to March (leap year)
    '04/01/2023',   // Roll to April
    '05/01/2023',   // Roll to May
    '06/01/2023',   // Roll to June
    '07/01/2023',   // Roll to July
    '08/01/2023',   // Roll to August
    '09/01/2023',   // Roll to September
    '10/01/2023',   // Roll to October
    '11/01/2023',   // Roll to November
    '12/01/2023',   // Roll to December
    '12/31/2023',   // Last day of year
    '01/01/2024',   // Roll to new year
    '01/01/2025',   // Roll to new year (from leap year)
    '06/16/2023',   // Next day in June
    '02/28/2024',   // Day before leap day
    '03/02/2024',   // Two days after leap day
    '01/01/2000',   // New millennium
    '01/01/2001',   // New year after leap century
    '01/16/2023',   // Next day in January
    '07/05/2023',   // Next day in July
    '11/24/2023'    // Next day in November
}

define_function TestNAVDateTimeGetNextDate() {
    stack_var integer x

    NAVLog("'***************** NAVDateTimeGetNextDate *****************'")

    for (x = 1; x <= length_array(NEXT_DATE_TEST); x++) {
        stack_var char expected[10]
        stack_var char result[NAV_MAX_BUFFER]
        stack_var char inputDate[10]

        inputDate = NEXT_DATE_TEST[x]
        expected = NEXT_DATE_EXPECTED[x]
        result = NAVDateTimeGetNextDate(inputDate)

        if (!NAVAssertStringEqual('Should calculate next date correctly', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVDateTimeGetNextDateInvalidInput() {
    stack_var integer x
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** NAVDateTimeGetNextDate - Invalid Input *****************'")

    // Test 1: Empty string
    result = NAVGetNextDate('')
    if (!NAVAssertStringEqual('Should return empty string for empty input', '', result)) {
        NAVLogTestFailed(1, '', result)
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Invalid date format
    result = NAVGetNextDate('not-a-date')
    if (!NAVAssertStringEqual('Should return empty string for invalid format', '', result)) {
        NAVLogTestFailed(2, '', result)
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test 3: Invalid month
    result = NAVGetNextDate('13/01/2023')
    if (!NAVAssertStringEqual('Should return empty string for invalid month', '', result)) {
        NAVLogTestFailed(3, '', result)
    }
    else {
        NAVLogTestPassed(3)
    }

    // Test 4: Invalid day
    result = NAVGetNextDate('01/32/2023')
    if (!NAVAssertStringEqual('Should return empty string for invalid day', '', result)) {
        NAVLogTestFailed(4, '', result)
    }
    else {
        NAVLogTestPassed(4)
    }
}

define_function TestNAVDateTimeGetNextDateEdgeCases() {
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** NAVDateTimeGetNextDate - Edge Cases *****************'")

    // Test 1: Feb 28 -> Feb 29 in leap year
    result = NAVGetNextDate('02/28/2020')
    if (!NAVAssertStringEqual('Should handle Feb 28 -> Feb 29 in leap year', '02/29/2020', result)) {
        NAVLogTestFailed(1, '02/29/2020', result)
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Feb 29 -> Mar 1 in leap year
    result = NAVGetNextDate('02/29/2020')
    if (!NAVAssertStringEqual('Should handle Feb 29 -> Mar 1 in leap year', '03/01/2020', result)) {
        NAVLogTestFailed(2, '03/01/2020', result)
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test 3: Century leap year (2000)
    result = NAVGetNextDate('02/28/2000')
    if (!NAVAssertStringEqual('Should handle Feb 28 -> Feb 29 in century leap year', '02/29/2000', result)) {
        NAVLogTestFailed(3, '02/29/2000', result)
    }
    else {
        NAVLogTestPassed(3)
    }

    // Test 4: Non-leap century year (1900)
    result = NAVGetNextDate('02/28/1900')
    if (!NAVAssertStringEqual('Should handle Feb 28 -> Mar 1 in non-leap century year', '03/01/1900', result)) {
        NAVLogTestFailed(4, '03/01/1900', result)
    }
    else {
        NAVLogTestPassed(4)
    }

    // Test 5: Year 2100 (non-leap century)
    result = NAVGetNextDate('02/28/2100')
    if (!NAVAssertStringEqual('Should handle Feb 28 -> Mar 1 in 2100', '03/01/2100', result)) {
        NAVLogTestFailed(5, '03/01/2100', result)
    }
    else {
        NAVLogTestPassed(5)
    }

    // Test 6: Dec 31, 2099 -> Jan 1, 2100
    result = NAVGetNextDate('12/31/2099')
    if (!NAVAssertStringEqual('Should handle year rollover to 2100', '01/01/2100', result)) {
        NAVLogTestFailed(6, '01/01/2100', result)
    }
    else {
        NAVLogTestPassed(6)
    }
}
