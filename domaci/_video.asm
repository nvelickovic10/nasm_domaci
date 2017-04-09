segment .code
; --------------------------------------------
; Stampanje stringa do SEP
; ulaz si
; parametri: offset, boja
; --------------------------------------------
print:
	pusha																		;cuvanje starih registara
	mov	ax, 0B800h                          ; pocetak video memorije na adresi 0B800h
	mov es, ax															; pocetak video memorije u es
	
	mov bx, [offset]												;offset u video memoriji
	
.petlja:
	mov al, byte [si]												;uzimamo trenutni bajt iz ulaznog stringa
	
	cmp al, SEP															
	je .kraj																;provera da li je terminator
	
	mov byte [es:bx], al                    ; ako nije, stavljamo vrednost u es[bx]
	inc bx																	; pomeramo se na bajt za boju
	mov ah, [boja]
	mov byte [es:bx], ah                   ; upisujemo trenutnu boju (uglavnom crna pozadina sa belim slovima, osim slova koja trepere)
	inc bx																	;pomeramo se na sledeci bajt u video memoriji
	inc si																	;pomeramo se na sledeci bajt u ulaznom stringu
	
	jmp .petlja															;petljamo do terminatora
	
.kraj:
	;mov byte [es:bx], '|'                    ; ispisujemo pajp na kraju cisto zbog debagovanja, da bismo znali gde je kraj stringa
	;inc bx
	;mov ah, [boja]
	;mov byte [es:bx], ah                   ; upisujemo trenutnu boju (uglavnom crna pozadina sa belim slovima, osim slova koja trepere)

	popa													;vracanje starih rgistara
	ret 

; --------------------------------------------
; Stampanje jednog karaktera
; ulaz si
; parametri: offset, boja
; --------------------------------------------
print_char:
	pusha													;cuvamo stare registre
	mov ax, 0B800h                          ; pocetak video memorije
	mov es, ax															;pocetak video memorije u es
	
	mov bx, [offset]												;ofset u video memoriji u bx

	mov al, byte [si]												;uzimamo vrednost iz si (iz ulaza)
	mov byte [es:bx], al                    ; stavljamo vrednost u es[bx]
	inc bx																	;inkrementiramo bx na sledeci bajt u video memoriji, bajt za boju
	mov ah, [boja]					
	mov byte [es:bx], ah                   ; upisujemo trenutnu boju (uglavnom crna pozadina sa belim slovima, osim slova koja trepere)
	
.kraj:
	popa										;vracamo stare registre
	ret	

; --------------------------------------------
; Brisanje sadrzaja ekrana
; Fakticki 2000 puta ispisemo prazno slovo jer imamo toliko karaktera na ekranu
; --------------------------------------------
cls:
	pusha
	mov cx, 160        										; Resetovati brojac znakova na vrednost 160 (iz nekog razloga prva linija pocinje od 160)
.loop:
	mov si, prazno
	mov word [offset], cx										; postavljamo ofset u video memoriji na vrednost brojaca cx
	call print_char       									; Ispisivati prazno mesto
	inc cx
	inc cx																; inkrementujemo cx dva puta jer preskacemo bajt za boju koji je vec ispisan
	cmp cx, 4000   												; Standardna velicina alfanumerickog ekrana 160x25 (4000 znakova + boja)
	jne .loop

	mov word [offset], 160								;vracamo ofset u video memoriji na 160 (prva linija)

	popa
	ret        

segment .data
boja_koja_treperi: db 08Fh						;pronadjena sistemom uzaludnih pokusaja
boja: db 0Fh													;varijabla za boju (video memorija ima 2000 karaktera a 4000 bajtova, karakter na ekranu opisuju 2 bajta prvi je karakter, a drugi je boja)
																			;boju karakterisu 2 hex cifre, prva je pozadina, a druga boja slova. 0Fh je crna pozadina, bela slova
prazno: db ' ',SEP										;prazan karakter koji koristi cls
offset: dw 160												;160 je duzina jedne linije na ekranu 80 karaktera i 80 boja
	