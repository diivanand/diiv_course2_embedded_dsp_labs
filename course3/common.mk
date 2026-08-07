# common.mk — shared build rules for every Course 3 module (m0 … m8).
#
# Included by each module's Makefile, which sets MODULE first:
#
#     MODULE := m3
#     include ../common.mk
#
# Layout convention: one directory per exercise under src/.  Every .c/.s file in
# that directory links into a single executable named after the directory.
#
#     src/ex-3-1/main.c
#     src/ex-3-2/driver.c  src/ex-3-2/routine.s   ->  build/ex-3-2
#
# Nothing here builds unless you create those directories — the exercises are
# yours to write.  `make new NAME=ex-3-1` scaffolds an empty one.
#
# Targets:  all list check run-<ex> dis-<ex> ll-<ex> thumb-<ex> new clean help
# Knobs:    OPT=0|1|2|3|s  SAN=1  VERBOSE=1

SHELL := /bin/bash

# ---------------------------------------------------------------- toolchain --
CC      := clang
OBJDUMP := $(shell xcrun --find llvm-objdump 2>/dev/null || echo llvm-objdump)

# Optimization level is a first-class knob: several Course 3 exercises only show
# what they are meant to show at -O0, and others exist to be read at -O2.
OPT ?= 0

WARN     := -Wall -Wextra -Wpedantic -Wshadow -Wconversion
BASE     := -std=gnu17 -g -O$(OPT) -fno-omit-frame-pointer
CFLAGS   ?= $(BASE) $(WARN)
ASFLAGS  ?= -g -O$(OPT)
LDFLAGS  ?=

# SAN=1 turns on AddressSanitizer + UndefinedBehaviorSanitizer (Modules 7–8).
ifeq ($(SAN),1)
CFLAGS  += -fsanitize=address,undefined -fno-sanitize-recover=all
LDFLAGS += -fsanitize=address,undefined
endif

# Cross-target used by the Cortex-M bridge (Module 6) and the embedded-C work
# (Module 8).  Apple clang can target this directly — no arm-none-eabi needed.
# -ffreestanding because there is no libc for this target: clang supplies its own
# stdint.h/stddef.h, but stdio.h and friends do not exist bare-metal.  Sources
# meant for `thumb-<ex>` must be freestanding-safe — i.e. the computational
# kernel, factored away from any printf-using driver.
THUMB_TARGET := thumbv7em-none-eabihf
THUMB_FLAGS  := --target=$(THUMB_TARGET) -mcpu=cortex-m4 -mfpu=fpv4-sp-d16 \
                -mfloat-abi=hard -std=gnu17 -O$(OPT) -ffreestanding -c

ifeq ($(VERBOSE),1)
Q :=
else
Q := @
endif

# ------------------------------------------------------------------ layout --
SRC   := src
BUILD := build
OBJ   := $(BUILD)/obj

