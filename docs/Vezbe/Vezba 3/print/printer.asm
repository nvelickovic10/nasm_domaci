segment .code
; ----------------------------------------------
; Rutina za komunikaciju sa perifernim uredjajem
; Paralelni printer port
; ----------------------------------------------
; Znak koji se stampa je u BL
pr_char:
        push    dx
        push    cx
		push	ax
        mov     dx, 0378h
        mov     al, bl                      ; posalji znak
        out     dx, al	
        inc     dx
 
; Cekaj sve dok ne bude Ready (programirani U/I - upotreba polling-a) 
wait_r:
        in      al, dx
        and     al, 080h 

; Busy je najtezi bit i invertovan je na interfejsu
        jz      wait_r	
        inc     dx
        in      al, dx
        or      al, 01h	

; Aktiviraj Strobe (najnizi bit)
        out     dx, al

; Sacekaj malo
        mov     cx, 5000	
delay:
        loop    delay		

; Deaktiviraj Strobe
        and     al, 0feh	
        out     dx, al
		pop		ax
        pop     cx			
        pop     dx
        ret

   
; -------------------------------------------------------
; Prekidna rutina za komunikaciju sa perifernim uredjajem
; U pricipu, rutna sadrzii kompetan kod pr_char, ali ga
; mi ovde pozivamo kao potprogram, da bi ga koristli bez
; izmena u nasim test programima Test1 i Test2 
; -------------------------------------------------------  
ipr_char:
        call    pr_char
        iret

; --------------------------------------------------------------------------   
; Int 17h je rezervisan za BIOS printer servis. 
; Mi za svoj drajver mozemo da koristimo bilo koji slobodni vektor prekida
; (npr 60h), ali i da zamenimo postojeci vektor (17h) sa svojim.    
; --------------------------------------------------------------------------  
; Sacuvati originalni vektor prekida 0x17, tako da kasnije mozemo da ga vratimo

_inst_17:
        cli
        xor     ax, ax
        mov     es, ax
        mov     bx, [es:17h*4]
        mov     [stari_int17_off], bx 
        mov     bx, [es:17h*4+2]
        mov     [stari_int17_seg], bx

; Modifikacija u tabeli vektora prekida tako da pokazuje na nasu rutinu
        mov     dx, ipr_char
        mov     [es:17h*4], dx
        mov     ax, cs
        mov     [es:17h*4+2], ax
        sti
        ret

; ----------------------------------------------------------------------------- 
; Vratiti stari vektor prekida 0x17

_uninst_17:
        cli
        xor     ax, ax
        mov     es, ax
        mov     ax, [stari_int17_seg]
        mov     [es:17h*4+2], ax
        mov     dx, [stari_int17_off]
        mov     [es:17h*4], dx
        sti
        ret

segment .data

stari_int17_seg: dw 0
stari_int17_off: dw 0
   