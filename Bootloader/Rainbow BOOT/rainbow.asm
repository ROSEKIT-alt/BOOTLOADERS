org 0x7C00
bits 16

start:
     mov ax, 0x0013
     int 0x10

     mov ax, 0xA000
     mov es, ax
     xor di, di
     mov cx, 64000

pixel_loop:
     mov ax, di
     xor dx, dx
     mov bx, 320
     div bx
     mov ax, dx
     mov bx, 6
     mul bx
     xor dx, dx
     mov bx, 320
     div bx
     mov bx, hue_table
     xlatb
     stosb
     loop pixel_loop

hue_table:
     db 0x04
     db 0x0E
     db 0x02
     db 0x03
     db 0x01
     db 0x05

times 510 - ($ - $$) db 0x00
dw 0xAA55