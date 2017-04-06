; ---------------------------------------------------------------------------
; FAT12 sistem datoteka                                                    
; Ucitava COM ili EXE datoteku, a zatim je izvrsava (opracije LOAD i EXEC)
; Promenljiva "ImePrograma" sadrzi ime datoteke
; Zbog velicine boot sektora, greske tokom ucitavanja date su sa po dva slova:
;     "GC" za "Greska u Citanju"          
;     "NP" za "Nije Pronadjeno"           

; Radi samo sa prvom MBR particijom koja mora da bude PRI DOS particija
; sa sistemom datoteka FAT12 (ID sistema datoteka: 1)

; Radi sa disketama 360KB 5"25, 1.2MB 5"25 i 1.44MB 3"5
                                                                         
;                              Memorija:        segment                                                 
;                 -------------------------------------                               
;                 Tabela vektora prekida           0000                          
;                 -------------------------------                               
;                 BIOS Data Area                   0040                          
;                 -------------------------------                              
;                 PrtScr Status / neiskorisceno    0050                          
;                 -------------------------------
;                 Adresa gde se ucitava program    0060                          
;                --------------------------------                               
;                 Raspoloziva memorija             nnnn                          
;                 -------------------------------                              
;                 2KB Boot stek                    A000 - 512 - 2KB              
;                 -------------------------------                              
;                 Boot sektor                      A000 - 512                    
;                 -------------------------------                             
;                                                  A000  (granica od 640 KB)                          
                                                                         
                                                                          
;  Vrednosti registara:                  
;  --------------------               
;  DL = broj boot disk jedinice                                                  
;  CS:IP = pocetak programa                                            
;  SS:SP = programski stek (ne mesati ga sa stekom boot sektora !)          
;  COM program standardne vrednosti: CS = DS = ES = SS = 50h, SP = 0, IP = 100h        
;  EXE program standardne vrednosti: zavisi od EXE zaglavlja  
; ---------------------------------------------------------------------------------                                                                          

ImageLoadSeg            equ     60h    ; U ovaj segment ucitava se kompletna slika programa sa diska
                                       ; To ne znaci da pocinje i izvrsavanje u ovom segmentu
;-----------------------
; Pocetak boot sektora 
;-----------------------
[ORG 0]
        jmp     short start
        nop
bsOemName               DB      "BootProg"      ; 0x03

;-----------------------------------
; Pocetak BPB (BIOS Parameter Block)
;-----------------------------------

; Nazivi polja su na engleskom jeziku da bi se lakse poredili sa rezultatima upotrebe raznih alata

bpbBytesPerSector       DW      0               ; 0x0B
bpbSectorsPerCluster    DB      0               ; 0x0D
bpbReservedSectors      DW      0               ; 0x0E
bpbNumberOfFATs         DB      0               ; 0x10
bpbRootEntries          DW      0               ; 0x11
bpbTotalSectors         DW      0               ; 0x13
bpbMedia                DB      0               ; 0x15
bpbSectorsPerFAT        DW      0               ; 0x16
bpbSectorsPerTrack      DW      0               ; 0x18
bpbHeadsPerCylinder     DW      0               ; 0x1A
bpbHiddenSectors        DD      0               ; 0x1C
bpbTotalSectorsBig      DD      0               ; 0x20

;----------
;Kraj BPB
;----------

bsDriveNumber           DB      0               ; 0x24   potrebno nam je za INT 13h, fn.2
bsUnused                DB      0               ; 0x25
bsExtBootSignature      DB      0               ; 0x26
bsSerialNumber          DD      0               ; 0x27
bsVolumeLabel           DB      "NO NAME    "   ; 0x2B
bsFileSystem            DB      "FAT12   "      ; 0x36

;------------------------------
; Pocetak koda iz boot sektora         
;------------------------------

start:
        cld                     ; Kopiranje nizova bice od nizih ka visim adresama

;-----------------------------------
; Koliko je RAM-a na raspolaganju?
;-----------------------------------

        int     12h             ; BIOS poziv za velicinu konvencionalne memorije ("top" u KB)
        shl     ax, 6           ; a zatim konvertovanje u paragrafe

