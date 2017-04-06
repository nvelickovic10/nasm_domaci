
#include <stdio.h>

extern void call_printf();

int main()
{
	call_printf();
	
	printf("zavsio asm\n");
	
	return 0;
}