APP_NAME ?= myapp
# Default build type (debug, release, test)
BUILD ?= release

# Set the directories for build and source files
TEST_DIR ?= tests
SRC_DIR ?= src
BUILD_BASE_DIR ?= build

# Flags for hardening and security
# https://best.openssf.org/Compiler-Hardening-Guides/Compiler-Options-Hardening-Guide-for-C-and-C++.html
CFLAGS ?= -Wall -Wextra -O2 -fPIE -MMD -MP
CFLAGS += -Wformat -Wformat=2 -Wconversion -Wsign-conversion -Wimplicit-fallthrough
CFLAGS += -fstrict-flex-arrays=3  -fstack-protector-strong
CFLAGS += -Werror=format-security -Werror=implicit -Werror=incompatible-pointer-types -Werror=int-conversion

# For threading uncomment the next line
#LDFLAGS ?= -pthread

# Build configurations
ifeq ($(BUILD),release)
  BUILD_DIR := $(BUILD_BASE_DIR)/release
  TARGET ?= $(BUILD_DIR)/$(APP_NAME)
else ifeq ($(BUILD),debug)
  CFLAGS := -g -O0 -DDEBUG -fno-omit-frame-pointer -fsanitize=address
  LDFLAGS += -fsanitize=address
  BUILD_DIR := $(BUILD_BASE_DIR)/debug
  TARGET ?= $(BUILD_DIR)/$(APP_NAME)_d
else ifeq ($(BUILD),test)
  CFLAGS := -g -O0 -DTEST -fprofile-arcs -ftest-coverage
  LDFLAGS += -fprofile-arcs -ftest-coverage
  BUILD_DIR := $(BUILD_BASE_DIR)/tests
  TEST_TARGET ?= $(BUILD_DIR)/$(APP_NAME)_t
else ifeq ($(BUILD),debug-test)
  CFLAGS := -g -O0 -DDEBUG -DTEST -fno-omit-frame-pointer -fsanitize=address
  LDFLAGS += -fsanitize=address
  BUILD_DIR := $(BUILD_BASE_DIR)/debug-test
  TEST_TARGET ?= $(BUILD_DIR)/$(APP_NAME)_td
else
  $(error Invalid build type: $(BUILD))
endif

# Collect all source files and their object files
SRCS := $(shell find $(SRC_DIR) -name *.c)
OBJS := $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.c.o,$(SRCS))
DEPS := $(OBJS:.o=.d)
# Collect all the test source files and their object files
TEST_SRCS := $(shell find $(TEST_DIR) -name *.c)
TEST_OBJS := $(patsubst $(TEST_DIR)/%.c,$(BUILD_DIR)/%.c.o,$(TEST_SRCS))
TEST_DEPS := $(TEST_OBJS:.o=.d)

# Link the object files to create the final executable
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $@ $(LDFLAGS)

# Line the object files to create the test executable
$(TEST_TARGET): $(OBJS) $(TEST_OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(TEST_OBJS) -o $@ $(LDFLAGS)

# Compile object files from source files
$(BUILD_DIR)/%.c.o: $(SRC_DIR)/%.c
	mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Compile object files from test source files
$(BUILD_DIR)/%.c.o: $(TEST_DIR)/%.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@


# Targets for running tests and cleaning up
.PHONY: release debug test debug-test all clean print check report report-txt leak leak-test
# These targets allow you to build in different modes without changing the BUILD variable
# You can run `make debug`, `make release`, etc.
# Each target will set the BUILD variable and call the main Makefile target
release:
	$(MAKE) BUILD=release
debug:
	$(MAKE) BUILD=debug
test:
	$(MAKE) BUILD=test
debug-test:
	$(MAKE) BUILD=debug-test

all: debug release debug-test test
	@echo "All builds completed: debug, release, and test."

leak: debug
	$(MAKE) BUILD=debug _leak
_leak:
	@echo "Running memory leak check..."
	ASAN_OPTIONS="detect_leaks=1" ./$(BUILD_DIR)/$(APP_NAME)_d
	@echo "Memory leak check complete. Check the output above for any leaks."

leak-test: debug-test
	$(MAKE) BUILD=debug-test _leak-test
_leak-test:
	@echo "Running memory leak on unit tests ..."
	ASAN_OPTIONS="detect_leaks=1" ./$(BUILD_DIR)/$(APP_NAME)_td
	@echo "Memory leak check complete. Check the output above for any leaks."

check: test
	$(MAKE) BUILD=test _check
_check:
	./$(BUILD_DIR)/$(APP_NAME)_t
	@echo "Tests completed."

report: clean test
	$(MAKE) BUILD=test _report
_report:
	@echo "Generating HTML coverage report..."
	./$(BUILD_DIR)/$(APP_NAME)_t
	gcovr -r . --html --html-details --exclude-directories $(BUILD_DIR)/harness --exclude '.*main\.c$$' --exclude '.*test\.c$$' -o $(BUILD_DIR)/coverage_report.html
	@echo "Coverage report generated at $(BUILD_DIR)/coverage_report.html"

report-txt: clean test
	$(MAKE) BUILD=test _report-txt
_report-txt:
	@echo "Generating text coverage report..."
	./$(BUILD_DIR)/$(APP_NAME)_t
	gcovr --txt -r . --exclude-directories $(BUILD_DIR)/harness --exclude '.*main\.c$$' --exclude '.*test\.c$$'

help:
	@echo "Usage: make [target]"
	@echo "Available targets:"
	@echo "  all         - Builds debug, release, and test targets"
	@echo "  release     - Build the application in release mode (default)"
	@echo "  debug       - Build the application in debug mode"
	@echo "  test        - Build the unit tests"
	@echo "  check       - Run tests and check results"
	@echo "  report      - Generate HTML coverage report after running tests"
	@echo "  report-txt  - Generate text coverage report after running tests"
	@echo "  leak        - Check for memory leaks in executable debug mode"
	@echo "  leak-test   - Check for memory leaks in unit tests debug mode"
	@echo "  clean       - Remove build artifacts"
	@echo "  print       - Print build variables for MakeFile debugging"
	@echo "  help        - Show this help message"


clean:
	$(RM) -rf $(BUILD_BASE_DIR)

# Print the build configuration and variables for debugging build issues
print:
	@echo "---- Build Configuration ----"
	@echo "Building in $(BUILD) mode"
	@echo "Build directory: $(BUILD_DIR)"
	@echo "CFLAGS: $(CFLAGS)"
	@echo "LDFLAGS: $(LDFLAGS)"
	@echo "---- Source Information ----"
	@echo "App Target: $(TARGET)"
	@echo "App source files: $(SRCS)"
	@echo "App object files: $(OBJS)"
	@echo "App dependencies: $(DEPS)"
	@echo "---- Test Information ----"
	@echo "Test target: $(TEST_TARGET)"
	@echo "Test source files: $(TEST_SRCS)"
	@echo "Test object files: $(TEST_OBJS)"
	@echo "Test Dependencies: $(TEST_DEPS)"


# Include the dependency files if they exist
# This allows for automatic dependency tracking
-include $(DEPS) $(TEST_DEPS)
