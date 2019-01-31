#include <sys/types.h>
#include <sys/wait.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sysexits.h>
#include <unistd.h>

char *getinput(char *buffer, size_t buflen) {
	printf("$$ ");
	return fgets(buffer, buflen, stdin);
}

int main(int argc, char **argv) {
	char buf[1024];
	pid_t pid;
	int status;

	char command[1024];
	char *token;

	while (getinput(buf, sizeof(buf))) {
		buf[strlen(buf) - 1] = '\0';
		// check "exit" - If so, then exit
		if(strcmp(buf, "exit") == 0)
			break;

		if((pid=fork()) == -1) {
			fprintf(stderr, "shell: can't fork: %s\n", strerror(errno));
			continue;
		} else if (pid == 0) {
			/* child process to do each command 
			– place your code here to handle read, write, append */
			token = strtok(buf, " ");
			while(token != NULL) {
                                if(strstr(token, "read") != NULL) {
					token = strtok(NULL, " ");
					if(strcmp(token, "<") == 0) {
						token = strtok(NULL, " ");
						strcpy(command, "");
						strcat(command, "cat ");
						strcat(command, token);
						strcat(command, " > temp.txt");
						system(command);
						token = strtok(NULL, " ");
						if(strcmp(token, "|") != 0) {
							break;
						}
					} else {
						printf("Usage: read < filename\n");
					}
				} else if(strstr(token, "write") != NULL) {
					token = strtok(NULL, " ");
                                        if(strcmp(token, ">") == 0) {
                                                token = strtok(NULL, " ");
                                                strcpy(command, "");
                                                strcat(command, "cat temp.txt > ");
                                                strcat(command, token);
                                                system(command);
						token = strtok(NULL, " ");
						if(strcmp(token, "|") != 0) {
							break;
						}
                                        } else {
                                                printf("Usage: write > filename\n");
                                        }
				} else if(strstr(token, "append") != NULL) {
					token = strtok(NULL, " ");
                                        if(strcmp(token, ">>") == 0) {
                                                token = strtok(NULL, " ");
                                                strcpy(command, "");
                                                strcat(command, "cat temp.txt >> ");
                                                strcat(command, token);
                                                system(command);
						token = strtok(NULL, " ");
						if(strcmp(token, "|") != 0) {
							break;
						}
                                        } else {
                                                printf("Usage: append >> filename\n");
                                        }
				}
				token = strtok(NULL, " ");
			}

			exit(EX_OK);
		}
		
		if ((pid=waitpid(pid, &status, 0)) < 0)
			fprintf(stderr, "shell: waitpid error: %s\n", strerror(errno));
	}
	exit(EX_OK);
}
