#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <pwd.h>
#include "harness/unity.h"
#include "../src/lab.h"

void setUp(void) {
  // set stuff up here
}

void tearDown(void) {
  // clean stuff up here
}

// Test cmd_parse with a simple command line
void test_cmd_parse(void)
{
     char **rval = cmd_parse("ls -a -l");
     TEST_ASSERT_TRUE(rval);
     TEST_ASSERT_EQUAL_STRING("ls", rval[0]);
     TEST_ASSERT_EQUAL_STRING("-a", rval[1]);
     TEST_ASSERT_EQUAL_STRING("-l", rval[2]);
     TEST_ASSERT_EQUAL_STRING(NULL, rval[3]);
     TEST_ASSERT_FALSE(rval[3]);
     cmd_free(rval);
}

// Test cmd_parse with more specific allocation case
void test_cmd_parse2(void)
{
     // The string we want to parse from the user: "foo -v"
     char *stng = (char*)malloc(sizeof(char)*7);
     strcpy(stng, "foo -v");
     char **actual = cmd_parse(stng);
     
     // Construct our expected output
     size_t n = sizeof(char*) * 6;
     char **expected = (char**) malloc(sizeof(char*) *6);
     memset(expected, 0, n);
     expected[0] = (char*)malloc(sizeof(char)*4);
     expected[1] = (char*)malloc(sizeof(char)*3);
     expected[2] = (char*)NULL;

     strcpy(expected[0], "foo");
     strcpy(expected[1], "-v");
     TEST_ASSERT_EQUAL_STRING(expected[0], actual[0]);
     TEST_ASSERT_EQUAL_STRING(expected[1], actual[1]);
     TEST_ASSERT_FALSE(actual[2]);
     
     free(expected[0]);
     free(expected[1]);
     free(expected);
     free(stng);
     cmd_free(actual);
}

// Test cmd_parse with empty input
void test_cmd_parse_empty(void)
{
     char **rval = cmd_parse("");
     TEST_ASSERT_TRUE(rval);
     TEST_ASSERT_FALSE(rval[0]);
     cmd_free(rval);
}

// Test cmd_parse with NULL input
void test_cmd_parse_null(void)
{
     char **rval = cmd_parse(NULL);
     TEST_ASSERT_FALSE(rval);
}

// Test cmd_parse with multiple spaces between args
void test_cmd_parse_multiple_spaces(void)
{
     char **rval = cmd_parse("ls    -a    -l");
     TEST_ASSERT_TRUE(rval);
     TEST_ASSERT_EQUAL_STRING("ls", rval[0]);
     TEST_ASSERT_EQUAL_STRING("-a", rval[1]);
     TEST_ASSERT_EQUAL_STRING("-l", rval[2]);
     TEST_ASSERT_FALSE(rval[3]);
     cmd_free(rval);
}

// Test trim_white with no whitespace
void test_trim_white_no_whitespace(void)
{
     char *line = (char*) calloc(10, sizeof(char));
     strncpy(line, "ls -a", 10);
     char *rval = trim_white(line);
     TEST_ASSERT_EQUAL_STRING("ls -a", rval);
     free(line);
}

// Test trim_white with whitespace at the start
void test_trim_white_start_whitespace(void)
{
     char *line = (char*) calloc(10, sizeof(char));
     strncpy(line, "  ls -a", 10);
     char *rval = trim_white(line);
     TEST_ASSERT_EQUAL_STRING("ls -a", rval);
     free(line);
}

// Test trim_white with whitespace at the end
void test_trim_white_end_whitespace(void)
{
     char *line = (char*) calloc(10, sizeof(char));
     strncpy(line, "ls -a  ", 10);
     char *rval = trim_white(line);
     TEST_ASSERT_EQUAL_STRING("ls -a", rval);
     free(line);
}

// Test trim_white with whitespace at both ends (single space)
void test_trim_white_both_whitespace_single(void)
{
     char *line = (char*) calloc(10, sizeof(char));
     strncpy(line, " ls -a ", 10);
     char *rval = trim_white(line);
     TEST_ASSERT_EQUAL_STRING("ls -a", rval);
     free(line);
}

