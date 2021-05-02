; KeyToggles v1.32

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
tempIsAiming := false
tempIsCrouching := false
tempIsSprinting := false
windowID := 0

configFileName := RTrim(A_ScriptName, A_IsCompiled ? ".exe" : ".ahk") . ".ini"

; Config file is missing, exit
if (!FileExist(configFileName))
	ExitWithErrorMessage(configFileName . " not found! The script will now exit.")

ReadConfigFile()
SetTimer, OnFocusChanged, %focusCheckDelay%

return

aimLabel:
Aim(!isAiming)
return

crouchLabel:
Crouch(!isCrouching)
return

sprintLabel:
Sprint(!isSprinting)
return

; Toggle aim 
Aim(ByRef pIsAiming)
{
	global

	isAiming := pIsAiming
	SendInput % isAiming ? "{" . aimKey . " down}" : "{" . aimKey . " up}"
	KeyWait, %aimKey%
}

; Toggle crouch 
Crouch(ByRef pIsCrouching)
{
	global

	isCrouching := pIsCrouching
	SendInput % isCrouching ? "{" . crouchKey . " down}" : "{" . crouchKey . " up}"
	KeyWait, %crouchKey%
}

; Disable all toggles
DisableAllToggles()
{
	Aim(false)
	Crouch(false)
	Sprint(false)
}

HookWindow()
{
	; All the variables below are declared as global so they can be used in the whole script
	global

	; Make the hotkeys active only for a specific window
	WinWaitActive, %windowName%
	Sleep, %hookDelay%
	WinGet, windowID, ID, %windowName%
	GroupAdd, windowIDGroup, ahk_id %windowID%
	Hotkey, IfWinActive, ahk_group windowIDGroup
}

; Disable toggles on focus lost and optionally restore them on focus
OnFocusChanged()
{
	global

	; Make sure to hook the window again if it no longer exists
	if (!WinExist(windowName) || !windowID)
	{
		HookWindow()
		RegisterHotkeys()
	}
	else
	{
		WinWaitActive, %windowName%
	}
	
	; Restore toggle states
	if (restoreTogglesOnFocus)
	{
		Aim(tempIsAiming)
		Crouch(tempIsCrouching)
		Sprint(tempIsSprinting)
	}
	
	WinWaitNotActive, %windowName%

	; Save toggle states
	tempIsAiming := isAiming
	tempIsCrouching := isCrouching
	tempIsSprinting := isSprinting

	DisableAllToggles()
}

ReadConfigFile()
{
	; All the variables below are declared as global so they can be used in the whole script
	global

	; General
	IniRead, windowName, %configFileName%, General, windowName
	IniRead, bAimToggle, %configFileName%, General, bAimToggle, 1
	IniRead, bCrouchToggle, %configFileName%, General, bCrouchToggle, 1
	IniRead, bSprintToggle, %configFileName%, General, bSprintToggle, 1
	IniRead, hookDelay, %configFileName%, General, hookDelay, 0
	IniRead, focusCheckDelay, %configFileName%, General, focusCheckDelay, 1000
	IniRead, restoreTogglesOnFocus, %configFileName%, General, restoreTogglesOnFocus, 1

	; Keys
	IniRead, aimKey, %configFileName%, Keys, aimKey, RButton
	IniRead, crouchKey, %configFileName%, Keys, crouchKey, LCtrl
	IniRead, sprintKey, %configFileName%, Keys, sprintKey, LShift

	; Debug
	IniRead, bDebug, %configFileName%, Debug, bDebug, 0
}

RegisterHotkeys()
{
	; All the variables below are declared as global so they can be used in the whole script
	global

	Hotkey, %aimKey%, aimLabel, % bAimToggle ? "On" : "Off"
	Hotkey, %crouchKey%, crouchLabel, % bCrouchToggle ? "On" : "Off"
	Hotkey, %sprintKey%, sprintLabel, % bSprintToggle ? "On" : "Off"
}

; Toggle sprint
Sprint(ByRef pIsSprinting)
{
	global

	isSprinting := pIsSprinting
	SendInput % isSprinting ? "{" . sprintKey . " down}" : "{" . sprintKey . " up}"
	KeyWait, %sprintKey%
}

; Exit script
ExitFunc(ExitReason, ExitCode)
{
	DisableAllToggles()
	ExitApp
}

; Display an error message and exit
ExitWithErrorMessage(ErrorMessage)
{
	MsgBox, 16, Error, %ErrorMessage%
	ExitApp, -1
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
