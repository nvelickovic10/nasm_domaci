; ==================================================
; Vezba 1: primer2.asm
;    - Unosenje znaka sa tastature upotrebom BIOS-a
;    - Ispisivanje tog znaka na ekranu upotrebom BIOS-a
;    - Provera da li je pritisnut kontrolni taster,
;      radi zavrsetka programa
;
; Prevodjenje:
;      nasm primer2.asm -f bin -o primer2.com
; ================================================== 

ESC  equ  1bh          ; ASCII kod za Esc taster 

     org  100h
citaj:     
     mov  ah, 0        ; BIOS funkcija za citanje sa tastature
     int  16h          ; BIOS prekid za rad sa tastaturom
     cmp  al, ESC      ; Procitani znak je u AL. Da li je to Esc?
     je   izlaz        ; Ako jeste, zavrsi sa radom
     mov  ah, 0eh      ; BIOS funkcija za ispisivaje znaka iz AL
     int  10h          ; BIOS prekid za rad sa ekranom
     jmp  citaj
izlaz:     
     ret              
