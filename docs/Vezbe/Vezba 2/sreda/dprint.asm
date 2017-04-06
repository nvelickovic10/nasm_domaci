
	org 100h
	
	mov ax, 0B800h
	mov es, ax
	
	mov bx, 160
	mov si, poruka
	
petlja:

	mov al, byte [si]
	
	cmp al, 0
	jz kraj
	
	mov byte [es:bx], al
	inc bx
	mov byte [es:bx], 02h
	inc bx
	inc si
	
	jmp petlja
	
kraj:
	ret
	
	
poruka: db 'Direktan upis u video memoriju',0
	