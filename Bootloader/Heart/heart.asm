org 0x7C00
bits 16

start:
     mov ax, 0x0013
     int 0x10
     mov ax, 0xA000
     mov ds, ax

animate:
     mov cx, 0x007F

main_loop:
     mov ax, cx
     call get_sin
     mov bx, ax
     imul bx
     call defrac
     imul bx
     call defrac
     mov bx, 40
     imul bx
     call defrac
     add ax, 160
     push ax

     mov al, 4
     mul cl
     call get_cos
     push ax
     mov al, 3
     mul cl
     call get_cos
     shl ax, 1
     push ax
     mov al, 2
     mul cl
     call get_cos
     mov bx, 5
     imul bx
     push ax
     mov ax, cx
     call get_cos
     mov bx, 13
     imul bx
     pop bx
     sub ax, bx
     pop bx
     sub ax, bx
     pop bx
     sub ax, bx
     neg ax
     mov bx, 3
     imul bx
     call defrac
     add ax, 100
     mov bx, 320
     mul bx
     pop bx
     add bx, ax
     mov byte [bx], 0x0C

     loop main_loop

defrac:
     mov al, ah
     mov ah, dl
     ret

get_cos:
     add al, 32

get_sin:
     test al, 64
     pushf
     test al, 32
     je .2
     xor al, 31
.2:
     and ax, 31
     mov bx, sin_table
     cs xlat
     popf
     je .1
     neg ax
.1:
     ret

sin_table:
     db 0x00, 0x09, 0x16, 0x24, 0x31, 0x3E, 0x47, 0x53
     db 0x60, 0x6C, 0x78, 0x80, 0x8B, 0x96, 0xA1, 0xAB
     db 0xB5, 0xBB, 0xC4, 0xCC, 0xD4, 0xDB, 0xE0, 0xE6
     db 0xEC, 0xF1, 0xF5, 0xF7, 0xFA, 0xFD, 0xFF, 0xFF

times 510 - ($ - $$) db 0x00
dw 0xAA55