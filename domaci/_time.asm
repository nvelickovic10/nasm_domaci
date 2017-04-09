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

; --------------------------------------------
; dodavanje jednog minuta na zadato vreme
; izlaz time
; --------------------------------------------
add_1_minute:
  pusha
                                  ;vreme je u formatu HH:MM:SS
  mov bx, 4                       ;postavljamo pokazivac na ^ bx=4, jer nju zelimo da inkrementiramo

  inc bx
.loop9:                           ;prvo proveravamo do 9 za owerflow
  dec bx
  mov al, [time+bx]               ;uzimamo vrednost na trenutnoj poziciji
  cmp al, byte ':'                ;da li je vrednost ':'?
  je .loop9                       ;ako jeste samo preskacemo
  inc al                        ;uvecamo vrednost za 1
  mov [time+bx], al             ;postavimo inkrementovanu vrednost
  cmp al, '9'                     ;da li je vece od '9'
  jng .end                        ;ako nije vece od '9' nema carry-ja i izlazimo iz funkcije
  mov [time+bx], byte '0'         ;prenosimo owerflow (ex. bilo je 39 minuta i dodajemo 1, znaci bice 40)
  cmp bx, 0                       ;ako smo dosli do poslednje cifre izlazimo iz petlje (nema owerflow za sate, samo padne na 00:00:00)
  je .end
  jmp .loop6

.loop6:                           ;pa do 6 za owerflow
  dec bx
  mov al, [time+bx]               ;uzimamo vrednost na trenutnoj poziciji
  cmp al, byte ':'                ; da li je vrednost ':'?
  je .loop6
  inc al                        ;uvecamo vrednost za 1
  mov [time+bx], al             ;postavimo inkrementovanu vrednost
  cmp al, '5'                     ;da li je vece od '5'
  jng .end                        ;ako nije vece od '5' nema carry-ja i izlazimo iz funkcije
  mov [time+bx], byte '0'         ;prenosimo owerflow (ex. bilo je 59 minuta i dodajemo 1, znaci bice 00)
  cmp bx, 0
  je .end
  jmp .loop9

.end:
  popa
  ret

; --------------------------------------------
; provera formata vremean
; ulaz ah gornja granica 0-ah, al cifra koja se proverava
; izlaz ah = 1 ako je validna cifra
; --------------------------------------------
check_digit:
  pusha
  cmp al, '0'
  jnge .invalid             ;ako nije veci ili jednak '0' nije validan
  cmp al, ah
  jnle .invalid 

  popa
  mov ah, 1                 ;ako je validna 0-ah vracamo rezultat ah=1
  ret
  
.invalid:
  popa
  mov ah, 0
  ret


; --------------------------------------------
; provera formata vremean
; ulaz time sa komandne linije
; izlaz al = 1 ako je validan
; --------------------------------------------
check_time_format:
  pusha

  xor bx, bx                ;inicijalizacija brojaca bx=0
.loop:
  mov al, [time+bx]         ;uzimamo trenutnu vrednost
  mov ah, '6'                 ;priprema za check digit (prvo proveravamo da li je cifra 0-6)
  call check_digit
  cmp ah, 0               ;rezultat check_digit je u ah, ako je nula nije validna
  je .invalid             ;ako nije 0-6 nije validan
  
  inc bx                    ;sledeca cifra
  mov al, [time+bx]         ;uzimamo trenutnu vrednost
  mov ah, '9'                 ;priprema za check digit (da li je cifra 0-9)
  call check_digit
  cmp ah, 0
  je .invalid             ;ako nije 0-9 nije validan

  cmp bx, 7                 ;ako smo stigli do kraja stringa (druge sekunde u time) onda izlazimo iz petlje
  je .valid
  
  inc bx                    ;sposle dve cifre ide ':'
  mov al, [time+bx]         ;uzimamo trenutnu vrednost
  cmp al, ':'
  jne .invalid              ;ako nije ':' posle dve cifre nije validan

  inc bx
  jmp .loop


.valid:
  popa
  mov al, 1
  ret

.invalid:
  popa
  mov al, 0
  ret