section .data

max: db 255
%define OFFSET_SIGUIENTES4PX 128

section .text

global Offset_asm

; *src [rdi], *dst [rsi], width [rdx], height [rcx], src_row_size [r8], dst_row_size [r9]
Offset_asm:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15

	; seteamos en 0
	xor r12, r12	; iterador i (Height)
	xor r13, r13	; iterador j (Width)
	xor r14, r14	; iterador src
	xor r15, r15	; iterador dst
	pxor xmm0, xmm0 ; pixeles src
	pxor xmm1, xmm1 ; pixeles dst

	; seteamos valores
	mov r14, [rdi]
	mov r15, [rsi] 

	.cicloH: 
		cmp r12, rdx	; if (i == height) 
		je .fin
		.cicloW:
			cmp r13, rcx		; if (j == width)
			je .finW
			inc r13				; j++
			movdqu xmm0, [r14]	; cargo 4 pixeles de src
			cmp r12, 8			; if (i < 8)
			jl .aplicarMarco
			cmp r13, 0			; if (j == 0)
			je .aplicarMarco
			cmp r13, 

			.aplicarMarco:


		.finW:
		xor r13, r13 	; j = 0
		inc r12			; i++
		jmp .cicloH		
		
	.fin:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret
	


