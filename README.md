## OndraSD File Manager
File manager used for loading programs into Ondra SPO 186 from SD card using Ondra-SD interface by Martin1 (more info: https://sites.google.com/site/ondraspo186/3-ondra-sd)

Based on Martin1's source codes, with some added functionalities:
- joystick support
- files and directories sorting  (using the "S" key)
- RAM test

---

To compile with *TASM* (version 3.2 tested):

`tasm -80 -b make.asm __ondrafm.bin`

To compile with *SjASMPlus* (version v1.21.0 tested):

`sjasmplus make.asm`
