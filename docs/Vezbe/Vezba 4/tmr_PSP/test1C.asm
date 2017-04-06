; =====================================================
; test1C.asm
;    - Testira rad nase prekidne rutine za prekid 1C
;    - Demonstrira ukljucenje drugih programskih modula
; ===================================================== 

ESC  equ  1bh                               ; ASCII kod za Esc taster 

org 100h
segment .code

main:
        mov     ax, [vrednost]
        mov     [brojac], ax
        call   _novi_1C
        mov  byte [var], 40h                ; ASCII kod za A
        mov     si, init_text
        call   _print	

ponovo:	
        mov     ah, 0                       ; BIOS funkcija za citanje sa tastature
        int     16h          
        cmp     al, ESC                     ; Procitani zanak je u AL. Da li je to Esc?
        je      .izlaz        
        jmp     ponovo
.izlaz:
        call   _stari_1C
        ret

%include "prekidi.asm"
%include "ekran.asm"

segment .data

init_text: db 'Inicijalizacija... ', 0x0A,0x0D,0
var:       db 0,0
vrednost:  dw 20
; Elementarni kvant kasnjenja je 55ms, tako da se vrednost zadaje kao
; koeficijent koji mnozi ovaj kvant, za zeljeno kasnjenje u sekundama.
; Npr. za kasnjenje od 0,99s potrebno je zadati 18, a vrednosti 19
; daje kasnjenje od 1,045s. Znaci, tacno kasnjenje od 1s nije moguce postici.
; Vrednost 0 daje maksimalno kasnjenje (oko jedan sat).  