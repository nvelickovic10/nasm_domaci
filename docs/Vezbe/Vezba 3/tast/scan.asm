; ==================================================
; scan.asm
;    - Demonstrira upotrebu mehanizma prekida
;      za nebaferisanu ulaznu operaciju sa tastatue
;    - Upotreba PIC 8259, linija IRQ1* (INT 09h) 
; ================================================== 

org 100h
segment .code

NULL           equ 000h
ESC            equ 001h			; Obratiti paznju da je ovo scan_code (nije ASCII, tj. ovde ESC nije 1Bh)  
KBD            equ 060h			; U/I registar u koji se upisuje scan_code
								; koji stize sa mikroprocesora 8048  
EOI            equ 020h			; Nespecificna EOI komanda za zavrsetak obrade prekida
Master_8259    equ 020h			; Napomena: Slave_8259 je na U/I adresi 0A0h

main:
    call   _cls
    mov     si, poruka1
    call   _print
    call   _inst_09	
    call    stampaj_scan_code
    call   _uninst_09
    mov     si, poruka2
    call   _print
	ret

    
; ------------------------------------------------------------------------
; Nasa rutina za obradu prekida 09h
tastatura:	                     
    push    ax			            
    in      al, KBD				; Ucitati scan_code iz I/O registra tastature  
    mov	   [kbdata], al
    mov     al, EOI				; Kod za End Of Interrupt (EOI)
    out	    Master_8259, al		; Poslati EOI na Master PIC (dozvola novih prekida)
    pop	    ax
    iret				

; ------------------------------------------------------------------------   
_inst_09:
    cli
    xor     ax, ax
    mov     es, ax
    mov     bx, [es:09h*4]
    mov     [stari_int09_off], bx 
    mov     bx, [es:09h*4+2]
    mov     [stari_int09_seg], bx

; Modifikacija u tabeli vektora prekida tako da pokazuje na nasu rutinu
    mov     dx, tastatura
    mov     [es:09h*4], dx
    mov     ax, cs
    mov     [es:09h*4+2], ax
    sti
    ret

; ------------------------------------------------------------------------
_uninst_09:
    cli
    xor     ax, ax
    mov     es, ax
    mov     ax, [stari_int09_seg]
    mov     [es:09h*4+2], ax
    mov     dx, [stari_int09_off]
    mov     [es:09h*4], dx
    sti
    ret

;------------------------------------------------------------------------- 
stampaj_scan_code:
pocetak:
    cmp  byte [kbdata],NULL
    je      pocetak
    cmp	 byte [odbaci], 1
	je   prvi
	cmp  byte [kbdata],ESC
    je      izlaz

cekaj:                                      ; Deo programa koji eliminise visestruko stampanje scan_code 
    mov byte al, [autorepeat]               ; pritisnutog tastera kada se aktivira autorepeat (typematic)
    cmp byte al, [kbdata]                   ; Ovo ne sprecava pojavu prekida 09h kod svakog autorepeata!
    je      cekaj                           ; Cekamo da se otpusti taster
    mov byte al, [kbdata]                   ; Napomena: Ovo ne funkcionise kod tastera koji ima scan_code
    mov byte [autorepeat], al               ;           sa prefiksom (tj. koji je duzi od jednog bajta). 
    
    not  byte [par]
    mov     al, [kbdata]
    mov     cx, 2
    mov     dx, s_code+1
    call    bin2hex
    mov     si, s_code
    call   _print
    cmp  byte [par], NULL                   ; Enter iza svakog drugog, tako da se Up i Dn 
    jne     nepar                           ; ispisuju u istom redu, u paru
    mov     si, CR_LF
    call   _print
 nepar:
    xor     ax, ax
    mov     [kbdata], al
    jmp     pocetak
 prvi:
    mov		[odbaci], byte 0
	jmp		nepar
 izlaz:
    ret

;-------------------------------------------------------------------------------------
stari_int09_seg: dw 0
stari_int09_off: dw 0

odbaci:		db 1
kbdata:	    db 0                            ; scan_code iz registra KBD (binarna vrednost pristigla sa tastature)
par:        db 0	                        ; par/nepar indikator
autorepeat: db 0                            ; sadrzi prethodnu vrednost scan_code
s_code:     db ' ', 0, 0, 0                 ; scan_code - hex vrednost            
CR_LF:      db 0Ah, 0Dh, 0                  ; novi red
poruka1:    db 'Ulazak u nasu prekidnu rutinu za obradu tastature. ',0Ah, 0Dh
            db 'Za kraj pritisnuti ESC.', 0Ah, 0Ah, 0Dh
            db ' Dn Up', 0Ah, 0Dh
            db ' -----', 0Ah, 0Dh, 0
poruka2:    db 0Ah, 0Dh,'Povratak u originalnu BIOS prekidnu rutinu.', 0Ah, 0Dh, 0		
;-------------------------------------------------------------------------------------

%include "bin2hex.asm"
%include "ekran.asm"