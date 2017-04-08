segment .code
; --------------------------------------------
; Stampanje stringa do SEP
; ulaz si
; parametri: offset, boja
; --------------------------------------------
print:
	pusha
	mov	ax, 0B800h                          ; pocetak video memorije
	mov es, ax
	
	mov bx, [offset]
	
.petlja:
	mov al, byte [si]
	
	cmp al, SEP
	je .kraj
	
	mov byte [es:bx], al                    ; karakter
	inc bx
	mov ah, [boja]
	mov byte [es:bx], ah                   ; boja
	inc bx
	inc si
	
	jmp .petlja
	
.kraj:
	mov byte [es:bx], '|'                    ; karakter
	inc bx
	mov ah, [boja]
	mov byte [es:bx], ah                   ; boja

	popa
	ret 

; --------------------------------------------
; Stampanje jednog karaktera
; ulaz si
; parametri: offset, boja
; --------------------------------------------
print_char:
	pusha
	mov ax, 0B800h                          ; pocetak video memorije
	mov es, ax
	
	mov bx, [offset]

	mov al, byte [si]	
	mov byte [es:bx], al                    ; karakter
	inc bx
	mov ah, [boja]
	mov byte [es:bx], ah                   ; boja
	
.kraj:
	popa
	ret

; --------------------------------------------
; Brisanje sadrzaja ekrana
; --------------------------------------------
cls:
	pusha
	mov cx, 160        										; Resetovati brojac znakova na vrednost 0
.loop:
	mov si, prazno
	mov word [offset], cx
	call print_char       									; Ispisivati prazno mesto
	inc cx
	inc cx
	cmp cx, 4000   												; Standardna velicina alfanumerickog ekrana 160x25 (4000 znakova + boja)
	jne .loop

	mov word [offset], 160

	popa
	ret        

segment .data
boja: db 0Fh
prazno: db ' ',SEP
offset: dw 160												;160 je duzina jedne linije na ekranu 80 karaktera i 80 boja
	