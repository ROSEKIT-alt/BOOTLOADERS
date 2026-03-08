org 0x7C00
bits 16

start:
     cli
     xor ax, ax
     mov ds, ax
     mov [bootdrive], dl
     mov ss, ax
     mov sp, 0x28
     push ax
     push word int9handler
     push ax
     push word int8handler

     mov sp, ax

     inc ax
     int 0x10

     mov cx, 0x2000
     mov ah, 0x01
     int 0x10

     cld
     mov ax, 0xb800
     mov es, ax

buildmaze:
     mov di, 0x0788
     mov si, maze
     mov dx, 0x05fa

.maze_outerloop:
     mov cx, 0x003c
     lodsw

.maze_innerloop:
     shl ax, 1
     push ax
     mov ax, 0x01db
     jc .draw
     mov ax, 0x0ff9
     cmp di, dx
     jnz .draw
     mov dh, 0x00
     mov al, 0x04

.draw:
     stosw
     push di
     add di, cx
     stosw
     pop di
     pop ax
     sub cx, 4
     jns .maze_innerloop

     sub di, 0x70
     jns .maze_outerloop

     sti

.end:
     mov al, 0x20
     out 0x20, al
     jmp .end

int8handler:
     pusha
     mov si, pacman_data

     dec byte [si + pace_offset]

     jump_offset: equ $ + 1
     jz .move_all
     popa
     iret

     push ds
     pop es
     mov ax, 0x0201
     mov cx, 0x0001
     bootdrive: equ $ + 1
     mov dx, 0x0080

     mov bx, 0x7C00
     int 0x13
     jmp start

.move_all:
     mov byte [si + pace_offset], 0x3
     mov al, [si + 3]
     mov dx, [si]
     call newpos

     jz .nodirchange

     mov [si + 2], al
    .nodirchange:
       mov al, [si + 2]
       mov dx, [si]
       call newpos
       jz .endpacman

.move:
     mov ax, 0x0f20
     cmp byte [es:di], 0x04
     jnz .nopowerpill
     mov byte [si + timer_offset], al

.nopowerpill:
     xchg dx, [si]
     call paint

.endpacman:
     mov bx, 3 * gh_length + pm_length
     mov byte [si + collision_offset], bh

.ghost_ai_outer:
     mov bp, 0xffff
     mov ah, [bx + si]

    cmp byte [si + timer_offset], 0x20
    jz .reverse
    xor ah, 8
   .reverse: mov al, 0xce

    mov dx, [bx + si + gh_offset_pos]
    cmp dx, [si]
    jne .ghost_ai_loop
    mov [si + collision_offset], al

.ghost_ai_loop:
    push dx
    cmp al, ah
    jz .next
    call newpos
    jz .next
    mov cx, 0x0c10

    cmp byte [si + timer_offset], bh
    jnz .skip_target
    mov cx, [si]
    add cx, [bx + si + gh_offset_focus]

.skip_target:
    push ax
    sub cl, dl
    sub ch, dh

    movsx ax, cl
    imul ax, ax
    movsx cx, ch
    imul cx, cx

    add cx, ax
    pop ax

    cmp cx, bp
    jnc .next
    mov bp, cx
    mov [bx + si], al
    mov [bx + si + gh_offset_pos], dx

.next:
    pop dx
    sub al, 4
    cmp al, 0xc2
    jnc .ghost_ai_loop

    mov ax, [bx + si + gh_offset_terrain]
    call paint

    sub bx, gh_length
    jns .ghost_ai_outer

.ghostterrain_loop:
    mov dx, [bx + si + gh_offset_pos + gh_length]
    cmp dx, [si]
    jne .skip_collision
    mov [si + collision_offset], al
   .skip_collision:
    call get_screenpos
    mov ax, [es:di]
    mov [bx + si + gh_offset_terrain + gh_length], ax
    add bx, gh_length
    cmp bx, 3 * gh_length + pm_length
    jnz .ghostterrain_loop

    mov cl, 0x10

    cmp byte [si + timer_offset], bh
    jnz .ghosts_invisible
 
    cmp byte [si + collision_offset], bh
    jz .no_collision

    mov dx, [si]
    mov ax, 0x0e0f

    call paint
    add byte [si + pace_offset], bl

    mov byte [jump_offset], 2

    jmp intxhandler_end

.ghosts_invisible:
    dec byte [si + timer_offset]
    mov ah, 0x0f
    mov cl, 0x0

.no_collision:
.ghostdraw:
    mov dx, [bx + si + gh_offset_pos]
    call paint
    add ah, cl
    sub bx, gh_length
    jns .ghostdraw

    mov ax, word 0x0e02

    mov dx, [si]
    call paint

.end:
    jmp intxhandler_end

newpos:
    mov [.modified_instruction + 1], al

.modified_instruction:
    db 0xfe, 0xc2
    and dl, 0x1f

get_screenpos:
    push dx
    movzx di, dh
    imul di, di, 0x28
    mov dh, 0
    add di, dx
    add di, 4
    shl di, 1
    pop dx
    cmp byte [es:di], 0xdb

    ret

paint:
    call get_screenpos
    stosw

    ret

int9handler:
    pusha
    in al, 0x60

    sub al, 0x21
    jnc intxhandler_end

    and al, 3
    shl al, 2
    neg al
    add al, 0xce
    cmp al, [pacman_data + 2]
    jz intxhandler_end
    mov [pacman_data + 3], al

intxhandler_end:
    popa
    iret

pacman_data:
    db 0x0f, 0x0f
    db 0xca
    db 0xca

pace_counter: db 0x10
ghost_timer: db 0x0

ghostdata:
    db 0xc2
ghostpos:
    db 0x01, 0x01
ghostterrain:
    dw 0x0ff9
ghostfocus:
    dw 0x0, 0x0
secondghost:
    db 0xce
    db 0x01, 0x17
    dw 0x0ff9
    db 0x0, 0x4
    db 0xca
    db 0x1e, 0x01
    dw 0x0ff9
    db 0xfc, 0x0
    db 0xce
    db 0x1e, 0x17
    dw 0x0ff9
    db 0x4, 0x0

lastghost:
    pm_length           equ ghostdata      - pacman_data
    gh_length           equ secondghost    - ghostdata
    gh_offset_pos       equ ghostpos       - ghostdata
    gh_offset_terrain   equ ghostterrain   - ghostdata
    gh_offset_focus     equ ghostfocus     - ghostdata
    pace_offset         equ pace_counter   - pacman_data
    timer_offset        equ ghost_timer    - pacman_data

maze: dw 0xffff, 0x8000, 0xbffd, 0x8081, 0xfabf, 0x8200, 0xbefd, 0x8001
      dw 0xfebf, 0x0080, 0xfebf, 0x803f, 0xaebf, 0xaebf, 0x80bf, 0xfebf
      dw 0x0080, 0xfefd, 0x8081, 0xbebf, 0x8000, 0xbefd, 0xbefd, 0x8001
      dw 0xffff

maze_length: equ $ - maze

collision_detect:

collision_offset equ collision_detect - pacman_data

times 510 - ($ - $$) db 0x00
dw 0xAA55