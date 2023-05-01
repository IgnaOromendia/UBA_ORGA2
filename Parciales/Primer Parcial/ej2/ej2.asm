global miraQueCoincidencia

section .data
gris_red: dd 0.2990
gris_green: dd 0.5870
gris_blue: dd 0.1140

%define OFFSET_PIXEL_SRC 32
%define OFFSET_PIXEL_DESTINO 8
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
    xor r12, r12    ; para hacer cuentas
    xor r13, r13
    xor r14, r14
    xor r15, r15
    xor rbx, rbx

    ; cargo los datos en mis registros
    mov r9d, edx    ; N
    imul r9d, r9d   ; NxN
    mov r12, rdi    ; para iterar A
    mov r13, rsi    ; para iterar B
    mov rbx, rcx    ; para iterar el destino

    .ciclo:
        mov r14d, [r12]                         ; levanto pixel A
        mov r15d, [r13]                         ; levanto pixel B
        cmp r8, r9                              ; if (i < N) continue
        je .fin
        cmp r14, r15                            ; if (A[i][j] == B[i][j]) jmp else setarlos en 1
        je .sonIguales
        ; si no son iguales hago lo siguiente
        xor r14, r14                            ; seteo en 0
        andn r14,r14                            ; seteo todo en 1
        mov [rbx], r14d                         ; guardo en destino 
        lea r12, [r12 + OFFSET_PIXEL_SRC]       ; voy al siguiente pixel de A
        lea r13, [r13 + OFFSET_PIXEL_SRC]       ; voy al siguiente pixel de B
        lea rbx, [rbx + OFFSET_PIXEL_DESTINO]   ; voy al siguiente pixel de destino
        add r8, OFFSET_PIXEL_SRC                ; i++

        .sonIguales
        ; muevo mis archivos a xmm
        movd xmm0, dword r14            ; [0|0|0|r14d] - siendo r14d = [B|G|R|A]

        ; desmpaquto mi pixel para multiplicar
        punpcklbw xmm0, xmm0            ; me quedaron repetidos [B|B|G|G|R|R|A|A]
        psrlw xmm0, 1                   ; elimino los repetdios [0|B|0|G|0|R|0|A]

        ; multiplco el xmm0 con cada const rgb dependiendo el offset rgb
        ; extraigo uno por uno de los colores en el orden que son recibidos
        ; BLUE
        extractps xmm0, r12, 3          ; otbengo [0|B] en r12
        imul r12, gris_blue             ; BLUE(px) * 0.114
        pinsrd r12, xmm0, 3             ; seteo en el xmm0 la parte de blue multiplicada
        ; GREEN
        xor r12, r12                    ; seteo en 0
        extractps xmm0, r12, 2          ; otbengo [0|G] en r12
        imul r12, gris_green            ; GREEN(px) * 0.587
        pinsrd r12, xmm0, 2             ; seteo en el xmm0 la parte de green multiplicada
        ; RED
        xor r12, r12                    ; seteo en 0
        extractps xmm0, r12, 1          ; otbengo [0|R] en r12
        imul r12, gris_red              ; RED(px) * 0.299
        pinsrd r12, xmm0, 1             ; seteo en el xmm0 la parte de red multiplicada
        ; ALFA - como el alfa va a ser ignorado lo seteo en 0 para la suma
        xor r12, r12                    ; seteo en 0
        pinsrd r12, xmm0, 0             ; seteo en el xmm0 0 al alfa para ignroarlo

        ; unifico los colores - ahroa tengo [B|G|R|0] en xmm0
        phaddd xmm0, xmm0 ; [B+G|R+0|B+G|R+0]
        phaddd xmm0, xmm0 ; [..|..|..|B+G+R+0] los .. significan que es lo mismo

        ; Paso la suma de 32 bits a 16, con saturación
        packusdw xmm0, xmm0 

        ; Paso la suma de 16 bits a 8, con saturación
        packuswb xmm0, xmm0

        ; seteo en 0
        xor r14, r14

        ; extraigo el byte 0 que representa la suma de los colores
        pextrb xmm0, r14

        mov [rbx], r14b                         ; guardo en destino 
        lea r12, [r12 + OFFSET_PIXEL_SRC]       ; voy al siguiente pixel de A
        lea r13, [r13 + OFFSET_PIXEL_SRC]       ; voy al siguiente pixel de B
        lea rbx, [rbx + OFFSET_PIXEL_DESTINO]   ; voy al siguiente pixel de destino
        add r8, OFFSET_PIXEL_SRC                ; i++
        
    .fin:
        ; epilogo
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbp
        ret
