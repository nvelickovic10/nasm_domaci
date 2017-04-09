; =====================================================
;    - Primer sa vezbi vezba4
;    - Testira rad nase prekidne rutine za prekid 1C
;    - postavlja alarm hendler na prekid 1C
;    - vrti se u petlji i ceka esc za kraj programa
; ===================================================== 

start_1c:
        mov     ax, [brzina]              ;pripremamo vrednosti [brzina] i [brojac]
        mov     [brojac], ax              ;da budu jednake
        call   _novi_1C                   ;pozivamo funkciju koja menja vektore prekida za prekid 1C sa default hendlera na nas

        call cls	

.ponovo:	
        mov     ah, 0                       ;BIOS funkcija za citanje sa tastature
        int     16h                         ;http://stanislavs.org/helppc/int_16.html
        
        cmp     al, ESC                     ;Procitani zanak je u AL. Da li je to Esc?
        je      .izlaz        
        jmp     .ponovo                     ;vrtimo se dok ne dodje esc

.izlaz:
        call   _stari_1C                  ;pozivamo funkciju koja menja vektore prekida za prekid 1C sa naseg hendlera na default
        ret                             

segment .data

brzina:  dw 18
; Elementarni kvant kasnjenja je 55ms, tako da se vrednost zadaje kao
; koeficijent koji mnozi ovaj kvant, za zeljeno kasnjenje u sekundama.
; Npr. za kasnjenje od 0,99s potrebno je zadati 18, a vrednosti 19
; daje kasnjenje od 1,045s. Znaci, tacno kasnjenje od 1s nije moguce postici.
; Vrednost 0 daje maksimalno kasnjenje (oko jedan sat).  