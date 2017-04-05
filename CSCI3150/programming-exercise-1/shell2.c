#include <stdio.h>
#include <stdlib.h> //Needed by malloc(), free()
#include <string.h> //Needed by strtok(), strcmp()
#include <limits.h> // Needed by PATH_MAX
#include <unistd.h> // Needed by getcwd(), execvp()
#include <sys/wait.h>
#include <sys/types.h>
#include <errno.h>
#include <signal.h>
#include <glob.h>

int token(char *buf);
char* input();
int cd(char *token);
pid_t sys(char **arg, int hasInput, int hasOutput);
void fg(int number);
void jobs();

typedef struct jobs {
    char cmd[256];
    pid_t *pidList;
    struct jobs *next;
} Jobs;
Jobs *head;

void Append(char command[], pid_t *pidList);
void Delete(Jobs *del);


int main(){
    signal(SIGINT, SIG_IGN);    // Ctrl + C
    signal(SIGTERM, SIG_IGN);   // "kill" command
    signal(SIGQUIT, SIG_IGN);   // Ctrl + backslash
    signal(SIGTSTP, SIG_IGN);   // Ctrl + Z
 
    setenv("PATH","/bin:/usr/bin:.",1);
    while (1) input();
}

void Append(char command[], pid_t *pidList) {
    Jobs *newJob = malloc(sizeof(Jobs));
    strcpy(newJob->cmd, command);
    newJob->pidList = pidList;
    newJob->next = NULL;

    if (head == NULL) {
        head = newJob;
    } else {
        Jobs *temp;
        for(temp = head; temp->next != NULL; temp = temp->next);
        temp->next = newJob;
    }
    //return newJob;
}

void Delete(Jobs *del) {
    Jobs *pre, *newJob;
    pre = NULL;

    for (newJob = head; newJob != NULL; pre = newJob, newJob = newJob->next) { 
        if (newJob == del) {
            if (pre == NULL) {
                head = newJob->next;
            } else {
                pre->next = newJob->next;
            }
            free(newJob->pidList);
            free(newJob);
            break;
        }
    }
}

void fg(int targetJob) {
    printf("fg %d\n", targetJob);

    if (head == NULL) {
        printf("No suspended job\n");
        return;
    }

    Jobs *tmp = head;

    int i;
    int found = 0;
    for(i = 1; i <= targetJob; i++) {
        if (i == targetJob) {
            printf("Job wake up: %s\n", tmp->cmd);
            found = 1;

            pid_t *pList = tmp->pidList;
            int j = 0, status, suspended = 0;
            while(pList[j]){
                kill(pList[j], SIGCONT);

                waitpid(pList[j], &status, WUNTRACED);
                if (WIFSTOPPED(status)){

                    suspended = 1;
                    break; //break while
                }
                j++;
            }

            if (suspended == 0) {
                Delete(tmp);
            }

            break; //break for
        }

        if (tmp->next == NULL) {
            break;
        }
        tmp = tmp->next;
    }

    if (!found) {
        printf("No such job\n");
    }
}

void jobs() {
    if (head == NULL) {
        printf("No suspended job\n");
        return;
    }

    Jobs *tmp = head;
    int i = 1;
    while(1) {
        printf("[%d] %s\n", i++, tmp->cmd);
        if (tmp->next == NULL) {
            break;
        }
        tmp = tmp->next;
    }
}

