This is test environment for NES game development

It is a very simple project form Famicom party book which can be found here:
https://famicom.party/book/01-briefhistory/


Dev environment uses free instruments such as:
1. VSCode as lightweight IDE(https://code.visualstudio.com/)
2. CA65 macroassembler as compile\link tool(https://cc65.github.io/doc/ca65.html)
3. Mesen nes emulator as testing/debugging tool(https://www.mesen.ca/download.php)

In order to get things working properly you should add 2 environment variables:
- Your CA65 working folder should be added to %PATH%
- You should add MESEN_PATH variable which points to Mesen.exe location