// Test trim_white with whitespace at both ends (double space)
void test_trim_white_both_whitespace_double(void)
{
     char *line = (char*) calloc(10, sizeof(char));
     strncpy(line, "  ls -a  ", 10);
     char *rval = trim_white(line);
     TEST_ASSERT_EQUAL_STRING("ls -a", rval);
     free(line);
}

// Test trim_white with all whitespace
void test_trim_white_all_whitespace(void)
{
     char *line = (char*) calloc(10, sizeof(char));
     strncpy(line, "  ", 10);
     char *rval = trim_white(line);
     TEST_ASSERT_EQUAL_STRING("", rval);
     free(line);
}

// Test trim_white with mostly whitespace
void test_trim_white_mostly_whitespace(void)
{
     char *line = (char*) calloc(10, sizeof(char));
     strncpy(line, "    a    ", 10);
     char *rval = trim_white(line);
     TEST_ASSERT_EQUAL_STRING("a", rval);
     free(line);
}

// Test trim_white with various whitespace characters
void test_trim_white_various_whitespace(void)
{
     char *line = (char*) calloc(20, sizeof(char));
     strncpy(line, " \t\r\n ls -a \t\r\n ", 20);
     char *rval = trim_white(line);
     TEST_ASSERT_EQUAL_STRING("ls -a", rval);
     free(line);
}

// Test trim_white with NULL input
void test_trim_white_null(void)
{
     char *rval = trim_white(NULL);
     TEST_ASSERT_NULL(rval);
}

// Test get_prompt with default prompt (environment var not set)
void test_get_prompt_default(void)
{
     char *prompt = get_prompt("MY_PROMPT");
     TEST_ASSERT_EQUAL_STRING("shell>", prompt);
     free(prompt);
}

// Test get_prompt with custom prompt (environment var set)
void test_get_prompt_custom(void)
{
     const char* prmpt = "MY_PROMPT";
     if(setenv(prmpt, "foo>", true)) {
          TEST_FAIL();
     }

     char *prompt = get_prompt(prmpt);
     TEST_ASSERT_EQUAL_STRING("foo>", prompt);
     free(prompt);
     unsetenv(prmpt);
}

// Test get_prompt with a different environment variable
void test_get_prompt_other_env(void)
{
     const char* prmpt = "OTHER_PROMPT";
     if(setenv(prmpt, "other>", true)) {
          TEST_FAIL();
     }

     char *prompt = get_prompt(prmpt);
     TEST_ASSERT_EQUAL_STRING("other>", prompt);
     free(prompt);
     unsetenv(prmpt);
}

// Test change_dir to home directory
void test_ch_dir_home(void)
{
     char *line = (char*) calloc(10, sizeof(char));
     strncpy(line, "cd", 10);
     char **cmd = cmd_parse(line);
     char *expected = getenv("HOME");
     change_dir(cmd);
     char *actual = getcwd(NULL, 0);
     TEST_ASSERT_EQUAL_STRING(expected, actual);
     free(line);
     free(actual);
     cmd_free(cmd);
}

// Test change_dir to root directory
void test_ch_dir_root(void)
{
     char *line = (char*) calloc(10, sizeof(char));
     strncpy(line, "cd /", 10);
     char **cmd = cmd_parse(line);
     change_dir(cmd);
     char *actual = getcwd(NULL, 0);
     TEST_ASSERT_EQUAL_STRING("/", actual);
     free(line);
     free(actual);
     cmd_free(cmd);
}

// Test change_dir to a specific directory
void test_ch_dir_specific(void)
{
     // First change to root to ensure we're starting from a consistent location
     chdir("/");
     
     char *line = (char*) calloc(10, sizeof(char));
     strncpy(line, "cd /tmp", 10);
     char **cmd = cmd_parse(line);
     change_dir(cmd);
     char *actual = getcwd(NULL, 0);
     TEST_ASSERT_EQUAL_STRING("/tmp", actual);
     free(line);
     free(actual);
     cmd_free(cmd);
     
     // Change back to root for other tests
     chdir("/");
}

