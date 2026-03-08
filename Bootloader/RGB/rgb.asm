org 0x7C00
bits 16

start:
     mov ax, 0x0013
     int 0x10

frame_loop:
     mov al, 4
     call fill_screen
     call delay

     mov al, 2
     call fill_screen
     call delay

     mov al, 1
     call fill_screen
     call delay

     jmp frame_loop

fill_screen:
     push ax
     push di

     mov di, 0xA000
     mov es, di

     xor di, di
     mov cx, 320*200

     .fill:
           stosb
           loop .fill

           pop di
           pop ax
           ret

delay:
     mov cx, 0
.outer:
     mov dx, 0
.inner:
     dec dx
     jnz .inner
     dec cx
     jnz .outer
     ret

times 510 - ($ - $$) db 0x00
dw 0xAA55