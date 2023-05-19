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
	pxor xmm1, xmm1	; contenedor A2
	pxor xmm3, xmm3	; contenedor B2
	xor r12, r12 	; para multiplicar

	; itA = 0, itB = 128, itC = 256
	mov rcx, rdi 			; iterador A
	lea r9, [rdi + 128]		; iterador B		
	lea r8, [rdi + 256]		; iterador C

	; recorremos el ciclo en busca del error
	.ciclo:
		cmp ebx, esi						; if(i == n)
		je .fin

		; cargamos valores
		movdqa xmm0, [rcx] 					; cargo los 8 de A
		movdqa xmm2, [r9]					; cargo los 8 de B
		movdqa xmm4, [r8]					; cargo los primeros 4 de C
		movdqa xmm5, [r8 + OFFSET_C]		; cargo los útlimos 4 de C

		movdqa xmm3, xmm0					; copiro los 8 de A en xmmm3
		punpcklwd xmm1, xmm0				; copio los últimos 4 de A a xmm1  [0|A3|0|A2|0|A1|0|A0]
		pxor xmm0, xmm0						; seteo en 0
		punpckhwd xmm0, xmm3				; copio los primeros 4 de A a xmm0 [0|A7|0|A6|0|A5|0|A4]
		pxor xmm3, xmm3						; seteo en 0

		movdqa xmm5, xmm2					; copio los 8 de B en xmm5
		punpcklwd xmm3, xmm2				; copio los últimos 4 de B a xmm3  [0|B3|0|B2|0|B1|0|B0]
		pxor xmm2, xmm2						; seteo en 0
		punpckhwd xmm2, xmm5				; copio los primeros 4 de B a xmm2 [0|B7|0|B6|0|B5|0|B4]
		pxor xmm5, xmm5						; seteo en 0

		; sumamos a + b
		paddsw xmm0, xmm2    				; los primeros 4 A + B
		paddsw xmm1, xmm3					; los últimos 4 A + B

		; multiplicamos por 8
		; para ahorrarme el trabajo de hacer h y l
		; convierto a float -> mutlipico por 8 -> convierto a integer
		cvtdq2ps xmm0, xmm0
		cvtdq2ps xmm1, xmm1

		mulps xmm0, [ocho]
		mulps xmm1, [ocho]

		cvttps2dq xmm0, xmm0
		cvttps2dq xmm1, xmm1
		
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
		

	.fin:
		pop r13
		pop r12
		pop rbp
		ret

