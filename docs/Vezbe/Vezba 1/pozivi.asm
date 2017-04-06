; ==================================================
; Vezba 1: pozivi.asm
;    - Brisanje sadrzaja ekrana
;    - Ispisivanje poruke na ekranu upotrebom BIOS-a
;    - Upotreba Data segmenta
;
; Prevodjenje:
;      nasm pozivi.asm -f bin -o pozivi.com
; ================================================== 

org 100h


; Kod za testiranje
; ---------------------------------------------
main:
      call _cls
      mov   si, poruka		
      call _print
      mov   si, novi_red
      call _print
izlaz:	
      ret	
    
    
; Ispisivanje poruke na ekranu upotrebom BIOS-a
; -----------------------------------------------
_print:
      push ax
      cld				; Clear direction (flag). Brine se da se SI krece u dobrom pravcu
.prn:
      lodsb				; Ucitavati znakove sve do nailaska prve nule
	                    ; Ucitava se se lokacije DS:SI, i SI se pomera
						; "unapred" u memoriji ako direction flag nije postavljen (cld)
						; Ucitan znak se smesta u AL
      or   al,al		; Ako je rezultat OR operacije, kao i drugih logickih i aritmetickih 0,
						; bice postavljen zero flag.
      jz  .end			; Kraj stringa
      mov  ah,0eh		; BIOS 10h: ah = 0eh (Teletype Mode), al = znak koji se ispisuje
      int  10h			; BIOS prekid za rad sa ekranom
      jmp .prn     
.end:
      pop  ax
      ret          

; Brisanje sadrzaja ekrana
; --------------------------------------------

_cls:
      pusha
      mov  ah,02h		; BIOS 10h: ah = 02h (Postavljanje pozicije kursora)
      mov  dh,0h		; dl - kolona, dh - red
      mov  dl,0h		; Pozicija 0,0 (pocetak ekrana - gornji levi ugao)
      int  10h			; BIOS prekid za rad sa ekranom
      xor  cx,cx		; Resetovati brojac znakova na vrednost 0
.loop:
      mov  si,prazno
      call _print		; Ispisivati prazno mesto
      inc  cx
      cmp  cx,2000		; Standardna velicina alfanumerickog ekrana 80x25 (2000 znakova)
      jne  .loop

      mov  ah,02h
      mov  dh,0h		; Startna pozicija za ispisivanje (0,0)
      mov  dl,0h
      int  10h			; BIOS prekid za rad sa ekranom

      popa
      ret

; Deo sa podacima
; --------------------------------------

segment .data

poruka:    db 'Puno pozdrava sa RAF-a!',0
prazno:    db ' ',0
novi_red:  db 0ah, 0dh,0

