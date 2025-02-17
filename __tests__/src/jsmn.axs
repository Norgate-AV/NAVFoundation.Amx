PROGRAM_NAME='jsmn'

#DEFINE __MAIN__
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Jsmn.axi'


DEFINE_DEVICE

dvTP    =   10001:1:0


DEFINE_CONSTANT

constant char TEST[][NAV_MAX_BUFFER]       =   {
    '{"contacts": [{"name": "Alice","age": 28,"phoneNumber": "01265 123456"},{"name": "Bob","age": 32,"phoneNumber": "01256 345678"},{"name": "Charlie","age": 40,"phoneNumber": "01432 678910"}],"details": {"id": "abc123-abc33-fe6899-1209dd","password": "secret","isStupid": true}}',
    '{"name": "John","age": 30,"cars": [{"name": "Ford","models": ["Fiesta","Focus","Mustang"]},{"name": "BMW","models": ["320","X3","X5"]},{"name": "Fiat","models": ["500","Panda"]}]}'
}

// Each key is a token
// Each value is a token
// Each object (including root) is considered a token
// Each array (including root) is considered a token
constant integer EXPECTED_COUNT[]     =   {
    32,
    30
}

constant integer EXPECTED_TYPE[][]      =   {
    {
        JSMN_TYPE_OBJECT,       // Root object
        JSMN_TYPE_STRING,       // contacts key
        JSMN_TYPE_ARRAY,        // contacts array
        JSMN_TYPE_OBJECT,       // contacts[0]
        JSMN_TYPE_STRING,       // contacts[0].name.key
        JSMN_TYPE_STRING,       // contacts[0].name.value
        JSMN_TYPE_STRING,       // contacts[0].age.key
        JSMN_TYPE_PRIMITIVE,    // contacts[0].age.value
        JSMN_TYPE_STRING,       // contacts[0].phoneNumber.key
        JSMN_TYPE_STRING,       // contacts[0].phoneNumber.value
        JSMN_TYPE_OBJECT,       // contacts[1]
        JSMN_TYPE_STRING,       // contacts[1].name.key
        JSMN_TYPE_STRING,       // contacts[1].name.value
        JSMN_TYPE_STRING,       // contacts[1].age.key
        JSMN_TYPE_PRIMITIVE,    // contacts[1].age.value
        JSMN_TYPE_STRING,       // contacts[1].phoneNumber.key
        JSMN_TYPE_STRING,       // contacts[1].phoneNumber.value
        JSMN_TYPE_OBJECT,       // contacts[2]
        JSMN_TYPE_STRING,       // contacts[2].name.key
        JSMN_TYPE_STRING,       // contacts[2].name.value
        JSMN_TYPE_STRING,       // contacts[2].age.key
        JSMN_TYPE_PRIMITIVE,    // contacts[2].age.value
        JSMN_TYPE_STRING,       // contacts[2].phoneNumber.key
        JSMN_TYPE_STRING,       // contacts[2].phoneNumber.value
        JSMN_TYPE_STRING,       // details key
        JSMN_TYPE_OBJECT,       // details object
        JSMN_TYPE_STRING,       // details.id.key
        JSMN_TYPE_STRING,       // details.id.value
        JSMN_TYPE_STRING,       // details.password.key
        JSMN_TYPE_STRING,       // details.password.value
        JSMN_TYPE_STRING,       // details.isStupid.key
        JSMN_TYPE_PRIMITIVE     // details.isStupid.value
    },
    {
        JSMN_TYPE_OBJECT,       // Root object
        JSMN_TYPE_STRING,       // name.key
        JSMN_TYPE_STRING,       // name.value
        JSMN_TYPE_STRING,       // age.key
        JSMN_TYPE_PRIMITIVE,    // age.value
        JSMN_TYPE_STRING,       // cars
        JSMN_TYPE_ARRAY,        // cars array
        JSMN_TYPE_OBJECT,       // cars[0]
        JSMN_TYPE_STRING,       // cars[0].name.key
        JSMN_TYPE_STRING,       // cars[0].name.value
        JSMN_TYPE_STRING,       // cars[0].models.key
        JSMN_TYPE_ARRAY,        // cars[0].models array
        JSMN_TYPE_STRING,       // cars[0].models[0]
        JSMN_TYPE_STRING,       // cars[0].models[1]
        JSMN_TYPE_STRING,       // cars[0].models[2]
        JSMN_TYPE_OBJECT,       // cars[1]
        JSMN_TYPE_STRING,       // cars[1].name.key
        JSMN_TYPE_STRING,       // cars[1].name.value
        JSMN_TYPE_STRING,       // cars[1].models.key
        JSMN_TYPE_ARRAY,        // cars[1].models array
        JSMN_TYPE_STRING,       // cars[1].models[0]
        JSMN_TYPE_STRING,       // cars[1].models[1]
        JSMN_TYPE_STRING,       // cars[1].models[2]
        JSMN_TYPE_OBJECT,       // cars[2]
        JSMN_TYPE_STRING,       // cars[2].name.key
        JSMN_TYPE_STRING,       // cars[2].name.value
        JSMN_TYPE_STRING,       // cars[2].models.key
        JSMN_TYPE_ARRAY,        // cars[2].models array
        JSMN_TYPE_STRING,       // cars[2].models[0]
        JSMN_TYPE_STRING        // cars[2].models[1]
    }
}

