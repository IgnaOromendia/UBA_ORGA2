
; ==============================================================================
; TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================

extern task

BITS 32
_start:
	call task
	; Si corremos un ret acá va a fallar porque no tenemos a dónde retornar
	;
	; Lo que deberíamos hacer es tener una syscall que nos permita avisar
	; el fin de nuestra ejecución al sistema.
	jmp $
