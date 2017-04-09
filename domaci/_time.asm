; --------------------------------------------
; dobijanje trenutnog vremena u formatu HH:MM:SS
; izlaz current_time
; --------------------------------------------
get_time:
  pusha                         ;cuvamo stare registre
  mov ah, 2Ch                   ;dos sistemski poziv za vreme CH = hour CL = minute DH = second 
  int  21h                      ; dobija se kada se pozove interapt 21h, a vrednost u ah je 2CH
                                ;http://spike.scu.edu.au/~barry/interrupts.html

  push dx                       ; push dx jer nam se u dh nalazi vrednost za sekunde
  push cx
  push cx                       ; dva puta push cx jer nam se u ch nalaze sati a u cl minuti

  xor bx, bx                    ;inicijalizujemo brojaz na bx=0

  pop ax                        ; hours, sada nam se u ah nalaze sati
  mov al, ah                    ; stavljamo sate iz ah u al da bismo uradili div/10 kako bismo znali da li je dvocifren rezultat
  mov ah, 0   
  mov cl, 10                    ;delimo sa 10

  ;DIV r/m8    Unsigned divide AX by r/m8, with result
  ;stored in AL ←Quotient, AH ← Remainder.
  div cl                      ;delimo vrednost iz ax sa cl, rezultat je u al, a ostatak u ah
                              ;ako je 12 sati, delimo sa 10 da bismo dobili 1 i ostatak 2
                              ;kako bismo te vrednosti upisali bajt po bajt u current_time

  add al, 48                  ;pretvaranje 9 u char (9 + 48 = '9' ASCII)
  add ah, 48
  mov [current_time+bx], al
  inc bx
  mov [current_time+bx], ah
  inc bx
  mov [current_time+bx], byte ':'    ;sada imamo upisano 'HH:' u current time
  inc bx

  pop ax                      ; sada radimo isto za minute samo sto se vrednost za minute sada vec nalazi u al, i odmah pristupamo deljenju sa 10
  mov ah, 0
  mov cl, 10

  ;DIV r/m8    Unsigned divide AX by r/m8, with result
  ;stored in AL ←Quotient, AH ← Remainder.
  div cl

  add al, 48
  add ah, 48
  mov [current_time+bx], al
  inc bx
  mov [current_time+bx], ah
  inc bx
  mov [current_time+bx], byte ':'         ;sada imamo upisano 'HH:MM:' u current_time
  inc bx

  pop ax                                  ;i sada ponovimo slicno za sekunde
  mov al, ah
  mov ah, 0
  mov cl, 10

  ;DIV r/m8    Unsigned divide AX by r/m8, with result
  ;stored in AL ←Quotient, AH ← Remainder.
  div cl
  add al, 48
  add ah, 48
  mov [current_time+bx], al
  inc bx
  mov [current_time+bx], ah

  inc bx
  mov [current_time+bx], byte SEP           ;sada imamo upisano 'HH:MM:SS',SEP u current_time

  popa                      ;vracamo stare registre
  ret