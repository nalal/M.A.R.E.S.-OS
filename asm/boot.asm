; Set to teletype mode and set string offset
call clear_fb

[org 0x7c00]
; Set kernel location in memory
KERNEL_REG equ 0x2000
mov [BOOT_DISK], dl

jmp B16_FUNCS

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

ENABLE_A20:
	in al, 0x92
	or al, 2
	out 0x92, al
	ret

B16_FUNCS:


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

call ENABLE_A20
cli
lgdt [GDT_DESC]
mov eax, cr0
or eax, 1
mov cr0, eax
jmp CODE_SEG:PROTECTED_MODE

[bits 32]
PROTECTED_MODE:
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

b32_funcs_end:


jmp $

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

times 510-($-$$) db 0
dw 0xaa55
