#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <limits.h>
#include <errno.h>
#include <signal.h>

char cwd[PATH_MAX + 1];

void sig_handler(int signum){
	if (signum == SIGINT)
		printf("\n[3150 shell:%s]$ ", cwd);
}

int main(){
	char tmp[256];
	char buf[256];

	setenv("PATH", "/bin:/usr/bin:.", 1);
	
	while (1){
		getcwd(cwd, PATH_MAX + 1);
		printf("[3150 shell:%s]$ ", cwd);

		signal(SIGINT, sig_handler);

		fgets(tmp, 256, stdin);
		tmp[strlen(tmp) - 1] = '\0';
		strcpy(buf, tmp);
		
		char *token = strtok(tmp, " ");

		int input_length = 0;
		while (token != NULL){
			token = strtok(NULL, " ");
			input_length++;
		}
	
		char **input = malloc(sizeof(char *) * input_length);
		int i;
		for (i = 0; i < input_length; i++)
			input[i] = malloc(sizeof(char));

		i = 0;
		input[i] = strtok(buf, " ");

		while (input[i] != NULL)
			input[++i] = strtok(NULL, " ");

		if (input[0] == NULL){
			;
		}
		else if (!strcmp(input[0], "exit")){
			if (input[1] != NULL)
				printf("exit: wrong number of arguments\n");
			else break;
		}
		else if (!strcmp(input[0], "cd")){
			if (input[2] != NULL)
				printf("cd: wrong number of arguments\n");
			else {
				int no = chdir(input[1]);
				if (no != 0)
					printf("%s: cannot change directory\n", input[1]);
			}
		}
		else {
			pid_t child_pid;
			if (!(child_pid = fork())){
				//setenv("PATH", "/bin:/usr/bin:.", 1);
				if (execvp(input[0], input) == -1){
					if (errno == 2)
						printf("%s: command not found\n", input[0]);
					else printf("%s: unknown error\n", input[0]);
				}
				exit(0);
			}
			else {
				waitpid(child_pid, NULL, WUNTRACED);
			}
		}
	}

	return 0;
}
