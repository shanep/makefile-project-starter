# Makefile Project Template

This is a simple Makefile project template that can be used to build, test, and
debug C projects. It includes support for debug builds, sanitizers, and code
coverage.

## Test Harness

This project uses the Unity Test Framework for unit testing. Refer to the
[Unity Getting Started Guide](https://github.com/ThrowTheSwitch/Unity/blob/master/docs/UnityGettingStartedGuide.md) for more information on how to write and run tests.

## Example Usage

To build the project run:

```bash
make release
```
To run the executable:

```bash
./build/release/myapp
```

To run the unit tests:

```bash
make check
```

To see all the configurations, run `make help`

```bash
Usage: make [target]
Available targets:
  debug     - Build the application in debug mode (default)
  release   - Build the application in release mode
  test      - Build the unit tests
  all       - Builds debug, release, and test targets
  check     - Run tests and check results
  report    - Generate coverage report after running tests
  leak      - Check for memory leaks in debug mode
  clean     - Remove build artifacts
  print     - Print build configuration and variables for debugging
  codespace - Set up the environment for CodeSpace
```

## VS Code Integration

This project is designed to work well with Visual Studio Code. Configurations
for debugging the application and unit tests are provided. Read about how to
use the debugger in the [VS Code documentation](https://code.visualstudio.com/docs/editor/debugging).

## Features

- Build targets for debug and release modes
- Support for Address Sanitizer (ASan)
- Code coverage support and report generation
- Simple structure for organizing source files and build artifacts
