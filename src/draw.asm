section .data

%include "defines.asm"

WIDTH		equ	20
HEIGHT		equ	20

playerPositionX		dq	WIDTH/2
playerPositionY		dq	HEIGHT/2

applePositionX		dq	WIDTH/4
applePositionY		dq	HEIGHT/4

section .bss

screenBuffer	resb	(WIDTH+1)*HEIGHT + 1
playground	resb	WIDTH*HEIGHT

; ****************

section .text

extern printString

; -----
;  Initialize the play ground.

global initPlayground
initPlayground:
	push	rbp
	mov	rbp, rsp
	push	rbx
	push	r12
	push	r13
	push	r14

;  Initialize loop.
	mov	r12, 0
	mov	r14, 0
loopRowInitPlayground:
	mov	r13, 0
loopColumnInitPlayground:
	cmp	r13, 0
	je	setWall
	cmp	r13, WIDTH-1
	je	setWall
	cmp	r12, 0
	je	setWall
	cmp	r12, HEIGHT-1
	je	setWall

	cmp	[playerPositionX], r13
	jne	afterInitPlayer
	cmp	[playerPositionY], r12
	jne	afterInitPlayer
	jmp	setPlayer
afterInitPlayer:
	cmp	[applePositionX], r13
	jne	afterInitApple
	cmp	[applePositionY], r12
	jne	afterInitApple
	jmp	setApple
afterInitApple:

	jmp	setEmpty
setWall:
	mov	byte [playground + r14], 'W'
	jmp	finishInitPlaygroundSite
setPlayer:
	mov	byte [playground + r14], 'P'
	jmp	finishInitPlaygroundSite
setApple:
	mov	byte [playground + r14], 'A'
	jmp	finishInitPlaygroundSite

setEmpty:
	mov	byte [playground + r14], 'E'
	jmp	finishInitPlaygroundSite

finishInitPlaygroundSite:
	inc	r14

	inc	r13
	cmp	r13, WIDTH
	jne	loopColumnInitPlayground

	inc	r12
	cmp	r12, HEIGHT
	jne	loopRowInitPlayground

doneInitPlayground:
	pop	r14
	pop	r13
	pop	r12
	pop	rbx
	pop	rbp
	ret

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
	push	r15

;  Initialize loop.
	mov	r12, 0
	mov	r14, 0
	mov	r15, 0
loopRowDraw:
	mov	r13, 0
loopColumnDraw:
	cmp	byte [playground + r15], 'W'
	je	drawWall
	cmp	byte [playground + r15], 'P'
	je	drawPlayerHead
	cmp	byte [playground + r15], 'A'
	je	drawApple
	jmp	drawEmpty

drawWall:
	mov	byte [screenBuffer + r14], '*'
	jmp	finishDrawSite
drawPlayerHead:
	mov	byte [screenBuffer + r14], 'O'
	jmp	finishDrawSite
drawApple:
	mov	byte [screenBuffer + r14], 'x'
	jmp	finishDrawSite
drawEmpty:
	mov	byte [screenBuffer + r14], ' '
	jmp	finishDrawSite
finishDrawSite:
	inc	r15
	inc	r14

	inc	r13
	cmp	r13, WIDTH
	jne	loopColumnDraw

	mov	byte [screenBuffer + r14], LF
	inc	r14

	inc	r12
	cmp	r12, HEIGHT
	jne	loopRowDraw

	mov	byte [screenBuffer + r14], NULL

drawBuffer:
	mov	rdi, screenBuffer
	call	printString

;  Draw done, return to calling routine.

doneDraw:

	pop	r15
	pop	r14
	pop	r13
	pop	r12
	pop	rbx
	pop	rbp
	ret
