extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_simplified
global alternate_sum_8
global product_2_f
global alternate_sum_4_using_c

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[?], x2[?], x3[?], x4[?]
alternate_sum_4:
	;prologo
	push rbp
	mov rbp, rsp
	;cuando alinear y cuando no?
	;sub rsp, 0x8

	;Hacemos la operacion
	sub edi , esi
	sub edx, ecx
	add edx, edi
	
	;recordar que si la pila estaba alineada a 16 al hacer la llamada
	;con el push de RIP como efecto del CALL queda alineada a 8

	;epilogo
	;guardamos en el registro de retorno el resultado de la operacion
	mov eax, edx
	pop rbp
	ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_using_c:
	;prologo
	push rbp ; alineado a 16
	mov rbp, rsp

	;Guardamos en rdi el resultado de x1 - x2
	call restar_c
	mov rdi, rax
	mov rsi, rdx ;Prologo para la sumar_c

	;Guardamos en rdi el resultado de (x1 - x2) + x3
	call sumar_c
	mov rdi, rax
	mov rsi, rcx ;Prologo para el segundo restar_C

	;Guardamos en rax el resultado de (x1 - x2 + x3) - x4
	call restar_c
	
	;epilogo
	pop rbp
	ret
; uint32_t alternate_sum_4_simplified(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[?], x2[?], x3[?], x4[?]
alternate_sum_4_simplified:
	sub rdi , rsi
	sub rdx, rcx
	add rdx, rdi
	mov rax, rdx
	ret
; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[rdi], x2[rsi], x3[rdx], x4[rcx], x5[r8], x6[r9], x7[rbp+0x10], x8[rbp + 0x18]
alternate_sum_8:
	;prologo
	push rbp ; alineado a 16
	mov rbp, rsp
	;x1 - x2 + x3 - x4 + x5 - x6 + x7 - x8
	
	sub rdi, rsi
	add rdi, rdx
	sub rdi, rcx
	add rdi, r8
	sub rdi, r9
	add rdi, [rbp+0x10]
	sub rdi, [rbp+0x18]
	
	mov rax, rdi
	;epilogo
	pop rbp
	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[rdi], x1[rsi], f1[xmm0]
product_2_f:
	; x1 * f1
	push rbp
	mov rbp, rsp

	cvtsi2ss xmm1, rsi ; convertimos el entero en float
	mulss xmm0, xmm1 ; multiplicamos
	cvttss2si rax, xmm0 ; convertimos el resultado flotante a entero
	
	mov [rdi], rax ; guardamos el resultado en el destino

	pop rbp
	ret

