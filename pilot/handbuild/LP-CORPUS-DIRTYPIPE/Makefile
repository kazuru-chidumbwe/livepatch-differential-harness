obj-m += livepatch-dirtypipe.o

KDIR ?= $(WORK_ROOT)/linux
# Do not use $(PWD)/$(CURDIR): a parent kernel `make` can export CURDIR, and
# script 19 `cd`s into the v5.16.10 tree before calling 17-run-v020.sh.
THIS_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

all:
	$(MAKE) -C $(KDIR) M=$(THIS_DIR) modules

clean:
	$(MAKE) -C $(KDIR) M=$(THIS_DIR) clean
