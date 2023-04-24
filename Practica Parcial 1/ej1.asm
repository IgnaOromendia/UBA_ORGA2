
global strArrayNew
global strArrayGetSize
global strArrayGet
global strArrayRemove
global strArrayDelete

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

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

	.end:
		pop rbp
		ret

; str_array_t* strArrayNew(uint8_t capacity) rdi
strArrayNew:
    push rbp
    mov rbp, rsp

    push r12    ; guardo los registros no volatiles
    push r13    ; guardo los registros no volatiles

    mov r12, rdi ; guardo la capacidad
    imul rdi, 8 ; como cada puntero a string ocupa 8bytes
    call malloc
    ; rax = puntero al inicio del array

    mov r13, rax ; guardo el rax en uno no volatil

    xor rdi, rdi ; seteo rdi en 0
    ; size = 8bits = 1byte
    ; capacity = 8bits = 1byte
    ; data = 64btis = 8bytes
    ; total 10 bytes
    ; para que quede alineada 2 + 6 + 8, con 6 de padding
    add rdi, 16
    call malloc
    ; rax = puntero de inicio del struct

    mov [rax], 0        ; size = 0
    mov [rax+1], r12    ; capcity = capacity (guardado en r12)
    mov [rax+8], r13    ; data = r13 (donde empieza el array)

    pop r12
    pop r13
    pop rbp
    ret


; uint8_t  strArrayGetSize(str_array_t* a)
strArrayGetSize:
    push rbp
    mov rbp, rsp

    xor rax, rax    ; limpio el rax
    mov al, [rdi]   ; devuelvo el size

    pop rbp
    ret

; void  strArrayAddLast(str_array_t* a, char* data); [rdi] [rsi]
strArrayAddLast:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    ; vamos a ver que hay capacidad suficiente
    mov r13, [rdi+1] ; obtengo la capacidad
    mov r14, [rdi]   ; obtengo el size
    cmp r14, r13
    je .nada

    mov r12, rdi
    mov rdi, rsi
    call strClone        ; copiamos el string y tenemos un puntero en rax

    mov r15, [r12+8]     ; obtengo el puntero al inico del array
    mov [r15+r14*8], rax ; agrego al final del array el nuevo string
    inc r14b             ; incrementamos el size
    mov [r12], r14b      ; guardamos el nuevo size

    .nada:
        pop r12
        pop r13
        pop r14
        pop r15
        pop rbp
        ret

; char* strArrayGet(str_array_t* a, uint8_t i) [rdi], [rsi] 
strArrayGet:
    push rbp
    mov rbp, rsp

    ; chequeo que el indice sea valido (0 ≤ i < size)
    xor r8, r8
    mov r9b, [rdi] ; obtengo el size
    cmp sil, r9b
    jge .nada
    cmp sil, r8b
    je .nada

    mov rcx, [rdi+8]; obtengo el puntero al inicio del arreglo
    mov rax, [rcx+rsi*8] ; obtengo el i-esimo

    .nada:
        pop rbp
        ret

; char* strArrayRemove(str_array_t* a, uint8_t i)
strArrayRemove:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    ; sete en 0
    xor r9, r9
    xor r8, r8
    xor r12, r12

    ; chequep que 0 ≤ i < size
    mov r9b, sil        ; guardo el i
    mov r12b, [rdi]     ; obtengo el size
    cmp r9b, r12b       ; comparo i con sie
    jge .nada
    cmp r9b, r8b        ; comparo i con 0
    je .nada

    ; muevo al rax el i-esimo
    mov r13, [rdi+8]       ; obtengo el puntero al array
    mov rax, [r13+r9*8]    ; me muevo hasta el i-esimo

    ; me fijo si no es el ultimo elemento
    cmp r9b, r12b
    je .guardar

    ; movemos string por string hacia la izquierda
    xor r14, r14            ; seteo en 0 r14
    mov r14, [r13+r9*8]     ; me muevo al i
    inc r14                 ; me muevo al i+1
    ; la idea es ir haceindo j = i+1 -> j+1 = i+2 ...
    .ciclo:
        mov [r13+r9*8], r14     ; arr[i] = siguiente
        inc r9                  ; i += 1
        cmp r9b, r12b           ; i == size
        je .guardar
        mov r14, [r13+r9*8]     ; siguiente = arr[i+1]
        jmp .ciclo

    .guardar:
        dec r12b            ; size - 1
        mov [rdi], r12b     ; guardo el size
        jmp .nada

    .nada:
        pop r12
        pop r13
        pop r14
        pop r15
        pop rbp
        ret


; void  strArrayDelete(str_array_t* a)
strArrayDelete:


