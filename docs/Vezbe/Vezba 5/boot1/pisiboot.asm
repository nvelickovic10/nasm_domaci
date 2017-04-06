; =======================================================================
; pisiboot.asm
;
; Pomocni program za upisivanje startnog zapisa na disketu u jedinici A:
; Datoteka sa startnim zapisom zadaje se kao parametar komandne linije.
; Program koristi BIOS i DOS sistemske pozive.
; =======================================================================

        org 100h

; ------------------------------------------
; Parsujemo komandnu liniju za ime datoteke 
; Za ovo koristimo PSP

        mov	    ch, 01h
        mov	    di, 81h
        mov	    al, ' '
repe	scasb
        lea	    dx, [di-1]					;Load Effective Address - slicno kao unarni '&' u C
        dec	    di
        mov	    al,13
repne	scasb
        mov byte [di-1], 0

; ------------------------------------------
; Otvaramo datoteku sa startnim zapisom

        mov	    ax, 3D00h                   ; Funkcija za otvaranje datoteke samo za citanje
        int	    21h                         ; DOS sistemski poziv
        jc	    kraj                        ; Greska pri otvaranju
        xchg	bx, ax                      ; Sacuvati deskriptor datoteke (handle) u BX

; ------------------------------------------
; Ucitavamo celokupnu datoteku 
; (prvih 512 bajtova) ciji je handle u BX

        mov	    ah, 3Fh                     ; Funkcija za citanje 
        mov	    cx, 512                     ; Velicina bafera
        mov     dx, sektor                  ; Lokacija bafera
        int	    21h                         ; DOS sistemski poziv
        jc	    kraj                        ; Greska pri citanju datoteke


; ------------------------------------------
; Upisujemo bafer koji sadrzi boot sektor 
; Koristimo BIOS INT 13h, funkciju AH = 03h
;    AL = broj sektora koje treba upisati (mora da bude veci od 0)
;    CH = broj cilindra
;    CL = broj sektora (broji se od 1)
;    DH = broj glave 
;    DL = broj disk jednice (jedinica A = 0)
;    ES:BX -> bafer sa podacima
;    U slucaju grseka vraca CF=1

        mov     dx, 0                       ; Disk jedinica 0 (jedinica A), glava 0
        mov	    bp, 3                       ; 3 pokusaja upisivanja
        mov	    cx, 0001h                   ; Cilindar 0, sektor 1
        mov	    bx, sektor                  ; Lokacija bafera sa sektorom

PisiPonovo:
        mov	    ax, 0301h                   ; AH=3, BIOS funkcija za pisanje, AL: Broj sektora (1)
        int	    13h
        jnc	    kraj
        xor	    ah, ah                      ; Resetujemo disk kontroler
        int	    13h			
        dec	    bp
        jnz	    PisiPonovo		
			
kraj:   ret

sektor:	  times 512 db 0

