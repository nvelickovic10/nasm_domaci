; =====================================================
;    - Primer sa vezbi vezba4
;    - Testira rad nase prekidne rutine za prekid 1C
;    - postavlja alarm hendler na prekid 1C
;    - vrti se u petlji i ceka esc za kraj programa
; ===================================================== 

start_interupts:
        mov     ax, [brzina]              ;pripremamo vrednosti [brzina] i [brojac]
        mov     [brojac], byte 1          
        call   _novi_1C                   ;pozivamo funkciju koja menja vektore prekida za prekid 1C sa default hendlera na nas
        call   _novi_09                   ;pozivamo funkciju koja menja vektore prekida za prekid 09 sa default hendlera na nas

        call cls

.cekaj_na_kraj:                           ;cekaj na kraj
        cmp [exit_state], byte 1          ;ceka dok neko ne postavi exit_state na 1, to moze ili kada pordje 10 sekundi u snooze stateu ili na esc u tast+hen
        je stop_interupts
        jmp .cekaj_na_kraj

stop_interupts:
        call   _stari_1C                  ;pozivamo funkciju koja menja vektore prekida za prekid 1C sa naseg hendlera na default
        call   _stari_09                  ;pozivamo funkciju koja menja vektore prekida za prekid 09 sa naseg hendlera na default
        ret                             

segment .data

snooze_state: db 0                          ;fleg da li smo u snooze state (odnosno onih 10 sekundi kada mozemo da produzimo alarm)
exit_state: db 0                            ;fleg da li mozemo da izadjemo iz programa

brzina:  dw 18
; Elementarni kvant kasnjenja je 55ms, tako da se vrednost zadaje kao
; koeficijent koji mnozi ovaj kvant, za zeljeno kasnjenje u sekundama.
; Npr. za kasnjenje od 0,99s potrebno je zadati 18, a vrednosti 19
; daje kasnjenje od 1,045s. Znaci, tacno kasnjenje od 1s nije moguce postici.
; Vrednost 0 daje maksimalno kasnjenje (oko jedan sat).  