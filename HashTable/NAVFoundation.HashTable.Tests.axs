DEFINE_CONSTANT

constant integer PHONEBOOK_NAME     = 1
constant integer PHONEBOOK_NUMBER   = 2
constant char PHONEBOOK[][][NAV_MAX_BUFFER] =   {
                                                    {
                                                        'Alice',
                                                        '555-1234'
                                                    },
                                                    {
                                                        'Bob',
                                                        '555-5678'
                                                    },
                                                    {
                                                        'Charlie',
                                                        '555-9012'
                                                    },
                                                    {
                                                        'Dave',
                                                        '555-3456'
                                                    },
                                                    {
                                                        'Frank',
                                                        '555-7890'
                                                    },
                                                    {
                                                        'Bill',
                                                        '555-4321'
                                                    },
                                                    {
                                                        'Fred',
                                                        '555-8765'
                                                    },
                                                    {
                                                        'John',
                                                        '555-2109'
                                                    }
                                                }


DEFINE_VARIABLE

volatile _NAVHashTable hashTable
volatile _NAVKeyValuePair phoneBookEntries[500]


define_function PhoneBookInit(_NAVKeyValuePair phoneBookEntries[]) {
    stack_var integer x
    stack_var integer count

    count = length_array(PHONEBOOK)
    NAVLog("'Phone book count: ', itoa(count)")

    if (count > max_length_array(phoneBookEntries)) {
        NAVLog("'Error: Phone book count ', itoa(count), ' is greater than max length ', itoa(max_length_array(phoneBookEntries))")
        return
    }

    set_length_array(phoneBookEntries, count)

    for (x = 1; x <= count; x++) {
        NAVLog("'Initializing phone book entry ', itoa(x)")
        NAVLog("'Name: ', PHONEBOOK[x][PHONEBOOK_NAME]")
        NAVLog("'Number: ', PHONEBOOK[x][PHONEBOOK_NUMBER]")

        phoneBookEntries[x].Key = PHONEBOOK[x][PHONEBOOK_NAME]
        phoneBookEntries[x].Value = PHONEBOOK[x][PHONEBOOK_NUMBER]
    }
}


define_function InvokeHashTable(_NAVHashTable hashTable) {
    stack_var integer x

    NAVLog('Initializing hash table...')
    NAVHashTableInit(hashTable)

    NAVLog('Adding items to hash table...')

    for (x = 1; x <= length_array(phoneBook); x++) {
        stack_var integer slot

        if (!length_array(phoneBookEntries[x].Key)) {
            NAVLog("'Error: Phone book key ', itoa(x), ' is empty'")
            continue
        }

        slot = NAVHashTableAddItem(hashTable, phoneBookEntries[x].Key, phoneBookEntries[x].Value)
        if (slot <= 0) {
            NAVLog("'Error adding item (', phoneBookEntries[x].Key, ') to hash table'")
            continue
        }

        NAVLog("'Added item (', phoneBookEntries[x].Key, ') to hash table at slot ', format('%04d', slot)")
    }

    if (NAVHashTableGetItemCount(hashTable) > 0) {
        NAVLog('Dumping hash table...')
        NAVHashTableDump(hashTable)

        return
    }

    NAVLog('Hash table is empty')
}


define_function GetHashTableItems(_NAVHashTable hashTable) {
    stack_var integer x

    if (NAVHashTableGetItemCount(hashTable) <= 0) {
        return

    }

    NAVLog('Getting items from hash table...')

    for (x = 1; x <= length_array(PHONEBOOK); x++) {
        stack_var char key[NAV_MAX_BUFFER]
        stack_var char value[NAV_MAX_BUFFER]

        key = PHONEBOOK[x][PHONEBOOK_NAME]

        value = NAVHashTableGetItemValue(hashTable, key)
        NAVLog("'Key: ', key, ' Value: ', value")
    }
}
