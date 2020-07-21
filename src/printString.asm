section .data

%include "defines.asm"

; ****************

section .text

; -----
;  Print NULL terminated string to STDOUT.
;
;  Arguments:
;    1)	rdi = string (address)
;  Returns:
;    nothing

global printString
printString:
	push	rbp
	mov	rbp, rsp
	push	rbx

	;  Count the number of characters in the string.
	mov	rbx, rdi
	mov	rdx, 0
strCountLoop:
	cmp	byte [rbx], NULL
	je	strCountDone
	inc	rdx
	inc	rbx
	jmp	strCountLoop
strCountDone:
	cmp	rdx, 0
	je	prtDone

	;  Call the OS to output the string.
	mov	rax, SYS_write
	mov	rsi, rdi
	mov	rdi, STDOUT
	syscall

	;  String printed, return to calling routine.
prtDone:
	pop	rbx
	pop	rbp
	ret
