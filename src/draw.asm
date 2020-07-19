section .data

%include "defines.asm"

WIDTH		equ	20
HEIGHT		equ	20

section .bss

screenBuffer	resb	(WIDTH+1)*HEIGHT + 1

; ****************

section .text

extern printString

; -----
;  Draw the playground.
;
;  Arguments:
;    1)	nothing
;  Returns:
;    nothing

global draw
draw:
	push	rbp
	mov	rbp, rsp
	push	rbx
	push	r12
	push	r13
	push	r14

;
	mov	r12, 0
	mov	r14, 0
loopRow:
	mov	r13, 0
loopColumn:
	mov	byte [screenBuffer + r14], '*'
	inc	r14

	inc	r13
	cmp	r13, WIDTH
	jne	loopColumn

	mov	byte [screenBuffer + r14], LF
	inc	r14

	inc	r12
	cmp	r12, HEIGHT
	jne	loopRow

	mov	byte [screenBuffer + r14], NULL

drawBuffer:
	mov	rdi, screenBuffer
	call	printString

;  Draw done, return to calling routine.

doneDraw:

	pop	r14
	pop	r13
	pop	r12
	pop	rbx
	pop	rbp
	ret