;------------------------------------------------
; Reervisati deo memorije za boot sektor i stek  
;------------------------------------------------

        sub     ax, 512 / 16    ; Rezervisati 32 paragrafa (512 bajtova) za kod iz boot sektora
        mov     es, ax          ; koji ce biti relociran. ES:0 -> top - 512

        sub     ax, 2048 / 16   ; Rezervisati 128 paragrafa (2048 bajtova) za boot stek
        mov     ss, ax          ; SS:0 -> top - 512 - 2048 
        mov     sp, 2048        ; Inicijalizacija SP za boot kod (dno steka je na top - 512)

;-------------------------------------------------------
; Boot kod kopira samog sebe u gornji deo memorije 
; da bi u donjoj memoriji mogao da ucita drugi program   
;-------------------------------------------------------

        mov     cx, 256          ; Kopira se 256 reci (512 bajtova)
        mov     si, 7C00h        
        xor     di, di           ; ES:DI -> pocetak odredisnog niza (ES:0 = top - 512)
        mov     ds, di           ; DS:SI -> pocetak izvornog niza (0:7C00h)
        rep     movsw            ; Kopiraj 512 bajtova

;----------------------------------------
; Predaja kontrole relociranom boot kodu
;----------------------------------------

        push    es               ; Ovaj deo boot koda sada je relociran ali ga jos uvek izvrsavamo
        push    word main        ; u nerelociranom delu. Tekuca vrednost ES (segment gde smo kopirali
        retf                     ; kod sa lokacije 0:7C00h) je buduca vrednost CS.

main:                            ; Sada nastavljamo izvrsavanje u relociranom boot kodu. 
        push    cs
        pop     ds               ; DS=CS jer je program svega 512 bajtova
        
        mov     [bsDriveNumber], dl     ; Sacuvati broj boot diska (npr. floppy A = 00, B = 01, prvi HDD = 080h...)
                                        ; Ovo smo dobili kao zaostatak nakon BIOS INT 19h - load boot sector.
                                        ; INT 19h prekidna rutina cita ovaj podatak iz CMOS RAM-a, Flash-a
                                        ; ili druge vrste memorije gde se cuvaju podaci za BIOS.
                                        ; INT 19h prekidna rutina, nakon upotrebe, broj diska ostavlja u DL.
;------------------------------------------
; Rezervisati memoriju za smestanje FAT12 
;------------------------------------------

        mov     ax, [bpbBytesPerSector]
        shr     ax, 4                    ; AX = velicina sektora u paragrafima
        mov     cx, [bpbSectorsPerFAT]   ; CX = velicina FAT u sektorima
        mul     cx                       ; AX = velicina FAT u paragrafima

        mov     di, ss                   ; FAT bafer se nalazi odmah iza steka  
        sub     di, ax                  
        mov     es, di                   ; ES:BX -> bafer za FAT 
        xor     bx, bx                   ; Pocetak bafera = ES:0 -> (top - 512 - 2048 - velicina FAT) 

        mov     ax, [bpbHiddenSectors]   ; Preskociti sakrivene i rezervisane sektore
        mov     dx, [bpbHiddenSectors+2]
        add     ax, [bpbReservedSectors] ; Boot sektor
        adc     dx, bx                   ; DX:AX = Linear Block Address (LBA) prvog sektora prve FAT  

        call    CitajSektor              ; Citati CX sektora prve FAT
  
        
