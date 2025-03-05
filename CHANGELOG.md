# Changelog

## [1.33.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.32.0...v1.33.0) (2025-03-05)

### 🌟 Features

- **core:** use log level INFO only to show banner ([3869fd0](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/3869fd04bf6a50ffcfb1e7f9eba34116b4888426))

## [1.32.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.31.0...v1.32.0) (2025-03-05)

### 🌟 Features

- **cryptography:** add initial sha256 implementation ([75ab001](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/75ab001145d6aa63fed5cd308a7c3440a29e1c31))
- **encoding:** add NAVHexToString alias function ([4f53b43](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/4f53b43cf8d08ae33814bb17a936c44775378de1))

### 🐛 Bug Fixes

- **intermodule-api:** remove unnecessary logging ([997d228](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/997d228bc5782e4f579390de39d01f3502a011c3))

## [1.31.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.30.0...v1.31.0) (2025-02-28)

### 🌟 Features

- **cryptography:** add initial aes128 implementation ([b422838](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/b422838f13d6979fca099edfe9fd5e03f7a1d6c9))
- add Stopwatch library ([7502d54](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/7502d549ca4b4919512ae4d25b26fdfbbe375bba))

### 🐛 Bug Fixes

- **cryptography:** output 20 byte digest for sha1 as per the RFC ([911f679](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/911f679389039d599c22b6af309135dcd34915d7))

## [1.30.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.29.0...v1.30.0) (2025-02-20)

### 🌟 Features

- **http-utils:** update NAVHttpRequestInit to take a \_NAVUrl struct ([54f80fd](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/54f80fd7bc0a880bbc7f5a55f48f0c2142191974))

## [1.29.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.28.0...v1.29.0) (2025-02-19)

### 🌟 Features

- **url:** add FullPath member to struct ([83dd725](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/83dd7254e8fdcc1b3c4b84a71ed83db56c46b8bc))
- **string-utils:** add NAVStringNormalizeAndReplace function ([46a0f5f](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/46a0f5fd9b6ab1782956da7d4f68280c57e48262))
- **string-utils:** add NAVStringTainCase function + various updates ([fbdbef4](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/fbdbef4223e0ad0003c50d5d22147f5c4beefce4))
- **http-utils:** complete initial implementation ([0e5f40e](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/0e5f40e2582344186560968d8c4e6f96db88aa32))

## [1.28.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.27.0...v1.28.0) (2025-02-18)

### 🌟 Features

- add Url library ([c4d6742](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/c4d6742892b7ecf9c16de8af9f21b10f89f8ae51))

## [1.27.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.26.3...v1.27.0) (2025-02-17)

### 🌟 Features

- **encoding:** add NAVCharToLong ([2322be8](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/2322be848e4d5c013fb783c310b930b30deffe7a))
- **encoding:** add specific ToByteArray functions for big/little endian ([e7c6dc4](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/e7c6dc4034b978a4adee3ea8a52319ae5a1235ab))
- complete initial SHA1 implementation ([81a56f2](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/81a56f274acb1e65d5cadb20e59f1458bdb964df))

## [1.26.3](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.26.2...v1.26.3) (2025-02-16)

### 🚀 Performance

- **string-utils:** use set_length_array only once before returning ([223c569](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/223c56941826cb0f2f81fb5dbff8ca5c1935c36e))
- **logic-engine:** use set_length_array only once before return ([3b67e94](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/3b67e9433c71b3e592e01581934da8c1fe45ed06))
- **snapi-helpers:** use set_length_array only once before return ([c9ed1ee](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/c9ed1ee1ac7fb3beaa6679c6f246700c1df6e067))

## [1.26.2](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.26.1...v1.26.2) (2025-02-15)

### 🚀 Performance

- **core:** remove unnecessary logging ([830d30d](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/830d30d5b781f795e5095ba58e612a7fe00a619e))
- **enova:** remove unnecessary logging ([2ae95d9](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/2ae95d94dd96e302ee1cbdfe893f0dba02c3b71d))
- **errorlog-utils:** remove unnecessary logging ([9800c1f](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/9800c1f9b9e591ba36bf4e9012781cc7a9a430c3))
- **file-utils:** remove unnecessary logging ([b14aae2](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/b14aae2a1860ade91980d3d5780448a594d12ceb))
- **mcp-base:** remove unnecessary logging ([61e870d](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/61e870dd30b6ec9e8f98a627942a04d42447e82d))
- **module-base:** remove unnecessary logging ([a5ea177](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a5ea1771228a4bfddf00932135fde8798e17ff1f))
- **rms-base:** remove unnecessary logging ([a070444](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a070444c5e56c7b11c1e66dc76cc3cd4a609a0bf))
- **socket-utils:** remove unnecessary logging ([8fc1df6](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/8fc1df6e8aa525090f139982242a97fa9806be75))
- **string-utils:** remove unnecessary logging ([6fc87ff](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/6fc87ff37dbf85fb3c815d143bf7c425a63a36f1))
- **timeline-utils:** remove unnecessary logging ([4e52730](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/4e5273012cccdb15109dd6fa01094f1d5d11e6d9))

## [1.26.1](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.26.0...v1.26.1) (2025-01-31)

### 🐛 Bug Fixes

- **socket-utils:** fix spelling error in socket logging ([8ff1e28](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/8ff1e2855fc357ff4e483f42c304f72b882d0663))

## [1.26.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.25.0...v1.26.0) (2025-01-29)

### 🌟 Features

- **socket-utils:** add helper functions for ssh client open/close ([16556ba](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/16556bafa770165aca8fc8e5b0a6c43a8c6b428f))

## [1.25.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.24.0...v1.25.0) (2025-01-10)

### 🌟 Features

- **enova:** add SWITCH event callback ([10b79e6](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/10b79e6a6135bd756cab226492cb50e67b5dcacb))

## [1.24.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.23.0...v1.24.0) (2025-01-09)

### 🌟 Features

- **enova:** add constant for mac inputs/outputs ([ea56c44](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/ea56c448d2694649706dac5daffab8e422fb937d))
- **enova:** add constant for switch level count ([cfde65a](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/cfde65ac2de8c4c60d4d009b7e8575f7a02655d1))
- **enova:** add new functions for dynamically getting IO info ([e067c82](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/e067c825c3322b1820360130d5dc070b1c561284))
- **enova:** compare current port to port count for ready status ([1de4ac0](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/1de4ac084a61fb9e3bdec61a0cd0d5efac133295))

## [1.23.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.22.0...v1.23.0) (2025-01-08)

### 🌟 Features

- **snapi-helpers:** add constant for switch level count ([1baea15](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/1baea15be856b4b53d3fb20df3b314d76c84dbc4))
- **snapi-helper:** add ParamaterCount member to NAVSnapiMessage type ([d68bb77](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/d68bb778f4f281424ccd538ab957cfe5cd417cda))
- **enova:** allow for up to 81 ports on switch device ([757df5c](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/757df5c2bb543ac89919ab071d392e5c387ea081))

## [1.22.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.21.1...v1.22.0) (2025-01-07)

### 🌟 Features

- **core:** get and show switcher device info if available ([27fc0ce](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/27fc0ce3c73642904554548b3e4327bf5c7d11c0))

### 🐛 Bug Fixes

- **enova-events:** display onerror correctly ([91fe619](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/91fe619234bd5bf11118f2fd31efb7e7a4a36cea))
- **module-base:** dont populate Property event.Args if there are none ([f3b8fdd](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/f3b8fdd498d2e211cedab0cf072126a3f5f57db3))

## [1.21.1](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.21.0...v1.21.1) (2025-01-05)

### 🐛 Bug Fixes

- **enova:** correct output labels and add output 4 ([41b7255](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/41b72554d40c9ac1bcafa89dfa9efd4183ae87e0))

## [1.21.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.20.1...v1.21.0) (2025-01-05)

### 🌟 Features

