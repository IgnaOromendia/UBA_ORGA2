section .data
    black:      db 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
    cut:        db 255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255
    take_bor:   db 255,255,255,255,0,0,0,0,0,0,0,0,255,255,255,255

section .text

; para hacerlo correr
; ./build/simd Sharpen -i asm img/colores32.bmp
; ./build/simd Sharpen -i asm img/paisaje.bmp
; ./build/simd Sharpen -i asm img/puente.bmp

; para testear
; python3 1_generar_imagenes.py
; python3 2_test_diff_cat_asm.py
; ./3_correr_test_mem.sh 

global Sharpen_asm

; void Sharpen_asm (uint8_t *src, uint8_t *dst, int width, int height, int src_row_size, int dst_row_size);
; rdi = *src, rsi = *dst, rdx = width, rcx = height, r8 = src_row_size, r9 = dst_row_size
Sharpen_asm:
    ;prologo
    push rbp
    mov rbp,rsp

    ; acomodo los registros que utilizare durante el programa
    movdqu xmm6, [black]    ; creamos 4px negros(0,0,0,255) en xmm6
    movdqu xmm7, [take_bor] ; xmm7 -> [ff,0,0,ff] (en realidad son mas ff pero se entiende que hace)
    sub rdx, 2              ; estamos restando los bordes negros al "tamaño final"
    sub rcx, 2              ; estamos restando los bordes negros al "tamaño final"
    ; xmm10 -> [0,0,0,0,ff,ff,ff,ff]
    movdqu xmm10, [cut]
    pslldq xmm10, 8
    ; xmm11 -> [ff,ff,ff,ff,0,0,0,0]
    movdqu xmm11, [cut]
    psrldq xmm11, 8
    ; xmm12 -> [0,0,0,ff,ff,...,ff]
    movdqu xmm12, [cut]
    pslldq xmm12, 3
    ; xmm13 -> [ff,ff,...,0,0,0,ff]
    movdqu xmm13, [cut]
    psrldq xmm13, 4
    por xmm13, xmm6

    ; hacemos la  linea superior
    xor r10, r10
    top_black:
        movups [rsi + r10], xmm6
        add r10, 4*4                ; 4(px) * 4(bytes cada px)
        cmp r10, r8
        jne top_black

    push r12
    push rdi
    push rsi
    xor r12, r12
    loop_sharpen:
        xor r10, r10            ; este registro guardara el avance por linea en px
        ; pintamos el primer px negro
        movdqu xmm0, [rsi + r8]
        pand xmm0, xmm12
        movups [rsi + r8], xmm0
        loop_line:
            mov r11, r10
            shl r11, 2                  ; multiplicamos por 4 = 2^2
            ; queremos que xmm0 sea = [b0,g0,r0,a0,b1,g1,r1,a1] y xmm1 los proximos 2 pixeles
            movdqu xmm0, [rdi + r11]    ; tomamos 4 px de 8bits cada valor del mismo
            movdqu xmm1, xmm0           ; copiamos a xmm1
            ; las siguientes dos lineas no son necesarias
            pslldq xmm0, 8              ; movemos 8bytes(64bits) a la derecha -> [0,0,px0,px1]
            psrldq xmm0, 8              ; movemos ahora los 2 px que quedaron a la posicion mas significativa <- [px0,px1,0,0]
            pmovzxbw xmm0, xmm0         ; convertimos de 8bits a 16
            psrldq xmm1, 8              ; movemos de derecha a izq <- [px2,px3,0,0]
            pmovzxbw xmm1, xmm1

            ; repetimos para los 4 px de abajo
            ; como solo podemos usar dos registros en [] copiamos r10 a r11 y le agregamos r8
            add r11, r8
            movdqu xmm2, [rdi + r11]
            movdqu xmm3, xmm2
            ; las siguientes dos lineas no son necesarias
            pslldq xmm2, 8
            psrldq xmm2, 8
            pmovzxbw xmm2, xmm2
            psrldq xmm3, 8
            pmovzxbw xmm3, xmm3

            ; repetimos para los 4 px de abajo
            add r11, r8
            movdqu xmm4, [rdi + r11]
            movdqu xmm5, xmm4
            ; las siguientes dos lineas no son necesarias
            pslldq xmm4, 8
            psrldq xmm4, 8
            pmovzxbw xmm4, xmm4
            psrldq xmm5, 8
            pmovzxbw xmm5, xmm5

            ; sumamos xmm0 con xmm4 y xmm1 con xmm5
            paddw xmm0, xmm4
            paddw xmm1, xmm5

            ; en este punto tendriamos:
            ; |     xmm0    |       xmm1      |
            ; | p0+p8,p1+p9 | px2+p10,px3+p11 |
            ; |     xmm2    |       xmm3      |
            ; |    p4, p5   |      p6, p7     |

            ; pasamos xmm2 y xmm3 a xmm4 y 5 respectivamente
            movdqu xmm4, xmm2
            movdqu xmm5, xmm3

            ; multiplicamos xmm4 y xmm5 por 9
            psllw xmm4, 3       ; multiplico por 2^4=8
            paddw xmm4, xmm2    ; le sumamos 1 => 8+1=9
            psllw xmm5, 3
            paddw xmm5, xmm3

            ; cortamos los pixeles no deseados
            pand xmm4, xmm10
            pand xmm5, xmm11

            ; |     xmm0    |      xmm1     |
            ; | p0+p8,p1+p9 | p2+p10,p3+p11 |
            ; |     xmm2    |      xmm3     |
            ; |    p4, p5   |     p6, p7    |
            ; |     xmm4    |      xmm5     |
            ; |    0,p5*9   |     p6*9,0    |

            psubsw xmm4, xmm0   ; xmm4-r(xmm0)
            psubsw xmm5, xmm1   ; xmm5-l(xmm1)
            psrldq xmm4, 8      ; desplazamos xmm4 hacia la izq
            pslldq xmm5, 8      ; desplazamos xmm5 hacia la derecha
            psubsw xmm4, xmm2   ; xmm4-l(xmm2)
            psubsw xmm5, xmm3   ; xmm5-r(xmm3)
            psubsw xmm4, xmm0   ; xmm4-l(xmm0)
            psubsw xmm5, xmm1   ; xmm5-r(xmm1)
            psubsw xmm4, xmm1   ; xmm4-l(xmm1)
            psubsw xmm5, xmm0   ; xmm4-r(xmm0)
            psubsw xmm4, xmm3   ; xmm4-l(xmm3)
            psubsw xmm5, xmm2   ; xmm4-r(xmm2)

            pslldq xmm4, 8      ; desplazamos xmm4 hacia la derecha
            psrldq xmm5, 8      ; desplazamos xmm5 hacia la izq

            packuswb xmm4, xmm5         ; unimos xmm4 y xmm5 y convertimos los valores de 16 en 8bits con sat
            sub r11, r8
            movdqu xmm0, [rsi + r11]    ; tomo 4px (donde guardare los del medio)
            pand xmm0, xmm7             ; paso xmm0 por la mascara take_bor (me deja los 2 px del borde)
            por xmm4, xmm0              ; en xmm4 queda lo que arme + los px laterales previos
            movups [rsi + r11], xmm4    ; guardamos xmm4 en la imagen destino

            add r10, 2                  ; avanzamos r10 (el contador de avance en px)
            cmp r10, rdx
            jne loop_line

        ; pintamos el ultimo pixel de negro
        movdqu xmm0, [rsi + r11]
        pand xmm0, xmm13
        movups [rsi + r11], xmm0

        add rdi, r8
        add rsi, r8
        inc r12             ; avance de una linea
        cmp r12, rcx
        jne loop_sharpen

    ; hacemos la  linea inferior
    add rsi, r8
    xor r10, r10
    btm_black:
        movups [rsi + r10], xmm6
        add r10, 4*4                ; 4(px) * 4(bytes cada px)
        cmp r10, r8
        jne btm_black

    pop rsi
    pop rdi
    pop r12

    ;epilogo
    pop rbp
	ret
