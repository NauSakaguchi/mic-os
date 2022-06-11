PREFIX = /usr/local
ARCH = h8300-elf
BINDIR = $(PREFIX)/bin
ADDNAME = $(ARCH)-

AR = $(BINDIR)/$(AADDNAME)ar
AS = $(BINDIR)/$(AADDNAME)as
CC = $(BINDIR)/$(AADDNAME)gcc
LD = $(BINDIR)/$(AADDNAME)ld
NM = $(BINDIR)/$(AADDNAME)nm
OBJCOPY = $(BINDIR)/$(AADDNAME)objcopy
OBJDUMP = $(BINDIR)/$(AADDNAME)objdump
RANLIB = $(BINDIR)/$(AADDNAME)ranlib
STRIP = $(BINDIR)/$(AADDNAME)strip

H8WRITE = ../../tools/h8write/h8write

# FreeBSD-4.x:/dev/cuaaX, FreeBSD-6.x:/dev/cuadX, FreeBSD(USB):/dev/cuaUx
# Linux:/dev/ttySx, Linux(USB):/dev/ttyUSBx, Windows:comX
H8WRITE_SERDEV = /dev/cuad0

OBJS = vector.o startup.o main.o
OBJS += lib.o serial.o

TARGET = kzload

CFLAGS = -Wall -mh -nostdinc -nostdlib -fno-builtin
#CFLAGS += -mint32 # intを32ビットにすると掛け算と割り算ができなくなる
CFLAGS += -I.
#CFLAGS += -g
CFLAGS += -Os
CFLAGS += -DKZLOAD

LFLAGS = -static -T ld.scr -L.

.SUFFIXES: .c .o
.SUFFIXES: .s .o

all : $(TARGET)

$(TARGET) : $(OBJS)
			$(CC) $(OBJS) -o $(TARGET) $(CFLAGS) $(LFLAGS)
			cp $(TARGET) $(TARGET).elf
			$(STRIP) $(TARGET)

.c.o : $<
		$(CC) -c $(CFLAGS) $<

.s.o : $<
		$(CC) -c $(CFLAGS) $<

$(TARGET).mot : $(TARGET)
				$(OBJCOPY) -O srec $(TARGET) $(TARGET).mot

image : $(TARGET).mot

write : $(TARGET).mot
		$(H8WRITE) -3069 -f20 $(TARGET).mot $(H8WRITE_SERDEV)

clean :
		rm -f $(OBJS) $(TARGET) $(TARGET).elf $(TARGET).mot
