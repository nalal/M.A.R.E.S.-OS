main: prep boot tail
	cat build/boot.bin build/tail.bin > system/sys.bin

prep:
	mkdir -p build system

boot: prep
	nasm -f bin asm/boot.asm -o build/boot.bin

tail: prep
	nasm -f bin asm/tail.asm -o build/tail.bin

clean:
	rm build system -rf
