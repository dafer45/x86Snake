section .data

; ****************

%include "defines.asm"

; -----
;  Data.

titleScreen	db	"================", LF
		db	"=    Snake!    =", LF
		db	"================", LF, NULL

nextScreen	db	"================", LF
		db	"=     Fake!    =", LF
		db	"================", LF, NULL

	timespec:
		tv_sec	dq	0
		tv_nsec	dq	0

; ****************

extern printString
extern sleep
extern cannonicalInputOff
extern cannonicalInputOn
extern echoOff
extern echoOn

section .text

global _start
_start:
	call	cannonicalInputOff
	call	echoOff

	;  Print title screen.
	mov	rdi, titleScreen
	call	printString

	mov	rdi, 900000000
	call	sleep

	mov	rdi, nextScreen
	call	printString

	call	echoOn
	call	cannonicalInputOn

	mov	rax, SYS_exit
	mov	rdi, EXIT_SUCCESS
	syscall
