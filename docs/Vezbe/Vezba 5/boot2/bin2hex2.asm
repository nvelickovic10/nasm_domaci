; ====================================================
; bin2hex2.asm
;
; Konverzija binarnog broja u heksadecimalne znakove
; cx - broj znakova
; dx - adresa gde se smestaju znakovi
; Data segment mora da sadrzi string hex_chr
; 
; Ova verzija razlikuje se od prethodnih bin2hex
; zbog toga sto se koristi i u EXE datotekama.
; Zbog toga mora da se vodi racuna o segmentima.
; ====================================================

SEGMENT CODE

bin2hex2:
    push    bp
    mov     bp, dx
    mov     di, cx 
    push    di
    dec     di	
    push    eax
sledeci:    
    call    konv
    dec     di
    pop     eax   
    shr     eax,4
    push    eax   
    loop    sledeci
    pop     eax    
    pop     di
    mov byte [ds:bp+di], 0	
    pop     bp		
    ret

konv:
    and     ax, 0x000f	
    mov     si, ax
    mov byte al, [hex_chr+si]  	
    mov byte [ds:bp+di], al	    ; mora DS override kada DS != SS jer asembler
    ret                         ; podrazmeva da se koristi SS, zbog BP
; -----------------------------------------------------------------------------

SEGMENT DATA
hex_chr:  db '0123456789ABCDEF'