;----------------------------------------------------------------
; Rezervisati memoriju za root direktorijum, a zatim ga ucitati   
;----------------------------------------------------------------

        mov     bx, ax
        mov     di, dx                   ; Sacuvati LBA prvog sektora prve FAT u DI:BX          

        mov     ax, 32                   ; Jedna direktorjumska stavka ima 32 bajta
        mov     si, [bpbRootEntries]     ; Broj direktorijumskih stavki
        mul     si                       ; Broj bajtova za direktorijum 
        div     word [bpbBytesPerSector]
        mov     cx, ax                   ; CX = velicina root direktorijuma u sektorima

        mov     al, [bpbNumberOfFATs]    ; Broj FAT tabela (standardno 2)
        cbw                              ; Konverovati sadrzaj AL u AX Word
        mul     word [bpbSectorsPerFAT]  ; Ukupan broj sektora za sve FAT
        add     ax, bx                   ; Dodati na LBA prvog sektora FAT
        adc     dx, di                   ; DX:AX = LBA prvog sektora root direktorijuma

        push    es                       ; Segment FAT bafera na stek (drugi parametar - WORD) 
        push    word ImageLoadSeg        
        pop     es                       ; Segment pocetka bafera za root direktorijum (060h)
        xor     bx, bx                   ; ES:BX -> bafer za root direktorijum

        call    CitajSektor              ; Citanje CX sektora root direktorijuma

        add     ax, cx                   ; Dodati broj sektora za root direktorijum na LBA
        adc     dx, bx                   ; podesiti LBA na prvi klaster oblasti podataka  
                                         ; (LBA_klastera_2)
        push    dx
        push    ax                       ; LBA_klastera_2 na stek (prvi parametar - DWORD)    

;--------------------------------------------------------------
; Potraziti COM ili EXE program kojeg treba ucitati i izvrsiti
;--------------------------------------------------------------

        mov     di, bx                  ; ES:DI -> tekuca stavka iz root direktorijuma
        mov     dx, si                  ; DX = broj stavki u direktorijumu
        mov     si, ImePrograma         ; DS:SI -> ime programa

;---------------------------------------------------
; Trazimo datoteku sa zadatim imenom
;---------------------------------------------------
; Ulaz:  DS:SI -> ime datoteke (11 znakova, tj 8+3)
;        ES:DI -> polje root direktorijuma
;        DX = broj stavki u root direktorijumu
; Izlaz: SI = redni broj prvog klastera datoteke          
;---------------------------------------------------

        mov     cx, 11                  ; CL = broj znakova u imenu (DOS 8+3). CH = 0.
NadjiIme:                               ; Ime je prvo polje od 11 bajtova u dir. stavci
        cmp     byte [es:di], ch        ; Pocetak tekuce direktorijumske stavke je [ES:DI]
        je      ImeNijeNadjeno          ; Kraj direktorijuma. Prvi bajt imena je 0 (nedodeljeno).
        pusha
        repe    cmpsb                   ; Ova instrikcija poredi [DS:SI] sa [ES:DI] 
        popa                            ; Poredi se CX bajtova, pri cemu se CX ne menja
        je      ImeNadjeno              ; Ako je svih CX bajtova medjusobno jednako, ZF=1
        add     di, 32                  ; Sledeca stavka u root direktorijumu
        dec     dx                      ; Da li je u pitanju poslednja stavka direktorijuma?
        jnz     NadjiIme                ; Ako nije, tazi dalje.
ImeNijeNadjeno:
        jmp     GreskaNP
ImeNadjeno:                             ; Pronasli smo trazeno ime datoteke.
        mov     si, [es:di+1Ah]         ; SI = redni broj prvog klastera (start).
                                        ; Ovo je bajt br. 26 u direktorijumskoj stavci.
;----------------------------
; Ucitati kompletni program
;----------------------------

CitajSledeciKlaster:
        call    CitajKlaster
        cmp     si, 0FF8h               ; EOC (End of Chain) moze da bude od 0FF8h do 0FFFh
        jc      CitajSledeciKlaster     ; Ovim se ispituje da li je SI manje od EOC. Ako jeste,
                                        ; ucitava se sledeci klaster.
;--------------------------------
; Ispitivanje tipa (COM ili EXE)
;--------------------------------

        cli                             ; Prlikom raznih podesavanja steka ne sme da dodje do prekida
        mov     ax, ImageLoadSeg
        mov     es, ax
        cmp     word [es:0], 5A4Dh      ; Da li su pva dva bajta "MZ"?
        je      RelocirajEXE            ; Ako jesu, to je EXE program

