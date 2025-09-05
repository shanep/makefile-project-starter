# Makefile Project Template

This is a simple Makefile project template that can be used to build, test, and
debug C projects. It includes support for debug builds, sanitizers, and code
coverage.

## Tools and Dependencies

- GNU Make
- GCC or Clang
- Address Sanitizer (ASan) for memory error detection
- gcov and lcov for code coverage
- gcovr for generating coverage reports
- pandoc for generating docx reports (optional)

## Test Harness

This project uses the Unity Test Framework for unit testing. Refer to the
[Unity Getting Started Guide](https://github.com/ThrowTheSwitch/Unity/blob/master/docs/UnityGettingStartedGuide.md) for more information on how to write and run tests.

## Example Usage

To build the project run:

```bash
make all
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
  print     - Print build variables for MakeFile debugging
  help      - Show this help message
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