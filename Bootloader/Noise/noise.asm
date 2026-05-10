org 0x7C00
bits 16

start:
     cli
     xor ax, ax
     mov ds, ax
     mov es, ax
     sti

     mov ax, 0x0013
     int 0x10

     mov ax, 0xA000
     mov es, ax

     xor di, di
     mov bx, 0xACE1

main:
     in al, 0x40
     xor bl, al
     rol bx, 3
     add bx, 0x1337

     mov ax, bx

     mov cl, al
     shr cl, 2

     mov al, bl
     xor al, bh
     and al, 0x3F

     add al, cl

     stosb
     inc di

     cmp di, 64000
     jb .skip
     xor di, di

.skip:
     mov al, 0xB6
     out 0x43, al

     mov ax, bx
     out 0x42, al
     mov al, ah
     out 0x42, al

     in al, 0x61
     or al, 3
     out 0x61, al

     mov cx, 500

.delay:
     loop .delay

     jmp main

times 510 - ($ - $$) db 0x00
dw 0xAA55