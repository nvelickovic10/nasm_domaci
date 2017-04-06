; ==================================================
; Vezba 1: primer1.asm
;    - Ispisivanje poruke na ekranu upotrebom DOS-a
;
; Prevodjenje:
;      nasm primer1.asm -f bin -o primer1.com
; ================================================== 

      org  100h

      mov  ah, 9       ; DOS funkcija za ispisivanje
      mov  dx, poruka  ; adresa poruke
      int  21h         ; DOS sistemski poziv
      ret

poruka: db 'Moj prvi program.$'
