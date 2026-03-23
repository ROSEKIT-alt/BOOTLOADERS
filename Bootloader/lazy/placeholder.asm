org 0x7C00
bits 16

;Too lazy to put it here
;Write it yourself

times 510 - ($ - $$) db 0x00
dw 0xAA55