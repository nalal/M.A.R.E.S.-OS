; Set to teletype mode and set string offset
call clear_fb

[org 0x7c00]
; Set kernel location in memory
KERNEL_REG equ 0x2000
mov [BOOT_DISK], dl

jmp end_prints

; Hacky 16 bit clear screen command I coppied from stack overflow like
; a lazy moron, I know what it does I just couldn't be bothered to 
; write it myself
clear_fb: ; Clears frame buffer
	mov ax,0
	mov es,ax
	mov di,0
	mov ax,0B800h 	; segment of video buffer
	mov es,ax 	; put this into es
	xor di,di 	; clear di, ES:DI points to video memory
	mov ah,4 	; attribute - red
	mov al,' ' 	; character to put there
	mov cx,4000 	; amount of times to put it there
	cld 		; direction - forwards
	rep stosw
	ret

end_prints:


mov ax, 0
xor ax, ax
mov es, ax
mov ds, ax
mov bp, 0x8000
mov sp, bp

mov bx, KERNEL_REG
mov dh, 20
; sectors to read
mov ah, 0x02
mov al, dh
; cyl
mov ch, 0x00
; sector
mov cl, 0x02
; header
mov dh, 0
; offset
mov dl, [BOOT_DISK]
int 0x13

mov ah, 0x0
mov al, 0x3
int 0x10

call clear_fb

cli
lgdt [GDT_DESC]
mov eax, cr0
or eax, 1
mov cr0, eax
jmp CODE_SEG:PROTECTED_MODE

[bits 32]
PROTECTED_MODE:
FRAMEBUFF_PTR equ 0x1000
mov word [FRAMEBUFF_PTR], 0
mov edx, 0xb8000 ; framebuffer register
mov cl, 80 ; collumn counter
mov bx, msg_str_0
call print_str_32
call print_newline_32
call print_crossbar_32
mov bx, loaded_32_str
call print_str_32
call print_newline_32
mov bx, k_loading_str_32
call print_str_32
mov ax, DATA_SEG
mov ds, ax
mov ss, ax
mov es, ax
mov fs, ax
mov gs, ax
mov ebp, 0x90000
mov esp, ebp


jmp KERNEL_REG


jmp b32_funcs_end
b32_funcs:

print_newline_32:
	cmp cl, 0
	je p_nl_32_exit
	mov al, ' '
        call print_char_32
	jmp print_newline_32
	p_nl_32_exit:
	call reset_col_counter_32
	ret

print_crossbar_32:
	cmp cl, 0
	je pcb_32_exit
	mov al, '='
        call print_char_32
	jmp print_crossbar_32
	pcb_32_exit:
	call reset_col_counter_32
	ret

print_str_32:
	cmp al, 0
	je term_print_32
        mov al, [bx]
        mov ah, 4
	call print_char_32
	inc bx
	jmp print_str_32
	term_print_32:
	ret

print_char_32:
	mov [edx], ax
	call inc_fb_addr
	cmp cl, 0
	je reset_pc32_exit
	dec cl
	jmp print_char_32_exit
	reset_pc32_exit:
	call reset_col_counter_32
	print_char_32_exit:
	ret

inc_fb_addr:
	add edx, 0x00002
	inc word [FRAMEBUFF_PTR]
	ret

reset_col_counter_32:
	mov cl, 80
	ret

b32_funcs_end:


jmp $

loaded_32_str:
	db "[PROTECTED MODE]", 0

GDT_START:
	null_desc:
		dd 0
		dd 0
	code_desc:
		dw 0xffff
		dw 0
		db 0
		db 154			;10011010
		db 207			;11001111
		db 0
	data_desc:
		dw 0xffff
		dw 0
		db 0
		db 146			;10010010
		db 207			;11001111
		db 0
GDT_END:

GDT_DESC:
	dw GDT_END - GDT_START -1
	dd GDT_START
	CODE_SEG equ code_desc - GDT_START
	DATA_SEG equ data_desc - GDT_START

BOOT_DISK:
	db 0

; Newline string
nl_str:
	db 13, 10, 0

k_loading_str_32:
	db "LOADING 'M.A.R.E.S.' KERNEL...", 0

; Bootloader version
msg_str_0:
	db "FTC-BOOTLOADER v1.0.0", 0

times 510-($-$$) db 0
dw 0xaa55



;db "=PROTECTED MODE (32 BIT) INITIALIZED=", 13, 10, 0

;times 512 db 0
