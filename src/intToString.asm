section .data

%include "defines.asm"

; ****************

section .text

; -----
;  Converts an integer to a string.
;
;  Arguments:
;    1) rdi = Integer to convert.
;    2) rsi = Buffer to write to.
;    3) rdx = Maximum number of characters in the bugger.
;  Returns:
;    String representation of the integer by reference.

global intToString
intToString:
	push	rbp
	mov	rbp, rsp
	push	r12
	push	r13

	mov	r12, rdx
	mov	rax, rdi
	mov	rdx, NULL
	mov	[rsi+r12], rdx
loopIntToString:
	cmp	r12, 0
	je	finishIntToString
	dec	r12
	cqo
	mov	r13, 10
	div	rax, r13
	add	rdx, 48
	mov	byte [rsi+r12], dl
	cmp	rax, 0
	je	clearRemainingEntries
	jmp	loopIntToString
clearRemainingEntries:
	cmp	r12, 0
	je	finishIntToString
	dec	r12
	mov	dl, ' '
	mov	byte [rsi+r12], dl
	jmp	clearRemainingEntries
finishIntToString:
	pop	r13
	pop	r12
	pop	rbp
	ret