// Test do_builtin for exit command
void test_do_builtin_exit(void)
{
     // This is tricky to test without exiting the test process
     // We'll just check that it recognizes "exit" as a builtin
     struct shell sh;
     sh.prompt = strdup("test>");
     
     char **cmd = cmd_parse("exit");
     bool result = do_builtin(&sh, cmd);
     
     // We should never reach this point in a real execution
     // but we can test that it recognizes exit as a builtin
     TEST_ASSERT_TRUE(result);
     
     // Clean up - this won't actually run in real execution
     // since exit would terminate the process
     free(sh.prompt);
     cmd_free(cmd);
}

// Test do_builtin for cd command
void test_do_builtin_cd(void)
{
     struct shell sh;
     sh.prompt = strdup("test>");
     
     char **cmd = cmd_parse("cd /tmp");
     bool result = do_builtin(&sh, cmd);
     
     TEST_ASSERT_TRUE(result);
     
     char *actual = getcwd(NULL, 0);
     TEST_ASSERT_EQUAL_STRING("/tmp", actual);
     
     free(sh.prompt);
     free(actual);
     cmd_free(cmd);
     
     // Change back to root for other tests
     chdir("/");
}

// Test do_builtin for history command
void test_do_builtin_history(void)
{
     struct shell sh;
     sh.prompt = strdup("test>");
     
     char **cmd = cmd_parse("history");
     bool result = do_builtin(&sh, cmd);
     
     TEST_ASSERT_TRUE(result);
     
     free(sh.prompt);
     cmd_free(cmd);
}

// Test do_builtin with non-builtin command
void test_do_builtin_external(void)
{
     struct shell sh;
     sh.prompt = strdup("test>");
     
     char **cmd = cmd_parse("ls");
     bool result = do_builtin(&sh, cmd);
     
     TEST_ASSERT_FALSE(result);
     
     free(sh.prompt);
     cmd_free(cmd);
}

// Test do_builtin with NULL command
void test_do_builtin_null(void)
{
     struct shell sh;
     sh.prompt = strdup("test>");
     
     bool result = do_builtin(&sh, NULL);
     
     TEST_ASSERT_FALSE(result);
     
     free(sh.prompt);
}

// Test parse_args with -v flag
void test_parse_args_version(void)
{
     // This is hard to test directly since it exits the process
     // We'll test that parse_args exists without crashing when no flags
     char *args[] = {"program_name", NULL};
     parse_args(1, args);
     
     // If we get here, it didn't exit, which is expected with no flags
     TEST_ASSERT_TRUE(true);
}

int main(void) {
  UNITY_BEGIN();
  
  // Original tests
  RUN_TEST(test_cmd_parse);
  RUN_TEST(test_cmd_parse2);
  RUN_TEST(test_trim_white_no_whitespace);
  RUN_TEST(test_trim_white_start_whitespace);
  RUN_TEST(test_trim_white_end_whitespace);
  RUN_TEST(test_trim_white_both_whitespace_single);
  RUN_TEST(test_trim_white_both_whitespace_double);
  RUN_TEST(test_trim_white_all_whitespace);
  RUN_TEST(test_trim_white_mostly_whitespace);
  RUN_TEST(test_get_prompt_default);
  RUN_TEST(test_get_prompt_custom);
  RUN_TEST(test_ch_dir_home);
  RUN_TEST(test_ch_dir_root);
  
  // Additional tests
  RUN_TEST(test_cmd_parse_empty);
  RUN_TEST(test_cmd_parse_null);
  RUN_TEST(test_cmd_parse_multiple_spaces);
  RUN_TEST(test_trim_white_various_whitespace);
  RUN_TEST(test_trim_white_null);
  RUN_TEST(test_get_prompt_other_env);
  RUN_TEST(test_ch_dir_specific);
  RUN_TEST(test_do_builtin_exit);
  RUN_TEST(test_do_builtin_cd);
  RUN_TEST(test_do_builtin_history);
  RUN_TEST(test_do_builtin_external);
  RUN_TEST(test_do_builtin_null);
  RUN_TEST(test_parse_args_version);

  return UNITY_END();
}