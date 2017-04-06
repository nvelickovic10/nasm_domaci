; ===========================================================
; COM.asm
;   - Nakon prevodjenja ime izvrsne datoteke bice startup.com
;   - Za testiranje preko boot sektora potrebno je promeniti
;     ekstenziju tako da ime bude startup.bin
; =========================================================== 

segment .code

        org	100h

        mov    si, poruka
        call  _print
      
        ; Prikazi trenutni sadrzaj registara
        mov     ax, cs
        call    print_reg
        mov     ax, ds
        call    print_reg
        mov     ax, es
        call    print_reg
        mov     ax, ss
        call    print_reg
        mov     ax, sp
        call    print_reg

        jmp     short $         ; Vrtimo se u beskonacnoj petlji, jer u ovom slucaju nemamo gde da idemo

 print_reg:       
         mov    cx, 4
         mov    dx, hex_vrednost
         call   bin2hex2
         mov    si, hex_vrednost
         call  _print
         mov    si, prazno
         call  _print
         ret
   

hex_vrednost:   db "0000",0
poruka:	        db 13,10,10,10,'Primer jednostavnog COM programa.',13,10,10
                db 'CS:  DS:  ES:  SS:  SP:',13,10,0

%include "bin2hex2.asm"
%include "ekran.asm"