#include <Date.au3>
#include <File.au3>
#include <Array.au3>
#include <WinAPISys.au3>
#pragma compile(Icon, .\RimWorld.ico)
#pragma compile(ProductName, RimWorld Wrapper)
#pragma compile(ProductVersion, 1.1)
#pragma compile(FileVersion, 1.1.0.0)
#pragma compile(FileDescription, RimWorld Wrapper - never start RimWorld twice)

if ProcessExists("RimWorldWin64.exe") Then
   MsgBox(0, "RimWorld already running", "RimWorld is already rumming")
   Exit
EndIf

$iniFile = @ScriptDir & '\config.insi'
if Not FileExists($iniFile) Then
   $iniFile = @AppDataDir & '\rimworldlauncher.ini'
EndIf

if Not FileExists($iniFile) Then
   IniWriteSection($iniFile, "Paths", 'SaveDirectory="' & @UserProfileDir & '\appdata\locallow\Ludeon Studios\RimWorld by Ludeon Studios\Saves"')
   IniWrite($iniFile, "Paths", "ModConfigFile", '"' & @UserProfileDir & '\appdata\locallow\Ludeon Studios\RimWorld by Ludeon Studios\Config\ModsConfig.xml"')
   IniWrite($iniFile, "Paths", "SteamModDirectory", '"%programfiles%\Steam\steamapps\workshop\content\294100"')
   IniWrite($iniFile, "Paths", "LocalModDirectory", '"%programfiles%\Rimworld\Mods"')
   IniWrite($iniFile, "Paths", "RimworldStartCommand", '"%programfiles%\Steam\Steam.exe" -applaunch 294100')
EndIf

; Verify INI-file values
$SaveDirectory = _WinAPI_ExpandEnvironmentStrings (IniRead($iniFile, "Paths", "SaveDirectory", "Error"))
if $SaveDirectory = "Error" Then
   MsgBox(0, "No SaveDirectory found", "Config.ini does not contain a SaveDirectory")
   Run('notepad.exe "' & $iniFile & '"')
   Exit
EndIf
if Not FileExists($SaveDirectory) Then
   MsgBox(0, "No SaveDirectory exists", "SaveDirectory: " & $SaveDirectory & " can not be found.")
   Run('notepad.exe "' & $iniFile & '"')
   Exit
EndIf

$ModConfigFile = _WinAPI_ExpandEnvironmentStrings (IniRead($iniFile, "Paths", "ModConfigFile", "Error"))
if $ModConfigFile = "Error" Then
   MsgBox(0, "No ModConfigFile found", "Config.ini does not contain a ModConfigFile")
   Run('notepad.exe "' & $iniFile & '"')
   Exit
EndIf
if Not FileExists($ModConfigFile) Then
   MsgBox(0, "No ModConfigFile exists", "ModConfigFile: " & $ModConfigFile & " can not be found.")
   Run('notepad.exe "' & $iniFile & '"')
   Exit
EndIf

$LocalModDirectory = _WinAPI_ExpandEnvironmentStrings (IniRead($iniFile, "Paths", "LocalModDirectory", "Error"))
if $LocalModDirectory = "Error" Then
   MsgBox(0, "No LocalModDirectory found", "Config.ini does not contain a LocalModDirectory")
   Run('notepad.exe "' & $iniFile & '"')
   Exit
EndIf
if Not FileExists($LocalModDirectory) Then
   MsgBox(0, "No LocalModDirectory exists", "LocalModDirectory: " & $LocalModDirectory & " can not be found.")
   Run('notepad.exe "' & $iniFile & '"')
   Exit
Else
   $localmods = _FileListToArray($LocalModDirectory, "*", 2, True)
EndIf

$SteamModDirectory = _WinAPI_ExpandEnvironmentStrings (IniRead($iniFile, "Paths", "SteamModDirectory", "Error"))
if $SteamModDirectory = "Error" Then
   ConsoleWrite("Config.ini does not contain a SteamModDirectory, assuming non-steam version")