;-------------------------
; Startovati COM program              
;-------------------------

        mov     ax, es                 
        sub     ax, 10h                ; Treba oduzeti 10h od svih segmentnih registara da bi se
        mov     es, ax                 ; u memoriji napravio prostor za PSP (memorijska struktura velicine 100h
        mov     ds, ax                 ; koju kreira DOS nakon ucitavanja, a pre izvrsavanja programa).
        mov     ss, ax                 ; Mi ne koristimo PSP, ali moramo da uzmemo u obzir memoriju koju zauzima.*
        xor     sp, sp                 ; SP se inicijalizuje na 0000. Zbog osobine 16-bitnog broja (wrap around)
                                       ; prvi PUSH pomera SP na FFFE, tj. na vrh memorijskog segmenta od 64K.
        push    es                     ; Ovaj sadrzaj ES bice vrednost CS nakon izvrsavanja instrukcije RETF.
        push    word 100h              ; Nakon instrukcije RETF, IP se inicijalizuje na 100h.
        jmp     Run                    ; U propratnom materijalu objasnjeno je zasto se ovako predaje kontrola.

; (*) Napomena. Ukoliko ne zelimo kompatibilnost sa MS-DOS-om, mozemo da izostavimo PSP. 
;               Tada ne treba za njega rezervisati prostor (treba izbaciti sub ax, 10h), 
;               inicijalnu vrednost IP treba posaviti na 0 ('push word 0h' umesto 'push word 100h'), 
;               a nasa cista binarna datoteka treba da ima 'ORG 0h' umesto 'ORG 100h'.       
        
;--------------------------------------
; Relocirati i startovati EXE program
;--------------------------------------

RelocirajEXE:
        mov     ds, ax                  ; Segment pocetka EXE slike sa diska (sa zaglavljem): kod nas 60h

        add     ax, [ds:08h]            ; AX = dodaje se velicina zaglavlja u pragrafima (preskacemo zaglavlje)
        mov     cx, [ds:06h]            ; CX = broj relokacionih stavki
        mov     bx, [ds:18h]            ; BX = ofset pocetka RPT (Relocation Pointer Table)

        jcxz    KrajRelokacije          ; Preskoci Relociraj ako je broj relokacionih stavki = 0

Relociraj:                              
        mov     di, [ds:bx]             ; DI = ofset stavke u RPT       | Svaka stavka predstavlja memorijsku adresu  
        mov     dx, [ds:bx+2]           ; DX = segment stavke u RPT     | segmentne adrese koju treba relocirati
        add     dx, ax                  ; DX = na segement stavke dodati segment pocetka programa u memoriji

        push    ds
        mov     ds, dx                  
        add     [ds:di], ax             ; Izvrsiti promenu adrese segmenta na lokaciji stavke
        pop     ds

        add     bx, 4                   ; Sledeca stavka (stavke su DWORD)
        loop    Relociraj

KrajRelokacije:

        mov     bx, ax                  ; Informacije iz zaglavlja koje je upisao linker 
        add     bx, [ds:0Eh]            ; AX sadrzi segment pocetka izvrsnog koda
        mov     ss, bx                  ; Podeseni SS za EXE
        mov     sp, [ds:10h]            ; Inicijalni SP za EXE

        add     ax, [ds:16h]            ; Podeseni CS
        push    ax
        push    word [ds:14h]           ; Inicijalni IP
Run:
        mov     dl, [cs:bsDriveNumber]  ; Posledjujemo broj disk jedinice programu 
        sti                             ; koji startujemo, ako mu to zbog necega treba
        retf
     
        
; --------------------------------------------------------------------------
; FAT klasteri su deo sistema datoteka i oni ne obuhvataju boot sektor,
; sektore koji sadrze FAT tabele niti sektore koji sadrze root direktorijum.
; Klasteri se odnose samo na oblast podataka, koji mogu da budi bilo koja
; vrsta datoteke ili direktorijuma. 
; - FAT klasteri se aresiraju od 2 do n (0 i 1 se ne koriste).
; - LBA trazenog klastera racuna se ovako:
;   (trazeni_klaster - 2) * (broj_sektora_po_klasteru) + LBA_klastera_2
;---------------------------------------------------------------------------

