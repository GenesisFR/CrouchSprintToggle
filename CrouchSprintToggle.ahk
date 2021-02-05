; CrouchSprintToggle v1.1

#NoEnv                 ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn                  ; Enable warnings to assist with detecting common errors.
SendMode Input         ; Recommended for new scripts due to its superior speed and reliability.
#SingleInstance force  ; Allow only a single instance of the script to run.
#UseHook               ; Allow listening for non-modifier keys.
#MaxThreadsPerHotkey 1

; Register a function to be called on exit
OnExit("ExitFunc")

isCrouching := false
isSprinting := false

; Read window title from an external text file
IniRead, windowTitle, CrouchSprintToggle.ini, General, windowName
;MsgBox % windowTitle

; Make the script active only for a specific application
WinGet, windowID, ID, %windowTitle%
GroupAdd, windowIDGroup, ahk_id %windowID%
#IfWinActive ahk_group windowIDGroup

	; Left control released
	~LCtrl UP::
	Sprint(false)
	isCrouching ? Crouch(false) : Crouch(true)
	return

	; Left control pressed
	~LCtrl::
	Sprint(false)
	SendInput {LCtrl down}
	return

	; Left shift released
	~LShift UP::
	Crouch(false)
	isSprinting ? Sprint(false) : Sprint(true)
	return

	; Left shift pressed
	~LShift::
	Crouch(false)
	SendInput {LShift down}
	return

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
	Crouch(false)
	Sprint(false)
	ExitApp
}

; Suspend script when pressing CTRL+F12
^F12::Suspend
