; HoldToggles v1.2

;#Requires AutoHotkey 1.1.30.03+ ; AHK Studio doesn't support this yet
#NoEnv                           ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn                            ; Enable warnings to assist with detecting common errors.
SendMode Input                   ; Recommended for new scripts due to its superior speed and reliability.
#SingleInstance force            ; Allow only a single instance of the script to run.
#UseHook                         ; Allow listening for non-modifier keys.
#MaxThreadsPerHotkey 1           ; Prevent accidental double-presses

; Register a function to be called on exit
OnExit("ExitFunc")

; State variables
isClicking := false
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
IniRead, isAimToggle, HoldToggles.ini, General, isAimToggle
IniRead, isCrouchToggle, HoldToggles.ini, General, isCrouchToggle
IniRead, isSprintToggle, HoldToggles.ini, General, isSprintToggle
IniRead, isDebug, HoldToggles.ini, General, isDebug

if (isDebug == "true")
{
	MsgBox % "windowName = " . windowName
	MsgBox % "isAimToggleEnabled = " . isAimToggle
	MsgBox % "isCrouchToggleEnabled = " . isCrouchToggle
	MsgBox % "isSprintToggleEnabled = " . isSprintToggle
}

; Make the script active only for a specific application
WinGet, windowID, ID, %windowName%
GroupAdd, windowIDGroup, ahk_id %windowID%
#IfWinActive ahk_group windowIDGroup

	; Right mouse button released
	*RButton Up::
	if (isAimToggle == "true")
	{
		isClicking ? Click(false) : Click(true)
	}
	return

	; Right mouse button pressed
	*RButton::
	if (isAimToggle == "true")
	{
		Click Down Right
	}
	return
	
	; Left control released
	~LCtrl UP::
	if (isCrouchToggle == "true")
	{
		Sprint(false)
		isCrouching ? Crouch(false) : Crouch(true)
	}
	return

	; Left control pressed
	~LCtrl::
	if (isCrouchToggle == "true")
	{
		Sprint(false)
		SendInput {LCtrl down}
	}
	return

	; Left shift released
	~LShift UP::
	if (isSprintToggle == "true")
	{
		Crouch(false)
		isSprinting ? Sprint(false) : Sprint(true)
	}
	return
	
	; Left shift pressed
	~LShift::
	if (isSprintToggle ==  "true")
	{
		Crouch(false)
		SendInput {LShift down}
	}
	return

	; Toggle click 
	Click(ByRef pIsClicking)
	{
		global isClicking := pIsClicking
		SendInput % isClicking ? "{Click Down Right}" : "{Click Up Right}"
	}
	
	; Toggle crouch 
	Crouch(ByRef pIsCrouching)
	{
		global isCrouching := pIsCrouching
		SendInput % isCrouching ? "{LCtrl down}" : "{LCtrl up}"
	}

	; Toggle sprint
	Sprint(ByRef pIsSprinting)
	{
		global isSprinting := pIsSprinting
		SendInput % isSprinting ? "{LShift down}" : "{LShift up}"
	}

#IfWinActive

; Exit script
ExitFunc(ExitReason, ExitCode)
{
	Click(false)
	Crouch(false)
	Sprint(false)
	ExitApp
}

; Suspend script when pressing CTRL+F12
^F12::Suspend
