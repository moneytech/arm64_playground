all: runner
CFLAGS := -g3 -O0
ASFLAGS := -g3
entry.o: entry.S
	as $(ASFLAGS) $< -o $@
runner: runner.c entry.o
	$(CC) $(CFLAGS) -Wall $^ -o $@
