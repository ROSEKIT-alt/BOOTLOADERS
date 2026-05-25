org 0x7C00
bits 16

RAM_FIRST               equ 0x0000
RAM_TEST_START          equ 0x1000
RAM_LAST                equ 0xFFFF

start:
     xor ax, ax
     mov ds, ax
     mov es, ax
     mov fs, ax
     mov gs, ax
     mov ss, ax
     mov sp, 0x7C00

RAM_ANNIHILATOR:
     call BITPATTERN_TEST
     call RANDOM_DATA_FLOOD
     call MOVE_DATA_WRECK
     call STUCK_CELL_CHECK
     jmp RAM_ANNIHILATOR

BITPATTERN_TEST:
     mov si, RAM_TEST_START
     mov cx, RAM_LAST - RAM_TEST_START
     mov al, 0x00
PATTERN_LOOP:
     stosb
     inc al
     and al, 0xFF
     loop PATTERN_LOOP
     ret

RANDOM_DATA_FLOOD:
     mov si, RAM_TEST_START
     mov cx, RAM_LAST - RAM_TEST_START
     mov bx, [RAM_FIRST]
RANDOM_FILL:
     mov ax, bx
     mul bx
     stosb
     mov bx, ax
     loop RANDOM_FILL
     ret

MOVE_DATA_WRECK:
     mov si, RAM_TEST_START
     mov di, RAM_TEST_START + 0x8000
     mov cx, RAM_LAST - RAM_TEST_START
     rep movsb
     ret

STUCK_CELL_CHECK:
     mov si, RAM_TEST_START
     mov cx, RAM_LAST - RAM_TEST_START
STUCK_LOOP:
     mov al, [si]
     xor al, 0xFF
     mov [si], al
     cmp [si], al
     jne STUCK_NEXT
     inc word [STUCK_COUNT]
STUCK_NEXT:
     inc si
     loop STUCK_LOOP
     ret

;RAM_TOTAL           dw 0xFFFF
;RAM_TOTAL_BYTES     dw 0xFFFF
STUCK_COUNT         dw 0x0000

times 510 - ($ - $$) db 0x00
db 0x55
db 0xAA