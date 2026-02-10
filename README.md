# NAVFoundation.Amx

<div align="center">
    <img src="./assets/img/AMX_NS_03.png" alt="" width="150" />
</div>

---

[![CI](https://github.com/Norgate-AV/NAVFoundation.Amx/actions/workflows/main.yml/badge.svg)](https://github.com/Norgate-AV/NAVFoundation.Amx/actions/workflows/main.yml)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![GitHub contributors](https://img.shields.io/github/contributors/Norgate-AV/NAVFoundation.Amx)](https://github.com/Norgate-AV/NAVFoundation.Amx/graphs/contributors)
[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

The NAVFoundation project is a collection of libraries for working with AMX devices. It's purpose is to provide a base for building NetLinx applications using modern programming techniques and patterns.

It builds on top of the NetLinx standard library to provide a set of higher level functions and utilities that are commonly used and taken for granted in other modern languages.

It's feature rich and written in pure NetLinx.

## Contents :book:

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Key Features :sparkles:](#key-features-sparkles)
- [Installation :zap:](#installation-zap)
- [Documentation :page_facing_up:](#documentation-page_facing_up)
- [Libraries :books:](#libraries-books)
- [Support :question:](#support-question)
- [Team :soccer:](#team-soccer)
- [Contributors :sparkles:](#contributors-sparkles)
- [LICENSE :balance_scale:](#license-balance_scale)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Key Features :sparkles:

- Modern, object-oriented approach to NetLinx programming
- Comprehensive utility libraries for common tasks
- Well-tested and production-ready components
- Consistent API design across all modules
- Extensive error handling and logging capabilities

## Installation :zap:

This library can be installed using [Scoop](https://scoop.sh/).

```powershell
# If you don't have sudo installed - Required to create symlinks in the AMX directory
scoop install gsudo

# Add the Norgate-AV AMX bucket
scoop bucket add norgateav-amx https://github.com/Norgate-AV/scoop-norgateav-amx

# Install NAVFoundation.Amx
sudo scoop install navfoundation-amx
```

## Usage :rocket:

To use the NAVFoundation.Amx libraries in your NetLinx project, simply include the desired library files in your project.

### Example

To use the `StringUtils` library, you would include it as follows:

```c
#include 'NAVFoundation.StringUtils.axi'
```

To use the `ArrayUtils` library, you would include it as follows:

```c
#include 'NAVFoundation.ArrayUtils.axi'
```

## Documentation :page_facing_up:

For more detailed guides and documentation, please refer the `README.md` files in each library folder.

## Libraries :books:

- [Core](./Core)
    - Provides a set of core constants, types, and functions for AMX programming.
- [ArrayUtils](./ArrayUtils)
    - Provides utility functions for working with arrays in AMX.
- [Assert](./Assert)
    - Provides assertion functions for testing and debugging.
- [BinaryUtils](./BinaryUtils)
    - Provides functions for binary data manipulation and conversion.
- [Cryptography](./Cryptography)
    - Provides cryptographic functions and utilities for secure data handling.
- [CsvUtils](./CsvUtils)
    - Provides functions for parsing and generating CSV data.
- [DateTimeUtils](./DateTimeUtils)
    - Provides utility functions for date and time manipulation.
- [Encoding](./Encoding)
    - Provides functions for encoding and decoding data in various formats.
- [Enova](./Enova)
    - Provides functions for interacting with Enova switchers.
- [ErrorLogUtils](./ErrorLogUtils)
    - Provides functions for error logging and handling.
- [Figlet](./Figlet)
    - Provides functions for generating ASCII art text using FIGlet fonts.
- [FileUtils](./FileUtils)
    - Provides utility functions for file operations and management.
- [HashTable](./HashTable)
    - Provides a hash table implementation for key-value storage.
- [HttpUtils](./HttpUtils)
    - Provides functions for HTTP requests and responses.
- [IniUtils](./IniUtils)
    - Provides functions for parsing and working with INI configuration files.
- [Int64](./Int64)
- [InterModuleApi](./InterModuleApi)
- [Jsmn](./Jsmn)
    - Provides a JSON parser for AMX.
- [Json](./Json)
    - Provides functions for working with JSON data.
- [List](./List)
    - Provides an array-based list implementation.
- [LogicEngine](./LogicEngine)
- [Math](./Math)
    - Provides mathematical functions and utilities.
- [McpBase](./McpBase)
- [ModuleBase](./ModuleBase)
- [NetUtils](./NetUtils)
    - Provides network-related utility functions.
- [NtpUtils](./NtpUtils)
    - Provides functions for working with NTP (Network Time Protocol).
- [PathUtils](./PathUtils)
    - Provides utility functions for file path manipulation.
- [Queue](./Queue)
    - Provides an array-based queue implementation.
- [Regex](./Regex)
    - Provides regular expression matching and manipulation functions.
- [Redis](./Redis)
- [RmsBase](./RmsBase)
- [SnapiHelpers](./SnapiHelpers)
    - Provides helper functions for SNAPI communication.
- [SocketUtils](./SocketUtils)
    - Provides functions for socket communication.
- [Stack](./Stack)
- [Stopwatch](./Stopwatch)
    - Provides a stopwatch utility for timing operations.
- [StringUtils](./StringUtils)
    - Provides utility functions for string manipulation.
- [TimelineUtils](./TimelineUtils)
    - Provides functions for working with timelines.
- [Toml](./Toml)
    - Provides functions for parsing and working with TOML configuration files.
- [Tui](./Tui)
- [UIUtils](./UIUtils)
- [Url](./Url)
    - Provides functions for URL manipulation and encoding.
- [WebSocket](./WebSocket)
    - Provides a WebSocket client implementation for AMX.
- [Xml](./Xml)
    - Provides functions for working with XML data.
- [Yaml](./Yaml)
    - Provides functions for working with YAML data.

## Support :question:

If you have any questions or issues, please open an issue on the [GitHub repository](https://github.com/Norgate-AV/NAVFoundation.Amx/issues).

## Team :soccer:

This project is maintained by the following person(s) and a bunch of [awesome contributors](https://github.com/Norgate-AV/NAVFoundation.Amx/graphs/contributors).

<table>
  <tr>
    <td align="center"><a href="https://github.com/damienbutt"><img src="https://avatars.githubusercontent.com/damienbutt?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Damien Butt</b></sub></a><br /></td>
  </tr>
</table>

## Contributors :sparkles:

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->

[![All Contributors](https://img.shields.io/badge/all_contributors-1-orange.svg?style=flat-square)](#contributors-sparkles)

Thanks go to these awesome people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://allcontributors.org) specification.

Contributions of any kind are welcome!

Check out the [contributing guide](CONTRIBUTING.md) for more information.

## LICENSE :balance_scale:

[MIT](LICENSE)
