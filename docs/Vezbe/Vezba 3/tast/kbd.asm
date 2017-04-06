; ==================================================
; kbd.asm
;    - Modifikovani scan.asm koji demonstrira
;      konverziju scan_code u ASCII upotrebom
;      (nepotpune) translacione tabele
; ================================================== 

org 100h
segment .code

NULL           equ 000h
ESC            equ 001h                     ; Obratiti paznju da je ovo scan_code (nije ASCII, tj. ovde ESC nije 1Bh)  
KBD            equ 060h                     ; U/I registar u koji se upisuje scan_code koji stize sa mikroprocesora 8048  
EOI            equ 020h                     ; Nespecificna EOI komanda za zavrsetak obrade prekida
Master_8259    equ 020h                     ; Slave_8259 je na U/I adresi 0A0h

L_SHIFT_DN     equ 02Ah                     ; Napomena: Za svaki taster, scan_code moze se dobiti upotrebom scan.asm
R_SHIFT_DN     equ 036h
L_SHIFT_UP     equ 0AAh
R_SHIFT_UP     equ 0B6h

main:
    call   _cls
    mov     si, poruka1
    call   _print
    call   _inst_09	
    call    print_taster
    call   _uninst_09
    mov     si, poruka2
    call   _print
	ret				
                    
; ------------------------------------------------------------------------
; Nasa rutina za obradu prekida 09h
tastatura:	                     
    push    ax			            
    in      al, KBD                         ; Ucitati scan_code iz I/O registra tastature  
    mov	   [kbdata], al
    call    shift_test
    mov     al, EOI                         ; Kod za End Of Interrupt (EOI)
    out	    Master_8259, al                 ; Poslati EOI na Master PIC (dozvola novih prekida)
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
    
;--------------------------------------------------------------------------------------------
; Ako je bilo promene u tasterima LEFT-SHIFT ili RIGHT-SHIFT,
; postavlja se ZF indikator (flag)

shift_test:
    cmp     al, L_SHIFT_DN                  ; Da li je pritisnut LEFT-SHIFT?
    je      ls_pritisnut                           
    cmp     al, L_SHIFT_UP                  ; Da li je otpusten LEFT-SHIFT?
    je      ls_otpusten                           
    cmp     al, R_SHIFT_DN                  ; Da li je pritisnut RIGHT-SHIFT?
    je      rs_pritisnut                        
    cmp     al, R_SHIFT_UP                  ; da li je otpusten RIGHT-SHIFT?
    je      rs_otpusten                          
	jmp     nije_shift                      ; Nista od prethodnog 

ls_pritisnut:	
    bts word [KBFLAGS], 0                   ; Postavi bit 0 u KBFLAGS
    jmp	    jeste_shift				
ls_otpusten:	
    btr word [KBFLAGS], 0                   ; Resetuj bit 0 u KBFLAGS
    jmp	    jeste_shift
rs_pritisnut:	
    bts word [KBFLAGS], 1                   ; Postavi bit 1 u KBFLAGS
    jmp	    jeste_shift
rs_otpusten:	
    btr word [KBFLAGS], 1                   ; Resetuj bit 1 u KBFLAGS
jeste_shift:	
    xor     al, al                          ; Postavi ZF indikator 
nije_shift:	
    ret	                                    ; Zadrzi ZF kakav je bio
  
; ------------------------------------------------------------------------------------------- 
print_taster:
pocetak:
    cmp byte [kbdata],NULL
    je      pocetak
    cmp byte [kbdata],ESC
    je      izlaz
    mov     al, [kbdata]
    mov     ah, al
    and     ah, 080h                        ; Proveravamo da li je scan_code za otpusteni taster
    jnz     odbaci                          ; Ako jeste, ne stampamo ga na ekranu
    cmp byte [kbdata],L_SHIFT_DN            ; Da li je zaostao scan_code za pritisnuti Shift?
    je      odbaci
    cmp byte [kbdata],R_SHIFT_DN
    je      odbaci
    mov	    bx, mala_slova	                ; Pocetak translacione tabele (DS je tekuci segment)
    test word [KBFLAGS], 03h                ; Da li je levi ili desni Shift pritisnut?
    jz	    mala			            
    mov	    bx, velika_slova                ; Pocetak translacione tabele kada je pritisnut Shift 		
mala:	

; Instukcija XLAT
; ------------------
; Translacija upotrebom memorijske tabele.
; Vrednost koju treba translirani nalazi se u AL.
; Rezultat translacije nalazi se takodje u AL.
; Pocetak tabele u memoriji odredjen je sadrzajem DS:BX. 
   
    xlat			               
    mov	    ah, 0Eh	                        ; Stampaj ASCII vrednost iz tabele	      
    int	    10h	
    cmp     al, 0Dh                         ; Da li je pritisnut Enter?
    jne     odbaci
    mov     al, 0Ah                         ; Ako jeste, idi u novi red
    int     10h
odbaci:
    xor     ax, ax
    mov     [kbdata], al
    jmp     pocetak
izlaz:
    ret

   
 ;-------------------------------------------------------------------------------------------
; Redukovana tabela za translaciju scan_code u ASCII
velika_slova:
    db  0, 27
    db  '!@#$%^&*()_+'
    db  8, 9
    db  'QWERTYUIOP{}'
    db  13, 0
    db  'ASDFGHJKL:"~'
    db  0
    db  '|ZXCVBNM<>?'
    db  0, 0, 0, 32
    times 70 db 0
    
mala_slova:
    db  0, 27
    db  '1234567890-='
    db  8, 9
    db  'qwertyuiop[]'
    db  13, 0
    db  'asdfghjkl;', 027h,'`'
    db  0
    db  '\zxcvbnm,./'
    db  0, 0, 0, 32
    times 70 db 0  

;--------------------------------------------------------------------------------------------
stari_int09_seg: dw 0
stari_int09_off: dw 0

KBFLAGS:    db 0        ; Indikatori o stanju nekih kontrolnih tastera
kbdata:	    db 0        ; scan_code iz registra KBD (binarna vrednost pristigla sa tastature)
poruka1:    db 'Ulazak u nasu prekidnu rutinu za obradu tastature. ',0Ah, 0Dh
            db 'Za kraj pritisnuti ESC.', 0Ah, 0Ah, 0Dh, 0
poruka2:    db 0Ah, 0Ah, 0Dh,'Povratak u originalnu BIOS prekidnu rutinu.', 0Ah, 0Dh, 0		
;--------------------------------------------------------------------------------------------

%include "ekran.asm"