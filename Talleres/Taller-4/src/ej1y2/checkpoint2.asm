section .data
ocho: dd 8, 8, 8, 8

%define OFFSET_SIGUIENTE 256
%define OFFSET_AB 64
%define OFFSET_C 128

section .text

global checksum_asm

; uint8_t checksum_asm(void* array, uint32_t n)
; array [rdi], n [rsi]
; c_ij = (a_ij + b_ij) * 8
checksum_asm:
	push rbp,
	mov rbp, rsp
	push r12
	push r13
	
	; seteamos en 0
	xor rbx, rbx	; iteardor N
	xor rcx, rcx 	; iterador A
	xor r9, r9		; iterador B
	xor r8, r8		; iterador C
	xor rdx, rdx	; suma
	pxor xmm0, xmm0 ; contenedor A1
	pxor xmm1, xmm1	; contenedor A2
	pxor xmm2, xmm2	; contenedor B1
	pxor xmm3, xmm3	; contenedor B2
	pxor xmm4, xmm4	; contenedor C1
	pxor xmm5, xmm5	; contenedor C2
	xor r12, r12 	; para multiplicar
	xor r13, r13	;

	; itA = 0, itB = 128, itC = 256
	mov rcx, rdi
	mov r9, rdi
	add r9, 128
	mov r8, rdi
	add r8, 256

	; recorremos el ciclo en busca del error
	.ciclo:
		cmp ebx, esi			; if(i == n)
		je .fin
		; cargamos valores
		pmovsxwd xmm0, [rcx] 				; cargo los primeros 4 de A
		pmovsxwd xmm1, [rcx + OFFSET_AB]  	; cargo los ultimos 4 de A
		pmovsxwd xmm2, [r9]					; cargo los primeros 4 de B
		pmovsxwd xmm3, [r9 + OFFSET_AB]		; cargo los ultimos 4 de B
		pmovsxwd xmm4, [r8]					; cargo los primeros 4 de C
		pmovsxwd xmm5, [r8 + OFFSET_C] 		; cargo los ultimos 4 de C

		; sumamos a + b
		paddsw xmm0, xmm2    				; los primeros 4 A + B
		paddsw xmm1, xmm3					; los ultimos 4 A + B

		; mulitplicamos por 8
		; suma 7
		extractps r12, xmm0, 3				; Obtengo A7+B7
		imul r12, 8							; multiplico por 8
		pinsrd xmm0, r12d, 3					; inserto de vuelta multiplicado
		xor r12, r12
		; suma 6
		extractps r12, xmm0, 2				; Obtengo A6+B6
		imul r12, 8							; multiplico por 8
		pinsrd xmm0, r12d, 2					; inserto de vuelta multiplicado
		xor r12, r12
		; suma 5
		extractps r12, xmm0, 1				; Obtengo A5+B5
		imul r12, 8							; multiplico por 8
		pinsrd xmm0, r12d, 1					; inserto de vuelta multiplicado
		xor r12, r12
		; suma 4
		extractps r12, xmm0, 0				; Obtengo A4+B4
		imul r12, 8							; multiplico por 8
		pinsrd xmm0, r12d, 0					; inserto de vuelta multiplicado
		xor r12, r12
		; suma 3
		extractps r12, xmm1, 3				; Obtengo A3+B3
		imul r12, 8							; multiplico por 8
		pinsrd xmm1, r12d, 3					; inserto de vuelta multiplicado
		xor r12, r12
		; suma 2
		extractps r12, xmm1, 2				; Obtengo A2+B2
		imul r12, 8							; multiplico por 8
		pinsrd xmm1, r12d, 2					; inserto de vuelta multiplicado
		xor r12, r12
		; suma 1
		extractps r12, xmm1, 1				; Obtengo A1+B1
		imul r12, 8							; multiplico por 8
		pinsrd xmm1, r12d, 1					; inserto de vuelta multiplicado
		xor r12, r12
		; suma 0
		extractps r12, xmm1, 0				; Obtengo A0+B0
		imul r12, 8							; multiplico por 8
		pinsrd xmm1, r12d, 0					; inserto de vuelta multiplicado
		xor r12, r12
		
		; comparamos con C
		pcmpeqd xmm0, xmm4					; Comparo los primeros 4 (A+B)*8
		pcmpeqd xmm1, xmm5					; Comparo los ultimos  4 (A+B)*8

		; me fijo si hay alguno 0
		pextrq r12, xmm0, 0		
		cmp r12, 1
		jne .noIguales

		pextrq r12, xmm0, 1		
		cmp r12, 1
		jne .noIguales

		pextrq r12, xmm1, 0
		cmp r12, 1
		jne .noIguales

		pextrq r12, xmm0, 1		
		cmp r12, 1
		jne .noIguales

		lea rcx, [rcx + OFFSET_SIGUIENTE]
		lea r9,  [r9  + OFFSET_SIGUIENTE]
		lea r8,  [r8  + OFFSET_SIGUIENTE]

		jmp .ciclo

		.noIguales:
		mov eax, 0
		jmp .fin
		

	.fin:
		pop r13
		pop r12
		pop rbp
		ret

