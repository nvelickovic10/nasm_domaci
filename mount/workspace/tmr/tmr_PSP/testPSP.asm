; =======================================================
; testPSP.asm
;    - Ista funkcionalnost kao \timer\test1C plus
;    - demostrira upotrebu parametra sa komandne linije
;      za vrednost kasnjenja, odnosno upotrebu DOS PSP
;    - konvertuje string sa komandne linije u integer
;    - rezervise neinicijalizovani deo memorije (radi 
;      eventualne kompatibilnosti sa drugim prevodiocima) 
; ======================================================= 

; DOS Program Segment Prefix (PSP)
; --------------------------------
; Svakom pogramu kojeg startuje, DOS dodeljuje PSP.
; Kod datoteka tipa .COM, on zauzima vrednosti ofset adresa od 0 do 0ffh
; unutar segmenta u koji se ucitava program. Ne treba zaboraviti da 
; izvrsne datoteke tipa .COM zuzimaju samo jedan segment i da je kod njih 
; CS=DS=SS=ES. Sadrzaj FS i GS je neodredjen.

; PSP je relikt starih operativnih sistema (CP/M) i sadrzi informacije
; o stanju programa. Znacajnije stvari koje su jos u upotrebi:
; parametri komandne linije, promenljive okruzenja, vektori rutina za
; obradu kriticnih gresaka kao i znacajne adrese prethodnog programa.

; Parametri komandne linije pocinju od ofset adrese 80h, na kojoj je bajt
; koji sadrzi duzinu komandne linije u znakovima (bajtovima),
; ukljucujuci i prazna mesta. String komandne linije pocinje od ofset
; adrese 81h i on NE SADRZI ime programa kome prosledjujemo parametar.
; Kod drugih operativnih sistema, string sa komandne linije cuva se
; na razne naacine. Portabilini programski jezici (kao sto je npr. C)
; imaju biblioteke koje to 'znaju'. 

; Elementarni kvant kasnjenja je 55ms, tako da se parametar zadaje kao
; koeficijent koji mnozi ovaj kvant, za zeljeno kasnjenje u sekundama.
; Npr. za kasnjenje od 0,99s potrebno je zadati 18, a parametar cija je 
; vrednosti 19, daje kasnjenje od 1,045s. Znaci, tacno kasnjenje od 1s
; nije moguce postici :(
; Parametar vrednosti 0 daje maksimalno kasnjenje (oko jedan sat).  


ESC  equ  1bh                               ; ASCII kod za Esc taster 

org 100h
segment .code

main:   cld
        mov     cx, 0080h                   ; Maksimalni broj izvrsavanja instrukcije sa prefiksom REPx
        mov     di, 81h                     ; Pocetak komandne linije u PSP.
        mov     al, ' '                     ; String uvek pocinje praznim mestom (razmak izmedju komande i parametra) 
repe    scasb                               ; Trazimo prvo mesto koje nije prazno (tada DI pokazuje na lokaciju iza njega)

; Instukcija SCASB
; ------------------
; Skenira string (po jedan bajt) na koji pokazuje ES:DI, trazeci znak (bajt) koji je zadat sadrzajem AL.
; DI se inkrementira nakon svakog poziva ove instrukcije, kada je zadato CLD (podrazumevani smer).
; Koristi se u kombinaciju sa prefiksima ponavljanja instrukcije: REPE i REPNE.
;   REPNE - nalazi prvi bajt koji je jednak sa bajtom u AL
;   REPE  - nalazi prvi bajt koji NIJE jednak sa bajtom u AL

        dec     di                          ; Vracamo DI da pokazuje gde treba
        mov     si, di                      ; Pocetak stringa u SI
        mov     al, 0dh                     ; Trazimo kraj stringa (pritisnut Enter)
repne   scasb                               ; (tada DI pokazuje na lokaciju iza njega) 
        mov byte [di-1], 0                  ; string zavrsavamo nulom   
        
        call   _string_to_int	            ; AX sadrzi int vrednost stringa na koji pokazuje SI 
        mov word [vrednost], ax
        mov     [brojac], ax
        call   _novi_1C
        mov byte [var], 'A' - 1             ; Pocetno slovo za nas primer (prekidna rutina ce ovo da inkrementira)                       
        mov     si, init_text
        call   _print	

ponovo:	
        mov     ah, 0                       ; BIOS funkcija za citanje sa tastature
        int     16h          
        cmp     al, ESC                     ; Procitani zanak je u AL. Da li je to Esc?
        je     .izlaz        
        jmp     ponovo
.izlaz:
        call   _stari_1C
        ret

%include "str2int.asm"
%include "prekidi.asm"
%include "ekran.asm"

segment .data
init_text: db 'Inicijalizacija... ', 0x0A,0x0D,0

; Neinicijalizvani deo. NASM ga inicijaluzuje nulom.
var:       resb 2
vrednost:  resw 1