int token(char *buf){
    int i = 0; int j = 0; int k, l;
    if (!strlen(buf)) return 0;
	char cmd[256];
	strcpy(cmd, buf);
    char *token = strtok(buf," ");
    if (!token) return 0;
    char ***argList = (char ***) malloc(sizeof(char*) * 130);
	argList[0] = (char **)malloc(sizeof(char *) * 130);
	
	while (token != NULL){
		if (!strcmp(token, "|")){
			argList[i][j] = NULL;				// skip the pipe
			i++;
			argList[i] = (char **)malloc(sizeof(char *) * 130);
			j = 0;
		}
		else {
			argList[i][j] = (char *)malloc(sizeof(char) * 256);
			strcpy(argList[i][j], token);				// copying from input if it is not a pipe
			j++;
		}
		token = strtok(NULL, " ");
	}

	free(token);

    argList[i][j] = NULL;		// the end of the input

    if (!strcmp(argList[0][0], "cd")){
		if (i >= 2 || j != 2)
			printf("cd: wrong number of arguments\n");        
		else if (chdir(argList[0][1]) == -1)
			printf("%s: cannot change directory\n", argList[0][1]);
    }
    else if (!strcmp(argList[0][0], "exit")){
        if (i >= 1 || j > 1)
			printf("exit: wrong number of arguments\n");
		else if (head != NULL)
			printf("There is at least one suspended job\n");
		else exit(0);
    }
    else if (strcmp(argList[0][0], "fg") == 0){
        if (i >= 2 || j != 2)
            printf("fg: wrong number of arguments\n");
        else fg(atoi(argList[0][1]));
    }
    else if (strcmp(argList[0][0], "jobs") == 0){
        jobs();  
    }
    else{
        pid_t child_pid;
		pid_t *pList = (pid_t *)malloc(sizeof(pid_t) * 130);
		int pipefd[2];
		int hasInput, hasOutput;
		char **command = (char**)malloc(sizeof(char *) * 130);

		for (k = 0; k <= i; k++){
			command = argList[k];

			if (k < i){
				pipe(pipefd);
				hasOutput = pipefd[1];		// not the last process, has output
			}
			else hasOutput = 1;

			child_pid = sys(command, hasInput, hasOutput);		// will fork a child to run something

			if(hasInput != 0)
				close(hasInput);
			if(hasOutput != 1)
				close(hasOutput);
			hasInput = pipefd[0];
			if (child_pid > 0)
				pList[k] = child_pid;		// store every children pid of the current job
		}

		int status;
		int suspended = 0;
		for (k = 0; k <= i; k++){
			waitpid(pList[k], &status, WUNTRACED);		// parent waits for children
			if (WIFSTOPPED(status)){
				Append(cmd, pList);			// if the job is suspended, link it to the job list
				suspended = 1;				// with all the pids of the children
				break;
			}
		}

		if (!suspended)
			free(pList);
    }

    for (k = 0; k <= i; k++){
		l = 0;
		while (argList[k][l] != NULL){
			free(argList[k][l]);
			l++;
		}
		free(argList[k]);
	}
	free(argList);

    return 0;
}

char* input(){
    char cwd[PATH_MAX+1];
    char *buf = malloc(255*sizeof(char));
    if(getcwd(cwd,PATH_MAX+1) != NULL){
        printf("[3150 shell:%s]$ ", cwd);
        fgets(buf,255,stdin);
        buf[strlen(buf)-1] = '\0';
        token(buf);
    }
    else{
        printf("Error Occured!\n");
    }
    return buf;
}

int cd(char *token){
    char buf[PATH_MAX+1];
    if(chdir(token) != -1){
        getcwd(buf,PATH_MAX+1);
        //printf("Now it is %s\n",buf);
    }
    else{
        printf("%s: Cannot Change Directory\n", token);
    }
    return 0;
}

pid_t sys(char **arg, int hasInput, int hasOutput) {
	char **wildcard = (char **)malloc(sizeof(char *) * 600);
	int i = 1;
	int j = 1;
	wildcard[0] = (char *)malloc(sizeof(char) * 256);
	strcpy(wildcard[0], arg[0]);

	while (arg[i] != NULL){
		if (strchr(arg[i], '*') != NULL){
			glob_t result;
			glob(arg[i], GLOB_NOCHECK, NULL, &result);
			int k;
			for (k = 0; k < result.gl_pathc; k++){
				wildcard[j] = (char *)malloc(sizeof(char) * 256);
				strcpy(wildcard[j], result.gl_pathv[k]);
				j++;
			}
			globfree(&result);
		}
		else {
			wildcard[j] = (char *)malloc(sizeof(char) * 256);
			strcpy(wildcard[j], arg[i]);
			j++;
		}
		i++;
	}

	wildcard[j] = NULL;



    pid_t child_pid;
    if(!(child_pid = fork())) {
        signal(SIGINT, SIG_DFL);    // Ctrl + C
        signal(SIGTERM, SIG_DFL);   // "kill" command
        signal(SIGQUIT, SIG_DFL);   // Ctrl + backslash
        signal(SIGTSTP, SIG_DFL);   // Ctrl + Z

		setenv("PATH", "/bin:/usr/bin:.", 1);

		if (hasInput != 0){
			dup2(hasInput, STDIN_FILENO);		// if this process will read from previous process
			close(hasInput);
		}
		if (hasOutput != 1){
			dup2(hasOutput, STDOUT_FILENO);		// if this process will write to next process
			close(hasOutput);
		}

		execvp(*arg, wildcard);

        if(errno == 2)
            printf("%s: command not found\n", *arg);
        else
            printf("%s: unknown error\n", *arg);

        exit(0);
    }
    
    return child_pid;
}
