@echo off
setlocal
rem scamsung no Windows: encontra o bash do Git for Windows e executa o CLI.
rem Uso: scamsung.cmd doctor
rem       scamsung.cmd -n apply light
set "HERE=%~dp0"
set "HERE=%HERE:\=/%"
set "BASH="

for %%B in (bash.exe) do if not "%%~$PATH:B"=="" set "BASH=%%~$PATH:B"
if not defined BASH if exist "%ProgramFiles%\Git\bin\bash.exe" set "BASH=%ProgramFiles%\Git\bin\bash.exe"
if not defined BASH if exist "%ProgramFiles(x86)%\Git\bin\bash.exe" set "BASH=%ProgramFiles(x86)%\Git\bin\bash.exe"
if not defined BASH if exist "%LOCALAPPDATA%\Programs\Git\bin\bash.exe" set "BASH=%LOCALAPPDATA%\Programs\Git\bin\bash.exe"

if not defined BASH goto :nobash

"%BASH%" "%HERE%scamsung" %*
exit /b %ERRORLEVEL%

:nobash
echo.
echo scamsung precisa do bash do Git for Windows para rodar no Windows.
echo.
echo   winget install --id Git.Git -e
echo   winget install --id Google.PlatformTools -e
echo.
echo Depois abra um terminal novo e rode:
echo   scamsung.cmd doctor
echo.
echo Alternativa: use WSL (wsl --install) e rode ./scamsung de dentro dele.
exit /b 1
