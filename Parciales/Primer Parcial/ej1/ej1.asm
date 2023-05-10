global templosClasicos
global cuantosTemplosClasicos
extern malloc

section .data
%define OFFSET_COL_CORTO 16
%define OFFSET_COL_LARGO 0
%define OFFSET_NOMBRE 8
%define OFFSET_SIGUIENTE 24

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;templo* templosClasicos(templo *temploArr, size_t temploArr_len);
; temploArr* [rdi], temploArr_len [rsi]
templosClasicos:
    push rbp
    mov rbp, rsp

    ; prologo
    push r12
    push r13
    push r14
    push r15

    ; seteo en 0
    xor r12, r12
    xor r13, r13
    xor r14, r14

    ; guardo mis variables
    mov r12, rsi ; para no perder el size
    mov r13, rdi ; para no perder el punter
    mov r14, rdi ; para ir moviendome por el array

    ; calculo la cantidad de templos clasicos
    call cuantosTemplosClasicos

    ; seteo en 0
    xor rdi, rdi ; cant templos clasicos

    ; obtengo cantidad de clasicos
    mov rdi, rax 

    ; generar un nuevo arreglo

    imul rdi, 24 ; como cada struct ocupa 24 bytes, multiplico la cantidad de clasicos por la cantdidad que ocupa en memoria uno
    call malloc 

    ; seteo en 0
    xor rdi, rdi    ; puntero al nuevo arreglo  
    xor rsi, rsi    ; donde me voy a mover por el nuevo arreglo
    xor r15, r15    ; nombre
    xor rdx, rdx    ; iterador i
    xor rcx, rcx    ; copia de n

    ; obtengo el puntero a mi nuevo arreglo
    mov rdi, rax    ; para devloverlo
    mov rsi, rax    ; para poder ir iterandolo

    ; recorro el arreglo
    .ciclo:
        xor r8, r8
        xor r9, r9
        xor r15, r15
        cmp rdx, r12
        je .fin
        ; es clasica?
        mov r8b, [r14 + OFFSET_COL_CORTO]   ; obtengo n
        mov rcx, r8                         ; copia de n
        mov r9b, [r14 + OFFSET_COL_LARGO]   ; obtengo m
        imul r8, 2                          ; 2n
        inc r8                              ; 2n+1
        inc rdx                             ; i++
        lea r14, [r14 + OFFSET_SIGUIENTE]   ; apunto al siguiente templo del array templos
        cmp r8, r9                          ; if (2n+1 == m)
        jne .ciclo
        ; agrego al nuevo arreglo
        mov r15, [r14 + OFFSET_NOMBRE - 24] ; obtengo nombre
        mov [rsi + OFFSET_COL_CORTO], cl    ; agrego el n
        mov [rsi + OFFSET_NOMBRE]   , r15   ; agrego el nombre
        mov [rsi + OFFSET_COL_LARGO], r9b   ; agrego el m
        lea rsi, [rsi + OFFSET_SIGUIENTE]   ; apunto al siguiente templo del array templos clasicos
        jmp .ciclo

    .fin:
    mov rax, rdi ; return el puntero al nuevo array

    ; epilogo
    pop r15
    pop r14
    pop r13
    pop r12

    pop rbp
    ret

;uint32_t cuantosTemplosClasicos(templo *temploArr, size_t temploArr_len);
; temploArr [rdi], temploArr_len [rsi]
cuantosTemplosClasicos:
    push rbp
    mov rbp, rsp

    ; prologo
    push r12
    push r13 ; alienada

    ;seteo en 0
    xor rcx, rcx ; size
    xor rdx, rdx ; iterador i
    xor r12, r12 ; contador de templos clasicos

    mov rcx, rsi    ; guardo size
    mov r13, rdi    ; guardo el puntero

    ; recorro el arreglo
    .ciclo:
        ; restuaro valores
        xor r8, r8
        xor r9, r9
        ; es clasica?
        cmp rdx, rcx                        ; if (i == temploArr_len)
        je .fin
        mov r8b, [r13 + OFFSET_COL_CORTO]   ; obtengo n
        mov r9b, [r13 + OFFSET_COL_LARGO]   ; obtengo m
        imul r8, 2                          ; n = 2n
        inc r8                              ; n++
        inc rdx                             ; i++
        lea r13, [r13 + OFFSET_SIGUIENTE]   ; apunto al siguiente templo
        cmp r8, r9                          ; if (2n+1 == m)
        jne .ciclo
        inc r12                             ; contador ++
        jmp .ciclo

    .fin:
        mov eax, r12d

        ; epilogo
        pop r13
        pop r12

        ; return
        pop rbp
        ret


