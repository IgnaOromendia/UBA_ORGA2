section .data

%define OFFSET_SIGUIENTE 256

section .text

global checksum_asm

; uint8_t checksum_asm(void* array, uint32_t n)
; array [rdi], n [rsi]
; c_ij = (a_ij + b_ij) * 8
checksum_asm:
	push rbp,
	mov rbp, rsp
	
	; seteamos en 0
	xoe rbx, rbx	; iteardor N
	xor rcx, rcx 	; iterador A
	xor r9, r9		; iterador B
	xor r8, r8		; iterador C
	xor rdx, rdx	; suma
	pxor xmm0, xmm0 ; contenedor A
	pxor xmm1, xmm1	; contenedor B
	pxor xmm2, xmm2	; contenedor C1
	pxor xmm3, xmm3	; contenedor C2

	; itA = 0, itB = 128, itC = 256
	lea rcx, rdi
	lea r9, rdi + 128
	lea r8, rdi + 256 

	; recorremos el ciclo en busca del error
	.ciclo:
		cmp ebx, esi			; if(i == n)
		je .fin
		; cargamos valores
		movdqu xmm0, [rcx] 		; cargo los 8 de A
		movdqu xmm1, [r9]		; cargo los 8 de B
		movdqu xmm2, [r8]		; cargo los primeros 4 de C
		movdqu xmm3, [r8 + 128] ; cargo los ultimos 4 de C

		; sumamos a + b
		
		; mulitplicamos por 8

		; comparamos con C




	.fin:
		pop rbp
		ret

