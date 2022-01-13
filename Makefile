#
# Copyright (c) 2021 jdeokkim
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

.PHONY: all clean

# TODO: Change the values of `PROJECT_NAME`, `PROJECT_PATH`, and `PROJECT_PREFIX`
PROJECT_NAME := c-krit/ftmpl
PROJECT_PATH := ftmpl
PROJECT_PREFIX := $(shell tput setaf 8)$(PROJECT_NAME):$(shell tput sgr0)

BINARY_PATH := $(PROJECT_PATH)/bin
INCLUDE_PATH := $(PROJECT_PATH)/include
LIBRARY_PATH := $(PROJECT_PATH)/lib
SOURCE_PATH := $(PROJECT_PATH)/src

FEROX_PATH ?= $(LIBRARY_PATH)/ferox
RAYLIB_PATH ?= $(LIBRARY_PATH)/raylib
    
SOURCES := $(SOURCE_PATH)/main.c

OBJECTS := $(SOURCES:.c=.o)

# TODO: Edit the line below if you want another name for your executable
TARGETS := $(BINARY_PATH)/$(PROJECT_PATH)

HOST_OS := LINUX

ifeq ($(OS),Windows_NT)
	PROJECT_PREFIX := $(PROJECT_NAME):
	HOST_OS := WINDOWS
else
	UNAME = $(shell uname)
	ifeq ($(UNAME),Linux)
		HOST_OS = LINUX
	endif
endif

CC := gcc
CFLAGS := -D_DEFAULT_SOURCE -g $(INCLUDE_PATH:%=-I%) -std=gnu99 -O2
LDFLAGS := $(LIBRARY_PATH:%=-L%) -no-pie
LDLIBS := -lferox -lraylib -lGL -lm -lpthread -ldl -lrt -lX11

CFLAGS += -I$(FEROX_PATH)/ferox/include
LDFLAGS += -L$(FEROX_PATH)/ferox/lib

TARGET_OS := $(HOST_OS)

ifeq ($(TARGET_OS),WINDOWS)
	ifneq ($(HOST_OS),WINDOWS)
		CC := x86_64-w64-mingw32-gcc
	endif

# TODO: Edit the line below if you want another name for your executable
	TARGETS := $(BINARY_PATH)/$(PROJECT_PATH).exe

	CFLAGS += -I$(RAYLIB_PATH)/src
	LDFLAGS += -L$(RAYLIB_PATH)/src
	LDLIBS := -lferox -lraylib -lopengl32 -lgdi32 -lwinmm -lpthread
endif

all: pre-build build post-build

pre-build:
	@echo "$(PROJECT_PREFIX) Using: '$(CC)' to build this project."
    
build: $(TARGETS)

$(SOURCE_PATH)/%.o: $(SOURCE_PATH)/%.c
	@echo "$(PROJECT_PREFIX) Compiling: $@ (from $<)"
	@$(CC) -c $< -o $@ $(CFLAGS) $(LDFLAGS) $(LDLIBS)
    
$(TARGETS): $(OBJECTS)
	@mkdir -p $(BINARY_PATH)
	@echo "$(PROJECT_PREFIX) Linking: $(TARGETS)"
	@$(CC) $(OBJECTS) -o $(TARGETS) $(CFLAGS) $(LDFLAGS) $(LDLIBS)
    
post-build:
	@echo "$(PROJECT_PREFIX) Build complete."

clean:
	@echo "$(PROJECT_PREFIX) Cleaning up."
	@rm -rf $(BINARY_PATH)/*
	@rm -rf $(SOURCE_PATH)/*.o