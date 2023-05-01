global miraQueCoincidencia

section .data
gris_red dd 0.2990
gris_green dd 0.5870
gris_blue dd 0.1140
mask dw 8

%define OFFSET_XMM 16
%define OFFSET_PIXEL 32
%define OFFSET_ROJO 16
%define OFFSET_BLUE 0
%define OFFSET GREEN 8

;########### SECCION DE TEXTO (PROGRAMA)
section .text
; void miraQueCoincidencia( uint8_t *A, uint8_t *B, uint32_t N, uint8_t *laCoincidencia )
; [rdi], [rsi], [rdx], [rcx]
miraQueCoincidencia:
    push rbp
    mov rbp, rsp

    ; prologo
    push r12
    push r13
    push r14
    push r15

    ; seteo en 0
    pxor xmm0, xmm0 ; pixel de A
    pxor xmm1, xmm1 ; pixel de B
    pxor xmm2, xmm2 ; resultado
    xor r8, r8      ; iterador 
    xor r9, r9      ; N
    xor r12, r12
    xor r13, r13
    xor r14, r14
    xor r15, r15
    xor rbx, rbx

    ; cargo los datos en mis registros
    mov r9d, edx    ; N
    mov r12, rdi    ; para iterar A
    mov r13, rsi    ; para iterar B
    mov rbx, rcx    ; para iterar el destino

    .ciclo:
        mov r14d, [r12] ; levanto pixel A
        mov r15d, [r13] ; levanto pixel B
        cmp r8, r9                      ; if (i < N) continue
        je .fin
        cmp r14, r15                    ; if (A[i] == B[i]) jmp else setarlos en 1
        je .sonIguales
        ; si no son iguales hago lo siguiente
        xor r14, r14                    ; seteo en 0
        andn r14,r14                    ; seteo todo en 1
        mov [rbx], r14d                 ; guardo en destino 
        lea r12, [r12 + OFFSET_PIXEL]   ; voy al siguiente pixel de A
        lea r13, [r13 + OFFSET_PIXEL]   ; voy al siguiente pixel de B
        lea rbx, [rbx + OFFSET_PIXEL]   ; voy al siguiente pixel de destino
        add r8, OFFSET_PIXEL            ; i++

        .sonIguales
        ; muevo mis archivos a xmm
        movd xmm0, dword r14
        ; desmpaquto mi pixel para multiplicar
        punpcklbw xmm0, xmm0            ; me quedaron repetidos
        psllw xmm0, 4                   ; elimino los repetdios 
        ; multipico
        ; aca multiplco el xmm0 con cada const rgb dependiendo el offset rgb
        
        ; hago la combinacion de colores
        ; ... 
        ; lo vuelvo a pasar a un registro de 32 con un convert
        mov [rbx], r14d                 ; guardo en destino 
        lea r12, [r12 + OFFSET_PIXEL]   ; voy al siguiente pixel de A
        lea r13, [r13 + OFFSET_PIXEL]   ; voy al siguiente pixel de B
        lea rbx, [rbx + OFFSET_PIXEL]   ; voy al siguiente pixel de destino
        add r8, OFFSET_PIXEL            ; i++
        
    .fin:
        ; epilogo
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbp
        ret
