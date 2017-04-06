; ==================================================
; Prekidi.asm
;    - Cuvanje starih vektora prekida
;    - Postavljanje novih vektora prekida
;      koji ukazuju na nase prekidne rurine
;
; ================================================== 

segment .code

; Sacuvati originalni vektor prekida 0x1C, tako da kasnije mozemo da ga vratimo
_novi_1C:
	cli
	xor ax, ax
	mov es, ax
	mov bx, [es:1Ch*4]
	mov [old_int_off], bx 
	mov bx, [es:1Ch*4+2]
	mov [old_int_seg], bx

; Modifikacija u tabeli vektora prekida tako da pokazuje na nasu rutinu
	mov dx, timer_int
	mov [es:1Ch*4], dx
	mov ax, cs
	mov [es:1Ch*4+2], ax
	push ds		; sacuvati sadrazaj DS jer ga INT 0x08 menja u DS = 0x0040
	pop gs		; (BIOS Data Area) i sa tako promenjenim DS poziva INT 0x1C
	sti         
	ret


; Vratiti stari vektor prekida 0x1C
_stari_1C:
	cli
	xor ax, ax
	mov es, ax
	mov ax, [old_int_seg]
	mov [es:1Ch*4+2], ax
	mov dx, [old_int_off]
	mov [es:1Ch*4], dx
	sti
	ret


timer_int:
	pusha

; Obrada tajmerskog prekida 
	dec word [brojac]
	jnz izlaz
	inc  byte [var]		
	mov ax, [vrednost]
	mov [brojac], ax
    mov si, var
	call _print

izlaz:
	popa  	
	iret

segment .data

old_int_seg: dw 0
old_int_off: dw 0
brojac:	dw 0
