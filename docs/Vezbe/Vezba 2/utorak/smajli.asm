
VID_SEG		equ		0b800h
START_POS	equ		400
START_COL	equ		01h
ASCII_SMILE	equ		01h
ASCII_ESC	equ		1bh
ROW_WIDTH	equ		160
CHAR_WIDTH	equ		2

	org 100h
	
	;inicijalizacija
	mov ax, VID_SEG
	mov es, ax
	
	mov bx, START_POS
	
	mov cl, START_COL
	
unos:
	mov ah, 0
	int 16h
	
	cmp al, ASCII_ESC
	je kraj
	
	cmp al, 'w'
	je idi_gore
	
	cmp al, 'a'
	je idi_levo
	
	cmp al, 's'
	je idi_dole
	
	cmp al, 'd'
	je idi_desno
	
	jmp unos
	
idi_gore:
	sub bx, ROW_WIDTH
	jmp crtanje

idi_levo:
	sub bx, CHAR_WIDTH
	jmp crtanje

idi_dole:
	add bx, ROW_WIDTH
	jmp crtanje

idi_desno:
	add bx, CHAR_WIDTH

crtanje:
	mov [es:bx], byte ASCII_SMILE
	inc bx
	mov [es:bx], byte cl
	dec bx
	
	inc cl
	
	jmp unos
	
kraj:
	ret
	
	
	
	
	
	
	
	
	