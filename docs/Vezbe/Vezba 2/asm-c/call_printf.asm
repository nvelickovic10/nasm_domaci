
extern _printf
global _call_printf

section .text

_call_printf:

	push 20
	push poruka
	call _printf ;printf("ispis broja: %d\n", 20);
	
	;pravimo 32-bit aplikaciju, tako da je stek 4-bajtni
	;posto stek raste na dole u memoriji, skidanje sa steka
	;se vrsi dodavanjem na sp
	add sp, 8 ;skidamo dva argumenta sa steka
	
	ret
		
poruka: db 'ispis broja: %d',10,0 ;10 je \n