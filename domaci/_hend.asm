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
	mov [brojac], ax											;ponovo ga inicijalizujemo na 18 (18*55ms=0.99s)

  call get_time													;potrazi trenutno vreme

  mov si, current_time	
  call print														;ispisi trenutno vreme

  mov [offset], word 320								;pomerimo offset u video memoriji na ledeci red
  mov si, time
  call print														;ispisemo zadato vreme

  mov [offset], word 160								;vratimo offset u video memoriji na prvobitnu vrednost

	cmp [snooze_state], byte 1									;da li smo u snooze stateu? ako jesmo skok do njega
	je .snooze

  mov si, time
  mov di, current_time
  call compare_strings									;da li je trenutno vreme vece od zaddatog vremena

  cmp ah, 1															;compare_strings ah=1 ako je di veci ili jednak od si
  jne .izlaz														;ako nije - nista...

  mov [offset], word 480								;pomerimo offset na 3. red  1 red = 160, 3 reda = 480
	mov al, [boja_koja_treperi]						;postavljanje boje koja treperi
	mov [boja], al
  mov si, timer_stop									
  call print														;ispis poruke da je alarm istekao
	mov [boja], byte 0Fh 									; vracanje normalne boje

	mov [offset], word 500								
  mov si, msg_snooze									
  call print														;ispis poruke da je alarm istekao

  mov [offset], word 160								;vratimo offset u video memoriji na prvobitnu vrednost

	mov [snooze_state], byte 1									; ulazimo u snooze state
	mov [snooze_count_char], byte '0'						;inicijalizujemo brojac do 10 sekundi na 0

.izlaz:
	popa  														;pop svih registara kako bismo ih vratili funkciji koja nas je pozvala

	iret															;interapt return

.snooze:
	inc byte [snooze_count_char]					;incrementujemo koliko smo sekundi u snoozu
	
	mov [offset], word 530
	mov si, snooze_count_char
	call print_char													;ispisujemo koliko je sekundi proslo u snoozeu
	mov [offset], word 160

	cmp [snooze_count_char], byte ':'  					;cekamo dok ne bude : 'lazna desetka' (asci vrednost '10' je ':')

	jne .izlaz

	mov [exit_state], byte 1
	jmp .izlaz

;=========================================
;	hendler za tastaturni prekid 09
; slusa na keyboard input i postavlja flagove po potrebi
;=========================================

;poziva se na svaki otkucaj na tastaturi interapt 09
tast_hen:
	pusha

; Obrada tastaturnog prekida 
	in al, KBD									;ucitavanje ukucanog karaktera

	cmp al, 01h									;da li je esc
	je .esc
	
	cmp al, 3Bh									;da li je f1
	je .inc

	jmp .izlaz

.esc:
	mov [exit_state], byte 1
	jmp .izlaz

.inc:
	cmp [snooze_state], byte 1				;da li je u snooze stateu? ako nije onda ne mozemo da inkrementiramo za minut
	jne .izlaz												;inkrementacija za minut moze da se odradi samo u onih 10 sekundi
	call add_1_minute
	mov [snooze_state], byte 0				;izlazimo iz snooze statea
	mov [brojac], byte 1							;postavljamo brojac na 1 kako bismo odmah inicirali reprint u timer_hen

	mov si, empty									
	mov [offset], word 480
  call print														;ispis praznog reda na mestu trepcuce poruke, da bi se obrisala
	mov [offset], word 160

	jmp .izlaz

.izlaz:
	popa														;pop svih registara kako bismo ih vratili funkciji koja nas je pozvala
	push word [cs:old_int_seg_tast]
	push word [cs:old_int_off_tast]
	retf														;return far


segment .data

snooze_count_char: db '0'								;brojac do 10 sekundi u snooze_state, stavili smo ga da bude '0' da bismo ga lakse ispisali
brojac:	dw 0														;brojac kojim proveravamo da li nas hendler treba da opali

;interapt 1C ce se desiti svakih 55ms, mi smo nas hendler postavili na interapt 1C, ali hocemo da opali na 1 sekundu
;postavljamo vrednost [brojac] na vrednost [brzina] zadatu u _1c.asm 18*55=0.99 sec (close enough)
;1C opali mi proverimo da li je brojac == 0
;ako nije samo ga dekrementiramo i iskuliramo
;ako jeste pustimo ostatak hendlera da radi
;tako osiguravamo da se radnja desi na svaku sekundu





