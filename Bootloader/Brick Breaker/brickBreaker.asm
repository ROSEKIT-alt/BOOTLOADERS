org 0x7C00
bits 16

SCREEN_W:             equ 320
SCREEN_H:             equ 200

BK_ROOF:              equ 30
BK_BORDER:            equ 10
BK_GAP:               equ 3
BK_PER_ROW:           equ 10
BK_ROWS:              equ 6

BK_LIVE_COLOR:        equ 0x2a
BK_MARKING_COLOR:     equ 0x10
BK_DEAD_COLOR:        equ 0x10
COLOR_BG:             equ 0x00
COLOR_BOARD:          equ 0x1f
COLOR_BALL:           equ 0x20
COLOR_FRAME:          equ 0x1f1f

BD_Y:                 equ 180
BD_H:                 equ 5
BD_W:                 equ 30
BD_X_INIT:            equ 200
BD_SPEED:             equ 12

BALL_INIT_X:          equ 150
BALL_INIT_Y:          equ 100
BALL_SPEED:           equ 3

BRICK_W:              equ (SCREEN_W - 2 * BK_BORDER) / BK_PER_ROW - BK_GAP
BRICK_H:              equ 8
BRICK_NR:             equ BK_PER_ROW * BK_ROWS
BG_PIXELS:            equ 0xf9ff - BRICK_NR

brick_array:          equ 0x0000
bd_x:                 equ 0x0140
bd_x_old:             equ 0x0142
bd_time:              equ 0x0144
ball_x:               equ 0x0146
ball_y:               equ 0x0148
ball_x_old:           equ 0x014A
ball_y_old:           equ 0x014C
cur_color:            equ 0x014E
v_y:                  equ 0x0150
v_x:                  equ 0x0152
v:                    equ 0x0154
is_collision:         equ 0x0156
is_init_done:         equ 0x0158

boot_game:
     mov ax, 0x0013
     int 0x10
     mov ax, 0xa000
     mov ds, ax
     mov es, ax
     cld

init_bricks:
     mov cx, BRICK_NR
     mov ax, BK_LIVE_COLOR
     xor di, di
     rep stosb

init_bg:
     mov cx, BG_PIXELS
     mov ax, COLOR_BG
     rep stosb
     mov cx, 3 * SCREEN_W
     mov di, 2 * SCREEN_W
     mov ax, COLOR_FRAME
     rep stosb
     dec di
     mov cx, 175
init_bg_loop:
     stosw
     add di, SCREEN_W - 2
     loop init_bg_loop

init_vars:
     mov ax, BD_X_INIT
     mov [bd_x], ax
     mov [bd_x_old], ax
     mov byte [bd_time], 0
     mov word [ball_x], BALL_INIT_X
     mov word [ball_y], BALL_INIT_Y
     mov ax, 1
     mov [v_y], ax
     mov [v_x], ax
     mov word [v], BALL_SPEED

game_loop:
     mov ah, 0x00
     int 0x1a
     cmp dl, [bd_time]
     je skip_game_loop
     mov [bd_time], dl

     mov ah, 0x02
     int 0x16
     mov bx, [bd_x]
     test al, 0x04
     jz test_alt
     cmp bx, BD_SPEED
     sub bx, BD_SPEED
     jge test_alt
     xor bx, bx
test_alt:
     test al, 0x08
     jz continue_game_loop
     add bx, BD_SPEED
     cmp bx, SCREEN_W - BD_W - 1
     jle continue_game_loop
     mov bx, SCREEN_W - BD_W - 1

continue_game_loop:
     mov [bd_x], bx
     call draw_ball
     call remove_ball
     call update_board
     call draw_bricks
     call collision_position_update
     call draw_ball
skip_game_loop:
     jmp game_loop

