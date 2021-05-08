; KeyToggles v1.32

;TODO
; add autofire support (https://autohotkey.com/board/topic/64576-the-definitive-autofire-thread/)
; add application profile support

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

; Constants
AIM_MODE_TOGGLE := 1
AIM_MODE_HOLD := 2
AIM_MODE_AUTOFIRE := 3

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

switch bAimMode
{
	case AIM_MODE_TOGGLE:
		AimToggle(!bAiming, true)
		return
	case AIM_MODE_HOLD:
		AimHold()
		return
	case AIM_MODE_AUTOFIRE:
		AimAutofire()
		return
	default:
}

;OutputDebug, aimLabel::%A_ThisHotkey% end

return

crouchLabel:

;OutputDebug, crouchLabel::%A_ThisHotkey% begin

switch bCrouchMode
{
	case AIM_MODE_TOGGLE:
		CrouchToggle(!bCrouching, true)
		return
	case AIM_MODE_HOLD:
		CrouchHold()
		return
	case AIM_MODE_AUTOFIRE:
		CrouchAutofire()
		return
	default:
}

;OutputDebug, crouchLabel::%A_ThisHotkey% end

return

sprintLabel:

;OutputDebug, sprintLabel::%A_ThisHotkey% begin

switch bSprintMode
{
	case AIM_MODE_TOGGLE:
		SprintToggle(!bSprinting, true)
		return
	case AIM_MODE_HOLD:
		SprintHold()
		return
	case AIM_MODE_AUTOFIRE:
		SprintAutofire()
		return
	default:
}

;OutputDebug, sprintLabel::%A_ThisHotkey% end

return

AimAutofire()
{
	global

	;OutputDebug, AimAutofire::begin
	;OutputDebug, AimAutofire::end
}

AimHold()
{
	global

	;OutputDebug, AimHold::begin
	;OutputDebug, AimHold::press

	SendInput % "{" . aimKey . " down}"
	Sleep, %holdKeyDelay%
	SendInput % "{" . aimKey . " up}"

	KeyWait, %aimKey%

	;OutputDebug, AimHold::release
	SendInput % "{" . aimKey . " down}"
	Sleep, %holdKeyDelay%
	SendInput % "{" . aimKey . " up}"

	;OutputDebug, AimHold::end
}

AimToggle(pAiming, pWait := false)
{
	global

	;OutputDebug, AimToggle::begin
	bAiming := pAiming
	;OutputDebug, AimToggle::bAiming %bAiming%

	SendInput % bAiming ? "{" . aimKey . " down}" : "{" . aimKey . " up}"

	if (pWait)
		KeyWait, %aimKey%

	;OutputDebug, AimToggle::end
}

CrouchAutofire()
{
	global

	;OutputDebug, CrouchAutofire::begin
	;OutputDebug, CrouchAutofire::end
}

CrouchHold()
{
	global

	;OutputDebug, CrouchHold::begin
	;OutputDebug, CrouchHold::press

	SendInput % "{" . crouchKey . " down}"
	Sleep, %holdKeyDelay%
	SendInput % "{" . crouchKey . " up}"

	KeyWait, %crouchKey%

	;OutputDebug, CrouchHold::release
	SendInput % "{" . crouchKey . " down}"
	Sleep, %holdKeyDelay%
	SendInput % "{" . crouchKey . " up}"

	;OutputDebug, CrouchHold::end
}

CrouchToggle(pCrouching, pWait := true)
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

ReleaseAllKeys()
{
	AimToggle(false)
	CrouchToggle(false)
	SprintToggle(false)
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
	if (restoreTogglesOnFocus && bAimMode == AIM_MODE_TOGGLE)
	{
		OutputDebug, OnFocusChanged::restoreToggleStates

		if (bRestoreAiming)
			AimToggle(true)
		if (bRestoreCrouching)
			CrouchToggle(true)
		if (bRestoreSprinting)
			SprintToggle(true)
	}

	OutputDebug, OnFocusChanged::WinWaitNotActive
	WinWaitNotActive, %windowName%

	; Save toggle states
	if (restoreTogglesOnFocus && bAimMode == AIM_MODE_TOGGLE && WinExist(windowName))
	{
		OutputDebug, OnFocusChanged::saveToggleStates

		bRestoreAiming := bAiming
		bRestoreCrouching := bCrouching
		bRestoreSprinting := bSprinting
	}

	ReleaseAllKeys()

	OutputDebug, OnFocusChanged::end
}

ReadConfigFile()
{
	; All the variables below are declared as global so they can be used in the whole script
	global

	; General
	IniRead, windowName, %configFileName%, General, windowName
	IniRead, bAimMode, %configFileName%, General, bAimMode, 1
	IniRead, bCrouchMode, %configFileName%, General, bCrouchMode, 1
	IniRead, bSprintMode, %configFileName%, General, bSprintMode, 1
	IniRead, holdKeyDelay, %configFileName%, General, holdKeyDelay, 0
	IniRead, hookDelay, %configFileName%, General, hookDelay, 0
	IniRead, focusCheckDelay, %configFileName%, General, focusCheckDelay, 1000
	IniRead, restoreTogglesOnFocus, %configFileName%, General, restoreTogglesOnFocus, 0

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

	Hotkey, %aimKey%, aimLabel, % bAimMode > 0 ? "On" : "Off"
	Hotkey, %crouchKey%, crouchLabel, % bCrouchMode > 0 ? "On" : "Off"
	Hotkey, %sprintKey%, sprintLabel, % bSprintMode > 0 ? "On" : "Off"
}

SprintAutofire()
{
	global

	;OutputDebug, SprintAutofire::begin
	;OutputDebug, SprintAutofire::end
}

SprintHold()
{
	global

	;OutputDebug, SprintHold::begin
	;OutputDebug, SprintHold::press

	SendInput % "{" . sprintKey . " down}"
	Sleep, %holdKeyDelay%
	SendInput % "{" . sprintKey . " up}"

	KeyWait, %sprintKey%

	;OutputDebug, SprintHold::release
	SendInput % "{" . sprintKey . " down}"
	Sleep, %holdKeyDelay%
	SendInput % "{" . sprintKey . " up}"

	;OutputDebug, SprintHold::end
}

SprintToggle(pSprinting, pWait := true)
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
	ReleaseAllKeys()
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

ReleaseAllKeys()
return
