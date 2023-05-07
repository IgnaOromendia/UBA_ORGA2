global miraQueCoincidencia

section .data
gris_red:   dd 0.299
gris_green: dd 0.587
gris_blue:  dd 0.114

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
        mov r14d, [r12]                         ; levanto pixel A
        mov r15d, [r13]                         ; levanto pixel B
        cmp r8, rdx                             ; if (i < N) continue
        je .fin
        cmp r14, r15                            ; if (A[i][j] == B[i][j]) jmp else setarlos en 1
        je .sonIguales
        ; si no son iguales hago lo siguiente
        xor r14, r14                            ; seteo en 0
        add r14b, 255                           ; r14 = 255
        mov [rbx], r14                          ; guardo en destino 
        lea r12, [r12 + OFFSET_PIXEL_SRC]       ; voy al siguiente pixel de A
        lea r13, [r13 + OFFSET_PIXEL_SRC]       ; voy al siguiente pixel de B
        lea rbx, [rbx + OFFSET_PIXEL_DESTINO]   ; voy al siguiente pixel de destino
        inc r8                                  ; i++
        jmp .ciclo

        .sonIguales:
        ; muevo mis archivos a xmm
        movd xmm0, r14d            ; [0|0|0|r14d] - siendo r14d = [B|G|R|A]

        ; desempaqueto mi pixel para multiplicar
        punpcklbw xmm0, xmm0            ; me quedaron repetidos [0|..|B|B|G|G|R|R|A|A]
        punpcklbw xmm0, xmm0            ; me quedaron repetidos [B|B|B|B|G|G|G|G|R|R|R|R|A|A|A|A]
        psrld xmm0, 24                  ; elimino los repetdios [0|0|0|B|0|0|0|G|0|0|0|R|0|0|0|A]

        ; multiplco el xmm0 con cada const rgb dependiendo el offset rgb
        ; extraigo uno por uno de los colores en el orden que son recibidos
        ; quiero extraer 24 bits de 0s y 8 bits de data
        ; BLUE
        extractps r9, xmm0, 0          ; otbengo [0|0|0|B] en r9
        cvtsi2ss xmm1, r9              ; convierto de entero a punto flotante
        mulss xmm1, [gris_blue]        ; BLUE(px) * 0.114
        extractps r9, xmm1, 0          ; otbengo la dw multiplicada en r9
        pinsrd xmm0, r9d, 0            ; seteo en el xmm0 la parte de blue multiplicada

        ; GREEN
        extractps r9, xmm0, 1          ; otbengo [0|0|0|G] en r9
        cvtsi2ss xmm1, r9              ; convierto de entero a punto flotante 
        mulss xmm1, [gris_green]         ; GREEN(px) * 0.587
        extractps r9, xmm1, 0          ; otbengo la dw multiplicada en r9
        pinsrd xmm0, r9d, 1            ; seteo en el xmm0 la parte de green multiplicada

        ; RED
        extractps r9, xmm0, 2          ; otbengo [0|0|0|R] en r9
        cvtsi2ss xmm1, r9              ; convierto de entero a punto flotante
        mulss xmm1, [gris_red]         ; RED(px) * 0.299
        extractps r9, xmm1, 0          ; otbengo la dw multiplicada en r9
        pinsrd xmm0, r9d, 2            ; seteo en el xmm0 la parte de red multiplicada

        ; ALFA - como el alfa va a ser ignorado lo seteo en 0 para la suma
        xor r9, r9                     ; setea en 0
        pinsrd xmm0, r9d, 3            ; seteo en el xmm0 0 al alfa para ignroarlo

        ; unifico los colores - ahroa tengo [B|G|R|0] en xmm0
        haddps xmm0, xmm0 ; [B+G|R+0|B+G|R+0]
        haddps xmm0, xmm0 ; [..|..|..|B+G+R+0] los .. significan que es lo mismo

        ; convierto de float a interger con truncado y extraigo
        cvttps2dq xmm0, xmm0    ; [0|0|0|B+G+R] pero ahora seria un integer
        extractps r9, xmm0, 0  ; extraigo la suma

        ; como se que maximo es 255 se que puedo pedir solo 1 byte
        mov [rbx], r9b                          ; guardo en destino 
        lea r12, [r12 + OFFSET_PIXEL_SRC]       ; voy al siguiente pixel de A
        lea r13, [r13 + OFFSET_PIXEL_SRC]       ; voy al siguiente pixel de B
        lea rbx, [rbx + OFFSET_PIXEL_DESTINO]   ; voy al siguiente pixel de destino
        inc r8                                  ; i++
        pxor xmm0, xmm0
        pxor xmm1, xmm1
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
