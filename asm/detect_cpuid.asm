jmp END_D_CPUID
DETECT_CPUID:
	pushfd
	pop eax
	
	mov ecx, eax
	
	xor eax, 1 << 21
	
	push eax
	popfd
	
	pushfd
	pop eax
	
	push ecx
	popfd
	
	xor eax,ecx
	jz NO_CPUID
	ret

NO_CPUID:
	hlt
END_D_CPUID:
