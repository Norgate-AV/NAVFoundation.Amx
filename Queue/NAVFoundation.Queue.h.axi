PROGRAM_NAME='NAVFoundation.Queue.h.axi'

#IF_NOT_DEFINED __NAV_FOUNDATION_QUEUE_H__
#DEFINE __NAV_FOUNDATION_QUEUE_H__

#include 'NAVFoundation.Core.axi'


(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

#IF_NOT_DEFINED NAV_MAX_QUEUE_ITEMS
constant integer NAV_MAX_QUEUE_ITEMS = 500
#END_IF


(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

struct _NAVQueue {
    integer Head
    integer Tail
    integer Capacity
    integer Count
    char Items[NAV_MAX_QUEUE_ITEMS][NAV_MAX_BUFFER]
}


#END_IF // __NAV_FOUNDATION_QUEUE_H__
