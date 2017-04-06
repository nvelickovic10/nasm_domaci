
	org 100h
	
	mov ax, 0B800h
	mov es, ax
	
	mov bx, 320
	
	mov si, poruka
	
petlja:
	mov al, byte [si]
	cmp al, 0
	je kraj
	
	mov [es:bx], al
	inc bx
	mov [es:bx], byte 02h
	inc bx

	inc si
	
	jmp petlja
	
kraj:
	ret
	
	
poruka: db 'Ispis u video memoriju',0
	