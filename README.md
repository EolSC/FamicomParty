This is test environment for NES game development

It is a very simple project from Famicom party book which can be found here:
https://famicom.party/book/01-briefhistory/


Dev environment uses free instruments such as:
1. VSCode as the lightweight IDE(https://code.visualstudio.com/)
2. CA65 macroassembler as the compile\link tool(https://cc65.github.io/doc/ca65.html)
3. Mesen NES emulator as the testing/debugging tool(https://www.mesen.ca/download.php)

In order to get things working properly you should add 2 environment variables:
- Your CA65 working folder should be added to %PATH%
- MESEN_PATH variable which points to Mesen.exe location

To Build and run this example:
1. Open TestRom.code-workspace in VSCode.
2. Use CTRL+SHIFT+P shortcut to open command menu. 
3. Type "Run task" command in pop-up window.
4. Select "Build & Run ROM" task in the list.

It should create ROM file within build/rom/ directory and open it within Mesen emulator. Make sure you 've set up environment variables and commandline is selected as default shell.
