; Set to teletype mode and set string offset
call clear_fb

[org 0x7c00]
mov ah, 0x0e

; Print bootloader version
mov bx, msg_str_0
call print_str
call print_nl ; Using manual newline so I can reuse ver string in protected mode
call print_crossbar

; Print execution mode
mov bx, msg_str_1
call print_str

mov bx, input_str
call print_str

; Jump forward to end
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

; Print bar across screen made up of '='s
print_crossbar:
	mov cl, 80
	mov al, '='
	start_pcb:
	cmp cl, 0
	je exit_pcb
	int 0x10
	dec cl
	jmp start_pcb
	exit_pcb:
	ret

; Print newline routine
print_nl:
	mov bx, nl_str
	call print_str
	ret

; Print string routine
print_str:
	mov al, [bx]
	cmp al, 0
	je term_print
	int 0x10
	inc bx
	jmp print_str
	term_print:
	ret

pressed_esc:
	mov ah, 0x0e
	;call print_nl
	;mov bx, ch_esc
	;call print_str
	jmp esc_ret

pnl_input:
	mov ah, 0x0e
	call print_nl
	jmp read_k_input

read_string:
	mov al, [bx]
	cmp al, 0
	je exit_rs
	inc bx
	int 0x10
	jmp read_string
	exit_rs:
	ret

;disk_read_err:
	;mov bx, err_str
	;call print_str
	;mov bx, disk_read_err_str
	;call print_str
	;ret

; End of info string print
end_prints:


read_k_input:
	mov ah, 0
	int 0x16
	cmp ah, 0x01
	je pressed_esc
	;cmp ah, 0x1C
	;je pnl_input
	mov ah, 0x0e
	;int 0x10
	jmp read_k_input
esc_ret:

;jmp end_disk
;print_str_from_disk:
;mov bx, disk_load
;call print_str

;mov ax, 0
;mov es, ax

;mov ah, 2
;; sectors to read
;mov al, 8
;; cyl
;mov ch, 0
;; sector
;mov cl, 2
;; header
;mov dh, 0
;; offset

;mov bx, 0x7e00
;int 0x13
;push bx
;mov bx, 0x0001
;cmp bh, 0
;je disk_read_ok
;disk_read_fail:
;pop bx
;mov ah, 0x0e
;;call disk_read_err
;jmp end_disk
;disk_read_ok:
;	pop bx
;	mov ah, 0x0e
;	call read_string
;	jmp read_k_input

;end_disk:

call clear_fb

cli
lgdt [GDT_DESC]
mov eax, cr0
or eax, 1
mov cr0, eax
jmp CODE_SEG:PROTECTED_MODE

[bits 32]
PROTECTED_MODE:
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

;ch_esc:
;	db "[ESC]", 13, 10, 0

;err_str:
;	db "[ERR]: ", 0

;disk_read_err_str:
	;db "DISK READ FAILURE", 13, 10, 0

; Newline string
nl_str:
	db 13, 10, 0

input_str:
	db "(Press ESC to initialize 32BIT mode)", 13, 10, 0

k_loading_str_32:
	db "LOADING 'M.A.R.E.S.' KERNEL...", 0

;disk_load:
;	db "LOADING DATA FROM DISK...", 13, 10, 0

; Bootloader version
msg_str_0:
	db "FTC-BOOTLOADER v1.0.0", 0

; Realmode notification string
msg_str_1:
	db "[REAL MODE]", 13, 10, 0

times 510-($-$$) db 0
dw 0xaa55



;db "=PROTECTED MODE (32 BIT) INITIALIZED=", 13, 10, 0

;times 512 db 0