Else
   if Not FileExists($SteamModDirectory) Then
	  MsgBox(0, "No SteamModDirectory exists", "SteamModDirectory: " & $SteamModDirectory & " can not be found.")
	  Run('notepad.exe "' & $iniFile & '"')
	  Exit
   Else
	  $steammods = _FileListToArray($SteamModDirectory, "*", 2, True)
   EndIf
EndIf

$RimworldStartCommand = _WinAPI_ExpandEnvironmentStrings (IniRead($iniFile, "Paths", "RimworldStartCommand", "Error"))
if $RimworldStartCommand = "Error" Then
   MsgBox(0, "No RimworldStartCommand found", "Config.ini does not contain a RimworldStartCommand")
   Run('notepad.exe "' & $iniFile & '"')
   Exit
EndIf
if StringInStr($RimworldStartCommand, "Steam.exe") > 0 Then
   $SteamPath = StringReplace(StringReplace($RimworldStartCommand, " -applaunch 294100", ""), '"', '')
   if Not FileExists($SteamPath) Then
	  MsgBox(0, "No RimworldStartCommand exists", "The steam-part in RimworldStartCommand: " & $SteamPath & " can not be found.")
	  Run('notepad.exe "' & $iniFile & '"')
	  Exit
   EndIf
Else
   if Not FileExists($RimworldStartCommand) Then
	  MsgBox(0, "No RimworldStartCommand exists", "RimworldStartCommand: " & $RimworldStartCommand & " can not be found.")
	  Run('notepad.exe "' & $iniFile & '"')
	  Exit
   EndIf
EndIf

ConsoleWrite("ModConfigFile: " & $ModConfigFile & @CRLF)
ConsoleWrite("SaveDirectory: " & $SaveDirectory & @CRLF)
ConsoleWrite("LocalModDirectory: " & $LocalModDirectory & @CRLF)
ConsoleWrite("SteamModDirectory: " & $SteamModDirectory & @CRLF)
ConsoleWrite("RimworldStartCommand: " & $RimworldStartCommand & @CRLF)
$lastSave = FileGetTime( $SaveDirectory , 0, 1)

Dim $latestMods[1] = [0]
Local $i = 1
For $x = 2 to $localmods[0]
    if FileGetTime($localmods[$x],1,1) > $lastSave Then
	  ReDim $latestMods[$latestMods[0] + 2]
	  $latestMods[$i] = $localmods[$x]
	  $latestMods[0] = $i
	  $i = $i + 1
    EndIf
Next

$i = 1
For $x = 2 to $steammods[0]
    if FileGetTime($steammods[$x],1,1) > $lastSave Then
	  ReDim $latestMods[$latestMods[0] + 2]
	  $latestMods[$i] = $steammods[$x]
	  $latestMods[0] = $i
	  $i = $i + 1
    EndIf
Next

if $latestMods[0] > 0 Then
   For $i = 1 to $latestMods[0]
	  Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	  Local $aPathSplit = _PathSplit($latestMods[$i], $sDrive, $sDir, $sFileName, $sExtension)
	  if StringInStr(FileRead($ModConfigFile), "<li>" & $sFileName & "</li>") Then
		 ContinueLoop
	  EndIf
	  $content = FileRead($latestMods[$i] & "/About/About.xml")
	  $content = StringReplace($content, "<name>", "|")
	  $content = StringReplace($content, "</name>", "|")
	  $content = StringSplit($content, "|")[2]
	  $answer = MsgBox(4, "New mod found", $content & @LF & @LF & "Should it be added?")
	  if $answer = 6 Then
		 _ReplaceStringInFile ( $ModConfigFile, "  </activeMods>", "    <li>" & $sFileName & "</li>" & @CRLF & "  </activeMods>")
	  EndIf
   Next
EndIf

$answer = MsgBox(4, "Run Rimworld", "Start RimWorld?")
if $answer = 6 Then
   Run($RimworldStartCommand)
EndIf