- **enova:** add audio xpoint definitions and helper functions ([44d6c6f](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/44d6c6f30aaf2f4a8d572a8991cfb44eba5e1fde))

## [1.20.1](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.20.0...v1.20.1) (2024-12-17)

### 🐛 Bug Fixes

- **core:** display error is master encounters an onerror event ([8509bbb](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/8509bbbb772d8febead713d4e815f9b03b3d2614))

## [1.20.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.19.0...v1.20.0) (2024-10-24)

### 🌟 Features

- **string-utils:** add aliases for NAVContains, StartsWith, EndsWith ([163899c](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/163899c4c79e71ac5bbb67bcce35387939ed02a0))
- **string-utils:** add NAVStringBetweenGreedy function ([590de8f](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/590de8fd611a0f5d1ee3f5b7a665b84a8c8f3223))

## [1.19.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.18.0...v1.19.0) (2024-10-23)

### 🌟 Features

- **lexer:** add a basic lexer library ([ee4919e](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/ee4919e0664a6395a3806160e4541003c96fe545))

## [1.18.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.17.0...v1.18.0) (2024-10-23)

### 🌟 Features

- **enova:** add NAVEnovaSetVideoMuteStateArray function ([0358a2e](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/0358a2ed54db7387f7ded3b3d112c2a24779117d))

## [1.17.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.16.0...v1.17.0) (2024-10-23)

### 🌟 Features

- **enova:** add new renamed library files ([5ba2c4e](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/5ba2c4e64968eb50f883b7292805ff153dcb2889))

## [1.16.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.15.1...v1.16.0) (2024-10-19)

### 🌟 Features

- **array-utils:** add SetArray function for all types ([b7663f0](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/b7663f06e20f1771f65209097a2cec03448f771b))
- **array-utils:** add types and functions for working with sets ([6dfa6af](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/6dfa6af2956b4c979f17165b4801b2891fa80206))

## [1.15.1](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.15.0...v1.15.1) (2024-10-18)

### 🐛 Bug Fixes

- **queue:** ensure count is set to 0 on init ([ddea693](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/ddea6932841ea2f9a32c6c996fb2b71fea13ed2a))

## [1.15.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.14.0...v1.15.0) (2024-10-18)

### 🌟 Features

- **queue:** add more detailed logging ([9137599](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/9137599d8c1d61dd69224e1c8510436c25d60b42))

## [1.14.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.13.0...v1.14.0) (2024-10-17)

### 🌟 Features

- **string-utils:** add NAVIsAlpha function ([4276835](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/42768356db47aaa4e5c3cb947c6f65ef1141a8ae))
- **string-utils:** add NAVIsAlphaNumeric function ([3d728db](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/3d728db784c1aa044a38c9dfb503af031c74483e))
- **string-utils:** add NAVIsDigit function ([7295814](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/72958142d9550aba70f51dc4fe63d1f72f3590a1))
- **string-utils:** add NAVIsSpace alias ([db39ff4](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/db39ff4c1fcd2dd36ed22fb9e862c0439278778c))

## [1.13.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.12.2...v1.13.0) (2024-10-16)

### 🌟 Features

- **string-utils:** add NAVStringAfter alias ([91fb654](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/91fb6544a9fdaf3bd9e32a4416ee9812f53c1b5d))
- **string-utils:** add NAVStringBefore alias ([49c931d](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/49c931d31404138bdef3f8f90b3a65ae91d0cfc1))
- **string-utils:** add NAVStringBetween alias ([a0a9ed2](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a0a9ed2ac0dd2e5f729fd3217d38648e92817ff5))
- **string-utils:** add NAVStringReplace alias ([e3d04fc](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/e3d04fc70f25b1470b4efa217fc5cd0edb32d9cf))
- **string-utils:** add param checks on strip functions ([3592f15](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/3592f15fcdc5cbecc018f5fea9c318f0d09bf317))

### 🐛 Bug Fixes

- **string-utils:** add param check in NAVIndexOf to prevent bad index ([0de8ff7](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/0de8ff7113533e00d01a6c789ab98320931ecd81))
- **string-utils:** fix bugs with NAVStringSubstring and NAVStringSlice ([586ad3c](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/586ad3cb0fbce909762ed18e46bea14776e7e571))

## [1.12.2](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.12.1...v1.12.2) (2024-10-14)

### 🐛 Bug Fixes

- **path-utils:** fix type conversion warnings ([1a48651](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/1a48651494cc74296301545988e3000537c1402e))
- **string-utils:** return char for boolean result functions ([63bf092](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/63bf0926ae35c65c1be34651dea8d55fbc4c997d))

## [1.12.1](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.12.0...v1.12.1) (2024-10-14)

### 🐛 Bug Fixes

- **file-utils:** if file_seek fails, ensure file is closed ([74b2a37](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/74b2a372afd6fa0807dd82d4495b9e8044db8af3))
- **file-utils:** use type_cast to fix compiler warnings ([bc72f2a](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/bc72f2ad0c7d25568784c61c24bedf31c074acdc))

## [1.12.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.11.0...v1.12.0) (2024-10-13)

### 🌟 Features

- **file-utils:** update NAVWalkDirectory function ([1fd0f28](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/1fd0f284f519cca379bfdc39e7bec2b59cec35ef))

## [1.11.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.10.0...v1.11.0) (2024-10-13)

### 🌟 Features

- **path-utils:** add NAVPathRelative and NAVPathResolve functions ([e804a10](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/e804a1067e6616131bc4eea8c2de54b24af1ff0c))
- **path-utils:** rename NAVPathSplitPath ([a0e1f9e](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a0e1f9e231ffc90c182ddfa6ffa93b110e19328c))
- **path-utils:** update NAVPathJoinPath function ([d9aa836](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/d9aa83682afa24799f33814729d363aeff2a6922))

## [1.10.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.9.0...v1.10.0) (2024-10-13)

### 🌟 Features

- **path-utils:** add helper function to remove escaped backslashes ([98338fa](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/98338faa5ebd5c601648a69fffcf2877d0b2218d))
- **path-utils:** add helper functions for identifying path slashes ([05e8a86](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/05e8a86cc7d954b25fa6c5cd7fbb8bacbe9f0896))
- **string-utils:** add NAVCharCodeAt function ([29e8d1b](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/29e8d1b38e62925f6c14e6f8b1aa36460bb8014b))
- **path-utils:** add NAVPathGetCwd function ([86e8f87](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/86e8f87b29d5f8780e00ed5fc4ff114b5e692be0))
- **path-utils:** add NAVPathIsAbsolute function ([5197c2a](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/5197c2a6dad45d4c837e2df530c417bd9f4f8438))
- **path-utils:** add NAVPathName function ([01c89d1](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/01c89d18e019e8cf3b09f3e02b7d4c33f4aec2bf))
- **path-utils:** add NAVPathNormalize function ([22ce625](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/22ce625297cbc325c69eaf61bf15a9ac569b8fe1))
- **string-utils:** complete NAVStringSlice function ([3f5a06f](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/3f5a06f9c70818919d9cc179f806d01c80de7f6b))
- **file-utils:** use updated functions in new path library ([f6511e4](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/f6511e4b8dd02e72df065cc84192558a4d0c7340))

### 🐛 Bug Fixes

- **path-utils:** ensure escaped backslashes are removed ([e537be0](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/e537be0befc7d36bf3ded99c3e129a4af78e51c6))
- **string-utils:** fix bug with NAVEndsWith function ([f263e41](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/f263e4156b39fd710bd841d8d3216a7c458a3e7a))
- **string-utils:** fix bug with NAVFindAndReplace function ([a9b1d40](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a9b1d4047be9dcd6bef79553c557d51fba0fee50))
- **path-utils:** fix bugs with NAVPathExtName function ([c488c80](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/c488c80057a293c095749c79f2a51b85769c7dbe))
- **string-utils:** fix NAVStringSubstring so returns the rest of string ([c274203](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/c274203d473902ab17a5ecfe8bda19c8cf33f5ea))
- **path-utils:** revamp NAVPathDirName function ([a360c90](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a360c903a04f0bb64b823893a90440ca2abab3a6))

