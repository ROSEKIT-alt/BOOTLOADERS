org 0x7C00
bits 16

start:
     mov ax, 0x0013
     int 0x10

     mov ax, 0xA000
     mov es, ax

     mov dx, 50

draw_loop:
     mov cx, dx
     sub cx, 50

     mov bx, 160
     sub bx, cx

     mov si, 160
     add si, cx

     push bx

scanline:
     mov ax, dx
     imul ax, 320
     add ax, bx
     mov di, ax

     mov al, dl
     add al, 32
     mov [es:di], al

     inc bx
     cmp bx, si
     jl scanline

     pop bx
     inc dx
     cmp dx, 150
     jl draw_loop

     jmp $

times 510 - ($ - $$) db 0x00
dw 0xAA55