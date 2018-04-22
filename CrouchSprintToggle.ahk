; CrouchSprintToggle v1.0

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

; Suspend script when pressing CTRL+F12
^F12::Suspend

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

; Escape pressed
~*Esc::
	; Save toggle states
	wasCrouching := isCrouching
	wasSprinting := isSprinting
	Crouch(false)
	Sprint(false)

	; Trigger Escape
	SendInput {Esc down}
	KeyWait, Esc
	SendInput {Esc up}

	; Restore toggle states
	if (wasCrouching)
		Crouch(true)
	else if (wasSprinting)
		Sprint(true)

	return

; Disable toggles when pressing the Windows/LAlt keys to keep the normal behavior 
*LWin::
*RWin::
	Crouch(false)
	Sprint(false)
	KeyWait, %A_ThisHotkey%
	SendInput % InStr(A_ThisHotkey, "LWin") ? "{LWin down}{LWin up}" : "{RWin down}{RWin up}"
	return

~*LAlt::
	Crouch(false)
	Sprint(false)
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

; Exit script
ExitFunc(ExitReason, ExitCode)
{
	Crouch(false)
	Sprint(false)
	ExitApp
}