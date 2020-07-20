section .data

%include "defines.asm"

WIDTH		equ	20
HEIGHT		equ	20

APPLE		equ	255
WALL		equ	254
HEAD		equ	253
MAX_ID		equ	HEAD

playerPositionX		dq	WIDTH/2
playerPositionY		dq	HEIGHT/2

applePositionX		dq	WIDTH/4
applePositionY		dq	HEIGHT/4

playerDirection		dq	0
playerSize		dq	10
snakeIsDeadFlag		dq	0

section .bss

screenBuffer	resb	(WIDTH+1)*HEIGHT + 1
playground	resb	WIDTH*HEIGHT

; ****************

section .text

extern printString
extern random

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
	mov	byte [playground + r14], WALL
	jmp	finishInitPlaygroundSite
setPlayer:
	mov	byte [playground + r14], HEAD
	jmp	finishInitPlaygroundSite
setApple:
	mov	byte [playground + r14], APPLE
	jmp	finishInitPlaygroundSite

setEmpty:
	mov	byte [playground + r14], 0
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
;  Set the player direction.
;
;  Arguments:
;    1) rdi = 0 (right), 1 (up), 2 (left), 3 (down)
;  Returns:
;    nothing

global updatePlayerDirection
updatePlayerDirection:
	push	rbp
	mov	rbp, rsp

	cmp	rdi, 'l'
	je	setRight
	cmp	rdi, 'i'
	je	setUp
	cmp	rdi, 'j'
	je	setLeft
	cmp	rdi, 'k'
	je	setDown
	jmp	finishUpdatePosition
setRight:
	mov	qword [playerDirection], 0
	jmp	finishUpdatePosition
setUp:
	mov	qword [playerDirection], 1
	jmp	finishUpdatePosition
setLeft:
	mov	qword [playerDirection], 2
	jmp	finishUpdatePosition
setDown:
	mov	qword [playerDirection], 3
	jmp	finishUpdatePosition
finishUpdatePosition:
	pop	rbp
	ret

; -----
;  Update playground.
;
;  Arguments:
;    nothing
;  Returns:
;    If the snake died -> rax = 1
;    Else -> rax = 1
global updatePlayground
updatePlayground:
	push	rbp
	mov	rbp, rsp

	call	updatePlayerBody
	call	updatePlayerPosition
	call	checkCollision
	cmp	rax, 1
	je	snakeIsDead
	jmp	snakeIsAlive

snakeIsDead:
	mov	qword [snakeIsDeadFlag], 1
	jmp	afterCheckSnakeIsDead
snakeIsAlive:
	mov	qword [snakeIsDeadFlag], 0
	jmp	afterCheckSnakeIsDead
afterCheckSnakeIsDead:
	call	checkAteApple

	call	imprintHead

	mov	rax, qword [snakeIsDeadFlag]
	pop	rbp
	ret

; -----
;  Update the player body.

updatePlayerBody:
	push	rbp
	mov	rbp, rsp
	push	r12
	push	r13
	push	r14
	push	r15
	push	rax

	;  Initialize loop.
	mov	r12, 0
	mov	r14, 0
loopRowUpdatePlayerBody:
	mov	r13, 0
loopColumnUpdatePlayerBody:
	cmp	byte [playground + r14], 0
	je	skipDecrementSite
	cmp	byte [playground + r14], MAX_ID
	jae	skipDecrementSite
	mov	r15b, byte [playground + r14]
	dec	r15b
	mov	byte [playground + r14], r15b

skipDecrementSite:
	inc	r14

	inc	r13
	cmp	r13, WIDTH
	jne	loopColumnUpdatePlayerBody

	inc	r12
	cmp	r12, HEIGHT
	jne	loopRowUpdatePlayerBody

	;  Set the previous player head position to the player length.
	mov	rax, qword [playerPositionY]
	mov	r12, WIDTH
	mul	r12
	add	rax, qword [playerPositionX]
	mov	r15, qword [playerSize]
	mov	byte [playground + rax], r15b

	pop	rax
	pop	r15
	pop	r14
	pop	r13
	pop	r12
	pop	rbp
	ret

; -----
;  Update the player position.

