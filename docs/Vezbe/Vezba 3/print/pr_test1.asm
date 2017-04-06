org 100h
segment .code

main:
        mov     si, print_text
        call   _pprint	
        ret

_pprint:
        push    ax
        cld
.prn:
        lodsb                               ; Ucitavati znakove sve do nailaska prve nule
        or      al, al     
        jz     .end                         ; Kraj stringa
        mov     bl, al
        call    pr_char
        jmp    .prn     
.end:
        pop     ax
        ret          

%include "printer.asm"

segment .data

print_text: db 'Printer Test_1: Poziv potprograma.', 0Ah, 0Dh, 0Ch, 0	

