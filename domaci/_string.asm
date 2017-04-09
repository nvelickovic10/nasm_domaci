segment .code
; --------------------------------------------
; Stampanje jednog karaktera
; ulaz si i di
; izlaz ax=1 ako su isti
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
    mov cx, bx
    inc cx

.loop:
    mov ah, [di]
    mov al, [si]
    cmp ah, al
    jne .not_equal
    dec cx
    inc di
    inc si
    cmp cx, 0
    jne .loop

    jmp .equal
   
.not_equal:
  popa
  mov ax, 0
  jmp .exit

.equal:
  popa
  mov ax, 1

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