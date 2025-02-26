#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <pwd.h>
#include <signal.h>
#include <getopt.h>
#include <limits.h>
#include <sys/types.h>
#include <readline/readline.h>
#include <readline/history.h>
#include "lab.h"

// Task 2: Print Version and parse args
void parse_args(int argc, char **argv) {
    int opt;
    while ((opt = getopt(argc, argv, "v")) != -1) {
        switch (opt) {
            case 'v':
                printf("Shell version %d.%d\n", lab_VERSION_MAJOR, lab_VERSION_MINOR);
                exit(EXIT_SUCCESS);
            default:
                fprintf(stderr, "Usage: %s [-v]\n", argv[0]);
                exit(EXIT_FAILURE);
        }
    }
}

// Task 4: Custom Prompt
char *get_prompt(const char *env) {
    const char *prompt_value = getenv(env);
    if (prompt_value) {
        return strdup(prompt_value);
    } else {
        return strdup("shell>");
    }
}

// Handle whitespace trimming for user input
char *trim_white(char *line) {
    if (!line) return NULL;
    
    // Trim leading whitespace
    char *start = line;
    while (isspace((unsigned char)*start)) {
        start++;
    }
    
    // All whitespace
    if (*start == '\0') {
        *line = '\0';
        return line;
    }
    
    // Trim trailing whitespace
    char *end = start + strlen(start) - 1;
    while (end > start && isspace((unsigned char)*end)) {
        end--;
    }
    
    // Terminate string after last non-whitespace character
    *(end + 1) = '\0';
    
    // If there was leading whitespace, shift the trimmed string to the beginning
    if (start != line) {
        memmove(line, start, (end - start) + 2); // +2 for the null terminator
    }
    
    return line;
}

// Parse commands for execution
char **cmd_parse(char const *line) {
    if (!line) return NULL;
    
    // Get maximum argument size from system
    long arg_max = sysconf(_SC_ARG_MAX);
    int max_args = (int)arg_max;
    if (max_args <= 0) max_args = 1024; // Fallback value
    
    char **result = (char **)calloc(max_args, sizeof(char *));
    if (!result) return NULL;
    
    // Make a copy of the line we can modify
    char *linecopy = strdup(line);
    if (!linecopy) {
        free(result);
        return NULL;
    }
    
    // Tokenize and store arguments
    int i = 0;
    char *token = strtok(linecopy, " ");
    while (token && i < max_args - 1) {
        result[i] = strdup(token);
        token = strtok(NULL, " ");
        i++;
    }
    
    // Last element is NULL to match execvp requirements
    result[i] = NULL;
    
    free(linecopy);
    return result;
}

// Free command resources
void cmd_free(char **line) {
    if (!line) return;
    
    for (int i = 0; line[i] != NULL; i++) {
        free(line[i]);
    }
    free(line);
}

// Task 5: Built-in Commands (exit, cd, history)
int change_dir(char **dir) {
    char *target_dir = NULL;
    
    // If no argument is provided or only "cd" is specified
    if (!dir[1]) {
        // First try to get HOME from environment
        target_dir = getenv("HOME");
        
        // If HOME is not set, use getpwuid to find home directory
        if (!target_dir) {
            uid_t uid = getuid();
            struct passwd *pw = getpwuid(uid);
            if (pw) {
                target_dir = pw->pw_dir;
            } else {
                fprintf(stderr, "cd: Could not determine home directory\n");
                return -1;
            }
        }
    } else {
        target_dir = dir[1];
    }
    
    // Change directory
    int result = chdir(target_dir);
    if (result != 0) {
        perror("cd");
        return -1;
    }
    
    return 0;
}

// Handle built-in commands
bool do_builtin(struct shell *sh, char **argv) {
    if (!argv || !argv[0]) return false;
    
    // Handle exit command
    if (strcmp(argv[0], "exit") == 0) {
        sh_destroy(sh);
        exit(EXIT_SUCCESS);
        return true;
    }
    
    // Handle cd command
    if (strcmp(argv[0], "cd") == 0) {
        change_dir(argv);
        return true;
    }
    
    // Handle history command
    if (strcmp(argv[0], "history") == 0) {
        HIST_ENTRY **hist_list = history_list();
        if (hist_list) {
            for (int i = 0; hist_list[i]; i++) {
                printf("%5d  %s\n", i + 1, hist_list[i]->line);
            }
        }
        return true;
    }
    
    // Not a built-in command
    return false;
}

// Initialize shell
void sh_init(struct shell *sh) {
    // Set up shell data structure
    sh->prompt = get_prompt("MY_PROMPT");
    
    // Check if we're in an interactive session
    sh->shell_terminal = STDIN_FILENO;
    sh->shell_is_interactive = isatty(sh->shell_terminal);
    
    if (sh->shell_is_interactive) {
        // Loop until in the foreground
        while (tcgetpgrp(sh->shell_terminal) != (sh->shell_pgid = getpgrp())) {
            kill(-sh->shell_pgid, SIGTTIN);
        }
        
        // Ignore interactive and job-control signals
        signal(SIGINT, SIG_IGN);
        signal(SIGQUIT, SIG_IGN);
        signal(SIGTSTP, SIG_IGN);
        signal(SIGTTIN, SIG_IGN);
        signal(SIGTTOU, SIG_IGN);
        
        // Put shell in its own process group
        sh->shell_pgid = getpid();
        if (setpgid(sh->shell_pgid, sh->shell_pgid) < 0) {
            perror("Couldn't put the shell in its own process group");
            exit(EXIT_FAILURE);
        }
        
        // Take control of the terminal
        tcsetpgrp(sh->shell_terminal, sh->shell_pgid);
        
        // Save default terminal attributes
        tcgetattr(sh->shell_terminal, &sh->shell_tmodes);
        
        // Initialize readline history
        using_history();
    }
}

// Destroy the shell and clean up resources
void sh_destroy(struct shell *sh) {
    if (sh->prompt) {
        free(sh->prompt);
        sh->prompt = NULL;
    }
    
    // Clear history
    clear_history();
}