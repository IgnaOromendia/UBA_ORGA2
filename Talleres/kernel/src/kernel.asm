; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================
; para ejecutar --
; qemu-system-i386 -s -S -fda diskette.img --monitor stdio
; GDB --
; gdb kernel.bin.elf
; target remote localhost:1234
; b kenrel.asm:

%include "print.mac"

global start


; COMPLETAR - Agreguen declaraciones extern según vayan necesitando
extern A20_enable
extern GDT_DESC
extern screen_draw_layout
extern IDT_DESC
extern idt_init
extern pic_reset
extern pic_enable
extern mmu_init_kernel_dir
extern copy_page
extern mmu_init_task_dir
extern tss_init
extern sched_init
extern tasks_init
extern tasks_screen_draw

; COMPLETAR - Definan correctamente estas constantes cuando las necesiten
; estos son los mismos define que en cdt del defines.h
%define CS_RING_0_SEL 0x08 ; es 0x08 porque es el GDT_IDX_CODE_0(1) << 3
%define DS_RING_0_SEL 0x18 ; es 0x18 porque es el GDT_IDX_DATA_0(3) << 3
%define GDT_IDX_TASK_INITIAL 11 << 3
%define GDT_IDX_TASK_IDLE 12 << 3

BITS 16
;; Saltear seccion de datos
jmp start

;;
;; Seccion de datos.
;; -------------------------------------------------------------------------- ;;
start_rm_msg db     'Iniciando kernel en Modo Real'
start_rm_len equ    $ - start_rm_msg

start_pm_msg db     'Iniciando kernel en Modo Protegido'
start_pm_len equ    $ - start_pm_msg

;;
;; Seccion de código.
;; -------------------------------------------------------------------------- ;;

;; Punto de entrada del kernel.
BITS 16
start:
    ; COMPLETAR - Deshabilitar interrupciones
    cli

    ; Cambiar modo de video a 80 X 50
    mov ax, 0003h
    int 10h ; set mode 03h
    xor bx, bx
    mov ax, 1112h
    int 10h ; load 8x8 font

    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO REAL
    ; (revisar las funciones definidas en print.mac y los mensajes se encuentran en la
    ; sección de datos)
    print_text_rm start_rm_msg, start_rm_len, 0x07, 0, 0

    ; COMPLETAR - Habilitar A20
    ; (revisar las funciones definidas en a20.asm)
    call A20_enable

    ; COMPLETAR - Cargar la GDT
    lgdt [GDT_DESC]

    ; COMPLETAR - Setear el bit PE del registro CR0
    push eax
    mov eax, 1
    mov cr0, eax
    pop eax

    ; COMPLETAR - Saltar a modo protegido (far jump)
    ; (recuerden que un far jmp se especifica como jmp CS_selector:address)
    ; Pueden usar la constante CS_RING_0_SEL definida en este archivo
    jmp CS_RING_0_SEL:modo_protegido

BITS 32
modo_protegido:
    ; COMPLETAR - A partir de aca, to do el codigo se va a ejectutar en modo protegido
    ; Establecer selectores de segmentos DS, ES, GS, FS y SS en el segmento de datos de nivel 0
    ; Pueden usar la constante DS_RING_0_SEL definida en este archivo
    mov ax, DS_RING_0_SEL
    mov ds, ax
    mov es, ax
    mov gs, ax
    mov fs, ax
    mov ss, ax

    ; COMPLETAR - Establecer el tope y la base de la pila
    mov esp, 0x25000
    mov ebp, esp

    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO PROTEGIDO
    print_text_pm start_pm_msg, start_pm_len, 0x07, 2, 0

    ; Inicializamos el registro cr3
    call mmu_init_kernel_dir
    mov cr3, eax

    ; Habilitamos la paginacion
    mov ecx, cr0
    or ecx, 0x80000000
    mov cr0, ecx

    xor edi, edi
    mov edi, 0x18000

    call mmu_init_task_dir

    ; Inicializamos la tss con las tareas idle e init
    call tss_init

    ; Inicializamos el scheduler
    call sched_init

    ; Cargamos las tareas
    call tasks_init

    ; TALLER 6
    ; Inicializamos la IDT
    call idt_init
    ; Cargamos la IDT
    lidt [IDT_DESC]
    ;Remapeamos el PIC
    call pic_reset
    ; Habilitamos el PIC
    call pic_enable

    call tasks_screen_draw

    ; Habilitamos las interrupciones
    sti

    ; Cargamos la tarea inicial
    mov ax, GDT_IDX_TASK_INITIAL
    ltr ax
    jmp GDT_IDX_TASK_IDLE:0

   
   
    ; Ciclar infinitamente 
    mov eax, 0xFFFF
    mov ebx, 0xFFFF
    mov ecx, 0xFFFF
    mov edx, 0xFFFF
    jmp $

;; -------------------------------------------------------------------------- ;;

%include "a20.asm"
