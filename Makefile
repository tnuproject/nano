PACKAGE := nano
THIS_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
REPO_DIR := $(patsubst %/,%,$(dir $(THIS_MK)))
TNU_ROOT ?= $(abspath $(REPO_DIR)/../tnu)
BUILD ?= build
UPSTREAM := src/upstream

CC ?= gcc
TNU_ROOT := $(abspath $(TNU_ROOT))
ifeq ($(wildcard $(TNU_ROOT)/userspace/linker.ld),)
$(error nano: TNU_ROOT='$(TNU_ROOT)' does not look like a TNU checkout)
endif
USER_CRT := $(TNU_ROOT)/$(BUILD)/obj/userspace/libc/src/crt0.o
USER_LIB := $(TNU_ROOT)/$(BUILD)/user/libtnu.a

CFLAGS := -std=gnu11 -O2 -g -Wall \
          -ffreestanding -fno-stack-protector -fno-builtin -fno-pic \
          -m64 -mno-red-zone \
          -I$(TNU_ROOT)/userspace/libc/include \
          -I$(TNU_ROOT)/kernel/include \
          -Isrc \
          -Isrc/upstream/src \
          -include src/config.h
LDFLAGS := -T $(TNU_ROOT)/userspace/linker.ld -nostdlib -static -no-pie \
           -Wl,-z,max-page-size=0x1000

NANO_SRCS := $(UPSTREAM)/src/browser.c \
             $(UPSTREAM)/src/chars.c \
             $(UPSTREAM)/src/color.c \
             $(UPSTREAM)/src/cut.c \
             $(UPSTREAM)/src/files.c \
             $(UPSTREAM)/src/global.c \
             $(UPSTREAM)/src/help.c \
             $(UPSTREAM)/src/history.c \
             $(UPSTREAM)/src/move.c \
             $(UPSTREAM)/src/nano.c \
             $(UPSTREAM)/src/prompt.c \
             $(UPSTREAM)/src/rcfile.c \
             $(UPSTREAM)/src/search.c \
             $(UPSTREAM)/src/text.c \
             $(UPSTREAM)/src/utils.c \
             $(UPSTREAM)/src/winio.c

NANO_OBJS := $(patsubst $(UPSTREAM)/src/%.c,$(BUILD)/obj/%.o,$(NANO_SRCS))
SHIM_OBJ := $(BUILD)/obj/tnu_curses.o

.PHONY: all build clean fetch patch

all: build

build: $(BUILD)/$(PACKAGE)

fetch: $(UPSTREAM)/src/nano.c

$(UPSTREAM)/src/nano.c:
	@mkdir -p $(UPSTREAM)
	@if [ ! -f "$@" ]; then \
		echo "nano: fetch upstream nano into $(UPSTREAM)"; \
		echo "nano: expected files under $(UPSTREAM)/src/"; \
		false; \
	fi

patch: fetch
	@echo "nano: no additional patch step in standalone repo"

$(BUILD)/$(PACKAGE): $(NANO_OBJS) $(SHIM_OBJ) $(USER_LIB) $(USER_CRT)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(USER_CRT) $(NANO_OBJS) $(SHIM_OBJ) $(USER_LIB) -lgcc

$(BUILD)/obj/%.o: $(UPSTREAM)/src/%.c src/config.h src/tnu_curses.h
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -Wno-error -w -c $< -o $@

$(BUILD)/obj/tnu_curses.o: src/tnu_curses.c src/tnu_curses.h
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(BUILD)
