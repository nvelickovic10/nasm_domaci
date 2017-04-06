; ==========================================================
; EXE.asm
;   - Nakon prevodjenja i linkovanja ime izvrsne datoteke
;     bice startup.exe
;   - Za testiranje preko boot sektora potrebno je promeniti
;     ekstenziju tako da ime bude startup.bin
; =========================================================== 
segment .code 

..start:                         ; Labela ..start je rezervisana za objektni modul u kome je pocetak
                                 ; izvrsnog programa, kada se linkuje vise objektnih modula.
        mov     ax, data         ; DS i ES moramo da inicijalizujemo odmah nakon pocetka izvrsavanja
        mov     ds, ax           ; jer oni nakon ucitavanja EXE programa sadrze adresu PSP. 
        mov     es, ax           ; CS, SS i SP su inicijalizovani prilikom ucitavanja (pre izvrsavanja).
        mov     si, poruka
        call   _print

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
  
        jmp     $               ; Vrtimo se u beskonacnoj petlji, jer u ovom slucaju nemamo gde da idemo
          
 print_reg:       
         mov    cx, 4
         mov    dx, hex_vrednost
         call   bin2hex2
         mov    si, hex_vrednost
         call  _print
         mov    si, prazno
         call  _print
         ret
  

  
segment data
hex_vrednost:   db "0000",0
nil:            times 4960 db 0       ; da bismo bili sigurni da se i duze datoteke ucitavaju normalno
poruka:         db 13,10,10,10,'Primer jednostavnog EXE programa.',13,10,10
                db 'CS:  DS:  ES:  SS:  SP:',13,10,0


; Za datoteku tipa EXE neophodno je definisati stack segment
; Linker ce informacije o steku upisati u zaglavlje EXE programa (bajtovi na lokacijama 0Eh do 11h)
; Program za ucitavanje ce ove informacije upisati u SS i SP pre nego sto predje na izvrsavanje
segment stack stack     ; prvo "stack" je ime segmenta, a drugo "stack" je vrsta segmenta
        resb 4096       ; Ukoliko ne definisemo vrstu segmenta, neki linkeri nece pravilno
                        ; inicalizovati stek (poruka "Warning: no stack")   
                 
%include "bin2hex2.asm"
%include "ekran.asm"
