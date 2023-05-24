section .data
    black:  db 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
    blue:   db 255,0,0,0,255,0,0,0,255,0,0,0,255,0,0,0
    green:  db 0,255,0,0,0,255,0,0,0,255,0,0,0,255,0,0
    red:    db 0,0,255,0,0,0,255,0,0,0,255,0,0,0,255,0

section .text

; para hacerlo correr
; ./build/simd Offset -i asm img/colores32.bmp
; ./build/simd Offset -i asm img/paisaje.bmp
; ./build/simd Offset -i asm img/puente.bmp

; para testear
; python3 1_generar_imagenes.py
; python3 2_test_diff_cat_asm.py
; ./3_correr_test_mem.sh 

global Offset_asm

; void Offset_asm (uint8_t *src, uint8_t *dst, int width, int height, int src_row_size, int dst_row_size);
; rdi = *src, rsi = *dst, rdx = width, rcx = height, r8 = src_row_size, r9 = dst_row_size
Offset_asm:
    ;prologo
    push rbp
    mov rbp,rsp

    movdqu xmm4, [black]    ; creo 4px negros(0,0,0,255)
    xor r10, r10            ; seteo en 0
    shl r9, 3               ; en r9 nos queda el row_size * 8, esto es asi para facilidad de implementacion
    sub rdx, 16             ; resto los bordes negros
    sub rcx, 16             ; resto los bordes negros

    ; hago las primeras 8 filas negras
    xor rax, rax                    ; hacemos rax = 0
    loop_top:
        movaps [rsi + r10], xmm4    ; cargamos 4px negros
        add r10, 16                 ; avanzamos 16bytes (4 pixeles)
        add rax, 2
        cmp rax, r8
        jne loop_top                ; volvemos a loopear si no son iguales

    ; hacemos la imagen del medio
    push r12
    xor r12, r12
    loop_shuffle:
        ; primero 8 px negros
        movaps [rsi + r10], xmm4
        add r10, 16
        movaps [rsi + r10], xmm4
        add r10, 16

        ; ahora hago el shuffle
        xor rax, rax ; seteo en 0
        loop_shuffle_int:
            
            ; marco los pixeles que voy a pintar
            movdqu xmm0, [black]            ; cargamos el valor black en xmm0
            movdqa xmm2, [rdi + r10 + 16*2] ; guardamos en xmm2 los 4px que estan a 4px de distancia de los de xmm0 por los bordes
            mov r11, r10
            add r11, r9
            movdqa xmm1, [rdi + r11]        ; guardamos en xmm1 los 4px que estan 8 mas abajo del que vamos a pintar
            add r11, 32
            movdqa xmm3, [rdi + r11]

            ; "filtramos" los colores que nos importa de cada set de 4pixeles
            movdqu xmm5, [blue]             ; guardamos el valor de blue en xmm5 temporalmente
            pand xmm1, xmm5
            movdqu xmm5, [green]
            pand xmm2, xmm5
            movdqu xmm5, [red]
            pand xmm3, xmm5
            ; combinamos los valores en xmm0
            por xmm0, xmm1
            por xmm0, xmm2
            por xmm0, xmm3
            ; guardamos el valor de xmm0 en la imagen dst
            movaps [rsi + r10], xmm0
            add r10, 16

            add rax, 4
            cmp rax, rdx
            jne loop_shuffle_int

        ; proximos 8 px negros
        movaps [rsi + r10], xmm4
        add r10, 16
        movaps [rsi + r10], xmm4
        add r10, 16

        inc r12     ; incrementamos en 1 el r12 por cada linea que avanzamos
        cmp r12, rcx
        jne loop_shuffle

    pop r12

    ; hago las ultimas 8 filas negras
    xor rax, rax        ; hacemos rax = 0
    loop_end:
        movaps [rsi + r10], xmm4 ; cargamos 4px negros
        add r10, 16     ; avanzamos 16bytes (4 pixeles)
        add rax, 2
        cmp rax, r8
        jne loop_end    ; volvemos a loopear si no son iguales

    ;epilogo
    pop rbp
    ret
