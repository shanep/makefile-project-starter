# Makefile Project Template

Steps to configure, build, run, and test the project.

## Building

```bash
make
```

## Testing

```bash
make check
```

## Clean

```bash
make clean
```
## Debugging

This is a very simple Makefile that will place the debug and release builds in the same directory. 
Therefore, make sure to run `make clean` if you are building a debug build, and then once you are
finished debugging, run `make clean` again before building a release build. On larger projects, the 
build system typically puts every architecture (x86, ARM, etc.) in separate directories and also 
separates out the debug and release builds.


```bash
make clean
make debug
```