## [1.9.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.8.0...v1.9.0) (2024-10-10)

### 🌟 Features

- **string-utils:** add NAVLastIndexOf function ([c869293](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/c869293a7a6857e9d64a3c058df66a96b3ca846a))
- move path related function into new PathUtils library ([1cee1ad](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/1cee1adafce2173f92e85f326390203c11364468))

## [1.8.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.7.2...v1.8.0) (2024-10-10)

### 🌟 Features

- **file-utils:** add debug logging to file copy/rename/delete functions ([c59f3aa](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/c59f3aad48e9718bfe4ad45ed7fd0a5ddfada19e))
- **file-utils:** add NAVDirectoryDelete function ([3bbef95](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/3bbef957a4cf8271b5d0950549c0a98df97c6ede))

### 🐛 Bug Fixes

- **errorlog-utils:** ensure logs directory is created, overwise exit ([9d755c2](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/9d755c2c54ce7d3d9144a04af18a766198ed3313))
- **errorlog-utils:** ensure NAVFormatLogToFile function returns a string ([ed743ae](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/ed743ae556eeb0e55415b5c11c3a418b7bbc0829))
- **file-utils:** remove return offset in NAVGetFileSize ([6d74632](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/6d746327f7280c07aba22867c298d0abdcb77abf))

## [1.7.2](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.7.1...v1.7.2) (2024-10-09)

### 🐛 Bug Fixes

- **errorlog-utils:** rename log files in reverse to not to overwrite ([99bb261](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/99bb261479e9a0eab0a05f028cb5d4ef004bdc7a))

## [1.7.1](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.7.0...v1.7.1) (2024-10-09)

### 🐛 Bug Fixes

- **errorlog-utils:** provide full absolute path in rename destination ([e0177de](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/e0177de7412e0fa2c1a44e512e0c1357da402cf4))

## [1.7.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.6.0...v1.7.0) (2024-10-09)

### 🌟 Features

- **errorlog-utils:** log to console when rotating log file ([09b827b](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/09b827b42e3ce6f58c08b6ad4df07f579436f0d0))

## [1.6.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.5.0...v1.6.0) (2024-10-09)

### 🌟 Features

- **errorlog-utils:** add error checking for getting file size ([202c69f](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/202c69f751f81b31268aa408540f07c3fa50bded))
- **errorlog-utils:** add option to send standard logs to file ([1019645](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/101964570568180992f4d6ad0c853ed778f6243e))

### 🚀 Performance

- **file-utils:** replace while loop with direct seek to end of file ([3dc2b1c](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/3dc2b1cf4a5a56e35285e06bbb57e7dfef17ca0a))

## [1.5.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.4.0...v1.5.0) (2024-10-09)

### 🌟 Features

- add error logging to file functionality ([65227df](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/65227df340c225bc63d215add3561a55bf4a5e12))

## [1.4.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.3.1...v1.4.0) (2024-10-08)

### 🌟 Features

- **core:** add Aspect state field to Display struct ([08001f2](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/08001f272d487643e73d31ed27a9a125a2295a05))
- **rms-events:** add asset method event callback ([2f2554c](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/2f2554c9831218fab2591986b17f80e8938f545a))
- **rms-events:** add asset registered event callbacks ([03de104](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/03de1048a7c78a9c97f95182a6611c4e321774f1))
- **rms-events:** add asset relocated event callback ([5663b18](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/5663b187f1b7f53a0ea966ec616a4b4811f2f019))
- **rms-events:** add assets register event callback ([b0ad149](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/b0ad149f23645500a454dfe2df6b2c4e3453636a))
- **device-priority-queue:** add debug logging ([6839d9e](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/6839d9e2301357723062e2901a2ceee38ef5d7c7))
- **rms-utils:** add device to \_NAVRmsSource struct ([9c0f252](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/9c0f252ff4600e7b0a9f1cea26ac20496cfe0dd8))
- **inter-module-api:** add extra functions ([346a525](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/346a5252229f01bc84c2c0f75613648061c322fe))
- **core:** add Freeze state field to Projector struct ([54ea3a4](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/54ea3a4bd8f9ace0041265ba2d1c9fcd258f26a6))
- **encoding:** add function aliases for Big/Little endian convertion ([e80450c](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/e80450c20881117d48a964a50068259e86c69463))
- **device-priority-queue:** add GetLastMessage function ([a0c76d4](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a0c76d42fd08f17c9d3d4d97e4a3acc15e0fd619))
- **inter-module-api:** add GetObjectRegistrationCount function ([31b1801](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/31b18015a238dd5fbfa2fdd7c692dc49eb6cb84b))
- **module-base:** add ID and BAUDRATE constants ([a2a379f](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a2a379fcc8c9484a998267447826ecb5c57c3a95))
- **cryptography:** add initial sha1 implementation ([63fb075](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/63fb0758c413af8d941fe3502482e0abe7cbc05f))
- **core:** add Initialized fields to state structs ([c2ad4ad](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/c2ad4adeaec35d42c9cd79ffebd3e3e898162958))
- **core:** add NAVDeviceIsOnline function ([6a4a415](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/6a4a415bfbf01576eff4ef7d0c1afd1cfa8056db))
- **data-time-utils:** add networktime setup ([6314a5c](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/6314a5cc531f81e348af0e12645a85c4bdbcaaba))
- **inter-module-api:** add object init function ([6daba2c](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/6daba2c40c2d89e9e39a8a189c131c93427ea8b3))
- **core:** add SendLevel functions ([a9cebd8](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a9cebd8c413ff513a1942752c752f063bbc47b37))
- **core:** add Socket number field to SocketConnection struct ([2bf3ec5](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/2bf3ec57407f1780e0595e4b37c9fd5ec9b6fc57))
- **core:** add some common state constants ([11e5dd3](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/11e5dd3c3c5b38f6b7d2646e98ca50e727b3a3e6))
- **inter-module-api:** add start_polling command header ([3153707](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/3153707b929966b4d32b2f870bb64747761047bd))
- **string-utils:** add StringSlice function ([99d439d](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/99d439dda7ca70f2e348808c13247de7bcfb29f1))
- **encoding:** complete base64 implementation ([64332de](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/64332deed93b36348353e14ac30ae3f53e41edda))
- **cryptography:** integrate md5 implementation ([3fc6773](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/3fc6773180b79bafe98fb425593d57a4bb92f37f))
- **errorlog-utils:** print calling file name in library function logs ([a6a0ef8](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a6a0ef82d09b89b1f85225922ea97d4c053060b5))
- **core:** print information banner on boot ([e944cb9](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/e944cb9d657f37b516427e7b87ed265c73df9d2f))
- **core:** print warning to console if **MAIN** is not defined ([457cecd](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/457cecd42e5447da77e8631e87aa3cae63d997de))
- **hashtable:** revert previous commit reducing default hashtable size ([801de50](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/801de5059674042af03cbf8069cf552eccb15c51))
- **queue:** revert previous commit reducing default queue size ([bee0d57](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/bee0d571c2edee8de89e872d977098ba4f21f98f))
- **stack:** revert previous commit reducing default stack size ([6a28b5d](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/6a28b5ddb6156b449b5a69f0b72dd84efdb4a025))

### 🐛 Bug Fixes