;---------------------------------------------------------------------------
; Zbog istorijskih razloga (efikasnije iskoriscenje tadasnjeg dragocenog
; disk prostora i minimalno pomeranje glave diska), 12-bitne FAT stavke ne
; zauzimaju po 2 bajta (jednu celu 16-bitnu rec), vec se dele medju susednim
; bajtovima na sledeci nacin:
; - Ukoliko je klaster parni, koristiti donjih 12 bitova 16-bitne reci
; - Ukoliko je klaster neparni, koristiti gornjih 12 bitova 16-bitne reci
;
; Zbog toga je velicina FAT tabele 6KB, umesto 8KB 
; Racunica: FAT12 ima 2^12 stavki = 4096 = 4K
; --------  - Ako se svaka adresira sa 2 cela bajta 
;             (16 bitova od kojih se koristi samo 12 donjih) to je 2B*4K=8KB
;           - Ako se svaka stavka adresira sa tacno 12 bitova (1.5 bajtova)
;             to je onda 1.5B*4K=6KB       
;----------------------------------------------------------------------------

;---------------------------------
; Citanje FAT12 klastera    
;---------------------------------
; Ulaz:  ES:BX -> bafer
;        SI = broj klastera 
; Izlaz: SI = sledeci klaster
;        ES:BX -> sledeca adresa
;---------------------------------

CitajKlaster:
        mov     bp, sp

        lea     ax, [si-2]                 ; trazeni_klaster - 2
        xor     ch, ch
        mov     cl, [bpbSectorsPerCluster] ; CX = broj_sektora_po_klasteru         
        mul     cx                         ; (trazeni_klaster - 2) * (broj_sektora_po_klasteru)

        add     ax, [ss:bp+1*2]            ; DX:AX = LBA_trazenog_klastera =
        adc     dx, [ss:bp+2*2]            ; = (trazeni_klaster-2)*(broj_sektora_po_klasteru)+LBA_klastera_2
              
        call    CitajSektor                ; Kopirati sektor u bafer za datoteku
        
        mov     ax, [bpbBytesPerSector]
        shr     ax, 4                      ; AX = broj paragrafa po sektoru
        mul     cx                         ; AX = broj procitanih paragrafa za trazeni klaster  

        mov     cx, es
        add     cx, ax
        mov     es, cx                     ; ES:BX nova vrednost pointera bafera za datoteku

; --------------------------------------
; Deo karakteristican samo za FAT12
; Izlaz: SI = sledeci klaster datoteke
;---------------------------------------

        mov     ax, 3
        mul     si
        shr     ax, 1
        xchg    ax, si                    ; SI = klaster * 3 / 2 = klaster * 1.5
        
        push    ds
        mov     ds, [ss:bp+3*2]           ; DS = memorijski segment gde je smestena FAT              
        mov     si, [ds:si]               ; SI = broj sledeceg klastera iz FAT
        pop     ds

        jnc     CitajParniKlaster         ; Parni klaster prilikom mnozenja sa 1.5 nije imao ostatak

        shr     si, 4                     ; Postavljanje bitova iz neparnog klastera na pravo mesto (0..11)    
                                          ; Sada je sadrzaj SI sa istim vazecim bitovima i za parne i za neparne 
CitajParniKlaster:
        and     si, 0FFFh                 ; Osigurati da su vazeci bitovi na pozicijama od 0..11 (FAT12).
        ret

;---------------------------------------------------
; Citanje sektora upotrebom BIOS INT 13h, funkcija 2 
;---------------------------------------------------
; Ulaz:  DX:AX = LBA      
;        CX = broj sektora koje treba procitati
;        ES:BX -> adresa bafera     
; Izlaz: CF = 1 ako je nastala greska  
;---------------------------------------------------

;---------------------------------------------------
; Parametri koje zahteva BIOS INT 13h, funkcija 2
;---------------------------------------------------  
; AH = 2    (funkcija za citanje sektora)
; AL = broj sektora koje odjednom treba procitati
; CH = cilindar (donjih 8 od 10 bitova)
; CL = preostala dva bita cilindra + 6 bitova za sektor
; DH = glava
; DL = broj disk jedinice
; ES:BX = pointer na bafer gde se smestaju sektori
;----------------------------------------------------

