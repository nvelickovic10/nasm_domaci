
VID_SEG		equ		0b800h
START_POS	equ		320
STR_TERM	equ		0
VID_GREEN	equ		02h
PROG_START	equ		100h

	org PROG_START
	
	;moramo zaobilazno da smestimo vednost u es
	mov ax, VID_SEG
	mov es, ax
	
	mov bx, word START_POS
	
	mov si, poruka
petlja:
	mov al, byte [si]   ;citamo bajt sa adrese na koju pokazuje si
	
	cmp al, STR_TERM
	je izlaz
	
	mov [es:bx], al
	inc bx
	mov [es:bx], byte VID_GREEN
	inc bx
	
	inc si
	
	jmp petlja
	
izlaz:
	ret
	
poruka: db 'Direktan upis u video memoriju',STR_TERM