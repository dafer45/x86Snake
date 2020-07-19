section .data

%include "defines.asm"

clearTerminalString	db	ESC, "[H", 27, "[2J", NULL

; ****************

section .text

extern printString

; -----
;  Clear the screen.
;
;  Arguments:
;    nothing
;  Returns:
;    nothing

global clearScreen
clearScreen:
	mov	rdi, clearTerminalString
	call	printString
