; HoldToggles v1.32

#MaxThreadsPerHotkey 1           ; Prevent accidental double-presses.
#NoEnv                           ; Recommended for performance and compatibility with future AutoHotkey releases.
#Persistent                      ; Keep the script permanently running since we use a timer.
#Requires AutoHotkey v1.1.33.02+ ; Display an error and quit if this version requirement is not met.
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
	ExitWithErrorMessage("HoldToggles.ini not found! The script will now exit.")

; Read options from config file
IniRead, windowName, HoldToggles.ini, General, windowName
IniRead, isAimToggle, HoldToggles.ini, General, isAimToggle, 1
IniRead, isCrouchToggle, HoldToggles.ini, General, isCrouchToggle, 1
IniRead, isSprintToggle, HoldToggles.ini, General, isSprintToggle, 1
IniRead, hookDelay, HoldToggles.ini, General, hookDelay, 0
IniRead, restoreTogglesOnFocus, HoldToggles.ini, General, restoreTogglesOnFocus, 1
IniRead, aimKey, HoldToggles.ini, Keys, aimKey, RButton
IniRead, crouchKey, HoldToggles.ini, Keys, crouchKey, LCtrl
IniRead, sprintKey, HoldToggles.ini, Keys, sprintKey, LShift
IniRead, isDebug, HoldToggles.ini, Debug, isDebug, 0

if (isDebug)
{
	arrValues := [windowName, isAimToggle, isCrouchToggle, isSprintToggle, aimKey, crouchKey, sprintKey, hookDelay]
	MsgBox, % Format("windowName: {}`nisAimToggleEnabled: {}`nisCrouchToggleEnabled: {}`nisSprintToggleEnabled: {}`naimKey: {}`ncrouchKey: {}`nsprintKey: {}`nhookDelay: {}", arrValues*)
}

; Make the hotkeys active only for a specific window
WinWaitActive, %windowName%
Sleep, %hookDelay%
WinGet, windowID, ID, %windowName%
GroupAdd, windowIDGroup, ahk_id %windowID%
Hotkey, IfWinActive, ahk_group windowIDGroup

if (isAimToggle)
	Hotkey, %aimKey%, aimLabel
if (isCrouchToggle)
	Hotkey, %crouchKey%, crouchLabel
if (isSprintToggle)
	Hotkey, %sprintKey%, sprintLabel

SetTimer, SetTogglesOnFocus, 1000
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

; Disable toggles on focus lost and restore them on focus
SetTogglesOnFocus:
If WinActive(windowName)
{
	WinWaitNotActive, %windowName%

	; Save toggle states
	global isAiming
	global isCrouching 
	global isSprinting 
	tempIsAiming := isAiming
	tempIsCrouching := isCrouching
	tempIsSprinting := isSprinting

	DisableAllToggles()

	; Restore toggle states
	if (restoreTogglesOnFocus)
	{
		WinWaitActive, %windowName%
		Aim(tempIsAiming)
		Crouch(tempIsCrouching)
		Sprint(tempIsSprinting)
	}
}

return

; Toggle aim 
Aim(ByRef pIsAiming)
{
	global isAiming := pIsAiming
	global aimKey
	SendInput % isAiming ? "{" . aimKey . " down}" : "{" . aimKey . " up}"
	KeyWait, %aimKey%
}

; Toggle crouch 
Crouch(ByRef pIsCrouching)
{
	global isCrouching := pIsCrouching
	global crouchKey
	SendInput % isCrouching ? "{" . crouchKey . " down}" : "{" . crouchKey . " up}"
	KeyWait, %crouchKey%
}

; Toggle sprint
Sprint(ByRef pIsSprinting)
{
	global isSprinting := pIsSprinting
	global sprintKey
	SendInput % isSprinting ? "{" . sprintKey . " down}" : "{" . sprintKey . " up}"
	KeyWait, %sprintKey%
}

; Disable all toggles
DisableAllToggles()
{
	Aim(false)
	Crouch(false)
	Sprint(false)
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
return

; Display an error message and exit
ExitWithErrorMessage(ErrorMessage)
{
	MsgBox, 16, Error, %ErrorMessage%
	ExitApp, -1
}

; Exit script
ExitFunc(ExitReason, ExitCode)
{
	DisableAllToggles()
	ExitApp
}
