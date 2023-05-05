section .data

max: db 255

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
	xor r12, r12	; iterador N
	xor r13, r13	; iterador src
	xor r14, r14	; iterador dst
	xor r15, r15
	pxor xmm0, xmm0 ; pixeles src

	; seteamos valores
	mov r13, [rdi]
	mov r14, [rsi] 

	.ciclo: 
		



	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret
	