- **string-utils:** apply fix for NAVFindAndReplace function ([2f0e5f3](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/2f0e5f3717969c2520344373b6b594605650a175))
- **device-priority-queue:** dont negate IsEmpty functions when checking ([2bc48df](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/2bc48dfedf8a4e988d938dcf05555a2e0b944806))
- **queue:** ensure head/tail indexes dont equate to 0 ([d70bdfa](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/d70bdfae6b8116d1a73a2d9fe53fa0605d488db6))
- **socket-utils:** ensure host address does not have whitespace at the ([9920430](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/9920430484a21e7de4ed84fc65397c3a038d63af))
- **device-priority-queue:** ensure timeline array size is set ([456b0cb](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/456b0cb5ea37a6595d0b8264cf2866d60275e9d2))
- **string-utils:** fix bug with NAVGetStringBetween ([7ad3340](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/7ad3340088fe1cad8dde93e34a3d320a2d8d3fd4))
- **string-utils:** fix NAVSplitString function ([51f2262](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/51f226234268cde90a41df19d49e611f99175b5b))
- fix release scripts ([4ad6b29](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/4ad6b295e2e835b5e7f70140b92defdae80e858e))

## [1.3.1](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.3.0...v1.3.1) (2024-03-27)

### 🐛 Bug Fixes

- only get controller info and log message if we are in the main ([208e1e0](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/208e1e003e6978f911c86f2b13ba929d58943ce9))

### ✨ Refactor

- only log error/warnings to errorlog ([4fd6cd9](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/4fd6cd99d9ca116031dfc55600957d346e5b8e62))
- **core:** update banner ([a930601](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a930601d045c8f80f238c71005980f52163733b7))

## [1.3.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.2.2...v1.3.0) (2024-03-09)

### 🌟 Features

- auto update scoop bucket ([1f2e00e](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/1f2e00e29a45f858ce93551631b57b0203f1a7dc))

### ✨ Refactor

- use manifest name for archive name ([28588d5](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/28588d5de3db3a4409fb634c4aba41ab62fde68a))

## [1.2.2](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.2.1...v1.2.2) (2024-03-06)

### 🐛 Bug Fixes

- add recurse flag to GCI in SymLink script ([b6f0b19](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/b6f0b19eba903e111a56037a002f544ad433f9f6))

## [1.2.1](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.2.0...v1.2.1) (2024-03-06)

### 🐛 Bug Fixes

- set working directory to script dir in SymLink.ps1 ([f8bf98d](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/f8bf98ddc31a5f2c01c782b799c8dd545dc4a1ac))

### 🤖 CI

- cleanup workflow ([b5b8f05](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/b5b8f059b99d0ce3102e606affd2f874e56ec426))

## [1.2.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.1.0...v1.2.0) (2024-03-06)

### 🌟 Features

- create sha256 sum of archive and add to releases ([e48f46a](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/e48f46a474bc34ae1cabcd4bfb89401e8312ce52))
- update symlink script to handle deleting symlinks ([e402537](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/e4025370243e55351df69a3fc8c228d991adbb23))

## [1.1.0](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.0.2...v1.1.0) (2024-03-06)

### 🌟 Features

- add archive script to semantic-release config ([c6cb672](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/c6cb672208c236c82c4301c8a7d83c869d771a53))

### 🐛 Bug Fixes

- fix semantic-release config for added exec option ([e1d373e](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/e1d373e8709f5eb9c3f6a00a3c86261bd30376ec))

### ✨ Refactor

- remove version param from archive script ([cc50053](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/cc50053041f7f5a3a479e6a9250f0eef75b8a2b0))

## [1.0.2](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.0.1...v1.0.2) (2024-03-06)

### 🐛 Bug Fixes

- use correct key to issue command with semantic-release/exec ([2b696e9](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/2b696e995df2404fc9f3d1e3f61762a197f50de5))

## [1.0.1](https://github.com/Norgate-AV/NAVFoundation.Amx/compare/v1.0.0...v1.0.1) (2024-03-05)

### 🐛 Bug Fixes

- fix ci to edit manifest correctly ([8a0e9ae](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/8a0e9ae9a64a57ec5b0ad9e99151d333a9d5b1c1))

## 1.0.0 (2024-03-05)

### 🌟 Features

