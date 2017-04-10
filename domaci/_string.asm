segment .code
; --------------------------------------------
; Stampanje jednog karaktera
; ulaz si i di
; izlaz al=1 ako su isti, ah=1, ako je di veci od si
; --------------------------------------------
compare_strings:
    pusha
    mov ax, si
    call string_length
    mov bx, ax
    mov ax, di
    call string_length
    cmp bx, ax
    jne .not_equal

    mov cx, bx          ;u cx stavimo duzinu stringa
    inc cx      

;proveravamo stringove karakter po karakter da vidimo da li su isti
.loop:
    mov ah, [di]        ;uzimamo karakter iz di
    mov al, [si]        ;uzimamo karakter iz si
    cmp ah, al          ;uporedjujemo ih
    jne .not_equal      ;ako nisu isti string nije jednak
    dec cx              ;decrementujemo brojac za duzinu stringa  
    inc di              ;sledeci karakter u di
    inc si              ;sledeci karakter u si
    cmp cx, 0           ;da li je cx=0?
    jne .loop           ;ako nije jos nismo na kraju stringa

    jmp .equal          ;ako jeste dosli smo do kraja stringa, svi karakteri su isti, znaci stringovi su isti
   
.not_equal:
  cmp ah, al
  jg .greater
  popa
  mov al, 0
  mov ah, 0
  jmp .exit

.greater:
  popa
  mov al, 0
  mov ah, 1
  jmp .exit

.equal:
  popa
  mov al, 1
  mov ah, 1

.exit:
  ret

; ------------------------------------------------------------------
; _string_length -- Vraca duzinu stringa
; Ulaz: AX = pointer na pocetak stringa
; Izlaz: AX = duzina u bajtovoma (bez zavrsne nule)
; ------------------------------------------------------------------

string_length:
        pusha
        mov     bx, ax                      ; Adresa pocetka stringa u BX
        xor     cx, cx                       ; Brojac bajtova
.loop:
        cmp byte [bx], SEP                    ; Da li se na lokaciji na koju pokazuje 
        je     .exit                        ; pointer nalazi nula (kraj stringa)?
        inc     bx                          ; Ako nije nula, uvecaj brojac za jedan
        inc     cx                          ; i pomeri pointer na sledeci bajt.
        jmp    .loop
.exit:
        mov word [.counter], cx           ; Privremeno sacuvati broj bajtova
        popa                                ; jer vacamo sve registre sa steka (tj. menjamo AX).
        mov     ax, [.counter]            ; Vracamo broj bajtova (duzinu stringa) u AX.
        ret


segment .data
.counter    dw 0