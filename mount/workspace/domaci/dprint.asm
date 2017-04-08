
	org 100h
	
	mov ax, 0B800h
	mov es, ax
	
	mov bx, 160 ;160 je duzina jedne linije na ekranu 80 karaktera i 80 boja
	mov si, poruka
	
petlja:

	mov al, byte [si]
	
	cmp al, 0
	jz kraj
	
	mov byte [es:bx], al ;karakter
	inc bx
	mov byte [es:bx], 05h ;boja
	inc bx
	inc si
	
	jmp petlja
	
kraj:
	ret
	
	
poruka: db 'Direktan upis u video memoriju',0
	