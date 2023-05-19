import os
import gdb

def load_descriptor_table(name, identifier):
    # Cargo todos los registros según qemu
    qemu_registers = gdb.execute('monitor info registers', to_string=True)
    # Busco al gdt
    descriptors = [reg for reg in qemu_registers.split('\n') if reg.startswith(f"{identifier}=")]
    # Debería haber uno sólo, me quedo con ese
    assert len(descriptors) == 1, f"Detectamos más de un {name}"
    descriptor_text = descriptors[0]

    # Parseo el texto de qemu
    #   Formato esperado:
    #   GDT=     00005020 00000117
    #              ó
    #   IDT=     000051a0 000007f7
    #   <Ident>    <Base>   <Size>
    (base_text, size_text) = descriptor_text.split()[1:]
    base = int(base_text, 16)
    size = int(size_text, 16) + 1 # +1 porque en realidad es el máximo offset
    assert size % 8 == 0, f"La {identifier} no tiene una cantidad entera de entradas"

    return base, size

def format_address(addr):
    return gdb.execute(f'output/a 0x{addr:X}', to_string=True)

def print_descriptor_table(register_name, table_name, descriptor, formatter, skip_not_present=True):
    base, size = descriptor
    entry_count = size // 8

    inferior = gdb.selected_inferior()

    print(register_name, "points to", format_address(base), "containing", entry_count, "entries:")

    rows = []
    columns = {}

    for i in range(entry_count):
        addr = base + i * 8
        entry_bytes = inferior.read_memory(addr, 8)
        entry_p = bool(int.from_bytes(entry_bytes[5], 'little') & 0x80)

        if skip_not_present and not entry_p:
            continue

        row = [str(column) for column in formatter(entry_bytes)]
        row.insert(0, f'{table_name}[{i}] =')

        for idx, column in enumerate(row):
            width = len(column)
            if idx in columns:
                columns[idx] = max(columns[idx], width)
            else:
                columns[idx] = width

        rows.append(row)

    for row in rows:
        for idx, column in enumerate(row):
            print(column.ljust(columns[idx] + 1), end='')
        print()

def print_descriptor_entry(table_name, gdt, index, formatter):
    base, size = gdt
    entry_count = size // 8
    assert 0 <= index <= entry_count, f"{table_name.upper()} index outside valid bounds"

    inferior = gdb.selected_inferior()
    addr = base + index * 8
    entry_bytes = inferior.read_memory(addr, 8)
    row = formatter(entry_bytes)
    print(f'{table_name}[{index}] =', ' '.join(row))

gdt_entry_types = [
    'Read-Only',
    'Read-Only, accessed',
    'Read-Write',
    'Read-Write, accessed',
    'Read-Only, expand-down',
    'Read-Only, expand-down, accessed',
    'Read-Write, expand-down',
    'Read-Write, expand-down, accessed',
    'Execute-Only',
    'Execute-Only, accessed',
    'Execute/Read',
    'Execute/Read, accessed',
    'Execute-Only, conforming',
    'Execute-Only, conforming, accessed',
    'Execute/Read, conforming',
    'Execute/Read, conforming, accessed',
]

def format_gdt_entry(entry_bytes):
        entry = [int.from_bytes(b, 'little') for b in entry_bytes]
        entry_base = entry[7] << 24 | entry[4] << 16 | entry[3] << 8 | entry[2]
        entry_limit = (entry[6] & 0x0F) << 16 | entry[1] << 8 | entry[0]
        entry_type = entry[5] & 0x0F
        entry_s = bool(entry[5] & 0x10)
        entry_dpl = (entry[5] & 0x60) >> 5
        entry_p = bool(entry[5] & 0x80)
        entry_a = bool(entry[6] & 0x10)
        entry_l = bool(entry[6] & 0x20)
        entry_db = bool(entry[6] & 0x40)
        entry_g = bool(entry[6] & 0x80)

        return [f'Base: {format_address(entry_base)},',
                f'Limit: {entry_limit:#x},',
                ('page granularity,' if entry_g else 'byte granularity,'),
                f'D/B: {int(entry_db)},',
                f'L: {int(entry_l)},',
                ('available bit set,' if entry_a else 'available bit clear,'),
                ('present,' if entry_p else 'not present,'),
                f'DPL: {entry_dpl},',
                ('System Segment,' if entry_s else 'Code/Data Segment,'),
                f'Type: {gdt_entry_types[entry_type]}']

idt_entry_types = {
    0b00101: 'Task Gate',
    0b00110: 'Interrupt Gate (16 bits)',
    0b01110: 'Interrupt Gate (32 bits)',
    0b01111: 'Trap Gate (16 bits)',
    0b11111: 'Trap Gate (32 bits)',
}
def format_idt_entry(entry_bytes):
        entry = [int.from_bytes(b, 'little') for b in entry_bytes]
        entry_offset = entry[7] << 24 | entry[6] << 16 | entry[1] << 8 | entry[0]
        entry_segsel = entry[3] << 8 | entry[2]
        entry_p = bool(entry[5] & 0x80)
        entry_dpl = (entry[5] & 0x60) >> 5
        entry_type = entry[5] & 0x1F

        segsel_idx = entry_segsel >> 3
        segsel_rpl = (entry_segsel & 0x06) >> 1
        segsel_ti = bool(entry_segsel & 0x01)
        segsel = f'{"ldt" if segsel_ti else "gdt"}[{segsel_idx}] (RPL={segsel_rpl})'

        return [f'Offset: {format_address(entry_offset)},',
                f'Segment Selector: {segsel},',
                ('present,' if entry_p else 'not present,'),
                f'DPL: {entry_dpl},',
                f'Type: {idt_entry_types.get(entry_type, f"Invalid Type (entry_type)")}']

