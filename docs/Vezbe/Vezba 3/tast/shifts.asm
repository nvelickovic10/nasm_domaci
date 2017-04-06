;---------------------------------------
;Prikazuje rad svih operatora pomeranja
;
;Izuzetak je sal, koji ne menja vrednost
;najznacajnijeg bita.
;---------------------------------------
    org 100h
	
segment .code

_main:
	call  .print_1
    mov   al, 81h
	call  .print_bin_newline
	sar   al, 1
	call  .print_bin_newline
	
	call  .print_2
    mov   al, 0C3H
	call  .print_bin_newline
	sar   al, 1
	call  .print_bin_newline
	
	call  .print_3
    mov   al, 81h
	call  .print_bin_newline
	shr   al, 1
	call  .print_bin_newline
	
	call  .print_4
    mov   al, 0C3H
	call  .print_bin_newline
	shr   al, 1
	call  .print_bin_newline
	
	call  .print_5
    mov   al, 81h
	call  .print_bin_newline
	sal   al, 1
	call  .print_bin_newline
	
	call  .print_6
    mov   al, 0C3H
	call  .print_bin_newline
	sal   al, 1
	call  .print_bin_newline
	
	call  .print_7
    mov   al, 81h
	call  .print_bin_newline
	shl   al, 1
	call  .print_bin_newline
	
	call  .print_8
    mov   al, 0C3H
	call  .print_bin_newline
	shl   al, 1
	call  _print_bin
	
	ret

.print_bin_newline:
    call _print_bin
	call .print_newline
	ret
.print_newline:
    push  dx
	mov   dx, CR_LF
	call  .print_msg
	pop   dx
	ret
.print_1:
    push  dx
	mov   dx, poruka_1
	call  .print_msg
	pop   dx
	ret
.print_2:
    push  dx
	mov   dx, poruka_2
	call  .print_msg
	pop   dx
	ret
.print_3:
    push  dx
	mov   dx, poruka_3
	call  .print_msg
	pop   dx
	ret
.print_4:
    push  dx
	mov   dx, poruka_4
	call  .print_msg
	pop   dx
	ret
.print_5:
    push  dx
	mov   dx, poruka_5
	call  .print_msg
	pop   dx
	ret
.print_6:
    push  dx
	mov   dx, poruka_6
	call  .print_msg
	pop   dx
	ret
.print_7:
    push  dx
	mov   dx, poruka_7
	call  .print_msg
	pop   dx
	ret
.print_8:
    push  dx
	mov   dx, poruka_8
	call  .print_msg
	pop   dx
	ret
.print_msg:                       ;ocekuje da se u dx nalazi adresa teksta, terminisanog $
    push  ax
	mov   ah, 9
	int   21h
	pop   ax
	ret
	

%include "printbin.asm"

segment .data
CR_LF: db 0aH, 0dH, '$'	
poruka_1: db 'Izvrsavam SAR nad 81h', 0ah, 0dh, '$'
poruka_2: db 'Izvrsavam SAR nad C3h', 0ah, 0dh, '$'
poruka_3: db 'Izvrsavam SHR nad 81h', 0ah, 0dh, '$'
poruka_4: db 'Izvrsavam SHR nad C3h', 0ah, 0dh, '$'
poruka_5: db 'Izvrsavam SAL nad 81h', 0ah, 0dh, '$'
poruka_6: db 'Izvrsavam SAL nad C3h', 0ah, 0dh, '$'
poruka_7: db 'Izvrsavam SHL nad 81h', 0ah, 0dh, '$'
poruka_8: db 'Izvrsavam SHL nad C3h', 0ah, 0dh, '$'