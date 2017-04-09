;===========================
;hendleri za prekide 1C (timer_hen) i 09 (tast_hen)
;===========================

;timer_hen ce biti pozvan na svakih 55ms od strane hardvera (odnosno bice pokrenut interapt 1C koji ce pozvati nas hendler iz vektora prekida)
timer_hen:
	pusha																	;push svih registara na stek, kako bismo ih sacuvali za prethodnu funkciju
																				;realno nije potrebno pushati sve registre, nego samo one koje koristimo u trenutnoj funkciji

; Obrada tajmerskog prekida 
	dec word [brojac]											;dekrementiramo brojac
	jnz .izlaz														;ako nije 0 iskuliramo poziv

	mov ax, [brzina]											;ako je nula
	mov [brojac], ax											;ponovo ga inicijalizujemo na 18

  call get_time													;potrazi trenutno vreme

  mov si, current_time	
  call print														;ispisi trenutno vreme

  mov [offset], word 320								;pomerimo offset u video memoriji na ledeci red
  mov si, time
  call print														;ispisemo zadato vreme

  mov [offset], word 160								;vratimo offset u video memoriji na prvobitnu vrednost

  mov si, current_time
  mov di, time
  call compare_strings									;da li je trenutno vreme i zadato vreme isto

  cmp ax, 1
  jne .izlaz														;ako nije - nista...

  mov [offset], word 480								;pomerimo offset na 3. red  1 red = 160, 3 reda = 480
  mov si, timer_stop									
  call print														;ispis poruke da je alarm istekao

  mov [offset], word 160								;vratimo offset u video memoriji na prvobitnu vrednost

.izlaz:
	popa  														;pop svih registara kako bismo ih vratili funkciji koja nas je pozvala

	iret															;interapt reture

segment .data

brojac:	dw 0														;brojac kojim proveravamo da li nas hendler treba da opali
;interapt 1C ce se desiti svakih 55ms, mi smo nas hendler postavili na interapt 1C, ali hocemo da opali na 1 sekundu
;postavljamo vrednost [brojac] na vrednost [brzina] zadatu u _1c.asm 18*55=0.99 sec (close enough)
;1C opali mi proverimo da li je brojac == 0
;ako nije samo ga dekrementiramo i iskuliramo
;ako jeste pustimo ostatak hendlera da radi
;tako osiguravamo da se radnja desi na svaku sekundu





;=========================================
;	hendler za tastaturni prekid 09 under construction...
; koristila bi ga tsr verzija da je imam
;=========================================

;poziva se na svaki otkucaj na tastaturi interapt 09
tast_hen:
	pusha

; Obrada tastaturnog prekida 
	in al, KBD
	mov bx, 0B800h
	mov es, bx
	mov bx, 460
	cmp al, 3Bh
	je .f1
	cmp al, 3Ch
	je .f2
	jmp .izlaz
.f1:
	mov [es:bx], byte '1'
	inc bx
	mov [es:bx], byte 2
	jmp .izlaz
.f2:
	mov [es:bx], byte '2'
	inc bx
	mov [es:bx], byte 2
	jmp .izlaz
.izlaz:
	popa														;pop svih registara kako bismo ih vratili funkciji koja nas je pozvala
	
	push word [cs:old_int_seg]
	push word [cs:old_int_off]
	retf														;return far
