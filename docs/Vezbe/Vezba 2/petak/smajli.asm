
	org 100h
	
	mov ax, 0b800h
	mov es, ax
	
	mov bx, 320+80
	mov dx, bx
	
pocetak:
	;iscrtavanje

	push bx
	mov bx, dx
	mov [es:bx], byte 0
	pop bx
	
	mov [es:bx], byte 1
	inc bx
	mov [es:bx], byte 02h
	dec bx
	
	mov dx, bx
	
	mov ah, 0
	int 16h
	
	;procitani karakter se nalazi u al
	
	cmp al, 'w'
	je idi_gore
	
	cmp al, 's'
	je idi_dole
	
	cmp al, 'a'
	je idi_levo
	
	cmp al, 'd'
	je idi_desno
	
	cmp al, 27
	je kraj
	
	jmp pocetak
idi_gore:
	sub bx, 160
	jmp pocetak
	
idi_dole:
	add bx, 160
	jmp pocetak
	
idi_levo:
	sub bx, 2
	jmp pocetak
	
idi_desno:
	add bx, 2
	jmp pocetak
	
kraj:
	ret