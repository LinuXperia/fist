MAKEFLAGS += -r

BINDIR := bin
BIN := $(BINDIR)/fist
BIN_SOURCES := \
	fist/bst.c \
	fist/dstring.c \
	fist/fist.c \
	fist/hashmap.c \
	fist/indexer.c \
	fist/serializer.c \
	fist/server.c \
	fist/tests.c \
	fist/lzf_c.c \
	fist/lzf_d.c

BIN_HEADER_SOURCES := \
	fist/bst.h \
	fist/dstring.h \
	fist/hashmap.h \
	fist/indexer.h \
	fist/serializer.h \
	fist/server.h \
	fist/version.h \
	fist/tests.h \
	fist/lzfP.h \
	fist/lzf.h


BIN_OBJECTS := $(BIN_SOURCES:=.o)
BIN_DEPS := $(BIN_SOURCES:=.d)

CC ?= gcc
CFLAGS ?= -Wall -O2 -g
CFLAGS += -std=c99 -D_DEFAULT_SOURCE
LDFLAGS ?=
LDLIBS :=
MKDIR ?= mkdir -p
RM ?= rm -f
CLANG_FORMAT ?= clang-format
DIFF ?= diff

.PHONY: all clean

all: $(BIN)

$(BIN): $(BIN_OBJECTS)
	$(MKDIR) $(BINDIR)
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

test: $(BIN)
	cppcheck --quiet --std=c99 --enable=style,warning,performance,portability,unusedFunction --error-exitcode=1 $(BIN_SOURCES)
	valgrind --log-file=valgrind.log --leak-check=full --error-exitcode=1  $(BIN) test

.PHONY: test

%.c.o: %.c
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

check_format:
	$(foreach f, $(BIN_SOURCES), $(CLANG_FORMAT) $(f) | $(DIFF) -u $(f) -;)
	$(foreach f, $(BIN_HEADER_SOURCES), $(CLANG_FORMAT) $(f) | $(DIFF) -u $(f) -;)

format:
	$(foreach f, $(BIN_SOURCES), $(CLANG_FORMAT) -i $(f);)
	$(foreach f, $(BIN_HEADER_SOURCES), $(CLANG_FORMAT) -i $(f);)

.PHONY: format check_format

clean:
	$(RM) $(BIN) $(BIN_OBJECTS) $(BIN_DEPS)

-include $(BIN_DEPS)
