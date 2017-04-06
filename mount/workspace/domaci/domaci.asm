ESC  equ  1bh                               ; ASCII kod za Esc taster
ENT  equ  0dh                               ; ASCII kod za Esc taster

org 100h

segment .code

main:   cld
        mov     cx, 0080h                   ; Maksimalni broj izvrsavanja instrukcije sa prefiksom REPx
        mov     di, 81h                     ; Pocetak komandne linije u PSP.
        mov     al, ' '                     ; String uvek pocinje praznim mestom (razmak izmedju komande i parametra) 
repe    scasb                               ; Trazimo prvo mesto koje nije prazno (tada DI pokazuje na lokaciju iza njega)
        dec     di                          ; Vracamo DI da pokazuje gde treba
        mov     si, di                      ; Pocetak stringa u SI
        mov     al, 0dh                     ; Trazimo kraj stringa (pritisnut Enter)
repne   scasb                               ; (tada DI pokazuje na lokaciju iza njega) 
        mov byte [di-1], 0                  ; string zavrsavamo nulom

        mov     si, sati
        call    _print

%include "ekran.asm"


segment .data

init_text:      db 'Inicijalizacija...', 0

sati:   dw 15, 0