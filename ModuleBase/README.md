# NAVFoundation.ModuleBase

A base framework for building NetLinx modules with standardized event handling and communication patterns.

## Overview

ModuleBase provides the foundation for creating reusable NetLinx modules with consistent:

- Device state management
- SNAPI event processing
- Property and passthru event callbacks
- Communication buffer handling

## Architecture

The library is designed around the `_NAVModule` struct (defined in NAVFoundation.Core) and provides event-driven callbacks for module communication.

### Key Components

- **`_NAVModulePropertyEvent`**: Handles property change events from SNAPI devices
- **`_NAVModulePassthruEvent`**: Handles passthru data events
- **Event Callbacks**: Optional callback system for processing module events

## Breaking Changes (Latest Version)

**Important**: This version removes automatic module initialization. You must now manually declare and initialize your module.

### What Changed

- ❌ Removed: Global `_NAVModule` variable declaration
- ❌ Removed: Automatic `NAVModuleInit()` call in `DEFINE_START`
- ✅ Added: Consumer must declare module variable and initialization

### Migration Guide

**Before (Old Version):**

```netlinx
#include 'NAVFoundation.ModuleBase.axi'

// Module was automatically declared and initialized
```

**After (New Version):**

```netlinx
#include 'NAVFoundation.ModuleBase.axi'

// You must now declare the module variable
DEFINE_VARIABLE
_NAVModule myModule

// You must now initialize the module
DEFINE_START {
    NAVModuleInit(myModule)
}
```

## Usage

### 1. Include the Library

```netlinx
#include 'NAVFoundation.ModuleBase.axi'
```

### 2. Declare Module Variable

In your main `.axs` file:

```netlinx
DEFINE_VARIABLE

_NAVModule myModule
```

### 3. Initialize the Module

```netlinx
DEFINE_START {
    NAVModuleInit(myModule)
}
```

### 4. Optional: Enable Event Callbacks

Define the virtual device and enable callbacks:

```netlinx
#define USING_NAV_MODULE_BASE_CALLBACKS
#define USING_NAV_MODULE_BASE_PROPERTY_EVENT_CALLBACK
#define USING_NAV_MODULE_BASE_PASSTHRU_EVENT_CALLBACK

define_function NAVModulePropertyEventCallback(_NAVModulePropertyEvent event) {
    switch (event.Name) {
        case NAV_MODULE_PROPERTY_EVENT_IP_ADDRESS: {
            // Handle IP address changes
        }
        case NAV_MODULE_PROPERTY_EVENT_PORT: {
            // Handle port changes
        }
    }
}

define_function NAVModulePassthruEventCallback(_NAVModulePassthruEvent event) {
    // Handle passthru data
}
```

## API Reference

### Functions

- `NAVModuleInit(_NAVModule module)`: Initialize module with default values

### Events

The library automatically handles `data_event[vdvObject]` for:

- **Property Events**: Device configuration changes (IP, port, credentials, etc.)
- **Passthru Events**: Raw data transmission through the module

## Dependencies

- NAVFoundation.Core.h.axi (for \_NAVModule struct)
- NAVFoundation.ArrayUtils.axi
- NAVFoundation.SnapiHelpers.axi
