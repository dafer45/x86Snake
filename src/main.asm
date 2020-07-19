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

section .text

global _start
_start:
	call	cannonicalInputOff
	call	echoOff

	;  Print title screen.
	mov	rdi, titleScreen
	call	printString

	mov	rbx, 10
loopA:
	mov	rdi, 200000000
	call	sleep

	call	getChar
	mov	byte [inputCharacter], al

	mov	rdi, inputCharacter
	call	printString

skipRead:
	cmp	rbx, 0
	je	done
	dec	rbx
	jmp	loopA
done:

	call	echoOn
	call	cannonicalInputOn

	mov	rax, SYS_exit
	mov	rdi, EXIT_SUCCESS
	syscall
