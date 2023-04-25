extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **
; a[al], b[bl]
; int32_t strCmp(char* a, char* b)
strCmp:
	push rbp
	mov rbp, rsp
	push rbx
	sub rsp, 8
	xor r8, r8

	.cycle
		mov al, [rdi]
		cmp al, r8b
		je .endOfa		
		;cmp bl, 0x0
		;je .mayor
		cmp al, [rsi]
		jg .mayor
		jl .menor
		inc rsi
		inc rdi
		jmp .cycle

	.menor
		mov eax, 1
		jmp .fin

	.mayor
		mov eax, -1
		jmp .fin

	.endOfa
		mov bl, [rsi]
		cmp bl, r8b
		jg .menor
		mov eax, 0
		jmp .fin

	.fin
		add rsp, 8
		pop rbx
		pop rbp
		ret

; char* strClone(char* a) 
;a[rdi]
strClone:
	push rbp,
	mov rbp, rsp

	; salvamos al puntero de a
	mov r12, rdi
	
	;guardamos el largo del string con la func. anterior
	call strLen
	mov edi, eax 
	
	;_malloc con esa length
	extern malloc
	call malloc

	; guardamos el puntero a nuestro nuevo espacio de memoria
	mov rsi, rax

	;recuperamos puntero a nuestro string original
	mov rdi, r12

	;copiamos char per char.
	.cycle:
		mov r9b, [rdi]
		mov [rsi], r9b
		mov r8b, [rdi]
		cmp r8b, 0
		je .end
		inc rsi
		inc rdi
		jmp .cycle

	.end
		pop rbp
		ret

; void strDelete(char* a)
strDelete:
	push rbp
	mov rbp, rsp

	extern free
	call free
	
	pop rbp
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
	push rbp
	mov rbp, rsp

	pop rbp
	ret

; a[rdi]
; uint32_t strLen(char* a)
strLen:
	push rbp
	mov rbp, rsp
	
	xor r8, r8
	mov esi, 0		;accumulator for result
	
	.ciclo
		mov al, [rdi]
		cmp al, r8b
		je .end
		inc rdi
		inc esi
		jmp .ciclo

	.end
		mov eax, esi
		pop rbp
		ret


 