section .data

%include "defines.asm"

seed		dq	1
modulus		dq	2<<31
multiplier	dq	1103515245
increment	dq	12345

; ****************

section .text

global random
random:
	push	rbp
	mov	rbp, rsp

	mov	rax, qword [seed]
	mul	qword [multiplier]
	add	rax, qword [increment]
	and	rax, 0x7FFFFFF
	mov	qword [seed], rax

	pop	rbp
	ret
