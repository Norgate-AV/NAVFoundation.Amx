DEFINE_VARIABLE

volatile _NAVStackString stackString
volatile _NAVStackInteger stackInteger


define_function char NAVCommandConsoleRunTestsEventCallback(_NAVConsole console) {
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                "'Command Console Run Tests Event Callback'")

    return TestStackString(stackString) && TestStackInteger(stackInteger)
}


define_function char TestStackInteger(_NAVStackInteger stack) {
    stack_var integer x
    stack_var integer capacity
    stack_var integer count

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                'Initializing stack...')
    NAVStackInitInteger(stack, 100)

    if (NAVStackIntegerGetCapacity(stack) != 100) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                    'Stack capacity is not 100')
        return false
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                'Pushing items to stack...')
    NAVStackPushInteger(stack, 10)
    NAVStackPushInteger(stack, 20)
    NAVStackPushInteger(stack, 40)
    NAVStackPushInteger(stack, 80)
    NAVStackPushInteger(stack, 100)

    if (NAVStackIntegerGetCount(stack) != 5) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                    'Stack count is not 5')
        return false
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                'Peeking stack...')
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                "'Peek: ', NAVStackPeekInteger(stack)")

    if (NAVStackPeekInteger(stack) != 100) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                    'Stack peek is not 100')
        return false
    }

    capacity = NAVStackIntegerGetCapacity(stack)
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                "'Stack capacity: ', itoa(capacity)")

    count = NAVStackIntegerGetCount(stack)
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                "'Items in stack: ', itoa(count)")

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                'Popping items from stack...')
    while (!NAVStackIntegerIsEmpty(stack)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                    "'Pop: ', itoa(NAVStackPopInteger(stack))")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                    "'Items in stack: ', itoa(NAVStackIntegerGetCount(stack))")
    }

    if (NAVStackIntegerGetCount(stack) != 0) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                    'Stack count is not 0')
        return false
    }

    return true
}


define_function char TestStackString(_NAVStackString stack) {
    stack_var integer x
    stack_var integer capacity
    stack_var integer count

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                'Initializing stack...')
    NAVStackInitString(stack, 100)

    if (NAVStackStringGetCapacity(stack) != 100) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                    'Stack capacity is not 100')
        return false
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                'Pushing items to stack...')
    NAVStackPushString(stack, 'Item 1')
    NAVStackPushString(stack, 'Item 2')
    NAVStackPushString(stack, 'Item 3')
    NAVStackPushString(stack, 'Item 4')
    NAVStackPushString(stack, 'Item 5')

    if (NAVStackStringGetCount(stack) != 5) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                    'Stack count is not 5')
        return false
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                'Peeking stack...')
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                "'Peek: ', NAVStackPeekString(stack)")

    if (NAVStackPeekString(stack) != 'Item 5') {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                    'Stack peek is not "Item 5"')
        return false
    }

    capacity = NAVStackStringGetCapacity(stack)
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                "'Stack capacity: ', itoa(capacity)")

    count = NAVStackStringGetCount(stack)
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                "'Items in stack: ', itoa(count)")

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                'Popping items from stack...')
    while (!NAVStackStringIsEmpty(stack)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                    "'Pop: ', NAVStackPopString(stack)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                    "'Items in stack: ', itoa(NAVStackStringGetCount(stack))")
    }

    if (NAVStackStringGetCount(stack) != 0) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG,
                    'Stack count is not 0')
        return false
    }

    return true
}