class KernelCommand(gdb.Command):
    "Performs various kernel-related operations"
    def __init__(self):
        super().__init__('kernel', gdb.COMMAND_USER, gdb.COMPLETE_COMMAND, True)

    def invoke(self, argument, from_tty):
        print('kernel reload -- Reloads the currently loaded kernel')

class KernelReloadCommand(gdb.Command):
    "Reloads the currently loaded kernel"
    def __init__(self):
        super().__init__('kernel reload', gdb.COMMAND_USER, gdb.COMPLETE_NONE, False)

    def invoke(self, argument, from_tty):
        diskette = os.getcwd() + '/diskette.img'
        elf = 'kernel.bin.elf'
        gdb.execute('make')
        gdb.execute(f'file {elf}')
        gdb.execute('directory')
        gdb.execute(f'monitor change floppy0 {diskette} raw')
        gdb.execute('monitor system_reset')

class InfoGDTCommand(gdb.Command):
    """Shows the currently loaded GDT
  info gdt -- Show descriptors present
  info gdt all -- Show all descriptors
  info gdt [idx] -- Show the i-th descriptor"""
    def __init__(self):
        super().__init__('info gdt', gdb.COMMAND_STATUS, gdb.COMPLETE_NONE, False)

    def invoke(self, argument, from_tty):
        gdtr = load_descriptor_table('gdtr', 'GDT')

        if argument == '':
            print_descriptor_table('GDTR', 'gdt', gdtr, format_gdt_entry)
        elif argument == 'all':
            print_descriptor_table('GDTR', 'gdt', gdtr, format_gdt_entry, False)
        else:
            index = gdb.parse_and_eval(argument)
            print_descriptor_entry('gdt', gdtr, index, format_gdt_entry)

class InfoIDTCommand(gdb.Command):
    """Shows the currently loaded IDT
  info idt -- Show descriptors present
  info idt all -- Show all descriptors
  info idt [idx] -- Show the i-th descriptor"""
    def __init__(self):
        super().__init__('info idt', gdb.COMMAND_STATUS, gdb.COMPLETE_NONE, False)

    def invoke(self, argument, from_tty):
        idtr = load_descriptor_table('idtr', 'IDT')

        if argument == '':
            print_descriptor_table('IDTR', 'idt', idtr, format_idt_entry)
        elif argument == 'all':
            print_descriptor_table('IDTR', 'idt', idtr, format_idt_entry, False)
        else:
            index = gdb.parse_and_eval(argument)
            print_descriptor_entry('idt', idtr, index, format_idt_entry)

KernelCommand()
KernelReloadCommand()
InfoGDTCommand()
InfoIDTCommand()

class GDTPrinter:
    def __init__(self, val):
        self.val = val

    def children(self):
        void_star = gdb.lookup_type('void').pointer()
        u32 = gdb.lookup_type('unsigned int')

        limit = self.val['limit_19_16'].cast(u32) << 16 | self.val['limit_15_0'].cast(u32)
        yield 'limit', limit.cast(u32)
        base = self.val['base_31_24'].cast(u32) << 24 | self.val['base_23_16'].cast(u32) << 16 | self.val['base_15_0'].cast(u32)
        yield 'base', base.cast(void_star)

        yield 'type', self.val['type'].cast(u32)
        yield 's',    self.val['s'].cast(u32)
        yield 'dpl',  self.val['dpl'].cast(u32)
        yield 'p',    self.val['p'].cast(u32)
        yield 'avl',  self.val['avl'].cast(u32)
        yield 'l',    self.val['l'].cast(u32)
        yield 'db',   self.val['db'].cast(u32)
        yield 'g',    self.val['g'].cast(u32)

class IDTPrinter:
    def __init__(self, val):
        self.val = val

    def children(self):
        void_star = gdb.lookup_type('void').pointer()
        offset = self.val['offset_31_16'].cast(u32) << 16 | self.val['offset_15_0'].cast(u32)
        yield 'offset', offset.cast(void_star)

        u32 = gdb.lookup_type('unsigned int')
        yield 'segsel',  self.val['segsel'].cast(u32)
        yield 'type',    self.val['type'].cast(u32)
        yield 'dpl',     self.val['dpl'].cast(u32)
        yield 'present', self.val['present'].cast(u32)

def orga2_printers(value):
    if value.type.name == 'gdt_entry_t':
        return GDTPrinter(value)
    if value.type.name == 'idt_entry_t':
        return IDTPrinter(value)
    return None

gdb.pretty_printers.append(orga2_printers)
