; =====================================================
; test_tsr.asm
;    - Instalira TSR rutinu i zavrsava se
; ===================================================== 

KBD equ 60h

org 100h

main:
        call   _novi_09
        mov dx, 00FFh
        mov ah, 31h
        int 21h
        
        ;ret

; Sacuvati originalni vektor prekida 0x1C, tako da kasnije mozemo da ga vratimo
_novi_09:
	cli
	xor ax, ax
	mov es, ax
	mov bx, [es:09h*4]
	mov [old_int_off], bx 
	mov bx, [es:09h*4+2]
	mov [old_int_seg], bx

; Modifikacija u tabeli vektora prekida tako da pokazuje na nasu rutinu
	mov dx, tast_int
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
	mov ax, [old_int_seg]
	mov [es:09h*4+2], ax
	mov dx, [old_int_off]
	mov [es:09h*4], dx
	sti
	ret


tast_int:
	pusha

; Obrada tastaturnog prekida 
	in al, KBD
	mov bx, 0B800h
	mov es, bx
	mov bx, 460
	cmp al, 3Bh
	je .f1
	cmp al, 3Ch
	je .f2
	jmp izlaz
.f1:
	mov [es:bx], byte '1'
	inc bx
	mov [es:bx], byte 2
	jmp izlaz
.f2:
	mov [es:bx], byte '2'
	inc bx
	mov [es:bx], byte 2
	jmp izlaz
izlaz:
	popa
	
	push word [cs:old_int_seg]
	push word [cs:old_int_off]
	retf
	;iret

old_int_seg: dw 0
old_int_off: dw 0
brojac:	dw 0

