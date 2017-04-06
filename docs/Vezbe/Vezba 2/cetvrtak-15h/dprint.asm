
VID_SEG			equ		0B800h
START_POS		equ		320
PROGRAM_START	equ		100h
COLOR			equ		02h

STRING_TERM		equ		0

	org PROGRAM_START
	
	;mov es, VID_SEG
	mov ax, VID_SEG
	mov es, ax

	mov bx, START_POS
	
	mov si, poruka
	
petlja:
	mov al, byte [si]
	
	cmp al, STRING_TERM
	je kraj
	
	mov [es:bx], al
	inc bx
	mov [es:bx], byte COLOR
	inc bx
	
	inc si
	
	
	jmp petlja

kraj:
	ret
	
poruka: db 'Direktan upis u video memoriju.',STRING_TERM