- **rms-base:** add \_NAVRmsAdapter type ([6828c87](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/6828c873ae1311fca33d17a52665f7da0b14a01a))
- **rms-base:** add \_NAVRmsHotlist type ([d32f910](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/d32f9105eb7555db1a15c32f0862c5dcd4c68dcf))
- **rms-utils:** add \_NAVRmsMonitorAssetProperties type ([b1fd4aa](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/b1fd4aa5af4581c10608b97bd9ce78f078f121e5))
- **rms-utils:** add \_NAVRmsSource struct ([d42f565](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/d42f56543673685e9072973e7b3f6477e3140e5b))
- **core:** add \_NAVRxBuffer type ([6b37331](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/6b37331f1660af8421833832a75ead00c3a967ed))
- **core:** add \_NAVStateBoolean type ([7ba02a0](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/7ba02a08ff7e55ad87dadba83722741822fc2518))
- **ui-utils:** add \_NAVUIState struct ([cc1a050](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/cc1a050bf253f1d8fc15493e54e4acfc64d049bf))
- **core:** add array of devices to \_NAVModule type ([77105fa](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/77105fabb084eff0e7ec9a43bc00c179ffb65179))
- **cryptography:** add base64 library ([2f30331](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/2f303315156ef097d176821b16978466ff5e3cff))
- **redis:** add basic redis library ([72dbff5](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/72dbff56cdb6a9d5be4a247520079acee763ecf2))
- **console:** add boilerplate for get info ([eb31371](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/eb313715e5395903302b3a86b335018b5bf231c2))
- **rms-base:** add catch all channel, button, and level event callbacks ([5532912](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/55329129477670cbebf2ea66fe319f038d7b7e0e))
- add ClientSocket functions ([0fe899e](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/0fe899e61f550667c6bde34861942f01109f3864))
- **core:** add credential type ([dfb52f0](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/dfb52f0fe3183e23285e9a86ddb24c4099a2e32a))
- **errorlog-utils:** add debug console log function call ([510727c](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/510727c7cb37e31a5b5527ddcae9b7b4295eb45c))
- **core:** add device info struct to \_NAVController type ([3b25665](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/3b25665738101e11c994447de34a668e07a95fd5))
- **core:** add device/string conversion functions ([b3320f0](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/b3320f07db1024e2825194533386c6593a0e8e3b))
- **queue:** add DevicePriorityQueue lib ([7d71443](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/7d71443795ba10a1f6a5f29183bbb257d0636f9f))
- **encoding:** add Encoding library ([a9e252b](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a9e252b8dd1342aceb66179770bd5ef087090d03))
- **console:** add extra constant definitions for command console ([ed71be8](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/ed71be87fb20922f5bfdd1a185cde2b2a977de73))
- **core:** add extra core functions ([9d76c07](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/9d76c07a2fb8307ba36eb01dc23424a267dfa034))
- **core:** add extra types ([65970a1](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/65970a17d0f52c05b9398c19324e09f1587be219))
- **rms-base:** add extra types ([a89c935](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a89c935fc197a89ff5c9f5becaa48cd574254de5))
- **core:** add feedback helper functions ([7011740](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/701174016f0c0176505a5adc2f8965bd7aa17b2e))
- **string-utils:** add function for reversing a string ([6c80fc3](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/6c80fc382df292e44b67412408933ff0c6943698))
- **rms:** add function for rms connection ([ecc6b01](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/ecc6b01a2bfff6ca1a397b40c66404ffec06c88c))
- **core:** add function to generate Norgate AV banner ([9b1e311](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/9b1e311c6d56cad5ebad20e57cc2372cb69f6572))
- **core:** add function to get mac address from unique id ([a5ffd53](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a5ffd535b8e656aa371b486be90958e376f7267a))
- **core:** add functions for getting controller information ([63ade03](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/63ade03223009cc12edc107115db3cebd454e897))
- **string-utils:** add functions for transforming cases ([4283966](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/4283966dca8a9f48a56302f5decc325a2aa3752e))
- **datetime-utils:** add functions for working with epoch ([346e335](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/346e335d37dae57fc251462a0922291e79bdca69))
- **stack:** add functions to support \_NAVStackInteger type ([beeebbd](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/beeebbde557c434f3fabc640a8810c7ec9f497a5))
- **socket-utils:** add GetSocketProtocol function ([cf4a2f8](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/cf4a2f801c1ef2ce98a56291ffda003ac60fad3a))
- **array-utils:** add initial file ([64e42a6](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/64e42a6725aaaeb0d60c25adea5374a2d0ca6d3d))
- **binary-utils:** add initial file ([99fd0b1](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/99fd0b16e3cc08d95c6182f53279239f4257c1ba))
- **core:** add initial file ([fa827f9](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/fa827f9328d214e5c8786ec4a8e65cdf42f663b6))
- **datetime-utils:** add initial file ([68d8388](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/68d8388f1a4642fe1459fc4444ac8e411b9ba1fe))
- **errorlog-utils:** add initial file ([e35c77f](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/e35c77fd94b38a8ffdc31c006036e3ac157f564f))
- **file-utils:** add initial file ([b457f81](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/b457f81ba7366b3b4ee73180a55ade7ad9cf2bb3))
- **hashtable:** add initial file ([b225cae](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/b225cae6b67448cbcef9959dda6ba58ccf5d4347))
- **jsmn:** add initial file ([a78a0f8](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a78a0f8ba557c3565d046e9845277a35a20dfbd6))
- **logic-engine:** add initial file ([3db90bd](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/3db90bdbd942c149849ae908e9395028ec1ee62d))
- **math:** add initial file ([b9888ed](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/b9888ed741ac4c7fc66910018b94491e1c159d19))
- **rms-base:** add initial file ([b634847](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/b634847a6927910397357a2eb98de7ad994fd28d))
- **rms-utils:** add initial file ([4cfc3d1](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/4cfc3d169c0a7548979dc556684fe895dcf80165))
- **mcp-base:** add initial files ([acf44ff](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/acf44ff0dc0d8b74188425b0a5ffcff0bd5c088b))
- **snapi-helpers:** add initial file ([1ec3357](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/1ec335721664b9b1d3982bfb90579de443be261e))
- **socket-utils:** add initial file ([ad7950b](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/ad7950b85a14a5c145316b174135abc0e126f586))
- **queue:** add initial files ([3cc62ef](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/3cc62ef86fbdba756a1df5c476b9ea0122749563))
- **stack:** add initial file ([85746cf](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/85746cf90f2204b32eeb9a5769bbde44f25477b7))
- **string-utils:** add initial file ([52334b8](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/52334b8684993d4883da55440151da39a83d65fd))
- **testing:** add initial file ([42c0089](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/42c0089bdd9158d56046280357e7a6e570dfc211))
- **ui-utils:** add initial file ([dab9c3d](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/dab9c3d4921326d1db4fc6fff6edbe1cc5e1ed60))
- **console:** add initial implementation of command console ([18429f9](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/18429f9778211cbeef1fd046a4662f73336dda7f))
- **debug-console:** add initial implementation ([8144f24](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/8144f245b678eeff0aa385cc39504dbbffe72fc0))
- **module-base:** add initial module base implementation ([d194a7d](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/d194a7d58a175f352b50e9088409a961b823549c))
- add inter-module api library ([81bcaa5](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/81bcaa5bf01e0de1e74414d88e4043abbb7e25aa))
- **socket-utils:** add invalid port error ([000a4b6](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/000a4b61ee206be57e2f8f4677088f9cfec63ed8))
- **core:** add IsAuthenticated flag to \_NAVSocketConnection type ([696da4d](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/696da4ddb20d73c20caaaa5dbfe967069011761a))
- **dxx:** add library for working with DxX devices ([4204b87](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/4204b87b4f92d5d25fb5e46ef04057c1fa7fb44b))
- **ntp-client:** add library for working with ntp ([04828e7](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/04828e7caafabb6939fe28fb89f3e1880b565a68))
- **core:** add master data event with basic logging ([9dccc1f](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/9dccc1f4b424908b4a88f145955c94478ff913b4))
- add md5 library ([fe32707](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/fe32707e1bd3627f690a7fc9d3a00fe61e89d02f))
- **core:** add NAVCommand functions ([a1781d4](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a1781d41f5a09c5f8990566a6f9f35d30db8640a))
- **file-utils:** add NAVFileReadLine function ([e7a4d62](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/e7a4d6291aec656e858cbf7acbc860c42e928549))
- **ui-utils:** add NAVPanelUpdate function ([58e6156](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/58e61567b45d03e1ee14c0607330f7c273d0af1d))
- **snapi-helpers:** add NAVParseSnapiMessage function ([f61aa05](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/f61aa056c0320da507d5a694b54eda12ab5e5436))
- **rms-base:** add NAVRmsClientInit function ([93c979b](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/93c979b194018bc957882b023f4bbb2a0678de46))
- **rms-base:** add NAVRmsConnectionCopy function ([6513c03](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/6513c037496470f62f57d8eeee491c00a6d57f35))
- **socket-utils:** add NAVServerSocketClose function ([50b50af](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/50b50af6ee931c2541bca6361e2ebbc1c6013fe8))
- **snapi-helpers:** add NAVSnapiHelpersErrorLog function ([6f76dd7](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/6f76dd7ea7bdd3a150e63617a4972b8b11d88e1a))
- **snapi-helpers:** add NAVSnapiMessageLog function ([fcd2487](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/fcd24874d0820eacd88b4d56f5e634dc5f662f8d))
- **string-utils:** add NAVStringGather function and callback ([b28bafc](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/b28bafc0b7f47dd25e4893f02d30f040a196caea))
- **string-utils:** add NAVStringSurround function ([5f52b16](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/5f52b165c4437da065dfb3f1e78fe9058501d4b9))
- **console:** add new command console types ([fa82062](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/fa82062e41f53e4272bde7b31308357582f9e102))
- **core:** add new functions to get xml and string to variable errors ([4038525](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/40385252249d61a09e0dc6e8051648ed295f7260))
- **rms-base:** add new functions to log rms notifications ([195b448](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/195b4483841fe17d16ea3da213b37252ee5a51ba))
- **array-utils:** add new functions ([9496d19](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/9496d19bfd135515dfd400cc81a7ef4219cd4dfc))
- **array-utils:** add new functions ([a46fa4c](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a46fa4c8ef18939a75a8b4efe73ae97df106a675))
- **array-utils:** add new functions ([64cbfab](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/64cbfab44ad4e0fcefeac0eda6031f3358aeb2b5))
- **array-utils:** add new functions ([c172217](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/c1722176e93bcc7f4131d09ad110eae973f67f75))
- **array-utils:** add new functions ([f0b6b8a](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/f0b6b8a5e0204a4bd9da3e2b2103d552742b7561))
- **binary-utils:** add new functions ([69344a7](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/69344a7ac6f96dca358ce57131a89c30a8ccc531))
- **math:** add new functions ([f781bdd](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/f781bddacdbae0a9eff997153b364685ccc2fcf0))
- **timeline-utils:** add new functions ([9293134](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/9293134e1b88f1a856121682856fa3bceea97fa1))
- **core:** add new NAVBooleanToOnOffString ([0eb404a](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/0eb404a72074920ad4f769f646ad0b4ed28f56c1))
- **array-utils:** add new slicing functions ([55ddede](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/55ddede5e700b847ce2ae396f98047a58e9bf48a))
- **module-base:** add passthru event handler and module init ([7819fbf](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/7819fbf85792da548d15b3261ae7ec1893d25d29))
- **core:** add serial port and data event types ([ba0adfb](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/ba0adfbca031d179bc9d71b450eb17892fa2cba8))
- **rms-base:** add server notification constants ([fcb0ece](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/fcb0ece2eca2707f941c00e2596d4d03ae7c9838))
- **array-utils:** add SetArray functions ([7e7ed93](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/7e7ed9344fc561718672b3dab56bd3ee1927a7b6))
- **datetime-utils:** add some boilerplate ([cb13066](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/cb13066ef94333714379bfdfc95cde3b72fca854))
- **file-utils:** add some boilerplate ([e4ac1e0](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/e4ac1e0a269306b58220cc4da30863cdc8b6f53e))
- **testing:** add some boilerplate ([3575be0](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/3575be04f7753cb061404924236d45435891eb56))
- **core:** add some core type casting functions ([7443185](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/744318517f37d1afcb43626fb1e47b2dd59c9a1b))
- **snapi-helpers:** add some helper functions ([621160e](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/621160e6174598b36e2955b79b1054371c19b41c))
- **enova:** add some more helpers and constants ([11e8186](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/11e818655c039fbe87e0fb7d57b0b825d63e120c))
- **core:** add specific kvp types ([59f5729](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/59f572938dfa88fd1cd89d622cc56a679ef7da53))
- **errorlog-utils:** add standard log message formatting ([539a42e](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/539a42e253695087f1b3e18108f8f7dfeb453da6))
- **http:** add start of http library ([085681c](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/085681cc4b1504a45d6a1a7bfa8cd237e5d444f1))
- add start of json library ([b723a66](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/b723a66068ed405644f406815ccb09b78b1730aa))
- add start of regex library ([75bc8e2](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/75bc8e2b46f307213a7f4c77b376c4516ed48c6f))
- **core:** add state tracking types ([267ac03](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/267ac03b75bf42c20314d474158434721257ad51))
- add SymLink.ps1 script to symlink files ([4608b2f](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/4608b2f1550b18574e037b4f85bbbd1ea4d0a4dc))
- **core:** add telnet command and option constants ([854b2f1](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/854b2f14e4d8e1e768f7c82a0fed13bfc75db71b))
- **testing:** add test suite type ([b40ea9b](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/b40ea9bb24ccf6ecaf206000ebae0ebaba2b50e4))
- **timedate-utils:** add timespec type ([a184cfb](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a184cfbc2b33984e12f8bb4c325573208e7f1e50))
- **timedate-utils:** add timespec type ([3ec9b67](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/3ec9b672d0e8771a2baebbd5dbdc93e41577b9f0))
- add tui library ([0b4d4e1](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/0b4d4e1d8de08f360d10274c6899d1babc260b71))
- **date-time-utils:** begin adding dst logic ([05dfcfb](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/05dfcfb60b3e3e2c2e4d7dc47df229dd4f38dc27))
- **core:** include RMSUtils if using RMS ([b0f4cff](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/b0f4cffde40999bad45ec2cca9ef105a4d1e2b56))
- **core:** include SnapiHelpers ([dcd832d](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/dcd832d882983d3a2dcded907b1cfad14284decb))
- **string-utils:** move types and constant into a separate header file ([ae8e0de](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/ae8e0de4ccb5841ba2277de5da8e1471ad01b420))
- **errorlog-utils:** only log to debug console if it is defined ([ff2bbcb](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/ff2bbcb19e168e64df57e5a84585efd47beb388c))
- **rms-base:** various updates ([3220615](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/3220615bf82ab4fb3b6fa5fc8f0c71aba5ccef83))

