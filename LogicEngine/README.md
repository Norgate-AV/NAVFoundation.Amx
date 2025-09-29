# NAVFoundation.LogicEngine

A lightweight, event-driven logic engine for AMX NetLinx that provides a simple framework for managing timed sequences of operations.

## Overview

The LogicEngine provides a timeline-based system for executing recurring logic cycles with defined event types. It supports three main event types:

- **Query**: Initial data gathering phase
- **Action**: Main processing phase (executed multiple times per cycle)
- **Idle**: Rest/cleanup phase

## Architecture

The engine uses a simplified struct design with minimal memory footprint:

- **`_NAVLogicEngine`**: Main engine struct (177 bytes)
    - `Ticks[]`: Timeline intervals for each event
    - `IsRunning`: Engine state flag
    - `PreviousEventId`: Last executed event ID
    - `EventNames[][]`: Human-readable event names

- **`_NAVLogicEngineEvent`**: Event callback data (52 bytes)
    - `Id`: Numeric event identifier
    - `Name`: Event name string

## Usage

### 1. Include the Library

```netlinx
#DEFINE USING_NAV_LOGIC_ENGINE_EVENT_CALLBACK
#include 'NAVFoundation.LogicEngine.axi'
```

### 2. Define Engine Variable

In your main `.axs` file:

```netlinx
DEFINE_VARIABLE

_NAVLogicEngine myEngine
```

### 3. Initialize the Engine

```netlinx
DEFINE_START {
    NAVLogicEngineInit(myEngine)
}
```

### 4. Define Timeline Event Handler

```netlinx
DEFINE_EVENT

timeline_event[TL_NAV_LOGIC_ENGINE] {
    NAVLogicEngineDrive(myEngine, timeline)
}
```

### 5. Define Event Callback

Uncomment and implement the callback in your code:

```netlinx
define_function NAVLogicEngineEventCallback(_NAVLogicEngineEvent event) {
    switch (event.Id) {
        case NAV_LOGIC_ENGINE_EVENT_ID_QUERY: {
            // Handle query events
        }
        case NAV_LOGIC_ENGINE_EVENT_ID_ACTION: {
            // Handle action events
        }
        case NAV_LOGIC_ENGINE_EVENT_ID_IDLE: {
            // Handle idle events
        }
    }
}
```

### 6. Control the Engine

```netlinx
// Start the engine
NAVLogicEngineStart(myEngine)

// Stop the engine
NAVLogicEngineStop(myEngine)

// Restart the current cycle
NAVLogicEngineRestart(myEngine)
```

## API Reference

### Functions

- `NAVLogicEngineInit(_NAVLogicEngine engine)`: Initialize engine with default values
- `NAVLogicEngineStart(_NAVLogicEngine engine)`: Start the timeline
- `NAVLogicEngineStop(_NAVLogicEngine engine)`: Stop the timeline
- `NAVLogicEngineRestart(_NAVLogicEngine engine)`: Reset to beginning of current cycle

## Memory Usage

- Engine instance: 177 bytes
- Event instance: 52 bytes
- Total per engine: ~229 bytes (including typical event usage)

## Timeline Sequence

The engine executes a 6-step sequence per cycle:

1. Query
2. Action
3. Action
4. Action
5. Action
6. Idle

Each step is 200ms.

## Dependencies

- NAVFoundation.Core.h.axi
- NAVFoundation.TimelineUtils.axi

## Recent Changes

- **Simplified Architecture**: Removed nested structs, flattened design for better performance
- **Memory Optimization**: Reduced memory footprint from 448 bytes to 177 bytes per engine
- **Modular Design**: Split constants/structs into header file for cleaner organization
