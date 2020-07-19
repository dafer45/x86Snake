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

inputCharacter	db	" ", LF, NULL

pollfd:
	fd	dd	0
	events	dw	0
	revents	dw	0

; ****************

extern printString
extern sleep
extern getChar
extern cannonicalInputOff
extern cannonicalInputOn
extern echoOff
extern echoOn
extern clearScreen
extern initPlayground
extern updatePlayerDirection
extern updatePlayground
extern draw

section .text

global _start
_start:
	call	cannonicalInputOff
	call	echoOff

	;  Print title screen.
	mov	rdi, titleScreen
	call	printString

	mov	rdi, 200000000
	call	sleep

	call	clearScreen
	call	initPlayground

	mov	rbx, 10
mainLoop:
	call	draw
	mov	rdi, 200000000
	call	sleep

	call	getChar
	mov	byte [inputCharacter], al
	call	clearScreen

	cmp	byte [inputCharacter], 'e'
	je	exit

	mov	rdi, 0
	mov	dil, [inputCharacter]
	call	updatePlayerDirection
	call	updatePlayground

;	mov	rdi, inputCharacter
;	call	printString

	jmp	mainLoop
exit:
	call	echoOn
	call	cannonicalInputOn

	mov	rax, SYS_exit
	mov	rdi, EXIT_SUCCESS
	syscall
