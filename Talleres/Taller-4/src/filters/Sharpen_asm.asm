section .data
    marco:      db 0,0,0,255,0,0,0,255,0,0,0,255,0,0,0,255
    sharpen: 

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
    push rbp
    mov rbp,rsp

    push r12
    push r13
    push r14
    push r15

    movdqu xmm0, [marco]    ; cargo el marco
    sub rdx, 2              ; resto los bordes
    sub rcx, 2              ; resto los brodes

    xor r10, r10            ; iterador
    marco_superior:
        movups [rsi + r10], xmm0    ; aplico marco
        add r10, 16                 ; avanzo 4px
        cmp r10, r8                 ; if (i == row_size )
        jne  marco_superior

    
    mov r12, r8                 ; iterador columna
    inc r12                     ; empiezo en la segunda columna porque la primera tiene marco
    xor r13, r13                ; iterador matriz sharpen
    sharpen:
        xor r10, r10            ; iterador de fila
        movups [rsi + r8], xmm0 ; aplico el marco de la primer columna

        sharpen_interno:
            movd r14, [rsi + r12 + r10]     ; cargo 1 pixel
            movdqu xmm1, [rsi + r12 + r11]  ; cargo 4 pixeles [px1,px2,px3,pxZ] siendo pxZ uno que no me sirve
            pslldq xmm1, 4                  ; me deshago del que no me sirve [0,px1,px2,px3]
            


            


    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
	ret
