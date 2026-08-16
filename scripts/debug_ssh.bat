@echo off
set GIT_SSH=C:\Windows\System32\OpenSSH\ssh.exe
git ls-remote git@github.com:maggie-co/tree-time.git > "%TEMP%\git_ssh_debug.txt" 2>&1
