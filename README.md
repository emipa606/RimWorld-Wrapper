# RimWorld-Wrapper
Never start RimWorld twice

I you are anything like me you have no self-control regarding mods.
The problem with constantly adding mods to RimWorld is that you have to start the game to activate new mods.
This doubles the time to start the game and with a couple of hundred mods active the start time is already on the long side.

I created this wrapper for myself that scans the mod-directories (Steam and locally) and checks if any of them has been created after the last save done.
It asks if these should be added and then adds them to the bottom of the list, then starting RimWorld with the new mods already active.

If anyone finds this as annoying as me you are free to use this wrapper for yourself.
Just download the latest release and modify the config.ini-file to match your setup.
The wrapper should work fine with the non-steam version of the game as well, although I havent tested myself.

The exe-file is compiled using AutoIt (https://www.autoitscript.com/site/autoit/) and the code-file is available here for anyone to use/modify.
