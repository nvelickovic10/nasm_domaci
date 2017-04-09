; =====================================================
;    - Primer sa vezbi vezba 4 (Under construction....)
;    - Instalira TSR rutinu
; ===================================================== 

start_tsr:
        call   _novi_09			;postavljamo novi vektor prekida 09
        
				mov dx, 0FFh				;dx sadrzi koliko memorije rezervisemo za tsr
														;https://courses.engr.illinois.edu/ece390/books/artofasm/CH18/CH18-1.html#HEADING1-3

        mov ah, 31h         ;tsr se dobija kada pozovemo prekid 21h a ah ima vrednost 31h vezba4.pdf
        int 21h							

				ret