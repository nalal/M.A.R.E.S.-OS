
[bits 32]
[extern main]
%include "asm/detect_cpuid.asm"
call DETECT_CPUID

call main
jmp $