### 🐛 Bug Fixes

- **core:** add compiler directive for console libs ([25a5464](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/25a546437b1c6bb40206624f8d59fa5934d2f12e))
- **module-base:** add compiler directive for event ([27878ea](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/27878eae73834c722247049e4b6fa6b7c484649e))
- **rms-base:** add compiler directive in RmsEvents ([b1ab5d8](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/b1ab5d89d08da8bb68e38cd700f9443538276e26))
- **enova:** add events include ([e932e19](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/e932e19201e9fce3d01b63410af4fff146d71b23))
- **logic-engine:** add missing ArrayUtils lib ([a7a40ed](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a7a40ed750df2616eb4c3676cf0d81076c9c0377))
- **queue:** add missing underscore to device priority queue compiler ([d5ea3fb](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/d5ea3fbe529e8c4fd17dcd2b04078d6b3cd877d0))
- **snapi-helpers:** allow for escaped params in double quotes ([f786eb3](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/f786eb39b3ac5e058139e376e9fb871947580dff))
- **string-utils:** allow NAVSplitString to return empty strings ([bf1249d](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/bf1249d556b0b9f3b1f0b611d35867e1ac0e1758))
- **testing:** declare max array sizes ([d7e37f4](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/d7e37f4b7554584381bcff8db65e8a485bae9917))
- **core:** fix circular dependency cycle ([c93fcf1](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/c93fcf15e995d0d6032c6f3bc67da8a8f77bca20))
- fix circular dependency hell ([4aba406](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/4aba4068d1dbf5ff5331663145739afb7d4ab235))
- **regex:** fix compile errors in files ([adcb025](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/adcb02594b0db7cf00e896c3a7fa6c004ba41671))
- **module-base:** fix compiler directive for vdvObject events ([80c1d04](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/80c1d04680b7924438571422816302101635da01))
- **errorlog-utils:** fix return size in function ([3becea5](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/3becea54c2de6be9bcb434b25d70a502f61ec1c6))
- **testing:** fix struct naming ([24c1e46](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/24c1e46fc668c1517ca2af7a9bb72e8974fdb41c))
- **errorlog-utils:** fix type mismatch ([6853f6d](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/6853f6d6c189a669046cc8fdc83885cc58cd3e24))
- **binary-utils:** include Core to utilize Core constants ([557ac3c](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/557ac3cb41a5b633c7a87170a09aec8557166b09))
- **queue:** initialize priority queue at boot ([a110ad0](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a110ad0f03e86d01fd3dcc494831ab860ffa4466))
- **core:** move \_NAVDevice type further down list ([8162bd6](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/8162bd619e8d6f27fbfabd55ff5a70575ed772d5))
- **core:** re-add PROGRAM_NAME ([8c9880d](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/8c9880d4b646bbdcab36727999b1400b53e589a8))
- **string-utils:** return passed buffer if cannot find separator ([de562f6](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/de562f69eef6af0ef0b5c7d18be413a98fdb6c04))
- **timeline-utils:** return results from timeline_active calls ([da8f49f](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/da8f49f6a43a443fa1af3cd6784836f84cd8184f))
- **core:** set mac address array length ([a2526bd](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a2526bde77442355911238df78fa47d71eec93b0))
- **string-utils:** subtract from startIndex to capture data correctly ([3f1deb1](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/3f1deb1bf77a5a68a1a6498b69c6c8ad1eccefc1))
- temporary fix for weird error. need to investigate ([dff09e6](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/dff09e631fc9da8d373da4acca4c4ad52d5eec9a))
- **rms-base:** update name of \_NAVRmsException member ([7faf934](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/7faf934fabd95828c6fd6e7b449cfbfc61cd3ee2))
- **core:** update name of member to not clash with SNAPI ([b9f775a](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/b9f775a7459112649544cb50e165ef310586a262))
- **module-base:** update names to match correct type ([916f7a4](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/916f7a4d08f60b14a989660e938c6443a0ffc19e))
- **string-utils:** update operator for equality ([e081148](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/e081148c2e42b1bf0282ea759e014738e2bd1026))
- **console:** use compiler directive to disable some functionality ([9c7cf2a](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/9c7cf2a2c80a257b022d2f4fd6e2bc6af4dfd2d6))

### 📖 Documentation

- **rms-base:** add initial README ([ca5ce54](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/ca5ce54e03c54ef5127bd9e65a9ede7bfd736d96))
- add intial README.md ([0ffd943](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/0ffd943ac4260cefdb4684f024370a45e49bed63))
- add links to individual library README ([5ab6f72](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/5ab6f723fda9d11fc653c310b0093a6936b5bb7f))
- add README.md for each library ([6e00bb7](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/6e00bb7e3f4d11140befb9474a367002a16a0039))
- **console:** add README.md ([2c519da](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/2c519da9c9673d59fa4da03863ef623303ace3ae))
- **core:** add README.md ([6b72b28](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/6b72b28354dbc05c8955f0a0d9cb48a05a7c7d4d))
- update links to point to library folders ([d21e51e](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/d21e51e24b81548901cbc4ef7b8cdc8007fa9da3))
- update readme ([3279303](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/32793037e81e1836f74ae56314813e30026c7adb))
- **timeline-utils:** update README with some boilerplate examples ([fba811f](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/fba811f1a2dc2ae1c5e047055bf7b46a07dc0a48))

### 💅 Style

- **rms-utils:** add final new line ([2d9afaa](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/2d9afaa9db3be31991c9cc1e41990463b141321b))
- **array-utils:** add new lines ([358ba0c](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/358ba0c9d74f6bf804d8d96199adea9b5301879a))
- **core:** add section labels to some structs ([94a880d](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/94a880d3fd44ffe1d9819c713cce489d1f8df2f0))
- **core:** add some line breaks ([2401cae](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/2401caebce2bc42e6fe2a8f408d29fc715fe3e07))
- **snapi-helpers:** apply formatting ([c368b41](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/c368b41c6a878d9b95185d20a8b114f5cfb094ea))

### ✨ Refactor

- add \_NAVDevice to \_NAVModule ([28de64a](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/28de64ad991caba1a04e8c8fc0d67eb42c60fc08))
- add banner ([631449b](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/631449bc3c39e8b605899089e2d145571b9a5eed))
- **string-utils:** add better error logging ([03a2542](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/03a2542ee1fb84d7d549545e5c79676b795f89d1))
- **file-utils:** add better logging ([9e94999](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/9e94999f8aac1c5e45b2882746551f9378cc7e05))
- **socket-utils:** add better logging ([f54102c](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/f54102c49f0089c0dbf5e25b29c5fee21e4c1371))
- **rms-base:** add compiler directive ([cdf94a1](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/cdf94a12255a5f349debba1681f2a3917c9fa331))
- **core:** add deprecation warnings ([4ec7b5f](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/4ec7b5f52543f4980b871d70639aa7ff43cf5fbd))
- **module-base:** add device property to property event ([5af71b6](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/5af71b64218885fc32d37a5b556b30cd95652ad1))
- **rms-base:** add extra properties to \_NAVRmsClient type ([53ec39e](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/53ec39e35adc812df4e8b14be04e7ee5e641f5b9))
- **testing:** add helper constants ([b486d38](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/b486d38f8b52243e67ea8d642d3176302555691b))
- **core:** add more ascii codes ([a248946](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a248946fee01a983545030b33aef4dfdde7da8b1))
- **rms-base:** add Name property to \_NAVRmsConnection type ([954ab08](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/954ab0850d34fa8e9df0ff5ca774ec24929bab87))
- **module-base:** add passthru event type ([80be3ee](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/80be3eef990cf5fb98a8dbcbec198a8c874e0cb7))
- **testing:** add skip property ([f776ab4](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/f776ab4eed83710db6d1b51a699a0eb77c6d2697))
- **socket-utils:** add some logging to ClientSocketOpen ([91d7b24](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/91d7b24c57a7caaf89035fd96075d4a5b3ee8ce0))
- **snapi-helpers:** allow for escaped double quotes ([5e2a24f](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/5e2a24f543eff7f8576ca57308562db14f0d2ddf))
- **error-log-utils:** always log to debug console ([64cd0e4](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/64cd0e4c5e8f979f06ab08ceedff7836f39c6758))
- **rms-base:** check dvMaster is not already defined ([3a77096](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/3a77096b5e6a8461e43a1e4e7013fe7d0ab825ed))
- **file-utils:** check file exists before opening ([8b2ba7e](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/8b2ba7ec594e848c9e91d4518d6d6cdee4797b31))
- **file-utils:** cleanup cleanup file error string retrieval ([9942bd4](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/9942bd48de64d93a6d3a901f7cafb480ca306d66))
- **console:** comment out setting of array lengths ([a89a059](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a89a059ec730fb69a012ea1a459e9c372c484fd0))
- **rms-events:** disable some event logging ([f76b5f3](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/f76b5f3f5d3b95a29b3616e088080802ac54c7ce))
- **core:** dont include debug and command console by default ([064e749](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/064e7498dcf7178eaea3daee2f7d8d28e8237a6f))
- **timeline-utils:** dont log to error log ([265e484](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/265e484b5d60b7ca48c1431922c2a3d9a2275148))
- **core:** if log is empty print a carriage return ([4ccfa71](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/4ccfa7178d6b093797ce17836162c880c208850a))
- **rms-base:** log snapi messages ([6a42e63](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/6a42e638ba08908bd0c444741049a4f3d8c37849))
- make logging more consistent ([b74c266](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/b74c266aa80ac9badddddad97f5ccac413ae1608))
- **hashtable:** make logging more consistent ([489a950](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/489a9501bb6190e0c8806be706e7fe67e59e4b6a))
- **core:** make UniqueId specifically 6 chars long ([91b8a15](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/91b8a15d2893d32897c53324d2ba3f9c74d1f458))
- **rms-base:** move events into new RmsEvents file ([adc05e8](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/adc05e86281ddac07a6222d1b152323cff362e52))
- **console:** move function into utils file and make generic ([2046018](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/20460189531760bea35636eb92e68ae45f7f7324))
- **core:** move includes to before types ([e9003b9](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/e9003b9419125a4844fc73829892f6c4daa21376))
- **core:** move timeline functions into a separate file ([021266d](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/021266d6c602d731134ecea16030f4ea7bcfdb62))
- only log to debug console if defined ([1f1eaf2](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/1f1eaf2be9a9cf0b2664beb55f6cfd79eff89065))
- **console:** refactor code to use new \_NAVCommandConsole type ([ea647c4](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/ea647c4a552956a63f162623b62ac95944324aba))
- reinstate PROGRAM_NAME ([21f42e9](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/21f42e9d7c895db53a91efaaf13629daed957f11))
- **math:** reinstate PROGRAM_NAME ([09cf6d4](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/09cf6d4da261670e33ad4b5906ffdf337e8e9dc3))
- **file-utils:** remove count param from NAVFileRead ([9911b13](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/9911b1323a14461fb72fac615fada26294edd79a))
- **console:** remove ping from debug console ([dff2871](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/dff2871b00241e4b09d13efdb508dbd193e9dcfd))
- **rms-base:** remove PROGRAM_NAME from RmsUtils ([01cfbed](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/01cfbed51eca72eba2923aa3bb3b6d6c87c4a972))
- remove PROGRAM_NAME. use #DEFINE to declare name. ([d8e516c](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/d8e516c2893ba3ea422bced32d1aae1980a65796))
- **rms-base:** remove rms power monitoring module ([818e9cc](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/818e9cc1afdd503cf66b2fb5041a69390b77a00d))
- **core:** remove unnecessary line breaks from banner ([2312538](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/231253804e30034bb126ba526ede9f2c0102e560))
- **rms-base:** rename \_NAVRmsException type member ([ecd3d7e](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/ecd3d7ebc0baabc86c318444737ad0411a82b451))
- **rms-base:** rename \_NAVRmsState type to \_NAVRmsConnectionState ([ec622f3](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/ec622f3a8996894ccd6323410585d282843ff565))
- **hashtable:** rename from HashTableUtils to HashTable ([6165df8](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/6165df82bf9682ea34801a937963fb2aed3afb7d))
- **queue:** rename global prioroty queue variable to priorityQueue ([36438f9](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/36438f97e8f9c94aef9c59bdb0fc482972a63c66))
- **core:** replace compliler warnings with error logs ([74890c3](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/74890c3c47d96c748b5db6c3e94803a2aa0b1c3a))
- **timeline-utils:** return integer result from functions ([80d4db8](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/80d4db8c8cbaa266cdb2e435ec52e4f1f0e5dbba))
- **errorlog-utils:** return level in uppercase ([e9259ea](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/e9259ea4d0544c723d129da56405ac4d5897d1c6))
- **stack:** set array size as stack increases and decreases ([7943e06](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/7943e061f4cd8b2d88e0af274e4d3186de65671c))
- **string-utils:** set NAVSplitString default separator if empty ([a188c1f](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a188c1f147b30a8a89a37175f3464ec37ae0559b))
- **rms-base:** update callback names ([ed29b80](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/ed29b808a5041154bc3db3f286b767e6765400f7))
- **ntp-client:** update clock syncing logic ([0a8fc44](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/0a8fc4493bbf26fe5bf70544551ca5fc380f2c0e))
- **queue:** update device priority queue callbacks and show ([78cabcd](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/78cabcd66d6353cc27abcceac444950f5b5d1fb6))
- **timeline-utils:** update error levels ([d2eaa74](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/d2eaa74adaf39272f4c8114b6f784d1a5cb957bf))
- **module-base:** update errorlog function ([1866a57](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/1866a57882ca13d0c5484a3a1ba0d7ffff3e6708))
- update licenses ([f3c895c](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/f3c895c5d7c365a3e9cb7e149173aeaba64f873d))
- **rms-base:** update log messaging ([07fefe3](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/07fefe3ab6ff5f4bf697c9997ef5f89fd9e04b9b))
- update logging functions ([a6641a6](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a6641a670b8cfe5f5e8b3e4b798544fede3e88cb))
- **rms-base:** update logging functions ([4222845](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/4222845fd1e46164d8132360c32b27291cb652a1))
- **string-utils:** update NAVGetTimeSpan ([bf6fe14](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/bf6fe142bc56b37927e4a0c9c48aee22110a0761))
- **snapi-helpers:** update SnapiMessage type ([83f5194](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/83f5194112e3b1609b9299728ddeb1129c9a9c8a))
- **rms-base:** update wording in logs ([6053fcf](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/6053fcf7ceeff92c931678f5ccff89bcf1992960))
- **core:** use ErrorLogUtils ([afcf24e](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/afcf24e049e20c58707b5a4a707c44eaabae3583))
- **rms-base:** use existing constant in RmsApi ([a283dbe](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a283dbe02a98859fd40ead610a5db384fc58ae77))
- **rms-base:** use existing RmsApi constant for reinit command ([a01506f](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a01506f04e9588442ab1026cb5f80239bb59eb02))
- **rms-base:** use server event constants and logging functions ([2006866](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/2006866e5f567ece57aa07ea0b62810d6789566e))
- **console:** using NAVServerSocketClose function ([f85871f](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/f85871f36a4f7ada7811b187fc346f770b4e01ec))
- **logic-engine:** utilize timeline library functions ([825381a](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/825381a1923f964bfa25918adaf7412de97f8fd4))
- **logic-engine:** various updates and improvements ([7e75ffd](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/7e75ffd7e431cec030ce9622920e2f8ceb2d2877))
- **rms-base:** various updates and improvements ([b454c64](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/b454c6450c8d75059a00bd6cf4b288af15b3dbb3))
- **errorlog-utils:** various updates ([65f004a](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/65f004a9bb709fd458baa61a1547dd5b4df114dd))
- **array-utils:** wrap strings in single quotes when printing array ([87e0675](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/87e0675a04b4c930aa5c541e7593c40ff426caec))

### 🛠️ Build

- add build cfg ([15bf23d](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/15bf23d492e95eadbac83dbaa7aa52787737f7ec))
- add local genlinx config ([07c170a](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/07c170a969136c002f488aab4019bc652ebe3ce3))
- add new paths to local genlinx config ([dbe01fe](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/dbe01fe40b19f80fa99cbefed0b61d4cb86844b0))
- make root directory the parent folder of the cfg file ([0671bbc](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/0671bbcf8872fe98cecb4534d8882e33a14e16cc))
- remove build cfgs and use pwsh script instead ([d56eea7](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/d56eea7617c6a9134ed73c948820f6fa153b1fa2))
- remove uncommited files from build cfgs ([1f1682e](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/1f1682e100b4e2b2d0429897a898b22bde3fcd44))
- update include paths ([04cf00d](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/04cf00d51e9429de03a3af10070eb5d96be1398e))
- use project version of genlinx for build ([1471f6c](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/1471f6c5461efe3b3731a2137717da2fd816375b))

### 🤖 CI

- add basic workflow ([5fc6fdb](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/5fc6fdb0e53356023d685841e509486a69f35e29))
- add ci specific build cfg. upload artifacts ([3c1bfa1](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/3c1bfa1ec2ede4b56d5c5c69df729afd91f2ac05))
- add deploy script ([ea6f307](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/ea6f3070785f5eaa19ac726ecab1c462ec571dfc))
- add genlinx check ([27aa40b](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/27aa40b22d8173c90559fee23a0aeee2dbf75dec))
- add gitversion steps ([df49089](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/df49089eafa8a8c9761c08ed71ced028706c4227))
- add initial GitVersion config ([5a3e8c5](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/5a3e8c50c50e4c591eb558adf0c3a126f8d922d4))
- add install gitversion step ([3c23585](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/3c23585ab15b510c5211a91a010791e9c2663978))
- add psversion, user and pwd check ([8dc58f6](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/8dc58f631a0969750986f422603a862c400172ea))
- add semantic-release step ([f491512](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/f4915121e17d295c91a0d7b49dc2d4e795442aae))
- add step to create tag ([4957a1e](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/4957a1ed84f5dd4241dae62b5bf7d080f810f256))
- always run ci on server ([ce905bd](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/ce905bd1d74df9e5e5fa89c03c58e7f55312dcf6))
- disable gitversion show config ([8797cfc](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/8797cfc1e03005ce5788d092ed3d8f592dc7c1da))
- fix typo in build cfg file name ([1a8bff5](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/1a8bff5815bca0b5e88b994daf317e13a985b5a8))
- make ci actually work [#1](https://github.com/Norgate-AV/NAVFoundation.Amx/issues/1) ([e19e089](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/e19e089d3c56b056e731e482cf103f0df2c5981e))
- output full manifest ([f4d61f5](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/f4d61f52f61036424fc769ba0383a95fe1d2e3a2))
- remove build failure artifact upload ([50bb54c](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/50bb54c1e580c60e867e3aa859c28387351a0fb2))
- remove display semver. add update manifest step ([a6181ee](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/a6181ee4154270f3bbe950b0678d4b8ddd466093))
- remove duplicate id ([aaf6cfc](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/aaf6cfcb56c2c6a113713a02096e8d0ec3e0077c))
- remove non-existent refs from cfg ([22a3168](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/22a316873256c99c47bc016bec25a526f1e7bda1))
- remove release notes from semantic-release commit ([8fdae4a](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/8fdae4ae60a6031290fc8df8b900fe8325156e2a))
- run on any push using checkout@v2 ([fda8e9a](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/fda8e9a485594974e22d46449d36d6abcebdbace))
- show gitversion running config ([de41a04](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/de41a04514fbbd9d696a72897126866cc2ac2a93))
- update build cfgs ([ed9ffa1](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/ed9ffa14584f5c57d179852e4698678e4c44ce95))
- update ci workflow ([44c0144](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/44c014465bb89d837d47f14ffde876d27b8ecebe))
- update ci workflow ([b1f1cd5](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/b1f1cd503b1c147a7a124a2de74a125c637d5fc7))
- update main workflow ([192a1f7](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/192a1f7e0299d754e6286007088f61e63d2be3f5))
- update workflow to use pwsh script ([82a6957](https://github.com/Norgate-AV/NAVFoundation.Amx/commit/82a69576fc1393d4ab176766c72ed7bbdc377b48))
