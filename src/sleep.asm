section .data

%include "defines.asm"

; ****************

timespec:
	tv_sec	dq	0
	tv_nsec	dq	0

; ****************

section .text

; -----
;  Sleep for given number of nano seconds.
;
;  Arguments:
;    1) rdi = number of nano seconds (value)
;  Return:
;    nothing

global sleep
sleep:
	;  Prolog.
	push	rbp
	mov	rbp, rsp
	push	rbx

	;  Function body.
	mov	qword [tv_sec], 0
	mov	qword [tv_nsec], rdi
	mov	rax, 35
	mov	rdi, timespec
	mov	rsi, 0
	syscall

	;  Return.
	pop	rbx
	pop	rbp
	ret