collision_position_update:
     mov bx, [ball_x]
     mov dx, [ball_y]
     mov cx, [v]
     cp_loop:
          add bx, [v_x]
          call collision_text
          test al, al
          jz next_coord
          sub bx, [v_x]
          neg word [v_x]
     next_coord:
          add dx, [v_y]
          cmp dx, BD_Y - 5
          jge game_over
          call collision_text
          test al, al
          jz test_cond
          sub dx, [v_y]
          neg word [v_y]
     test_cond:
          loop cp_loop
          mov [ball_x], bx
          mov [ball_y], dx
          ret

game_over:
     jmp boot_game

collision_text:
     push dx
     push cx
     push bx
     mov ax, SCREEN_W
     mul dx
     add ax, bx
     mov si, ax
     mov bx, 7
     col_loop2:
          mov cx, 8
     col_loop1:
          lodsb
          cmp al, COLOR_BG
          je no_col
     check_deads:
          cmp al, BK_DEAD_COLOR
          je no_col
          cmp al, BK_LIVE_COLOR
          mov al, 1
          jne return_col_test
          dec si
          xchg si, di
          mov al, BK_MARKING_COLOR
          stosb
          xchg si, di
          jmp return_col_test
     no_col:
          loop col_loop1
          add si, SCREEN_W - 8
          dec bx
          test bx, bx
          jnz col_loop2
          xor ax, ax
     return_col_test:
          pop bx
          pop cx
          pop dx
          ret

remove_ball:
      mov ax, COLOR_BG
      mov [cur_color], ax
      mov ax, [ball_y_old]
      mov bx, SCREEN_W
      mul bx
      mov di, [ball_x_old]
      jmp common_ball_draw

draw_ball:
      mov ax, COLOR_BALL
      mov [cur_color], ax
      mov ax, [ball_y]
      mov [ball_y_old], ax
      mov bx, SCREEN_W
      mul bx
      mov di, [ball_x]
      mov [ball_x_old], di

common_ball_draw:
      add di, ax
      mov bx, 7

draw_ball_loop:
      mov cx, 8

draw_byte_loop:
      mov ax, [cur_color]
      stosb
      loop draw_byte_loop
      add di, SCREEN_W - 8
      dec bx
      test bx, bx
      jnz draw_ball_loop

update_board:
      mov bx, BD_Y * SCREEN_W
      mov di, [bd_x_old]
      add di, bx
      mov al, COLOR_BG
      call draw_board_loaded
      mov di, [bd_x]
      mov [bd_x_old], di
      add di, bx
      mov al, COLOR_BOARD
      call draw_board_loaded

draw_board_loaded:
      mov cx, BD_H
draw_board_loop:
      push cx
      mov cx, BD_W
      rep stosb
      add di, SCREEN_W - BD_W
      pop cx
      loop draw_board_loop
      ret

draw_bricks:
      mov di, SCREEN_W * BK_ROOF + BK_BORDER
      xor si, si
      mov cx, BK_ROWS
      draw_brick_row_loop:
           push cx
           mov cx, BRICK_H
      draw_brick_line_loop:
           call draw_brick_line_and_gap
           add di, SCREEN_W
           loop draw_brick_line_loop
           add di, SCREEN_W * (BK_GAP)
           pop cx
           add si, BK_PER_ROW
           loop draw_brick_row_loop
           ret

draw_brick_line_and_gap:
      push cx
      push di
      push si
      mov bx, BK_PER_ROW
      draw_brick_line_and_gap_loop:
           mov cx, BRICK_W
           push cx
           push si
           push di
           xchg si, di

check_brick_line:
      lodsb
      cmp al, BK_MARKING_COLOR
      je remove_this
      loop check_brick_line
      jmp check_done
remove_this:
      stosb
check_done:
      pop di
      pop si
      pop cx
      lodsb
      rep stosb
      mov cx, BK_GAP
      mov ax, COLOR_BG
      rep stosb
      dec bx
      test bx, bx
      jnz draw_brick_line_and_gap_loop
      pop si
      pop di
      pop cx
      ret

fill:
      times 510 - ($ - $$) db 0x00
      dw 0xAA55