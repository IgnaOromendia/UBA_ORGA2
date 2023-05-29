/* ** por compatibilidad se omiten tildes **
================================================================================
 TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Rutinas del controlador de interrupciones.
*/
#include "pic.h"

#define PIC1_PORT 0x20
#define PIC2_PORT 0xA0

static __inline __attribute__((always_inline)) void outb(uint32_t port,
                                                         uint8_t data) {
  __asm __volatile("outb %0,%w1" : : "a"(data), "d"(port));
}
void pic_finish1(void) { outb(PIC1_PORT, 0x20); }
void pic_finish2(void) {
  outb(PIC1_PORT, 0x20);
  outb(PIC2_PORT, 0x20);
}

// COMPLETAR: implementar pic_reset()
void pic_reset() {
  // Inicializo el PIC_1
  outb(PIC1_PORT, 0x11);      // ICW1 - IRQs activas por flanco, Modo cascada, ICW4 Si - donde arrancan

  outb(PIC1_PORT + 1, 0x20);   // ICW2 - INT base para el PIC_1 tipo 8

  outb(PIC1_PORT + 1, 0x4);   // ICW3 - PIC_1 Master, tiene yn Slave conectado a IRQ2

  outb(PIC1_PORT + 1, 0x1);   // ICW4 - Modo No Buffered, Fin de Interrupcion Normal, Desahbilitamos las interrucpicones del PIC_1

  outb(PIC1_PORT + 1, 0xFF);  // OCW1 - Set o Clearel IMR

  // Inicializo el PIC_2
  outb(PIC2_PORT, 0x11);      // ICW1 - IRQs activas por flanco, Modo cascada, ICW4 Si - arrancan

  outb(PIC2_PORT + 1, 0x28);  // ICW2 - INT base para el PIC_1 tipo 70h

  outb(PIC2_PORT + 1, 0x2);   // ICW3 - PIC_2 Slace, IRQ2 es la linea que envía al Master

  outb(PIC2_PORT + 1, 0x1);   // ICW4 - Modo No Buffered, Fin de Interrupcion Normal
}

void pic_enable() {
  outb(PIC1_PORT + 1, 0x00);
  outb(PIC2_PORT + 1, 0x00);
}

void pic_disable() {
  outb(PIC1_PORT + 1, 0xFF);
  outb(PIC2_PORT + 1, 0xFF);
}
