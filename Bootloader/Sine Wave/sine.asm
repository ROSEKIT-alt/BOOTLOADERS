org 0x7C00
bits 16

start:
     mov ax, 0x0013
     int 0x10

     mov ax, 0xA000
     mov es, ax

     finit

main_loop:
     xor bx, bx

draw_wave:
     push bx
     fild word [esp]

     mov word [tmp], 20
     fidiv word [tmp]
     fsin

     mov word [tmp], 40
     fimul word [tmp]
     mov word [tmp], 100
     fiadd word [tmp]

     fistp word [tmp]
     pop bx

     mov ax, [tmp]
     imul ax, 320
     add ax, bx
     mov di, ax

     mov byte [es:di], 14

     inc bx
     cmp bx, 320
     jne draw_wave

     mov dx, 0x03DA
.vblank:
     in al, dx
     test al, 8
     jz .vblank

     jmp main_loop

tmp dw 0

times 510 - ($ - $$) db 0x00
dw 0xAA55