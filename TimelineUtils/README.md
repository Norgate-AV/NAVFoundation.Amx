# NAVFoundation.TimelineUtils

The TimelineUtils library contains a set of basic wrapper functions for working with NetLinx timelines, providing error logging and some basic guard clauses.

## Contents :book:

-   [NAVGetTimelineInitError](#libraries-books)

## Functions

### NAVTimelineStart

```c
/*
    Initializes a timeline.

    Parameters:
        id - The ID of the timeline to initialize.
        times - An array of times in milliseconds.
        relative - Whether the times are relative to the previous time or absolute.
        mode - The mode of the timeline.

    Returns:
        0 if the timeline was initialized successfully, otherwise an error code.
*/
integer NAVTimelineStart(long id, long times[], long relative, long mode);
```

#### Example

```c
DEFINE_CONSTANT
constant long TL = 1;

DEFINE_VARIABLE
volatile long ticks[] = { 200 };

DEFINE_START {
    stack_var integer result

    // Initialize the timeline.
    result = NAVTimelineStart(TL, ticks, TIMELINE_ABSOLUTE, TIMELINE_REPEAT);

    // Check for errors.
    if (result != 0) {
        send_string 0, NAVGetTimelineInitError(result);
    }
}

DEFINE_EVENT
timeline_event[TL] {
    // Do something every 200 milliseconds.
    send_string 0, "Tick!";
}
```

### NAVGetTimelineInitError

```c
/*
    Returns a string representation of the error code returned by NAVTimelineInit.

    Parameters:
        error - The error code returned by NAVTimelineInit.

    Returns:
        A string representation of the error code.
*/
char[NAV_MAX_BUFFER] NAVGetTimelineInitError(integer error);
```

#### Example

```c
DEFINE_CONSTANT
constant long TL = 1;

DEFINE_VARIABLE
volatile long ticks[] = { 200 };

DEFINE_START {
    stack_var integer result

    // Initialize the timeline.
    result = NAVTimelineStart(TL, ticks, TIMELINE_ABSOLUTE, TIMELINE_REPEAT);

    // Check for errors.
    if (result != 0) {
        send_string 0, "NAVGetTimelineInitError(result)";
    }
}
```

## NAVFoundation.TimelineUtils

```c

```
