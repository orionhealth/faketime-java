@echo off
REM Build JNI DLLs for Windows (x86 and x64) using MinGW (gcc).
REM Outputs go to target\native\win32_<arch>\

setlocal enabledelayedexpansion

if "%JAVA_HOME%"=="" (
  echo ERROR: JAVA_HOME must be set
  exit /b 1
)

set CC32=%CC32%
if "%CC32%"=="" set CC32=gcc
set CC64=%CC64%
if "%CC64%"=="" set CC64=x86_64-w64-mingw32-gcc

set INCLUDES=-I "%JAVA_HOME%\include" -I "%JAVA_HOME%\include\win32"

set OUT32=target\native\win32_x86_32
set OUT64=target\native\win32_x86_64

if not exist "%OUT32%" mkdir "%OUT32%"
if not exist "%OUT64%" mkdir "%OUT64%"

echo ==> Windows x86 (32-bit)
%CC32% -m32 -O2 -shared -static-libgcc -Wl,--add-stdcall-alias -o "%OUT32%\faketime.dll" -D_JNI_IMPLEMENTATION_ %INCLUDES% src\main\c\agent.c

echo ==> Windows x86_64
%CC64% -O2 -shared -static-libgcc -Wl,--add-stdcall-alias -o "%OUT64%\faketime.dll" -D_JNI_IMPLEMENTATION_ %INCLUDES% src\main\c\agent.c

echo done.
