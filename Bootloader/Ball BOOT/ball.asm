org 0x7C00
bits 16

start:
     mov ax, 0x0013
     int 0x10

     mov word [x_pos], 160
     mov word [y_pos], 100

     mov ax, 0xA000
     mov es, ax

game_loop:
     mov al, 0x00
     call draw_ball

     mov ah, 0x01
     int 0x16
     jz move_done

     mov ah, 0x00
     int 0x16

     cmp ah, 0x48
     je move_up
     cmp ah, 0x50
     je move_down
     cmp ah, 0x4B
     je move_left
     cmp ah, 0x4D
     je move_right
     jmp move_done

move_up:
     dec word [y_pos]
     jmp move_done

move_down:
     inc word [y_pos]
     jmp move_done

move_left:
     dec word [x_pos]
     jmp move_done

move_right:
     inc word [x_pos]

move_done:
     mov al, 0x28
     call draw_ball

     mov dx, 0x03DA
.wait:
     in al, dx
     test al, 8
     jz .wait

     jmp game_loop

draw_ball:
     mov cx, [y_pos]
     mov si, cx
     add si, 5
.y_loop:
     mov bx, [x_pos]
     mov di, bx
     add di, 5
.x_loop:
     push ax
     mov ax, cx
     imul ax, 320
     add ax, bx
     mov bp, ax
     pop ax

     mov [es:bp], al

     inc bx
     cmp bx, di
     jl .x_loop
     inc cx
     cmp cx, si
     jl .y_loop
     ret

x_pos dw 0
y_pos dw 0

times 510 - ($ - $$) db 0x00
dw 0xAA55