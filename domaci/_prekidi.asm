; ==================================================
;   - Ovo je primer sa vezbi, sve je jasno...
;    - Cuvanje starih vektora prekida
;    - Postavljanje novih vektora prekida
;      koji ukazuju na nase prekidne rurine
; ================================================== 

segment .code

; Sacuvati originalni vektor prekida 0x1C, tako da kasnije mozemo da ga vratimo
_novi_1C:
	cli
	xor ax, ax
	mov es, ax
	mov bx, [es:1Ch*4]
	mov [old_int_off_time], bx 
	mov bx, [es:1Ch*4+2]
	mov [old_int_seg_time], bx

; Modifikacija u tabeli vektora prekida tako da pokazuje na nasu rutinu
	mov dx, timer_hen
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
	mov ax, [old_int_seg_time]
	mov [es:1Ch*4+2], ax
	mov dx, [old_int_off_time]
	mov [es:1Ch*4], dx
	sti
	ret

; Sacuvati originalni vektor prekida 0x09, tako da kasnije mozemo da ga vratimo
_novi_09:
	cli
	xor ax, ax
	mov es, ax
	mov bx, [es:09h*4]
	mov [old_int_off_tast], bx 
	mov bx, [es:09h*4+2]
	mov [old_int_seg_tast], bx

; Modifikacija u tabeli vektora prekida tako da pokazuje na nasu rutinu
	mov dx, tast_hen
	mov [es:09h*4], dx
	mov ax, cs
	mov [es:09h*4+2], ax
	sti         
	ret


; Vratiti stari vektor prekida 0x09
_stari_09:
	cli
	xor ax, ax
	mov es, ax
	mov ax, [old_int_seg_tast]
	mov [es:09h*4+2], ax
	mov dx, [old_int_off_tast]
	mov [es:09h*4], dx
	sti
	ret

segment .data

old_int_seg_time: dw 0
old_int_off_time: dw 0

old_int_seg_tast: dw 0
old_int_off_tast: dw 0