constant char EXPECTED_VALUE[][][NAV_MAX_BUFFER] = {
    {
        '{"contacts": [{"name": "Alice","age": 28,"phoneNumber": "01265 123456"},{"name": "Bob","age": 32,"phoneNumber": "01256 345678"},{"name": "Charlie","age": 40,"phoneNumber": "01432 678910"}],"details": {"id": "abc123-abc33-fe6899-1209dd","password": "secret","isStupid": true}}',
        'contacts',
        '[{"name": "Alice","age": 28,"phoneNumber": "01265 123456"},{"name": "Bob","age": 32,"phoneNumber": "01256 345678"},{"name": "Charlie","age": 40,"phoneNumber": "01432 678910"}]',
        '{"name": "Alice","age": 28,"phoneNumber": "01265 123456"}',
        'name',
        'Alice',
        'age',
        '28',
        'phoneNumber',
        '01265 123456',
        '{"name": "Bob","age": 32,"phoneNumber": "01256 345678"}',
        'name',
        'Bob',
        'age',
        '32',
        'phoneNumber',
        '01256 345678',
        '{"name": "Charlie","age": 40,"phoneNumber": "01432 678910"}',
        'name',
        'Charlie',
        'age',
        '40',
        'phoneNumber',
        '01432 678910',
        'details',
        '{"id": "abc123-abc33-fe6899-1209dd","password": "secret","isStupid": true}',
        'id',
        'abc123-abc33-fe6899-1209dd',
        'password',
        'secret',
        'isStupid',
        'true'
    },
    {
        '{"name": "John","age": 30,"cars": [{"name": "Ford","models": ["Fiesta","Focus","Mustang"]},{"name": "BMW","models": ["320","X3","X5"]},{"name": "Fiat","models": ["500","Panda"]}]}',
        'name',
        'John',
        'age',
        '30',
        'cars',
        '[{"name": "Ford","models": ["Fiesta","Focus","Mustang"]},{"name": "BMW","models": ["320","X3","X5"]},{"name": "Fiat","models": ["500","Panda"]}]',
        '{"name": "Ford","models": ["Fiesta","Focus","Mustang"]}',
        'name',
        'Ford',
        'models',
        '["Fiesta","Focus","Mustang"]',
        'Fiesta',
        'Focus',
        'Mustang',
        '{"name": "BMW","models": ["320","X3","X5"]}',
        'name',
        'BMW',
        'models',
        '["320","X3","X5"]',
        '320',
        'X3',
        'X5',
        '{"name": "Fiat","models": ["500","Panda"]}',
        'name',
        'Fiat',
        'models',
        '["500","Panda"]',
        '500',
        'Panda'
    }
}


define_function RunTests() {
    stack_var integer x

    for (x = 1; x <= length_array(TEST); x++) {
        stack_var JsmnParser parser
        stack_var JsmnToken tokens[NAV_MAX_JSMN_TOKENS]
        stack_var integer count
        stack_var char failed

        jsmn_init(parser)
        count = jsmn_parse(parser, TEST[x], tokens)

        if (count != EXPECTED_COUNT[x]) {
            NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Test ', itoa(x), ' failed. Expected ', itoa(EXPECTED_COUNT[x]), ' tokens, got ', itoa(count)")
            continue
        }

        {
            stack_var integer z

            for (z = 1; z <= count; z++) {
                if (tokens[z].type != EXPECTED_TYPE[x][z]) {
                    NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Test ', itoa(x), ' failed. Token ', itoa(z), ' expected type ', itoa(EXPECTED_TYPE[x][z]), ' got ', itoa(tokens[z].type)")
                    failed = true
                    break
                }

                {
                    stack_var char value[NAV_MAX_BUFFER]

                    value = jsmn_get_token(TEST[x], tokens[z])

                    if (value != EXPECTED_VALUE[x][z]) {
                        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Test ', itoa(x), ' failed. Token ', itoa(z), ' expected value ', EXPECTED_VALUE[x][z], ' got ', value")
                        failed = true
                        break
                    }
                }
            }

            if (failed) {
                continue
            }
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(x), ' passed'")
    }
}


DEFINE_EVENT

button_event[dvTP, 1] {
    push: {
        RunTests()
    }
}
