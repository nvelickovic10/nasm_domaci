;==================================================
; Registrovanje naseg hendlera za interapt 1C (user time interapt), 
; KOMPAJLIRANJE: nasm domaci.asm -f bin -o domaci.com
; POKRETANJE: domaci.com -start HH:MM:SS
;==================================================

ESC equ 1bh                                 ; ASCII kod za Esc taster
AKY equ 61h                                 ; ASCII kod za Esc taster
ENT equ 0dh                                 ; ASCII kod za Ent taster
SEP equ 25h                                 ; ASCII kod za $ (terminator)
SPA equ 20h                                 ; ASCII kod za Space taster
KBD equ 60h                                 ; Tastatura adresa za citanje vrednosti sa tastature (in al, KBD)

org 100h

segment .code
main:
  call cls                          ;obrisi ceo ekran

  call get_args                     ;parsiraj argumente komandne linije (izlaz su [command] i [time])

  mov si, command                   ;provera da li je uneta komanda == -start
  mov di, komanda_start             ;ulazi za sompare string su di i si
  call compare_strings              ;compare_string (proveravamo sadrzaj command i komanda_start da li su jednaki)
  cmp al, 1                         ;compare_string u registru ax vraca vrednost 1 ako su jednaki stringovi
  je .start_timer

  mov si, command                   ;provera da li je uneta komanda == -stop
  mov di, komanda_stop
  call compare_strings
  cmp al, 1
  je .stop_timer

.badargs:
  mov si, msg_badargs               ;nije prepoznata komanda, ispisujemo poruku 'losi argmenti'
  jmp .end                          ;zavrsavamo program ako nismo prepoznali komandu

.start_timer:
  call check_time_format            ;provera da li je vreme uneto u dobrom formatu HH:MM:SS
  cmp al, 1
  jne .badargs                      ;ako nije ispisi poruku

  ;call start_tsr                   ;tsr verzija (under construction...) NE RADI
  call start_interupts              ;pokretanje promene vektora prekida za interapt 1C
  mov si, easter_egg
  jmp .end

.stop_timer:
  mov si, msg_stop                  ;lol ovo bi imalo smisla sa tsr

.end:
  call cls
  call print                        ;ispisati poslednju poruku
  ret                               ;kraj programa (svega)

segment .data
  empty: db '                                    ',SEP
  command: db '      ',SEP                          ;get_args ucitava vrednost na ovu adresu
  time: db 'HH:MM:SS',SEP                           ;get_args ucitava vrednost na ovu adresu

  komanda_start: db '-start',SEP                    ;string koji koristimo za proveru komande, da li je -start
  komanda_stop: db '-stop',SEP                      ;ili -stop
  
  current_time: db 'HH:MM:SS',SEP                   ;get_time ucitava vrednost na ovu adresu

  easter_egg: db 'mulT kill!!', SEP                   ;poruka za kraj

  msg_badargs: db 'ne valjaju argumenti',SEP        ;poruke koje ispisujemo na ekranu
  msg_start: db 'starting timer',SEP
  msg_stop: db 'stopping timer',SEP
  timer_stop: db 'BANG!!!',SEP
  msg_snooze: db 'SNOOZE (F1)',SEP

                                                    ;ukljucivanje ostalih modula
%include "_time.asm"                                ;dobijanje trenutnog vremena
%include "_video.asm"                               ;rad sa video memorijom
%include "_hend.asm"                                ;hendleri prekida
%include "_string.asm"                              ;rad sa stringovima
%include "_args.asm"                                ;parsiranje argumenata komandne linije
%include "_prekidi.asm"                             ;prekidi, zamena vektora prekida
%include "_1c.asm"                                  ;instaliranje naseg hendlera za interapt 1C (User time interrupt)
%include "_tsr.asm"                                 ;instaliranje naseg hendlera za interapt 09 (Keyboard interrupt)
