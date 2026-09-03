obj-m += livepatch-callback-stub.o
THIS_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
all:
	$(MAKE) -C $(KDIR) M=$(THIS_DIR) modules
