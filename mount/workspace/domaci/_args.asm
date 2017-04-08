; --------------------------------------------
; Parsiraje argumanata komandne linije
; izlaz command i time
; --------------------------------------------
get_args:
  pusha
  mov cx, 0080h                     ; Maksimalni broj izvrsavanja instrukcije sa prefiksom REPx
  mov di, 81h                       ; Pocetak komandne linije u PSP.
  mov al, SPA                       ; String uvek pocinje praznim mestom (razmak izmedju komande i parametra) 
  repe scasb                        ; Trazimo prvo mesto koje nije prazno (tada DI pokazuje na lokaciju iza njega)
  dec di                            ; Vracamo DI da pokazuje gde treba
  mov si, di

  xor bx, bx                        ; bx = 0, ofset
  mov al, SPA                       ;cekamo space

.read_command:
  mov ah, [di]    
  cmp ah, ENT
  je .done_cmd
  mov [command+bx], ah
  inc bx
  scasb
  jne .read_command
  dec bx

.done_cmd:
  mov byte [command+bx], SEP

  xor bx, bx
  mov al, SPA                         ;cekamo enter

.read_time:
  mov ah, [di]     
  cmp ah, ENT
  je .done_time               
  mov [time+bx], ah
  inc bx
  scasb
  jne .read_time
  dec bx
  
.done_time:
  mov byte [time+bx], SEP

.exit:
  popa
  ret