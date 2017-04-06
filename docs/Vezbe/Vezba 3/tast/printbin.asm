; ========================================================
; Program ispisuje unapred zadat integer broj na ekranu
; ========================================================
	  
_print_bin:
	  pusha
	  mov  cx, 8
.petlja:
      push ax
	  and  al, 80h
	  jz   .nula
	  mov  al, 31h
	  jmp  .ispis
.nula:
      mov  al, 30h
.ispis:
	  mov  ah, 0eh
	  int  10h
	  pop  ax
	  sal  ax, 1
	  loop .petlja

      popa
	  ret
	  