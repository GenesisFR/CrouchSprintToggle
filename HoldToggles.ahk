; HoldToggles v1.3

#MaxThreadsPerHotkey 1           ; Prevent accidental double-presses
#NoEnv                           ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Requires AutoHotkey 1.1.30.03+ ; AHK Studio doesn't support this yet
#SingleInstance force            ; Allow only a single instance of the script to run.
#UseHook                         ; Allow listening for non-modifier keys.
#Warn                            ; Enable warnings to assist with detecting common errors.
SendMode Input                   ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%      ; Ensures a consistent starting directory.

; Register a function to be called on exit
OnExit("ExitFunc")

; State variables
isAiming := false
isCrouching := false
isSprinting := false

; Config file is missing, exit
if (!FileExist("HoldToggles.ini"))
{
	MsgBox, 16, Error, HoldToggles.ini not found! The script will now exit.
	ExitApp, -1
}

; Read options from config file
IniRead, windowName, HoldToggles.ini, General, windowName
IniRead, isAimToggle, HoldToggles.ini, General, isAimToggle, 1
IniRead, isCrouchToggle, HoldToggles.ini, General, isCrouchToggle, 1
IniRead, isSprintToggle, HoldToggles.ini, General, isSprintToggle, 1
IniRead, aimKey, HoldToggles.ini, General, aimKey, RButton
IniRead, crouchKey, HoldToggles.ini, General, crouchKey, LCtrl
IniRead, sprintKey, HoldToggles.ini, General, sprintKey, LShift
IniRead, isDebug, HoldToggles.ini, General, isDebug

if (isDebug)
{
	arrValues := [windowName, isAimToggle, isCrouchToggle, isSprintToggle, aimKey, crouchKey, sprintKey]
	MsgBox, % Format("windowName: {}`nisAimToggleEnabled: {}`nisCrouchToggleEnabled: {}`nisSprintToggleEnabled: {}`naimKey: {}`ncrouchKey: {}`nsprintKey: {}", arrValues*)
}

; Make the hotkeys active only for a specific application
WinWaitActive, %windowName%
WinGet, windowID, ID, %windowName%
GroupAdd, windowIDGroup, ahk_id %windowID%
Hotkey, IfWinActive, ahk_group windowIDGroup

if (isAimToggle)
	Hotkey, %aimKey%, aimLabel
if (isCrouchToggle)
	Hotkey, %crouchKey%, crouchLabel
if (isSprintToggle)
	Hotkey, %sprintKey%, sprintLabel

return

aimLabel:
if (isDebug)
	MsgBox % "Aim " . (!isAiming ? "pressed" : "released")

Aim(!isAiming)
return

crouchLabel:
if (isDebug)
	MsgBox % "Crouch " . (!isCrouching ? "pressed" : "released")

Crouch(!isCrouching)
return

sprintLabel:
if (isDebug)
	MsgBox % "Sprint " . (!isSprinting ? "pressed" : "released")

Sprint(!isSprinting)
return

; Toggle aim 
Aim(ByRef pIsAiming)
{
	global isAiming := pIsAiming
	global aimKey
	SendInput % isAiming ? "{" . aimKey . " down}" : "{" . aimKey . " up}"
}

; Toggle crouch 
Crouch(ByRef pIsCrouching)
{
	global isCrouching := pIsCrouching
	global crouchKey
	SendInput % isCrouching ? "{" . crouchKey . " down}" : "{" . crouchKey . " up}"
}

; Toggle sprint
Sprint(ByRef pIsSprinting)
{
	global isSprinting := pIsSprinting
	global sprintKey
	SendInput % isSprinting ? "{" . sprintKey . " down}" : "{" . sprintKey . " up}"
}

; Disable all toggles
DisableAllToggles()
{
	Aim(false)
	Crouch(false)
	Sprint(false)
}

; Exit script
ExitFunc(ExitReason, ExitCode)
{
	DisableAllToggles()
	ExitApp
}

; Suspend script (useful when in menus)
!F12:: ; ALT+F12
Suspend

; Single beep when suspended
if (A_IsSuspended)
	SoundBeep, 1000
; Double beep when resumed
else
{
	SoundBeep, 1000
	SoundBeep, 1000
}

DisableAllToggles()
