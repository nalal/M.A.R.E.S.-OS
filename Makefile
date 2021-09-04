main: prep boot kernel_asm tail print_c kernel_c link
	cat build/boot.abn build/kernel.bin build/tail.abn > system/sys.bin

prep:
	mkdir -p build system

boot: prep
	nasm -f bin asm/boot.asm -o build/boot.abn

tail: prep
	nasm -f bin asm/tail.asm -o build/tail.abn

kernel_asm: prep
	nasm -f elf asm/k_entry.asm -o build/k_entry.abn

print_c: prep
	i386-elf-gcc -ffreestanding -m32 -g -c c/printing.c -o build/c_print.o

kernel_c: prep
	i386-elf-gcc -ffreestanding -m32 -g -c c/kernel.c -o build/c_kernel.o

link: prep kernel_c print_c kernel_asm
	i386-elf-ld -o build/kernel.bin -Ttext 0x2000 build/k_entry.abn build/c_kernel.o build/c_print.o --oformat binary

clean:
	rm build system -rf
