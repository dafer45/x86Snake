section .bss

termios:	resb	36

stdin_fd:	equ	0
ICANON:		equ	1<<1
ECHO:		equ	1<<3

section .text
global cannonicalInputOff
cannonicalInputOff:
	call	readStdinTermios

	;  Clear cannonical bit.
	and	dword [termios+12], ~ICANON

	call	writeStdinTermios

	ret

global echoOff
echoOff:
	call	readStdinTermios

	;  Clear echo bit.
	and	dword [termios+12], ~ECHO

	call	writeStdinTermios

	ret

global cannonicalInputOn
cannonicalInputOn:
	call	readStdinTermios

	;  Set cannonical bit.
	or	dword [termios+12], ICANON

	call	writeStdinTermios

	ret

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

writeStdinTermios:
	push	rbx

	mov	eax, 36h
	mov	ebx, stdin_fd
	mov	ecx, 5402h
	mov	edx, termios
	int	80h

	pop	rbx
	ret
