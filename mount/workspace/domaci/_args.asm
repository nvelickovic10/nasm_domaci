; --------------------------------------------
; Parsiraje argumanata komandne linije
; izlaz command i time
; --------------------------------------------
get_args:
    pusha                               ;push svih registara kako bismo ih sacuvali
    mov cx, 0080h                       ; Maksimalni broj izvrsavanja instrukcije sa prefiksom REPx, da ne bismo beskonacno citali
    mov di, 81h                         ; Pocetak komandne linije u PSP (program segment prefix). Ako smo pokrenuli program sa domaci.com -start 12:00:00
                                        ;                                                                      trenutno se nalazimo ovde ^
    
    mov al, SPA                         ; Stavljamo vrednost ' ' u al, al se koristi u scasb
    repe scasb                          ; scasb uporedjuje vrednost u al sa vrednosti u di. repe ponavlja scasb sve dok su al i di isti.Trazimo prvo mesto koje nije prazno (ako smo slucajno ukucali vise spejsova nego sto treba (ex. domaci.com     -start 12:00:00))
    dec di                              ; Vracamo DI da pokazuje gde treba domaci.com -start 12:00:00
                                        ;                                            ^

    xor bx, bx                        ;bx = 0, ofset od pocetka stringa, u C bi to bilo command[bx]
    mov al, SPA                       ;cekamo space 


;hocemo da procitamo -start, postavimo pokazivac di na - i citamo sve dok ne naidjemo do space ' '
;svaki karakter stavimo u [command+bx] i inkrementiramo di i bx
.read_command:
    inc di
    mov ah, [di]    
    cmp ah, ENT                             ;provera da li je trenutni karakter enter, ako smo slucajno ukucali samo domaci.com -start
    je .done_cmd 
    mov [command+bx], ah                    ;stavljamo trenutni karakter u [command+bx]
    inc bx
    cmp ah, al                              ;da li je trenutni karakter space?
    jne .read_command                       ;ako nije idemo na sledeci
    dec bx

.done_cmd:
    mov byte [command+bx], SEP              ;stavljamo separator (terminator) na kraj stringa

    xor bx, bx                              ;resetujemo bx=0 jer cemo sada da citamo zadato vreme
    
    mov al, ENT                         ;cekamo enter za kraj komande


;sve isto kao kod .read_command samo sto sada citamo zadato vreme
;domaci.com -start 12:00:00
;trenutno smo ovde ^
.read_time:
    inc di
    mov ah, [di]                    
    mov [time+bx], ah
    inc bx
    cmp ah, al
    jne .read_time

    dec bx

.done_time:
    mov byte [time+bx], SEP                 ;postavljamo terminator na kraj stringa za zadato vreme

.exit:
    popa                                    ;pop svih registara, vracamo ih prethodnoj funkciji
    ret