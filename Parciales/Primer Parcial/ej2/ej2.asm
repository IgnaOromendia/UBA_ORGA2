global miraQueCoincidencia

conversor_gris  dd 0.114, 0.587,  0.299, 0

section .data
%define OFFSET_PIXEL_SRC 4
%define OFFSET_PIXEL_DESTINO 1

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
    xor r8, r8      ; iterador N
    xor r9, r9      ; para hacer cuentas
    xor r12, r12    ; it A
    xor r13, r13    ; it B
    xor r14, r14    ; maenja pixel A
    xor r15, r15    ; maenja pixel B
    xor rbx, rbx    ; it dst

    ; cargo los datos en mis registros
    imul rdx, rdx   ; NxN
    mov r12, rdi    ; para iterar A
    mov r13, rsi    ; para iterar B
    mov rbx, rcx    ; para iterar el destino

    .ciclo:
        cmp r8, rdx                             ; if (i < N) continue
        je .fin
        mov r14d, [r12]                         ; levanto pixel A
        mov r15d, [r13]                         ; levanto pixel B
        cmp r14, r15                            ; if (A[i][j] == B[i][j]) jmp else setarlos en 1
        je .sonIguales

        ; si no son iguales hago lo siguiente
        xor r14, r14                            ; seteo en 0
        add r14b, 255                           ; r14 = 255
        mov [rbx], r14b                         ; guardo en destino 
        jmp .avanzar

        .sonIguales:
        ; muevo mis archivos a xmm
        movd xmm0, r14d            ; [0|0|0|r14d] - siendo r14d = [B|G|R|A]

        ; desempaqueto mi pixel para multiplicar
        punpcklbw xmm0, xmm0            ; me quedaron repetidos [0|..|B|B|G|G|R|R|A|A]
        punpcklbw xmm0, xmm0            ; me quedaron repetidos [B|B|B|B|G|G|G|G|R|R|R|R|A|A|A|A]
        psrld xmm0, 24                  ; elimino los repetdios [0|0|0|B|0|0|0|G|0|0|0|R|0|0|0|A]

        cvtdq2ps xmm0, xmm0             ; convierto los 4 integers a floats
        mulps xmm0, [conversor_gris]    ; multiplico cada dword con su correspondiente constante

        ; sumo los colores
        haddps xmm0, xmm0 ; [B+G|R+0|B+G|R+0]
        haddps xmm0, xmm0 ; [..|..|..|B+G+R+0] los .. significan que es lo mismo

        ; convierto de float a interger con truncado y extraigo
        cvttss2si r9, xmm0   ; [..|..|..|B+G+R] pero ahora seria un integer

        ; como se que maximo es 255 se que puedo pedir solo 1 byte
        mov [rbx], r9b                          ; guardo en destino 

        .avanzar:
        lea r12, [r12 + OFFSET_PIXEL_SRC]       ; voy al siguiente pixel de A
        lea r13, [r13 + OFFSET_PIXEL_SRC]       ; voy al siguiente pixel de B
        lea rbx, [rbx + OFFSET_PIXEL_DESTINO]   ; voy al siguiente pixel de destino
        inc r8                                  ; i++
        pxor xmm0, xmm0
        xor r9, r9
        jmp .ciclo
        
    .fin:
        ; epilogo
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbp
        ret
