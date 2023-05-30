global Offset_asm

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

; void Offset_asm (uint8_t *src, uint8_t *dst, int width, int height, int src_row_size, int dst_row_size);
; rdi = *src, rsi = *dst, rdx = width, rcx = height, r8 = src_row_size, r9 = dst_row_size
Offset_asm:
    ;prologo
    push rbp
    mov rbp,rsp

    push r12
    push r13

    movdqu xmm4, [black]    ; creo 2PX negros(0,0,0,255)
    xor r10, r10            ; seteo en 0 - iterador de dst
    shl r9, 3               ; en r9 nos queda el row_size * 8, para ir recorriendolo
    sub rdx, 16             ; resto los bordes negros
    sub rcx, 16             ; resto los bordes negros

    ; hago las primeras 8 filas negras
    xor rax, rax                    ; seteo rax = 0
    loop_top:
        movaps [rsi + r10], xmm4    ; cargamos 2PX negros
        add r10, 16                 ; avanzamos 2PX
        add rax, 2                  ; rax += 2
        cmp rax, r8                 ; if (rax == src_row_size)
        jne loop_top                ; volvemos a loopear si no son iguales


    ; Imagen del medio
    xor r12, r12
    loop_offset:
        ; primero 8 px negros
        movaps [rsi + r10], xmm4        ; aplico los primeros 2PX
        add r10, 16                     ; avanzo 2PX
        movaps [rsi + r10], xmm4        ; aplico los segundos 2PX
        add r10, 16                     ; avanzo 2PX

        
        xor rax, rax ; seteo en 0 - contador de pixeles
        loop_offset_int:
            
            ; marco los pixeles que voy a pintar
            movdqu xmm0, [black]            ; cargo el valor black en xmm0
            movdqa xmm2, [rdi + r10 + 32]   ; cargo en xmm2 img[i][j+8]
            mov r11, r10                    ; r11 = img[i][j]
            add r11, r9                     ; r11 = img[i+8][j]
            movdqa xmm1, [rdi + r11]        ; cargo en xmm1 los 2PX que estan 8 mas abajo del que vamos a pintar
            add r11, 32                     ; r11 = img[i+8][j+8]
            movdqa xmm3, [rdi + r11]        ; cargo en xmm3 los 2PX de la diagonal

            ; Filtro colores
            ; blue
            movdqu xmm5, [blue]             ; xmm5 = blue
            pand xmm1, xmm5                 
            ; green
            movdqu xmm5, [green]            ; xmm5 = green
            pand xmm2, xmm5
            ; red
            movdqu xmm5, [red]              ; xmm3 = red
            pand xmm3, xmm5

            ; combino los valores en xmm0
            por xmm0, xmm1
            por xmm0, xmm2
            por xmm0, xmm3

            ; guatdo en dst
            movaps [rsi + r10], xmm0
            add r10, 16

            add rax, 4                  ; rax += 4
            cmp rax, rdx                ; if (rax == width)
            jne loop_offset_int

        ; proximos 8 px negros
        movaps [rsi + r10], xmm4        ; aplico los primeros 2PX
        add r10, 16                     ; avanzo 2PX
        movaps [rsi + r10], xmm4        ; aplico los segundos 2PX
        add r10, 16                     ; avanzo 2PX

        inc r12                         ; r12++
        cmp r12, rcx                    ; if (r12 == height)
        jne loop_offset

    ; hago las ultimas 8 filas negras
    xor rax, rax        ; hacemos rax = 0
    loop_end:
        movaps [rsi + r10], xmm4    ; cargamos 2PX negros
        add r10, 16                 ; avanzamos 2PX
        add rax, 2                  ; rax += 2
        cmp rax, r8                 ; if (rax == src_row_size)
        jne loop_end                ; volvemos a loopear si no son iguales

    pop r13
    pop r12

    ;epilogo
    pop rbp
    ret
