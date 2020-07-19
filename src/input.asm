%include "defines.asm"

section .bss

;  Termios datastructure
termios:	resb	36

pollfd:
	fd	dd	0
	events	dw	0
	revents	dw	0

inputCharacter	resb	1

stdin_fd:	equ	0
ICANON:		equ	1<<1
ECHO:		equ	1<<3

section .text

;  Read character from STDIN if available.
;  Arguments:
;    nonthing
;  Returns:
;    If STDIN has input character -> al = the character.
;    Else -> al = 0

global getChar
getChar:
	;  Prologue.
	push	rbp
	mov	rbp, rsp

	;  Check whether STDIN has a character to read.
	mov	dword [fd], STDIN
	mov	word [events], 0x001	; Check for existing character.
	mov	word [revents], 0
	mov	rax, SYS_poll
	mov	rdi, pollfd
	mov	rsi, 1
	mov	rdx, 0
	syscall
prepareReadCharacter:
	;  If character exists, jump to read character.
	cmp	word [revents], 0x001
	je	readCharacter
	; Else, set the character to 0 and ignore the read.
	mov	byte [inputCharacter], 0
	jmp	readCharacterDone
readCharacter:
	mov	rax, SYS_read
	mov	rdi, STDIN
	mov	rsi, inputCharacter
	mov	rdx, 1
	syscall
readCharacterDone:
	mov	al, byte [inputCharacter]

	;  Epilogue.
	pop	rbp
	ret

;  Turn off cannonical input (= don't wait for enter).
global cannonicalInputOff
cannonicalInputOff:
	call	readStdinTermios

	;  Clear cannonical bit.
	and	dword [termios+12], ~ICANON

	call	writeStdinTermios

	ret

;  Turn off echo.
global echoOff
echoOff:
	call	readStdinTermios

	;  Clear echo bit.
	and	dword [termios+12], ~ECHO

	call	writeStdinTermios

	ret

;  Turn on cannonical input (wait for enter before returning).
global cannonicalInputOn
cannonicalInputOn:
	call	readStdinTermios

	;  Set cannonical bit.
	or	dword [termios+12], ICANON

	call	writeStdinTermios

	ret

;  Turn on echo.
global echoOn
echoOn:
	call	readStdinTermios

	;  Set echo bit.
	or	dword [termios+12], ECHO

	call	writeStdinTermios

	ret

;  Read STDIN termios
;  Arguments:
;    nothing.
;  Returns:
;    Overwrites termios.

readStdinTermios:
	push	rbx

	mov	eax, 36h
	mov	ebx, stdin_fd
	mov	ecx, 5401h
	mov	edx, termios
	int	80h

	pop	rbx
	ret

;  Write STDIN termios
;  Arguments:
;    Global terminos structure.
;  Returns:
;    nothing.

writeStdinTermios:
	push	rbx

	mov	eax, 36h
	mov	ebx, stdin_fd
	mov	ecx, 5402h
	mov	edx, termios
	int	80h

	pop	rbx
	ret
