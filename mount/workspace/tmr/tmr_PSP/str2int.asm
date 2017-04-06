; ------------------------------------------------------------------
; _string_to_int -- Konvertuje decimalni string u int
; Ulaz: SI = pocetak stringa (maksimalno 5 znakova, do '65536')
; Izlaz: AX = celobrojna vrednost (int)
; -------------------------------------------------------------------
_string_to_int:
        pusha
        mov     ax, si                      ; Duzina stringa
        call    _string_length
        add     si, ax                      ; Pocinjemo od znaka sa krajnje desne strane
        dec     si
        mov     cx, ax                      ; Duzina stringa se koristi kao brojac znakova
        mov     bx, 0                       ; U BX ce biti trazena celobrojna vrednost
        mov     ax, 0

      ; Racunamo decimalnu vrednost kod pozicionog sistema sa osnovom 10        

        mov word [.multiplikator], 1        ; Prvi znak mnozimo sa 1
.Sledeci:
        mov     ax, 0
        mov byte al, [si]                   ; Uzimamo znak
        sub     al, 48                      ; Konvertujemo iz ASCII u broj
        mul word [.multiplikator]           ; Mnozimo sa pozicijom
        add     bx, ax                      ; Dodajemo u BX
        push    ax                          ; Mnozimo multiplikator sa 10
        mov word ax, [.multiplikator]
        mov     dx, 10
        mul     dx
        mov word [.multiplikator], ax
        pop     ax
        dec     cx                          ; Da li ima jos znakova
        cmp     cx, 0
        je     .Izlaz
        dec     si                          ; Pomeramo se na sledecu poziciju ulevo
        jmp    .Sledeci
.Izlaz:
        mov word [.tmp], bx                 ; Privremeno cuvamo dobijeni int zbog 'popa'
        popa
        mov word ax, [.tmp]
        ret

       .multiplikator   dw 0  
       .tmp             dw 0

; ------------------------------------------------------------------
; _string_length -- Vraca duzinu stringa
; Ulaz: AX = pointer na pocetak stringa
; Izlaz: AX = duzina u bajtovoma (bez zavrsne nule)
; ------------------------------------------------------------------

_string_length:
        pusha
        mov     bx, ax                      ; Adresa pocetka stringa u BX
        mov     cx, 0                       ; Brojac bajtova
.Dalje:
        cmp byte [bx], 0                    ; Da li se na lokaciji na koju pokazuje 
        je     .Kraj                        ; pointer nalazi nula (kraj stringa)?
        inc     bx                          ; Ako nije nula, uvecaj brojac za jedan
        inc     cx                          ; i pomeri pointer na sledeci bajt.
        jmp    .Dalje
.Kraj:
        mov word [.TmpBrojac], cx           ; Privremeno sacuvati broj bajtova
        popa                                ; jer vacamo sve registre sa steka (tj. menjamo AX).
        mov     ax, [.TmpBrojac]            ; Vracamo broj bajtova (duzinu stringa) u AX.
        ret

       .TmpBrojac    dw 0
