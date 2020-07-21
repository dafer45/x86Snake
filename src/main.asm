section .data

; ****************

%include "defines.asm"

; -----
;  Data.

titleScreen	db	"===================", LF
		db	"=      Fake!      =", LF
		db	"===================", LF,
		db	LF
		db	"i - Up", LF
		db	"k - Down", LF
		db	"j - Left", LF
		db	"l - Right", LF
		db	LF
		db	"e - Exit", LF
		db	LF
		db	"Press ENTER to play.", LF, NULL

scoreLabel	db	"Score: ", NULL
score		db	"ABCD", NULL
newLine		db	LF, NULL

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
extern clearScreen
extern initPlayground
extern updatePlayerDirection
extern updatePlayground
extern draw
extern getScore
extern intToString

section .text

global _start
_start:
	call	cannonicalInputOff
	call	echoOff

showTitleScreen:
	call	clearScreen
	mov	rdi, titleScreen
	call	printString
	mov	rdi, scoreLabel
	call	printString
	mov	rdi, score
	call	printString
	mov	rdi, newLine
	call	printString

waitForEnter:
	mov	rdi, 200000000
	call	sleep

	call	getChar
	cmp	al, 'e'
	je	exit
	cmp	al, LF
	jne	waitForEnter

	call	clearScreen
	call	initPlayground

	mov	rbx, 10
mainLoop:
	call	draw
	mov	rdi, 100000000
	call	sleep

	call	getChar
	mov	byte [inputCharacter], al
	call	clearScreen

	cmp	byte [inputCharacter], 'e'
	je	exit

	mov	rdi, 0
	mov	dil, [inputCharacter]
	call	updatePlayerDirection
	call	updatePlayground
	cmp	rax, 1
	je	onDead

	jmp	mainLoop
onDead:
;	call	clearScreen
;	mov	rdi, scoreLabel
;	call	printString
	call	getScore
	mov	rdi, rax
	mov	rsi, score
	mov	rdx, 4
	call	intToString
	jmp	showTitleScreen
;	mov	rdi, score
;	call	printString
exit:
	call	echoOn
	call	cannonicalInputOn

	mov	rax, SYS_exit
	mov	rdi, EXIT_SUCCESS
	syscall
