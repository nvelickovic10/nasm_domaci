
	org 100h
	
ASCII_W		equ		119
ASCII_A		equ		97
ASCII_S		equ		115
ASCII_D		equ		100
ASCII_ESC	equ		27

START_POS	equ		640+80
V_SEG		equ		0B800h
GREEN		equ		02h
ASCII_SMILE	equ		01
	
	mov ax, V_SEG
	mov es, ax
	
	mov bx, START_POS		;pocetna pozicija
	
citanje:
	mov ah, 0
	int 16h					;al sadrzi procitani bajt
	
	cmp al, ASCII_W			;pritisnuto w?
	je idi_gore
	
	cmp al, ASCII_A			;pritisnuto a?
	je idi_levo
	
	cmp al, ASCII_S			;pritsnuto s?
	je idi_dole
	
	cmp al, ASCII_D			;pritisnuto d?
	je idi_desno
	
	cmp al, ASCII_ESC		;pritisnuto ESC?
	je kraj
	
	jmp citanje
idi_gore:
	sub bx, 160
	jmp iscrtavaj
	
idi_levo:
	sub bx, 2
	jmp iscrtavaj
	
idi_dole:
	add bx, 160
	jmp iscrtavaj
	
idi_desno:
	add bx, 2
	jmp iscrtavaj
	
iscrtavaj:
	mov al, byte ASCII_SMILE
	mov byte [es:bx], al
	inc bx
	mov byte [es:bx], GREEN
	dec bx
	jmp citanje

kraj:
	ret
	