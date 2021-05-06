; KeyToggles v1.32

;TODO
; add autofire support
; add key hold support

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

; Initialize state variables
bAiming := false
bCrouching := false
bSprinting := false
bRestoreAiming := false
bRestoreCrouching := false
bRestoreSprinting := false
windowID := 0

configFileName := RTrim(A_ScriptName, A_IsCompiled ? ".exe" : ".ahk") . ".ini"
OutputDebug, init::configFileName %configFileName%

; Config file is missing, exit
if (!FileExist(configFileName))
	ExitWithErrorMessage(configFileName . " not found! The script will now exit.")

ReadConfigFile()
SetTimer, OnFocusChanged, %focusCheckDelay%

return

aimLabel:

;OutputDebug, aimLabel::%A_ThisHotkey% begin
Aim(!bAiming, true)
;OutputDebug, aimLabel::%A_ThisHotkey% end

return

crouchLabel:

;OutputDebug, crouchLabel::%A_ThisHotkey% begin
Crouch(!bCrouching, true)
;OutputDebug, crouchLabel::%A_ThisHotkey% end

return

sprintLabel:

;OutputDebug, sprintLabel::%A_ThisHotkey% begin
Sprint(!bSprinting, true)
;OutputDebug, sprintLabel::%A_ThisHotkey% end

return

; Toggle aim 
Aim(pAiming, pWait := false)
{
	global

	;OutputDebug, Aim::begin
	bAiming := pAiming
	;OutputDebug, Aim::bAiming %bAiming%
	SendInput % bAiming ? "{" . aimKey . " down}" : "{" . aimKey . " up}"

	if (pWait)
		KeyWait, %aimKey%

	;OutputDebug, Aim::end
}

; Toggle crouch 
Crouch(pCrouching, pWait := true)
{
	global

	;OutputDebug, Crouch::begin
	bCrouching := pCrouching
	;OutputDebug, Crouch::bCrouching %bCrouching%
	SendInput % bCrouching ? "{" . crouchKey . " down}" : "{" . crouchKey . " up}"

	if (pWait)
		KeyWait, %crouchKey%

	;OutputDebug, Crouch::end
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
	OutputDebug, HookWindow::begin
	WinGet, windowID, ID, %windowName%
	OutputDebug, HookWindow::WinGet %windowID%
	GroupAdd, windowIDGroup, ahk_id %windowID%
	Hotkey, IfWinActive, ahk_group windowIDGroup
	OutputDebug, HookWindow::end
}

; Disable toggles on focus lost and optionally restore them on focus
OnFocusChanged()
{
	global

	OutputDebug, OnFocusChanged::begin

	OutputDebug, OnFocusChanged::WinWaitActive
	WinWaitActive, %windowName%
	Sleep, %hookDelay%

	; Make sure to hook the window again if it no longer exists
	if (windowID != WinExist(windowName))
	{
		HookWindow()
		RegisterHotkeys()

		; That's a different window, don't restore toggle states
		bRestoreAiming := false
		bRestoreCrouching := false
		bRestoreSprinting := false
	}

	; Restore toggle states
	if (restoreTogglesOnFocus)
	{
		OutputDebug, OnFocusChanged::restoreToggleStates

		if (bRestoreAiming)
			Aim(true)
		if (bRestoreCrouching)
			Crouch(true)
		if (bRestoreSprinting)
			Sprint(true)
	}

	OutputDebug, OnFocusChanged::WinWaitNotActive
	WinWaitNotActive, %windowName%

	; Save toggle states
	if (restoreTogglesOnFocus && WinExist(windowName))
	{
		OutputDebug, OnFocusChanged::saveToggleStates

		bRestoreAiming := bAimToggle ? bAiming : false
		bRestoreCrouching := bCrouchToggle ? bCrouching : false
		bRestoreSprinting := bSprintToggle ? bSprinting : false
	}

	DisableAllToggles()

	OutputDebug, OnFocusChanged::end
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
Sprint(pSprinting, pWait := true)
{
	global

	;OutputDebug, Sprint::begin
	bSprinting := pSprinting
	;OutputDebug, Sprint::bSprinting %bSprinting%
	SendInput % bSprinting ? "{" . sprintKey . " down}" : "{" . sprintKey . " up}"

	if (pWait)
		KeyWait, %sprintKey%

	;OutputDebug, Sprint::end
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
