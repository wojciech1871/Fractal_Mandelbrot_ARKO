GCC=g++
CFLAGS=-Wall -m64 -no-pie
LFLAGS=-lSDL2
TARGET=mand

all: mand.o generateMand.o
	$(GCC) $(CFLAGS) mand.o generateMand.o -o $(TARGET) $(LFLAGS)

generateMand.o: generateMand.asm
	nasm -f elf64 -o generateMand.o generateMand.asm

mand.o: mand.cpp
	$(GCC) $(CFLAGS) -c mand.cpp -o mand.o

clean:	
	rm -f *.o

