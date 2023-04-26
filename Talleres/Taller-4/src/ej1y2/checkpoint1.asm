section .data

mask db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ,11 ,12 ,13, 14, 15

section .text

global invertirBytes_asm

; void invertirBytes_asm(uint8_t* p, uint8_t n, uint8_t m)
; [rdi] [rsi-sil] [rcx-cl]
invertirBytes_asm:
	push rbp
	mov rbp, rsp

	; seteo en 0
	xor r8, r8
	xor r9, r9
	pxor xmm0, xmm0
	pxor xmm1, xmm1

	mov r8b, sil
	mov r9b, dl

	; me fijo si son iguales
	cmp r8, r9
	je .fin

	; swapeo entre n y m en la mascara
	mov byte [mask + rsi], dl
	mov byte [mask + rdx], sil

	movdqu xmm0, [rdi]
	movdqu xmm1, [mask]

	; hago el swap
	pshufb xmm0, xmm1

	; apunto a mi nuevo swap
	movdqu [rdi], xmm0

	; revierto la máscara para los otros tests
	mov byte [mask + rsi], sil
	mov byte [mask + rdx], dil

	.fin:
	pop rbp
	ret