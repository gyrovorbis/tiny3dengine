        ;; This is a collection of functions
        ;; from the famous tiny tetris by Marcus Comsted



getkeys:
	bp p7,0,quit	; external 5VOLT ?
	ld p3		; p3(Keys) into ACC
	bn acc,6,quit	; MODE-key
	bn acc,7,sleep	; SLEEP-key
	ret

quit:
	jmp goodbye
	
sleep:
	bn p3,7,sleep	; Wait for SLEEP to be depressed
	mov #0,vccr	; Blank LCD
sleepmore:
	set1 pcon,0	; Enter HALT mode
	bp p7,0,quit	; Docked?
	bp p3,7,sleepmore	; No SLEEP press yet
	mov #$80,vccr	; Reenable LCD

waitsleepup:
	bn p3,7,waitsleepup
	br getkeys


	;; Function:	clrscr
	;;
	;; Clears the screen

clrscr:	
	clr1 ocr,5
	push acc
	push xbnk
	push 2
	mov #0,xbnk
.cbank:	mov #$80,2
.cloop:	mov #0,@R2
	inc 2
	ld 2
	and #$f
	bne #$c,.cskip
	ld 2
	add #4
	st 2
.cskip:	ld 2
	bnz .cloop
	bp xbnk,0,.cexit
	mov #1,xbnk
	br .cbank
.cexit:	pop 2
	pop xbnk
	pop acc
	set1 ocr,5
	ret
	
	
	;; Function:	setscr
	;;
	;; Copies a predefined full-screen image to the screen
	;;
	;; Inputs:
	;;   trl = low byte of predefined screen ROM address
	;;   trh = high byte of predefined screen ROM address
	
setscr:
	push acc
	push xbnk
	push c
	push 2
	
	ld trl
	add #2
	st trl

	bn psw, cy, .no_ovf
	inc trh

.no_ovf:
	mov #$80,2
	xor acc
	st xbnk
	st c
.sloop:	ldc
	st @R2
	inc 2
	ld 2
	and #$f
	bne #$c,.sskip
	ld 2
	add #4
	st 2
	bnz .sskip
	inc xbnk
	mov #$80,2
.sskip:	inc c
	ld c
	bne #$c0,.sloop
	pop 2
	pop c
	pop xbnk
	pop acc

	ret

	
