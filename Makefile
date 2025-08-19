APP_NAME ?= myapp
# Default build type (release)
BUILD ?= release

# Set the directories for build and source files
TEST_DIR ?= tests
SRC_DIR ?= src
BUILD_BASE_DIR ?= build

# Global Flags
CFLAGS ?= -Wall -Wextra  -MMD -MP
# For threading uncomment the next line
#LDFLAGS ?= -pthread


# Build configurations
ifeq ($(BUILD),release)
  CFLAGS += -O2
  BUILD_DIR := $(BUILD_BASE_DIR)/release
  TARGET ?= $(BUILD_DIR)/$(APP_NAME)
else ifeq ($(BUILD),debug)
  CFLAGS += -g -O0 -DDEBUG -fno-omit-frame-pointer -fsanitize=address
  LDFLAGS += -fsanitize=address
  BUILD_DIR := $(BUILD_BASE_DIR)/debug
  TARGET ?= $(BUILD_DIR)/$(APP_NAME)_d
else ifeq ($(BUILD),test)
  CFLAGS += -g -O0 -DTEST -fprofile-arcs -ftest-coverage
  LDFLAGS += -fprofile-arcs -ftest-coverage
  BUILD_DIR := $(BUILD_BASE_DIR)/tests
  TEST_TARGET ?= $(BUILD_DIR)/$(APP_NAME)_t
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
	$(CC) $(CFLAGS) $(TEST_OBJS) -o $@ $(LDFLAGS)

# Compile object files from source files
$(BUILD_DIR)/%.c.o: $(SRC_DIR)/%.c
	mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Compile object files from test source files
$(BUILD_DIR)/%.c.o: $(TEST_DIR)/%.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# These targets allow you to build in different modes without changing the BUILD variable
# You can run `make debug`, `make release`, etc.
# Each target will set the BUILD variable and call the main Makefile target
release:
	$(MAKE) BUILD=release
debug:
	$(MAKE) BUILD=debug
test:
	$(MAKE) BUILD=test

# Targets for running tests and cleaning up
.PHONY: debug release test clean print
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
