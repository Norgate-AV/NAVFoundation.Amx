PROGRAM_NAME='NAVFiglet'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char FIGLET_TESTS[][255] = {
    'A',
    'Hi',
    'TEST',
    'Hello',
    '123',
    'ABC123',
    'Hello World!',
    '!@#$%',
    'Code',
    'NAV',
    'a',
    'abc',
    '0',
    ' ',
    '.',
    'X',
    '?',
    '',
    'NorgateAV',
    'NAVFoundation'
}

DEFINE_VARIABLE

volatile char FIGLET_EXPECTED[20][2048]

define_function InitializeFigletExpectedData() {
    // A
    FIGLET_EXPECTED[1] = "
        '    _', $0D, $0A,
        '   / \', $0D, $0A,
        '  / _ \', $0D, $0A,
        ' / ___ \', $0D, $0A,
        '/_/   \_\'
    "
    // Hi
    FIGLET_EXPECTED[2] = "
        ' _   _ _', $0D, $0A,
        '| | | (_)', $0D, $0A,
        '| |_| | |', $0D, $0A,
        '|  _  | |', $0D, $0A,
        '|_| |_|_|'
    "
    // TEST
    FIGLET_EXPECTED[3] = "
        ' _____ _____ ____ _____', $0D, $0A,
        '|_   _| ____/ ___|_   _|', $0D, $0A,
        '  | | |  _| \___ \ | |', $0D, $0A,
        '  | | | |___ ___) || |', $0D, $0A,
        '  |_| |_____|____/ |_|'
    "
    // Hello
    FIGLET_EXPECTED[4] = "
        ' _   _      _ _', $0D, $0A,
        '| | | | ___| | | ___', $0D, $0A,
        '| |_| |/ _ \ | |/ _ \', $0D, $0A,
        '|  _  |  __/ | | (_) |', $0D, $0A,
        '|_| |_|\___|_|_|\___/'
    "
    // 123
    FIGLET_EXPECTED[5] = "
        ' _ ____  _____', $0D, $0A,
        '/ |___ \|___ /', $0D, $0A,
        '| | __) | |_ \', $0D, $0A,
        '| |/ __/ ___) |', $0D, $0A,
        '|_|_____|____/'
    "
    // ABC123
    FIGLET_EXPECTED[6] = "
        '    _    ____   ____ _ ____  _____', $0D, $0A,
        '   / \  | __ ) / ___/ |___ \|___ /', $0D, $0A,
        '  / _ \ |  _ \| |   | | __) | |_ \', $0D, $0A,
        ' / ___ \| |_) | |___| |/ __/ ___) |', $0D, $0A,
        '/_/   \_\____/ \____|_|_____|____/'
    "
    // Hello World!
    FIGLET_EXPECTED[7] = "
        ' _   _      _ _        __        __         _     _ _', $0D, $0A,
        '| | | | ___| | | ___   \ \      / /__  _ __| | __| | |', $0D, $0A,
        '| |_| |/ _ \ | |/ _ \   \ \ /\ / / _ \| ''__| |/ _` | |', $0D, $0A,
        '|  _  |  __/ | | (_) |   \ V  V / (_) | |  | | (_| |_|', $0D, $0A,
        '|_| |_|\___|_|_|\___/     \_/\_/ \___/|_|  |_|\__,_(_)'
    "
    // !@#$%
    FIGLET_EXPECTED[8] = "
        ' _   ____    _  _    _  _  __', $0D, $0A,
        '| | / __ \ _| || |_ | |(_)/ /', $0D, $0A,
        '| |/ / _` |_  __  _/ __) / /', $0D, $0A,
        '|_| | (_| |_| || |_\__ \/ /_', $0D, $0A,
        '(_)\ \__,_|_  __  _(   /_/(_)', $0D, $0A,
        '    \____/  |_||_|  |_|'
    "
    // Code
    FIGLET_EXPECTED[9] = "
        '  ____          _', $0D, $0A,
        ' / ___|___   __| | ___', $0D, $0A,
        '| |   / _ \ / _` |/ _ \', $0D, $0A,
        '| |__| (_) | (_| |  __/', $0D, $0A,
        ' \____\___/ \__,_|\___|'
    "
    // NAV
    FIGLET_EXPECTED[10] = "
        ' _   _    ___     __', $0D, $0A,
        '| \ | |  / \ \   / /', $0D, $0A,
        '|  \| | / _ \ \ / /', $0D, $0A,
        '| |\  |/ ___ \ V /', $0D, $0A,
        '|_| \_/_/   \_\_/'
    "
    // a
    FIGLET_EXPECTED[11] = "
        '', $0D, $0A,
        '  __ _', $0D, $0A,
        ' / _` |', $0D, $0A,
        '| (_| |', $0D, $0A,
        ' \__,_|'
    "
    // abc
    FIGLET_EXPECTED[12] = "
        '       _', $0D, $0A,
        '  __ _| |__   ___', $0D, $0A,
        ' / _` | ''_ \ / __|', $0D, $0A,
        '| (_| | |_) | (__', $0D, $0A,
        ' \__,_|_.__/ \___|'
    "
    // 0
    FIGLET_EXPECTED[13] = "
        '  ___', $0D, $0A,
        ' / _ \', $0D, $0A,
        '| | | |', $0D, $0A,
        '| |_| |', $0D, $0A,
        ' \___/'
    "
    // space
    FIGLET_EXPECTED[14] = "
        '', $0D, $0A,
        '', $0D, $0A,
        '', $0D, $0A,
        '', $0D, $0A,
        ''
    "
    // .
    FIGLET_EXPECTED[15] = "
        '', $0D, $0A,
        '', $0D, $0A,
        '', $0D, $0A,
        ' _', $0D, $0A,
        '(_)'
    "
    // X
    FIGLET_EXPECTED[16] = "
        '__  __', $0D, $0A,
        '\ \/ /', $0D, $0A,
        ' \  /', $0D, $0A,
        ' /  \', $0D, $0A,
        '/_/\_\'
    "
    // ?
    FIGLET_EXPECTED[17] = "
        ' ___', $0D, $0A,
        '|__ \', $0D, $0A,
        '  / /', $0D, $0A,
        ' |_|', $0D, $0A,
        ' (_)'
    "
    // empty string
    FIGLET_EXPECTED[18] = ''
    // NorgateAV
    FIGLET_EXPECTED[19] = "
        ' _   _                       _          ___     __', $0D, $0A,
        '| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /', $0D, $0A,
        '|  \| |/ _ \| ''__/ _` |/ _` | __/ _ \ / _ \ \ / /', $0D, $0A,
        '| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /', $0D, $0A,
        '|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/', $0D, $0A,
        '                 |___/'
    "
    // NAVFoundation
    FIGLET_EXPECTED[20] = "
        ' _   _    ___     _______                     _       _   _', $0D, $0A,
        '| \ | |  / \ \   / /  ___|__  _   _ _ __   __| | __ _| |_(_) ___  _ __', $0D, $0A,
        '|  \| | / _ \ \ / /| |_ / _ \| | | | ''_ \ / _` |/ _` | __| |/ _ \| ''_ \', $0D, $0A,
        '| |\  |/ ___ \ V / |  _| (_) | |_| | | | | (_| | (_| | |_| | (_) | | | |', $0D, $0A,
        '|_| \_/_/   \_\_/  |_|  \___/ \__,_|_| |_|\__,_|\__,_|\__|_|\___/|_| |_|'
    "
}

define_function TestNAVFiglet() {
    stack_var integer x
    stack_var char result[2048]

    NAVLog("'***************** NAVFiglet *****************'")

    InitializeFigletExpectedData()

    for (x = 1; x <= length_array(FIGLET_TESTS); x++) {
        result = NAVFiglet(FIGLET_TESTS[x])

        if (!NAVAssertStringEqual('Should create the correct Figlet output', FIGLET_EXPECTED[x], result)) {
            NAVLogTestFailed(x, FIGLET_EXPECTED[x], result)
            continue
        }

        NAVLogTestPassed(x)
        NAVFigletLog(result)
    }
}
