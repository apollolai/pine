LEGACY_BUILD_PATH := true
RELEASE_LEVEL := green
SUPPORT_FLOAT_HARD :=false
TARGET_BUILD_VARIANT := eng
TARGET_BOARD := generic

TOP := .
TOPDIR := $(shell pwd)/
PINETOP := $(patsubst %morpheus,%,$(shell pwd))pine


BUILD_SYSTEM := $(TOPDIR)build/core
PREBUILT_DIR := $(TOPDIR)prebuilt
OUT_DIR := $(TOPDIR)out
BOARDS_DIR := $(TOPDIR)boards

# Set up various standard variables based on configuration
# and host information.
include $(BUILD_SYSTEM)/config.mk

# Bring in standard build system definitions.
include $(BUILD_SYSTEM)/definitions.mk

ALL_MODULES := 

#search all module.mk
subdirs := \
	external \
	kernel \
	amp \
	sdk \
	packages \
        test \
        doc \
        boards 

subdir_makefiles := \
	$(shell build/tools/findleaves.py --prune=out --prune=.repo --prune=.git $(subdirs) module.mk)

include $(subdir_makefiles)

.PHONY: clean 
clean: $(addsuffix -clean, $(ALL_MODULES))
	$(hide) rm -rf $(TOP)/out

.PHONY: release release-clean
release-clean: 
	-$(hide) rm -rf $(RELEASE_DIR)

RELEASE_MODULES := $(addsuffix -release, $(ALL_MODULES))
$(RELEASE_MODULES) : | release-clean
$(RELEASE_MODULES) : | rootfs  
release: $(RELEASE_MODULES)
	$(hide) mkdir -p $(RELEASE_PINE_DIR)/build
	$(hide) $(RSYNC) $(PINETOP)/build/* $(RELEASE_PINE_DIR)/build
	$(hide) sed 's/RELEASE_LEVEL := .*/RELEASE_LEVEL := $(RELEASE_LEVEL)/' $(PINETOP)/build/core/main.mk > $(RELEASE_PINE_DIR)/build/core/main.mk
	$(hide) echo 'ro.build.version=$(TARGET_BUILD_VERSION)' >> $(RELEASE_PINE_DIR)/build/system.prop
	$(hide) $(RSYNC) $(PINETOP)/Makefile $(RELEASE_PINE_DIR)
	$(hide) cd $(OUT_DIR) && tar czf mx_$(shell date +%Y%m%d).$(RELEASE_LEVEL).release.tgz release 

.PHONY: release-check
release-check: release
	+$(hide) cd $(RELEASE_PINE_DIR) && make dfu SUPPORT_FLOAT_HARD=$(SUPPORT_FLOAT_HARD) TARGET_BOARD=$(TARGET_BOARD)
	+$(hide) cd $(RELEASE_PINE_DIR)/out && tar czvf emmc_$(shell date +%Y%m%d).$(RELEASE_LEVEL).release.tgz eMMCimg
	+$(hide) cd $(RELEASE_PINE_DIR)/out && tar czvf dfu_$(shell date +%Y%m%d).$(RELEASE_LEVEL).release.tgz dfu.zip dfu.encrypt.zip
	+$(hide) mv $(RELEASE_PINE_DIR)/out/*.release.tgz $(OUT_DIR)

.PHONY: list-modules
list-modules: 
	@echo $(ALL_MODULES)

.PHONY: all
all: 
	echo "Nothing to do!"
