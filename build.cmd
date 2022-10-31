@echo off
SETLOCAL EnableDelayedExpansion
set "OBJFOLDER=build\\obj"
set "SRCFOLDER=.\\src"
set OBJFILES=
set CFG_FILE=nes.cfg

echo Cleaning output dir: %OBJFOLDER%...
if exist %OBJFOLDER% rd %OBJFOLDER% /Q /S
mkdir %OBJFOLDER%
if exist %OUTPUT_FOLDER% rd %OUTPUT_FOLDER% /Q /S
mkdir %OUTPUT_FOLDER%
echo Building solution...
echo %SRCFOLDER%
for %%F in (%SRCFOLDER%\*.asm) do ca65 --verbose %%F -o %OBJFOLDER%\\%%~nF.o
for %%F in (%OBJFOLDER%\*.o) do set "OBJFILES=!OBJFILES! %%F"
echo Linking solution...
ld65 %OBJFILES% -C %CFG_FILE% -o %OUTPUT_FOLDER%\\%OUTPUT_FILE%
echo Done building

