obj-m += livepatch-inline.o

KDIR ?= $(WORK_ROOT)/linux

all:
	$(MAKE) -C $(KDIR) M=$(CURDIR) modules

clean:
	$(MAKE) -C $(KDIR) M=$(CURDIR) clean
