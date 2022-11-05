@echo off
SETLOCAL EnableDelayedExpansion
set "OBJFOLDER=build\obj"
set "SRCFOLDER=src"
set "OUTPUT_FOLDER=build\rom"
set "OUTPUT_FILE=testrom"
set OBJFILES=
set CFG_FILE=nes.cfg

echo Cleaning output dir: %OBJFOLDER%...
if exist %OBJFOLDER% rd %OBJFOLDER% /Q /S
mkdir %OBJFOLDER%
if exist %OUTPUT_FOLDER% rd %OUTPUT_FOLDER% /Q /S
mkdir %OUTPUT_FOLDER%
echo Building solution...
echo Source folder: %SRCFOLDER%
for /R %SRCFOLDER% %%F in (*.asm) do ca65 --verbose %%F -g -o %OBJFOLDER%\\%%~nF.o -l %OBJFOLDER%\\%%~nF.listing
for %%F in (%OBJFOLDER%\*.o) do set "OBJFILES=!OBJFILES! %%F"
echo Linking solution...
ld65 %OBJFILES% -C %CFG_FILE% -o %OUTPUT_FOLDER%\\%OUTPUT_FILE%.nes --dbgfile %OUTPUT_FOLDER%\\%OUTPUT_FILE%.dbg -m %OUTPUT_FOLDER%\\%OUTPUT_FILE%.map
echo Done building

