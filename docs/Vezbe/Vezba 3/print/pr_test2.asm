org 100h
segment .code

main:
        call   _inst_17
        mov     si, print_text
        call   _pprint
        call   _uninst_17
        ret

_pprint:
        push    ax
        cld
.prn:
        lodsb                               ; Ucitavati znakove sve do nailaska prve nule
        or      al, al     
        jz     .end                         ; Kraj stringa
        mov     bl, al
        int     17h
        jmp    .prn     
.end:
        pop     ax
        ret          

%include "printer.asm"

print_text: db 'Printer Test_2: Upotreba prekida.', 0Ah, 0Dh, 0Ch, 0	