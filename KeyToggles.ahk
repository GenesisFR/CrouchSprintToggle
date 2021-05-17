; KeyToggles v1.4

; TODO
; add application profiles (https://stackoverflow.com/questions/45190170/how-can-i-make-this-ini-file-into-a-listview-in-autohotkey)
; add overlay

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
KEY_MODE_TOGGLE := 1
KEY_MODE_HOLD := 2
KEY_MODE_AUTOFIRE := 3

; Initialize state variables
bAiming := false
bCrouching := false
bSprinting := false
bAutofireAiming := false
bAutofireCrouching := false
bAutofireSprinting := false
bRestoreAiming := false
bRestoreCrouching := false
bRestoreSprinting := false
bRestoreHandled := false
windowID := 0

; A handy label to allow quickly jumping back to top in AHK Studio
init:

configFileNameTrimmed := RTrim(A_ScriptName, A_IsCompiled ? ".exe" : ".ahk")
configFileName := configFileNameTrimmed . ".ini"
OutputDebug, init::configFileName %configFileName%

; Config file is missing, exit
if (!FileExist(configFileName))
	ExitWithErrorMessage(configFileName . " not found! The script will now exit.")

ReadConfigFile()

; Restart the script as admin
if (bRunAsAdmin && !A_IsAdmin)
{
	try
	{
		if A_IsCompiled
			Run *RunAs "%A_ScriptFullPath%" /restart
		else
			Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"

		ExitApp
	}
}

SetTimer, OnFocusChanged, %nFocusCheckDelay%

return

aimLabel:

;OutputDebug, %A_ThisLabel%::%A_ThisHotkey% begin

switch bAimMode
{
	case KEY_MODE_TOGGLE:
		isMouseButton := IsMouseButton(A_ThisHotkey)
		;OutputDebug, %A_ThisLabel%::%A_ThisHotkey% isMouseButton(%isMouseButton%)

		; Send a regular click if the hotkey is a mouse button clicked outside the window
		if (isMouseButton && !IsMouseOverWindow(windowID))
		{
			;OutputDebug, %A_ThisLabel%::%A_ThisHotkey% outside window
			SendClick(A_ThisHotkey)
		}
		; Otherwise toggle the key
		else
			AimToggle(!bAiming, true)

		return
	case KEY_MODE_HOLD:
		AimHold()
		return
	case KEY_MODE_AUTOFIRE:
		; Based on https://autohotkey.com/board/topic/64576-the-definitive-autofire-thread/?p=407264
		bAutofireAiming := !bAutofireAiming
		SetTimer, AimAutofire, % bAutofireAiming ? nAutofireKeyDelay : "Off"
		KeyWait, %aimAutofireKey%
		return
}

;OutputDebug, %A_ThisLabel%::%A_ThisHotkey% end

return

crouchLabel:

;OutputDebug, %A_ThisLabel%::%A_ThisHotkey% begin

switch bCrouchMode
{
	case KEY_MODE_TOGGLE:
		isMouseButton := IsMouseButton(A_ThisHotkey)
		OutputDebug, %A_ThisLabel%::%A_ThisHotkey% isMouseButton(%isMouseButton%)

		if (isMouseButton && !IsMouseOverWindow(windowID))
		{
			OutputDebug, %A_ThisLabel%::%A_ThisHotkey% outside window
			SendClick(A_ThisHotkey)
		}
		else
			CrouchToggle(!bCrouching, true)

		return
	case KEY_MODE_HOLD:
		CrouchHold()
		return
	case KEY_MODE_AUTOFIRE:
		bAutofireCrouching := !bAutofireCrouching
		SetTimer, CrouchAutofire, % bAutofireCrouching ? nAutofireKeyDelay : "Off"
		KeyWait, %crouchAutofireKey%
		return
}

;OutputDebug, %A_ThisLabel%::%A_ThisHotkey% end

return

sprintLabel:

;OutputDebug, %A_ThisLabel%::%A_ThisHotkey% begin

switch bSprintMode
{
	case KEY_MODE_TOGGLE:
		isMouseButton := IsMouseButton(A_ThisHotkey)
		OutputDebug, %A_ThisLabel%::%A_ThisHotkey% isMouseButton(%isMouseButton%)

		if (isMouseButton && !IsMouseOverWindow(windowID))
		{
			OutputDebug, %A_ThisLabel%::%A_ThisHotkey% outside window
			SendClick(A_ThisHotkey)
		}
		else
			SprintToggle(!bSprinting, true)

		return
	case KEY_MODE_HOLD:
		SprintHold()
		return
	case KEY_MODE_AUTOFIRE:
		bAutofireSprinting := !bAutofireSprinting
		SetTimer, SprintAutofire, % bAutofireSprinting ? nAutofireKeyDelay : "Off"
		KeyWait, %sprintAutofireKey%
		return
}

;OutputDebug, %A_ThisLabel%::%A_ThisHotkey% end

return

AimAutofire()
{
	global

	;OutputDebug, %A_ThisFunc%::begin

	SendInput % "{" . aimKey . " down}"
	Sleep, %nKeyDelay%
	SendInput % "{" . aimKey . " up}"

	;OutputDebug, %A_ThisFunc%::end
}

AimHold()
{
	global

	;OutputDebug, %A_ThisFunc%::begin

	SendInput % "{" . aimKey . " down}"
	Sleep, %nKeyDelay%
	SendInput % "{" . aimKey . " up}"

	KeyWait, %aimKey%

	SendInput % "{" . aimKey . " down}"
	Sleep, %nKeyDelay%
	SendInput % "{" . aimKey . " up}"

	;OutputDebug, %A_ThisFunc%::end
}

AimToggle(pAiming, pWait := false)
{
	global

	;OutputDebug, %A_ThisFunc%::begin
	bAiming := pAiming
	;OutputDebug, %A_ThisFunc%::bAiming %bAiming%

	SendInput % bAiming ? "{" . aimKey . " down}" : "{" . aimKey . " up}"

	if (pWait)
		KeyWait, %aimKey%

	;OutputDebug, %A_ThisFunc%::end
}

CrouchAutofire()
{
	global

	;OutputDebug, %A_ThisFunc%::begin

	SendInput % "{" . crouchKey . " down}"
	Sleep, %nKeyDelay%
	SendInput % "{" . crouchKey . " up}"

	;OutputDebug, %A_ThisFunc%::end
}

CrouchHold()
{
	global

	;OutputDebug, %A_ThisFunc%::begin

	SendInput % "{" . crouchKey . " down}"
	Sleep, %nKeyDelay%
	SendInput % "{" . crouchKey . " up}"

	KeyWait, %crouchKey%

	SendInput % "{" . crouchKey . " down}"
	Sleep, %nKeyDelay%
	SendInput % "{" . crouchKey . " up}"

	;OutputDebug, %A_ThisFunc%::end
}

CrouchToggle(pCrouching, pWait := false)
{
	global

	;OutputDebug, %A_ThisFunc%::begin
	bCrouching := pCrouching
	;OutputDebug, %A_ThisFunc%::bCrouching %bCrouching%

	SendInput % bCrouching ? "{" . crouchKey . " down}" : "{" . crouchKey . " up}"

	if (pWait)
		KeyWait, %crouchKey%

	;OutputDebug, %A_ThisFunc%::end
}

HookWindow()
{
	; All the variables below are declared as global so they can be used in the whole script
	global

	; Make the hotkeys active only for a specific window
	OutputDebug, %A_ThisFunc%::begin
	WinGet, windowID, ID, %sWindowName%
	OutputDebug, %A_ThisFunc%::WinGet %windowID%
	GroupAdd, windowIDGroup, ahk_id %windowID%
	Hotkey, IfWinActive, ahk_group windowIDGroup
	OutputDebug, %A_ThisFunc%::end

	if (windowID && bShowNotifications)
		TrayTip, %configFileNameTrimmed%, % "The window """ . sWindowName . """ has been hooked."
}

IsMouseButton(pKey)
{
	return InStr(pKey, "LButton") || InStr(pKey, "MButton") || InStr(pKey, "RButton") || InStr(pKey, "XButton1") || InStr(pKey, "XButton2")
}

IsMouseOverWindow(hwnd)
{
	global
	MouseGetPos, , , mouseWindowID
	return hwnd == mouseWindowID
}

; Disable toggles on focus lost and optionally restore them on focus
OnFocusChanged()
{
	global

	OutputDebug, %A_ThisFunc%::begin

	OutputDebug, %A_ThisFunc%::WinWaitActive
	WinWaitActive, %sWindowName%
	Sleep, %nHookDelay%

	; Make sure to hook the window again if it no longer exists
	if (windowID != WinExist(sWindowName))
	{
		HookWindow()
		RegisterHotkeys()

		; That's a different window, don't restore toggle states
		bRestoreAiming := false
		bRestoreCrouching := false
		bRestoreSprinting := false
	}

	; Restore toggle states
	if (ShouldRestoreTogglesOnFocus())
	{
		OutputDebug, %A_ThisFunc%::restoreToggleStates (%bRestoreAiming%, %bRestoreCrouching%, %bRestoreSprinting%)

		if (bRestoreAiming)
			AimToggle(true)
		if (bRestoreCrouching)
			CrouchToggle(true)
		if (bRestoreSprinting)
			SprintToggle(true)
	}

	OutputDebug, %A_ThisFunc%::WinWaitNotActive
	WinWaitNotActive, %sWindowName%

	; Save toggle states
	if (ShouldRestoreTogglesOnFocus())
	{
		OutputDebug, %A_ThisFunc%::saveToggleStates

		; A snapshot of the toggle states was already taken elsewhere, don't take another one
		if (bRestoreHandled)
			bRestoreHandled := false
		else
		{
			bRestoreAiming := bAiming
			bRestoreCrouching := bCrouching
			bRestoreSprinting := bSprinting
		}
	}

	ReleaseAllKeys()

	OutputDebug, %A_ThisFunc%::end
}

ReadConfigFile()
{
	; All the variables below are declared as global so they can be used in the whole script
	global

	; General
	IniRead, sWindowName, %configFileName%, General, windowName, "put_window_name_here"
	IniRead, bAimMode, %configFileName%, General, aimMode, 1
	IniRead, bCrouchMode, %configFileName%, General, crouchMode, 1
	IniRead, bSprintMode, %configFileName%, General, sprintMode, 1
	IniRead, nAutofireKeyDelay, %configFileName%, General, autofireKeyDelay, 100
	IniRead, nFocusCheckDelay, %configFileName%, General, focusCheckDelay, 1000
	IniRead, nHookDelay, %configFileName%, General, hookDelay, 0
	IniRead, nKeyDelay, %configFileName%, General, keyDelay, 0
	IniRead, bRestoreTogglesOnFocus, %configFileName%, General, restoreTogglesOnFocus, 0
	IniRead, bShowNotifications, %configFileName%, General, showNotifications, 0
	IniRead, bRunAsAdmin, %configFileName%, General, runAsAdmin, 0

	; Keys
	IniRead, aimKey, %configFileName%, Keys, aimKey, RButton
	IniRead, crouchKey, %configFileName%, Keys, crouchKey, LCtrl
	IniRead, sprintKey, %configFileName%, Keys, sprintKey, LShift
	IniRead, aimAutofireKey, %configFileName%, Keys, aimAutofireKey, F1
	IniRead, crouchAutofireKey, %configFileName%, Keys, crouchAutofireKey, F2
	IniRead, sprintAutofireKey, %configFileName%, Keys, sprintAutofireKey, F3

	if (sWindowName == "put_window_name_here")
		ExitWithErrorMessage("You must specify a window name! The script will now exit.")
}

RegisterHotkeys()
{
	global

	; Enabled only for toggle and hold modes
	Hotkey, %aimKey%, aimLabel, % bAimMode > 0 && bAimMode < KEY_MODE_AUTOFIRE ? "On" : "Off"
	Hotkey, %crouchKey%, crouchLabel, % bCrouchMode > 0 && bCrouchMode < KEY_MODE_AUTOFIRE ? "On" : "Off"
	Hotkey, %sprintKey%, sprintLabel, % bSprintMode > 0 && bSprintMode < KEY_MODE_AUTOFIRE ? "On" : "Off"

	; Enabled only for autofire mode
	Hotkey, %aimAutofireKey%, aimLabel, % bAimMode == KEY_MODE_AUTOFIRE ? "On" : "Off"
	Hotkey, %crouchAutofireKey%, crouchLabel, % bCrouchMode == KEY_MODE_AUTOFIRE ? "On" : "Off"
	Hotkey, %sprintAutofireKey%, sprintLabel, % bSprintMode == KEY_MODE_AUTOFIRE ? "On" : "Off"

	; Fixes issues when pressing system keys while toggle keys are modifiers and are enabled
	Hotkey, !Tab, SendAltTab, On
	Hotkey, Escape, SendEscape, On
	Hotkey, LWin, SendWindows, On
	Hotkey, RWin, SendWindows, On
}

ReleaseAllKeys()
{
	global

	OutputDebug, %A_ThisFunc%::values (%bAiming%, %bCrouching%, %bSprinting%)

	if (bAiming)
		AimToggle(false)
	if (bCrouching)
		CrouchToggle(false)
	if (bSprinting)
		SprintToggle(false)

	bAutofireAiming := false
	bAutofireCrouching := false
	bAutofireSprinting := false

	SetTimer, AimAutofire, Off
	SetTimer, CrouchAutofire, Off
	SetTimer, SprintAutofire, Off
}

SendAltTab()
{
	global

	OutputDebug, %A_ThisFunc%::begin

	; Check if keys are physically pressed
	isCtrlPressed := GetKeyState("Control", "P")
	isShiftPressed := GetKeyState("Shift", "P")

	OutputDebug, %A_ThisFunc%::isCtrlPressed %isCtrlPressed%
	OutputDebug, %A_ThisFunc%::isShiftPressed %isShiftPressed%

	; Take a snapshot of the toggle states
	if (ShouldRestoreTogglesOnFocus())
	{
		bRestoreAiming := bAiming
		bRestoreCrouching := bCrouching
		bRestoreSprinting := bSprinting
		bRestoreHandled := true
	}

	ReleaseAllKeys()

	; Handle Ctrl+Alt+Tab, Shift+Alt+Tab and Ctrl+Shift+Alt+Tab
	if (isCtrlPressed)
		SendInput {Control down}
	if (isShiftPressed)
		SendInput {Shift down}

	SendInput {Alt down}{Tab}

	OutputDebug, %A_ThisFunc%::end
}

SendClick(pKey)
{
	global

	OutputDebug, %A_ThisFunc%::begin

	; Take a snapshot of the toggle states
	if (ShouldRestoreTogglesOnFocus())
	{
		bRestoreAiming := bAiming
		bRestoreCrouching := bCrouching
		bRestoreSprinting := bSprinting
		bRestoreHandled := true
	}

	ReleaseAllKeys()

	SendInput % "{" . pKey . " down}"
	KeyWait, %pKey%
	SendInput % "{" . pKey . " up}"

	OutputDebug, %A_ThisFunc%::end
}

SendEscape()
{
	global

	OutputDebug, %A_ThisFunc%::begin

	; Check if keys are physically pressed
	isCtrlPressed := GetKeyState("Control", "P")

	OutputDebug, %A_ThisFunc%::isCtrlPressed %isCtrlPressed%

	; Take a snapshot of the toggle states
	if (ShouldRestoreTogglesOnFocus())
	{
		bRestoreAiming := bAiming
		bRestoreCrouching := bCrouching
		bRestoreSprinting := bSprinting
		bRestoreHandled := true
	}

	ReleaseAllKeys()

	; Handle Ctrl+Escape
	if (isCtrlPressed)
		SendInput {Control down}

	SendInput {Escape}

	OutputDebug, %A_ThisFunc%::end
}

SendWindows()
{
	global

	OutputDebug, %A_ThisFunc%::begin

	; Check if keys are physically pressed
	isShiftPressed := GetKeyState("Shift", "P")

	OutputDebug, %A_ThisFunc%::isShiftPressed %isShiftPressed%

	; Take a snapshot of the toggle states
	if (ShouldRestoreTogglesOnFocus())
	{
		bRestoreAiming := bAiming
		bRestoreCrouching := bCrouching
		bRestoreSprinting := bSprinting
		bRestoreHandled := true
	}

	ReleaseAllKeys()

	; Handle Shift+Win
	if (isShiftPressed)
		SendInput {Shift down}

	SendInput {LWin}

	OutputDebug, %A_ThisFunc%::end
}

ShouldRestoreTogglesOnFocus()
{
	global
	return bRestoreTogglesOnFocus && bAimMode == KEY_MODE_TOGGLE || bCrouchMode == KEY_MODE_TOGGLE || bSprintMode == KEY_MODE_TOGGLE && WinExist(sWindowName)
}

SprintAutofire()
{
	global

	;OutputDebug, %A_ThisFunc%::begin

	SendInput % "{" . sprintKey . " down}"
	Sleep, %nKeyDelay%
	SendInput % "{" . sprintKey . " up}"

	;OutputDebug, %A_ThisFunc%::end
}

SprintHold()
{
	global

	;OutputDebug, %A_ThisFunc%::begin

	SendInput % "{" . sprintKey . " down}"
	Sleep, %nKeyDelay%
	SendInput % "{" . sprintKey . " up}"

	KeyWait, %sprintKey%

	SendInput % "{" . sprintKey . " down}"
	Sleep, %nKeyDelay%
	SendInput % "{" . sprintKey . " up}"

	;OutputDebug, %A_ThisFunc%::end
}

SprintToggle(pSprinting, pWait := false)
{
	global

	;OutputDebug, %A_ThisFunc%::begin
	bSprinting := pSprinting
	;OutputDebug, %A_ThisFunc%::bSprinting %bSprinting%

	SendInput % bSprinting ? "{" . sprintKey . " down}" : "{" . sprintKey . " up}"

	if (pWait)
		KeyWait, %sprintKey%

	;OutputDebug, %A_ThisFunc%::end
}

; Exit script
ExitFunc(ExitReason, ExitCode)
{
	;OutputDebug, %A_ThisFunc%::ExitReason(%ExitReason%) ExitCode(%ExitCode%)

	; Only release keys if the script is closed from the tray menu or reloaded/replaced
	if (ExitReason != "Exit")
		ReleaseAllKeys()
}

; Display an error message and exit
ExitWithErrorMessage(ErrorMessage)
{
	MsgBox, 16, Error, %ErrorMessage%
	ExitApp, 1
}

#IfWinActive ahk_group windowIDGroup
LButton::
MButton::
RButton::
XButton1::
XButton2::
;OutputDebug, %A_ThisHotkey%::begin

if (!IsMouseOverWindow(windowID))
{
	;OutputDebug, %A_ThisHotkey%::outside window
	SendClick(A_ThisHotkey)
}
else
{
	;OutputDebug, %A_ThisHotkey%::click
	SendInput % "{" . A_ThisHotkey . " down}"
	KeyWait, %A_ThisHotkey%
	SendInput % "{" . A_ThisHotkey . " up}"
}

;OutputDebug, %A_ThisHotkey%::end
return
#IfWinActive

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
