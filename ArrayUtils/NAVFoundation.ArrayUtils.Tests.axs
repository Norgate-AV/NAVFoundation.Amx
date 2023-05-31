define_function TestStringArraySort(char value[][]) {
    NAVLog('Unsorted array...')
    NAVPrintArrayString(value)

    NAVLog('Sorting array...')
    NAVArraySelectionSortString(value)

    NAVLog('Sorted array...')
    NAVPrintArrayString(value)

    NAVLog('Reversing array...')
    NAVArrayReverseString(value)

    NAVLog('Reversed array...')
    NAVPrintArrayString(value)
}
