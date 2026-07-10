obj-m += livepatch-corpus03.o

KDIR ?= $(WORK_ROOT)/linux

all:
	$(MAKE) -C $(KDIR) M=$(CURDIR) modules

clean:
	$(MAKE) -C $(KDIR) M=$(CURDIR) clean