;----------------------------------------------------------
; Konverzija iz LBA u CHS (Cylinder Head Sector):
;---------------------------------------------------------- 
; S = (LBA mod SPT) + 1
; H = (LBA / SPT) mod HPC
; C = (LBA / SPT) / HPC 
; gde su:
;           S - sektor
;           H - glava
;           C - cilindar 
;           SPT - broj sektora po stazi
;           HPC - broj glava po cilindru
;
; Neke BIOS verzije (Western Digital, Phoenix Technologies)
; poseduju tzv. INT 13h Extensions koje direktno rade sa LBA
; ----------------------------------------------------------


CitajSektor:
        pusha

SledeciSektor:
        mov     di, 5                   ; 5 pokusaja citanja

PokusajPonovo:
        pusha                           ; Cuvamo sve registre
        div     word [bpbSectorsPerTrack]    
                ; AX = LBA / SPT          Operacija div daje rezutat deljenja u AX, a ostatak u DX .
                ; DX = LBA mod SPT  = sektor - 1   
        mov     cx, dx
        inc     cx                      ; CX = sektor
        xor     dx, dx
        div     word [bpbHeadsPerCylinder]
                ; AX = (LBA / SPT) / HPC = cilindar               
                ; DX = (LBA / SPT) mod HPC = glava
                                        ; Cilindar se koduje sa 10 bitova, sektor sa 6 bitova
        mov     ch, al                  ; CH = LSB 0...7 od broja cilindra
        shl     ah, 6
        or      cl, ah                  ; CL = MSB 8...9 od broja cilindra + redni broj sektora
                
        mov     dh, dl                  ; DH = broj glave       
        mov     dl, [bsDriveNumber]     ; DL = broj diska     
        mov     ax, 201h                ; AL = ukupan broj sektora koje treba procitati               
                                        ; AH = 2 = funkcija za citanje
        int     13h                     ; Citaj sektor
        jnc     ZavrsenoCitanje         ; CF = 0 ako nema greske
                                        ; Nesto nije u redu. Resetovati disk.
        xor     ah, ah                  ; AH = 0 = reset funkcija
        int     13h                     

        popa
        dec     di
        jnz     PokusajPonovo           
        jmp     short GreskaGC

ZavrsenoCitanje:
        popa
        dec     cx
        jz      KrajCitanja             ; Poslednji sektor

        add     bx, [bpbBytesPerSector] ; Podesiti ofset u baferu za sledeci sektor
        add     ax, 1
        adc     dx, 0                   ; Podesiti LBA za sledeci sektor
        jmp     short SledeciSektor

KrajCitanja:
        popa
        ret

;--------------------
; Poruke o greskama
;--------------------

GreskaGC:
        mov     si, GreskaCitanja
        jmp     short Greska
GreskaNP:
        mov     si, NijePronadjen
Greska:
        mov     ah, 0Eh
        mov     bx, 7

        lodsb
        int     10h                    ; Prvi znak poruke o gresci
        lodsb
        int     10h                    ; Drugi znak poruke o gresci

        jmp     short $                ; Zavrsetak u beskonacnoj petlji :(

;-------------------
; String konstante
;-------------------
 GreskaCitanja      db      "GC"       ; Koristimo skracenice jer nemamo dovoljno prostora
 NijePronadjen      db      "NP"       ; za kompletne poruke unutar 512 bajtova boot sektora.
                                       ; Ovo se resava tako sto boot sektor ucita program "boot loader"
                                       ; koji moze da bude znatno veci od 512 bajtova. Npr., nas STARTUP.BIN
                                       ; moze da bude boot loader!
;------------------------------------------------
; Ispuniti peostali prostor boot sektora nulama
;------------------------------------------------

               times (512-13-($-$$)) db 0

;----------------------------------------------
; Ime programa kojeg treba ucitati i izvrsiti
;----------------------------------------------

ImePrograma     db      "STARTUP BIN"   ; Ime i ekstenzija datoteke moraju da budu dopunjeni
                                        ; praznim mestima (ukupno 11 bajtova, tacka se ne racuna)

;--------------------------
; ID za kraj boot sektora
;--------------------------

                dw      0AA55h
