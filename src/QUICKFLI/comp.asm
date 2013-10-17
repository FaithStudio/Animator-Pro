

;   comp.asm - Copyright 1989 Jim Kent; Dancing Flame, San Francisco.
;   A perpetual non-exclusive license to use this source code in non-
;   commercial applications is given to all owners of the Autodesk Animator.
;   If you wish to use this code in an application for resale please
;   contact Autodesk Inc., Sausilito, CA  USA  phone (415) 332-2244.

	TITLE   comp

_TEXT	SEGMENT  BYTE PUBLIC 'CODE'
_TEXT	ENDS
_DATA	SEGMENT  WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT  WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT  WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST,	_BSS,	_DATA
	ASSUME  CS: _TEXT, DS: DGROUP, SS: DGROUP, ES: DGROUP
_TEXT      SEGMENT

;unlccomp decodes a FLI_LC chunk of a flic frame.  This is the main
;'delta' type chunk.  It contains information to transform one frame
;into the next frame where hopefully the next frame is mostly the same
;as the one frame.  This uses a combination of 'skip' compression and
;run length compression.  
	PUBLIC _unlccomp
; unlccomp(cbuf, screen)
; UBYTE *cbuf;  /* points to a FLI_LC chunk after chunk header. */
; UBYTE *screen;		   /* 64000 byte screen */
_unlccomp PROC far
linect equ word ptr[bp-2]
	;save the world and set the basepage
	push bp
	mov bp,sp
	sub sp,4
	push es
	push ds
	push si
	push di
	push bx
	push cx

	cld	;clear direction flag in case Aztec or someone mucks with it.

	lds si,[bp+4+2]
	les di,[bp+8+2]
	lodsw	;get the count of # of lines to skip
	mov dx,320
	mul dx
	add di,ax
	lodsw		;get line count
	mov	linect,ax	;save it on stack
	mov	dx,di	;keep pointer to start of line in dx
	xor	ah,ah	;clear hi bit of ah cause lots of unsigned uses to follow
linelp:
	mov	di,dx
	lodsb		;get op count for this line
	mov bl,al  
	test bl,bl
	jmp endulcloop
ulcloop:
	lodsb	;load in the byte skip
	add di,ax
	lodsb	; load op/count
	test al,al
	js ulcrun
	mov cx,ax
	rep movsb
	dec bl
	jnz ulcloop
	jmp ulcout
ulcrun:
	neg al
	mov cx,ax ;get signed count
	lodsb	  ;value to repeat in al
	rep stosb
	dec bl
endulcloop:
	jnz ulcloop
ulcout:
	add	dx,320
	dec linect
	jnz	linelp

	pop cx
	pop bx
	pop di
	pop si
	pop ds
	pop es
	mov	sp,bp
	pop	bp
	ret	

_unlccomp ENDP

	;cset_colors(csource)
	;set the color palette hardware from a compressed source 
	;of format:
	;WORD # of runs, run1, run2, ...,runn
	;each run is of form:
	;BYTE colors to skip, BYTE colors to set, r1,g1,b1,r2,g2,b2,...,rn,gn,bn
	public _cset_colors
_cset_colors proc far
	push bp
	mov bp,sp
	push ds
	push si
	push di
	push cx
	push bx
	cld

	lds si,[bp+4+2]	;load the source compressed color data
	mov di,0		;clear dest color index 
	lodsw
	mov bx, ax   	;get the count of color runs
	test bx,bx
	jmp endcu
cu:
	lodsb		;get the colors to skip
	add di,ax	;add to color index
	lodsb		;get the count of colors to set
	mov cx,ax	;use it as a loop counter
	or  cx,cx	;test for zero
	jnz	set1c
	mov cx,256
set1c:
	mov	dx,3c8h	;point dx to vga color control port
	mov ax,di
	out dx,al	;say which color index to start writing to
	inc di		;bump color index
	inc dx		;point port to vga color data
	;jmp s1		;stall as per IBM VGA tech spec to give hardware time to settle
s1:
	lodsb		;get red component
	out dx,al	;tell the video DAC where it's at
	;jmp s2		;stall some more for poor slow hardware
s2:
	lodsb		;same same with green component
	out dx,al
	;jmp s3
s3:
	lodsb		;same with blue
	out dx,al
	loop set1c

	dec bx
endcu:
	jnz cu

	pop bx
	pop cx
	pop di
	pop si
	pop ds
	pop	bp
	ret	

_cset_colors endp


_TEXT	ENDS
END
