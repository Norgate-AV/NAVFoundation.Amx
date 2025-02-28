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

- [Libraries :books:](#libraries-books)
- [Key Features :sparkles:](#key-features-sparkles)
- [Installation :package:](#installation-package)
- [Quick Start :rocket:](#quick-start-rocket)
- [Documentation :page_facing_up:](#documentation-page_facing_up)
- [Support :question:](#support-question)
- [Team :soccer:](#team-soccer)
- [Contributors :sparkles:](#contributors-sparkles)
- [LICENSE :balance_scale:](#license-balance_scale)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Libraries :books:

- [Core](./Core)
- [ArrayUtils](./ArrayUtils)
- [BinaryUtils](./BinaryUtils)
- [Console](./Console)
- [Cryptography](./Cryptography)
- [DateTimeUtils](./DateTimeUtils)
- [Encoding](./Encoding)
- [Enova](./Enova)
- [ErrorLogUtils](./ErrorLogUtils)
- [FileUtils](./FileUtils)
- [HashTable](./HashTable)
- [HttpUtils](./HttpUtils)
- [InterModuleApi](./InterModuleApi)
- [Jsmn](./Jsmn)
- [LogicEngine](./LogicEngine)
- [Math](./Math)
- [McpBase](./McpBase)
- [ModuleBase](./ModuleBase)
- [NtpClient](./NtpClient)
- [PathUtils](./PathUtils)
- [Queue](./Queue)
- [Redis](./Redis)
- [RmsBase](./RmsBase)
- [SnapiHelpers](./SnapiHelpers)
- [SocketUtils](./SocketUtils)
- [Stack](./Stack)
- [Stopwatch](./Stopwatch)
- [StringUtils](./StringUtils)
- [TimelineUtils](./TimelineUtils)
- [Tui](./Tui)
- [UIUtils](./UIUtils)
- [Url](./Url)

## Key Features :sparkles:

- Modern, object-oriented approach to NetLinx programming
- Comprehensive utility libraries for common tasks
- Well-tested and production-ready components
- Consistent API design across all modules
- Full compatibility with AMX NetLinx Studio
- Extensive error handling and logging capabilities

## Installation :package:

This library can be installed using [Scoop](https://scoop.sh/).

```powershell
scoop bucket add norgate-av-amx
scoop install navfoundation-amx
```

## Quick Start :rocket:

Here are some basic usage examples:

```netlinx
// Example 1: Using the Core library
#include 'NAVFoundation.Core.axi'

DEFINE_START
{
    // Your code here
}

// Example 2: Using the HttpUtils library
#include 'NAVFoundation.HttpUtils.axi'

DEFINE_START
{
    // Your code here
}
```

## Documentation :page_facing_up:

For more detailed guides and documentation, please refer to the [official documentation](https://github.com/Norgate-AV/NAVFoundation.Amx/wiki).

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
