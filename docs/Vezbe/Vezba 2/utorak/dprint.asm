
	org 100h
	
	mov ax, 0B800h
	mov es, ax
	
	
	mov bx, 320
	mov si, poruka
	
ispis:
	mov al, byte [si]
	
	cmp al, 0
	je kraj
	
	mov byte [es:bx], al
	inc bx
	mov [es:bx], byte 05h
	inc bx
	
	inc si
	
	jmp ispis
	
kraj:
	ret
	
poruka: db 'Ispis u video memoriji',0