EXERCISES := $(sort $(notdir $(patsubst %/,%,$(wildcard $(SRC)/*/))))
BINARIES  := $(addprefix $(BUILD)/,$(EXERCISES))

.PHONY: all list check new clean help
.DEFAULT_GOAL := all

all: $(BINARIES)
ifeq ($(EXERCISES),)
	@echo "[$(MODULE)] no exercises yet — create one with:  make new NAME=ex-N-M"
endif

# ------------------------------------------------- per-exercise rule factory --
# $(1) = exercise name.  Sources are every .c and .s in src/$(1)/.
define EXERCISE_RULES

$(1)_CSRC := $$(wildcard $(SRC)/$(1)/*.c)
$(1)_SSRC := $$(wildcard $(SRC)/$(1)/*.s)
$(1)_OBJS := $$(patsubst $(SRC)/$(1)/%.c,$(OBJ)/$(1)/%.o,$$($(1)_CSRC)) \
             $$(patsubst $(SRC)/$(1)/%.s,$(OBJ)/$(1)/%.o,$$($(1)_SSRC))

$(OBJ)/$(1)/%.o: $(SRC)/$(1)/%.c
	$$(Q)mkdir -p $$(dir $$@)
	$$(Q)echo "  CC    $$<"
	$$(Q)$$(CC) $$(CFLAGS) -MMD -MP -c $$< -o $$@

$(OBJ)/$(1)/%.o: $(SRC)/$(1)/%.s
	$$(Q)mkdir -p $$(dir $$@)
	$$(Q)echo "  AS    $$<"
	$$(Q)$$(CC) $$(ASFLAGS) -c $$< -o $$@

$(BUILD)/$(1): $$($(1)_OBJS)
	$$(Q)mkdir -p $$(dir $$@)
	$$(Q)echo "  LD    $$@"
	$$(Q)$$(CC) $$($(1)_OBJS) $$(LDFLAGS) -o $$@

.PHONY: run-$(1) dis-$(1) ll-$(1) thumb-$(1)

run-$(1): $(BUILD)/$(1)
	@echo "--- running $(1) (OPT=$$(OPT)$(if $(filter 1,$(SAN)), SAN=on,)) ---"
	@./$(BUILD)/$(1)

dis-$(1): $(BUILD)/$(1)
	$$(Q)$$(OBJDUMP) -d --no-show-raw-insn $(BUILD)/$(1)

# Emit LLVM IR for each C source (the course pairs A64 listings with .ll).
ll-$(1): $$($(1)_CSRC)
	$$(Q)mkdir -p $(BUILD)/ll/$(1)
	$$(Q)for f in $$($(1)_CSRC); do \
	    out=$(BUILD)/ll/$(1)/$$$$(basename $$$$f .c).ll; \
	    echo "  LL    $$$$out"; \
	    $$(CC) $$(CFLAGS) -S -emit-llvm $$$$f -o $$$$out; \
	  done

# Cross-compile the C sources to Cortex-M4 Thumb-2 and disassemble, for the
# "one algorithm, two ARMs" comparison.  Object only — no board, no linking.
thumb-$(1): $$($(1)_CSRC)
	$$(Q)mkdir -p $(BUILD)/thumb/$(1)
	$$(Q)built=0; \
	 for f in $$($(1)_CSRC); do \
	    out=$(BUILD)/thumb/$(1)/$$$$(basename $$$$f .c).o; \
	    if $$(CC) $$(THUMB_FLAGS) $$$$f -o $$$$out 2>$(BUILD)/thumb/$(1)/err.txt; then \
	      echo "  M4    $$$$f"; \
	      $$(OBJDUMP) -d --no-show-raw-insn $$$$out; \
	      built=$$$$((built+1)); \
	    else \
	      echo "  skip  $$$$f (not freestanding-safe for $(THUMB_TARGET))"; \
	      sed -n '1,3p' $(BUILD)/thumb/$(1)/err.txt | sed 's/^/          /'; \
	    fi; \
	  done; \
	  rm -f $(BUILD)/thumb/$(1)/err.txt; \
	  if [ $$$$built -eq 0 ]; then \
	    echo ""; \
	    echo "  Nothing cross-compiled.  This target is bare-metal: there is no libc,"; \
	    echo "  so a file using <stdio.h>, malloc, or the like cannot build for it."; \
	    echo "  Factor the routine you want to compare into its own .c file that"; \
	    echo "  includes only <stdint.h>/<stddef.h>, and keep the driver separate."; \
	  fi

endef

$(foreach E,$(EXERCISES),$(eval $(call EXERCISE_RULES,$(E))))

-include $(shell find $(OBJ) -name '*.d' 2>/dev/null)

# ------------------------------------------------------------------ helpers --
list:
	@echo "module $(MODULE) — exercises found in $(SRC)/:"
	@if [ -z "$(EXERCISES)" ]; then echo "  (none yet)"; \
	 else for e in $(EXERCISES); do echo "  $$e"; done; fi

# Verify the toolchain this module needs, without requiring any sources.
check:
	@echo "module $(MODULE) toolchain check"
	@printf '  %-22s' "clang";       command -v $(CC) >/dev/null && $(CC) --version | head -1 || { echo "MISSING"; exit 1; }
	@printf '  %-22s' "llvm-objdump"; command -v $(OBJDUMP) >/dev/null && echo "$(OBJDUMP)" || echo "MISSING (install Xcode CLT)"
	@printf '  %-22s' "host target";  $(CC) -dumpmachine
	@printf '  %-22s' "thumb target"; \
	  if echo 'int f(int x){return x+1;}' | $(CC) $(THUMB_FLAGS) -x c - -o /dev/null 2>/dev/null; \
	  then echo "$(THUMB_TARGET) OK"; else echo "$(THUMB_TARGET) UNAVAILABLE"; fi
	@echo "  OK"

new:
	@if [ -z "$(NAME)" ]; then echo "usage: make new NAME=ex-N-M"; exit 1; fi
	@mkdir -p $(SRC)/$(NAME)
	@echo "created $(SRC)/$(NAME)/ — add .c and/or .s files, then: make run-$(NAME)"

clean:
	$(Q)rm -rf $(BUILD)
	@echo "[$(MODULE)] cleaned"

help:
	@echo "Course 3 — module $(MODULE)"
	@echo
	@echo "  make                 build every exercise in $(SRC)/"
	@echo "  make list            list discovered exercises"
	@echo "  make check           verify the toolchain (no sources needed)"
	@echo "  make new NAME=ex-3-1 scaffold an empty exercise directory"
	@echo "  make run-<ex>        build and run one exercise"
	@echo "  make dis-<ex>        disassemble one exercise (A64)"
	@echo "  make ll-<ex>         emit LLVM IR for its C sources"
	@echo "  make thumb-<ex>      cross-compile to Cortex-M4 and disassemble"
	@echo "  make clean           remove $(BUILD)/"
	@echo
	@echo "  knobs:  OPT=0|1|2|3|s (default 0)   SAN=1 (ASan+UBSan)   VERBOSE=1"
	@echo
	@echo "  Layout: one directory per exercise under $(SRC)/; every .c/.s inside"
	@echo "          links into a single binary named after the directory."
