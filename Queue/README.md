# NAVFoundation.Queue

This is the Queue library for NAVFoundation. It contains a set of utility functions for working with queues.

## Breaking Changes

### v3.0.0 - Event Handling Refactor

**Important**: As of version 3.0.0, the `timeline_event[TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE]` and the global variable declaration have been removed from the library to minimize side effects and avoid global variable dependencies. This is a breaking change that requires updates to consumer code.

#### What Changed

- The timeline event that previously handled failed responses has been removed from `NAVFoundation.DevicePriorityQueue.axi`.
- The global variable declaration `volatile _NAVDevicePriorityQueue priorityQueue` has been removed from the library.
- The library now focuses purely on data structures and functions, without enforcing global variables or event handling.
- Consumers must now declare their own queue variable and manage the timeline event in their own code.

#### Migration Guide

To migrate your code to the new version:

1. **Remove any reliance on the built-in event**: The library no longer declares or handles the `TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE` timeline event.

2. **Declare your queue variable**: Add a variable declaration for your queue instance in your consumer code. You can name it anything you want:

    ```netlinx-source
    DEFINE_VARIABLE
    volatile _NAVDevicePriorityQueue myDeviceQueue  // Replace 'myDeviceQueue' with your preferred name
    ```

3. **Add the event to your consumer code**: In your main `.axs` file (or wherever you declare events), add the following:

    ```netlinx-source
    DEFINE_EVENT
    timeline_event[TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE] {
        NAVDevicePriorityQueueFailedResponse(yourQueueVariable)  // Replace 'yourQueueVariable' with your actual queue instance name
    }
    ```

4. **Ensure callback definitions**: If you're using the callback mechanism, make sure `USING_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE_EVENT_CALLBACK` is defined in your code. **Important**: Because NetLinx compiles top-down, these compiler directives must be placed _before_ the `#include` statement for the library.

5. **Update function calls**: Replace any references to the old global `priorityQueue` variable with your new variable name throughout your code.

#### Example Consumer Code

Here's a complete example of how to use the library after the migration:

```netlinx-source
PROGRAM_NAME='MyProgram'

// Compiler directives must be defined BEFORE the include
#DEFINE USING_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE_EVENT_CALLBACK

// Include the library
#include 'NAVFoundation.DevicePriorityQueue.axi'

// Declare your queue variable (previously was global in the library)
DEFINE_VARIABLE
volatile _NAVDevicePriorityQueue myDeviceQueue

// Define the callback if needed
define_function NAVDevicePriorityQueueFailedResponseEventCallback(_NAVDevicePriorityQueue queue) {
    // Your custom logic here
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed response for queue: ', queue.LastMessage")
}

DEFINE_EVENT
// Handle the timeline event in your code (previously was in the library)
timeline_event[TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE] {
    NAVDevicePriorityQueueFailedResponse(myDeviceQueue)
}

// Other events and logic...
button_event[dvTP, 1] {
    push: {
        // Initialize and use your queue
        NAVDevicePriorityQueueInit(myDeviceQueue)
        // ... rest of your code
    }
}
```
