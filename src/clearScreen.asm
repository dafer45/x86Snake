section .data

%include "defines.asm"

clearTerminalString	db	ESC, "[H", ESC, "[2J", NULL

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
	push	rbp
	mov	rbp, rsp

	mov	rdi, clearTerminalString
	call	printString

	pop	rbp
	ret
