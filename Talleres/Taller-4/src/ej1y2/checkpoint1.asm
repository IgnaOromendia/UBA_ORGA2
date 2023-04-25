
section .text

global invertirBytes_asm

; void invertirBytes_asm(uint8_t* p, uint8_t n, uint8_t m)
; [rdi] [rsi-sil] [rcx-cl]
invertirBytes_asm:
	push rbp
	mov rbp, rsp

	; seteo en 0
	xor r8, r8
	xor xmm0, xmm0

	mov xmm0, [rdi] ; cargo los 128 bits

	pop rbp
	ret