updatePlayerPosition:
	push	rbp
	mov	rbp, rsp
	push	r12
	push	r13
	push	r14

	cmp	qword [playerDirection], 0
	je	movePlayerRight
	cmp	qword [playerDirection], 1
	je	movePlayerUp
	cmp	qword [playerDirection], 2
	je	movePlayerLeft
	cmp	qword [playerDirection], 3
	je	movePlayerDown
movePlayerRight:
	mov	r12, qword [playerPositionX]
	inc	r12
	mov	qword [playerPositionX], r12
	jmp	afterMovePlayer
movePlayerUp:
	mov	r12, qword [playerPositionY]
	dec	r12
	mov	qword [playerPositionY], r12
	jmp	afterMovePlayer
movePlayerLeft:
	mov	r12, qword [playerPositionX]
	dec	r12
	mov	qword [playerPositionX], r12
	jmp	afterMovePlayer
movePlayerDown:
	mov	r12, qword [playerPositionY]
	inc	r12
	mov	qword [playerPositionY], r12
	jmp	afterMovePlayer
afterMovePlayer:
;	mov	rax, qword [playerPositionY]
;	mov	r12, WIDTH
;	mul	r12
;	add	rax, qword [playerPositionX]
;	mov	byte [playground + rax], HEAD

	pop	r14
	pop	r13
	pop	r12
	pop	rbp
	ret

; -----
;  Check collsion.
;
;  Arguments:
;    nothing
;  Return:
;    If collsion has occured -> rax = 1
;    Else -> rax = 0
checkCollision:
	push	rbp
	mov	rbp, rsp

	mov	rax, qword [playerPositionY]
	mov	r12, WIDTH
	mul	r12
	add	rax, qword [playerPositionX]
	cmp	byte [playground + rax], APPLE
	je	noCollision
	cmp	byte [playground + rax], HEAD
	je	noCollision
	cmp	byte [playground + rax], 0
	je	noCollision
	jmp	collisionOccured
noCollision:
	mov	rax, 0
	jmp	finishCheckCollision
collisionOccured:
	mov	rax, 1
	jmp	finishCheckCollision
finishCheckCollision:
	pop	rbp
	ret

; -----
;  Check if the snake ate the apple.
;
;  Arguments:
;    nothing
;  Returns:
;    nothing

checkAteApple:
	push	rbp
	mov	rbp, rsp

	mov	rax, qword [playerPositionY]
	mov	r12, WIDTH
	mul	r12
	add	rax, qword [playerPositionX]
	cmp	byte [playground + rax], APPLE
	jne	finishCheckAteApple
	mov	r12, qword [playerSize]
	inc	r12
	mov	qword [playerSize], r12
	call	addNewApple
finishCheckAteApple:
	pop	rbp
	ret

; -----
;  Add new apple to the playground.
;
;  Arguments:
;    nothing
;  Returns:
;    nothing

addNewApple:
	push	rbp
	mov	rbp, rsp
	push	r12

	call	random
	mov	r12, WIDTH
	cqo
	div	r12
	mov	[applePositionX], rdx
	call	random
	mov	r12, HEIGHT
	cqo
	div	r12
	mov	[applePositionY], rdx
	call	tryAddApple

	pop	r12
	pop	rbp
	ret

tryAddApple:
	push	rbp
	mov	rbp, rsp

	mov	rax, qword [applePositionY]
	mov	r12, WIDTH
	mul	r12
	add	rax, qword [applePositionX]
	mov	byte [playground + rax], APPLE

	pop	rbp
	ret

; -----
;  Imprint head on the playground.
;
;  Arguments:
;    nothing
;  Returns:
;    nothing

imprintHead:
	push	rbp
	mov	rbp, rsp

	mov	rax, qword [playerPositionY]
	mov	r12, WIDTH
	mul	r12
	add	rax, qword [playerPositionX]
	mov	byte [playground + rax], HEAD

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
	cmp	byte [playground + r15], WALL
	je	drawWall
	cmp	byte [playground + r15], HEAD
	je	drawPlayerHead
	cmp	byte [playground + r15], APPLE
	je	drawApple
	cmp	byte [playground + r15], 0
	jne	drawBody
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
drawBody:
	mov	byte [screenBuffer + r14], 'o'
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
