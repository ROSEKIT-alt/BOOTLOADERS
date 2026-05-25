org 0x7C00
bits 16

mov cx, 0xFFFF
mov ax, 0x5555
mov bx, 0xAAAA

hot_loop:
xor ax, bx
not ax
ror ax, 3
mul bx
add bx, dx
clc
stc
loop hot_loop

jmp hot_loop

times 510 - ($ - $$) db 0xFF
db 0x55
db 0xAA