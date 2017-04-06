; =======================================================
; bootsec.asm
;    - Izgled startnog zapisa od 512 bajtova na disketi
;      nepoznatog formata
;    - Demonstrira upotrebu pseudoinstrukcije TIMES
;
;    - Mora da se koristi na realnom sistemu sa disketom.
;      VMware virtuelna masina ga ne podrzava !
; ======================================================= 

        org 7c00h           ; Adresa odakle BIOS INT 19h ucitava prvih 512 bajtova 
                            ; i zatim mu predaje kontrolu 
        mov   si, poruka
        call _print
        jmp   $

; Ispisivanje poruke na ekranu upotrebom BIOS-a
; Ne koristimo %include "ekran.asm" jer bi to
; verovatno bilo vise od 512 bajtova (zbog CLS i slicno) 
; -------------------------------------------------------
_print:
        push ax
        cld
.prn:
        lodsb                 ; Ucitavati znakove sve do nailaska prve nule
        or   al,al     
        jz  .end              ; Kraj stringa
        mov  ah,0eh           ; BIOS 10h: ah = 0eh (Teletype Mode), al = znak koji se ispisuje
        int  10h              ; BIOS prekid za rad sa ekranom
        jmp .prn     
.end:
        pop  ax
        ret       

poruka: 	
        db '(c) 2010. Racunarski fakultet, Beograd.', 0ah, 0dh
        db '          08.2008. Operativni sistemi.', 0ah, 0dh
        db '          Primer startnog zapisa.', 0 
		
        times 510- ($-$$) db 0    ; Popuniti ostatak sektora nulama
        dw  0aa55h                ; Magicni broj na kraju startnog zapisa

