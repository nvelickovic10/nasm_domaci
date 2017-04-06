
ASCII_ESC	equ		1bh
START_POS	equ		0
VID_SEG		equ		0b800h
ASCII_SMILE	equ		1
VID_GREEN	equ		2

	org 100h
	
	mov ax, VID_SEG
	mov es, ax
	
	mov bx, START_POS
citaj:	
	mov ah, 0
	int 16h

	mov dx, bx
	
	cmp al, 'w'
	je idi_gore
	
	cmp al, 's'
	je idi_dole
	
	cmp al, 'a'
	je idi_levo
	
	cmp al, 'd'
	je idi_desno
	
	cmp al, ASCII_ESC
	je kraj
	
	jmp citaj
	
idi_gore:
	sub bx, 160
	jmp iscrtaj
idi_dole:
	add bx, 160
	jmp iscrtaj
idi_levo:
	sub bx, 2
	jmp iscrtaj
idi_desno:
	add bx, 2
	jmp iscrtaj
	
iscrtaj:
	;brisanje prethodnog
	push bx
	mov bx, dx
	mov [es:bx], byte 0
	pop bx
	
	mov [es:bx], byte ASCII_SMILE
	inc bx
	mov [es:bx], byte VID_GREEN
	dec bx
	jmp citaj

kraj:
	ret