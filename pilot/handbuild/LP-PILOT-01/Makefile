obj-m += livepatch-cmdline.o

# KDIR overridden at build time by 04-handbuild.sh
KDIR ?= $(WORK_ROOT)/linux

all:
	$(MAKE) -C $(KDIR) M=$(CURDIR) modules

clean:
	$(MAKE) -C $(KDIR) M=$(CURDIR) clean
