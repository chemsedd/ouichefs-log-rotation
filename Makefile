KERNELDIR ?= /lib/modules/$(shell uname -r)/build

obj-m += src/largest.o src/oldest.o

all :
	make -C $(KERNELDIR) M=$(PWD) modules

clean:
	make -C $(KERNELDIR) M=$(PWD) clean

