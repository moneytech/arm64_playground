#include <stdio.h>
#include <string.h>

char *get_line_input(void) {
    static char buff[256];
    if (fgets(buff, 256, stdin) == NULL) {
        buff[0] = 0;
    }
    else {
        int end = strlen(buff);
        if (end > 0 && buff[end - 1] == '\n')
            buff[end - 1] = 0;
    }
    return buff;
}
void print_line(char *buff) {
    puts(buff);
}

void entry(void);

int main(int argc, char *argv[]) {
	entry();
}
