
ASCII_ESC	equ		27

	org 100h
	
	mov dl, 00h
	mov ax, 0b800h
	mov es, ax
	
	mov bx, 560
	
petlja:
	mov ah, 0
	int 16h
	;al sadrzi procitano slovo
	
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
	
	jmp petlja
	
idi_gore:
	sub bx, 160
	jmp ispis
	
idi_dole:
	add bx, 160
	jmp ispis
	
idi_levo:
	sub bx, 2
	jmp ispis
	
idi_desno:
	add bx, 2
	jmp ispis
	
ispis:
	mov [es:bx], byte 1
	inc bx
	mov [es:bx], byte dl
	dec bx
	inc dl
	cmp dl, 10h
	je reset_col
	jmp petlja
	
reset_col:
	mov dl, 0h
	jmp petlja
	
kraj:
	ret
	
	
	
	
	
	
	
	
	
	
	
	
	
	
