
EABI_TOLLCHAIN_ROOT := $(PREBUILT_DIR)/toolchain/armv5-marvell-eabi-softfp
EABI_TOOLS_PREFIX := $(EABI_TOLLCHAIN_ROOT)/bin/arm-marvell-eabi-

HARD_TOOLCHAIN_ROOT := $(PREBUILT_DIR)/toolchain/armv7-marvell-linux-gnueabi-hard
HARD_TOOLS_PREFIX := $(HARD_TOOLCHAIN_ROOT)/bin/arm-marvell-linux-gnueabi-

SOFTFP_TOOLCHAIN_ROOT := $(PREBUILT_DIR)/toolchain/armv7-marvell-linux-gnueabi-softfp_x86_64
SOFTFP_TOOLS_PREFIX := $(SOFTFP_TOOLCHAIN_ROOT)/bin/arm-marvell-linux-gnueabi-

ifeq ($(strip $(TARGET_TOOLS_PREFIX)),)
ifeq ($(strip $(SUPPORT_FLOAT_HARD)), true)
TARGET_TOOLS_PREFIX := $(HARD_TOOLS_PREFIX)
TARGET_TOOLS_ROOT := $(HARD_TOOLCHAIN_ROOT)
else
TARGET_TOOLS_PREFIX := $(SOFTFP_TOOLS_PREFIX)
TARGET_TOOLS_ROOT := $(SOFTFP_TOOLCHAIN_ROOT)
endif
endif

ifneq ($(wildcard $(TARGET_TOOLS_PREFIX)gcc$(HOST_EXECUTABLE_SUFFIX)),)
    TARGET_CC := $(TARGET_TOOLS_PREFIX)gcc$(HOST_EXECUTABLE_SUFFIX)
    TARGET_CXX := $(TARGET_TOOLS_PREFIX)g++$(HOST_EXECUTABLE_SUFFIX)
    TARGET_AR := $(TARGET_TOOLS_PREFIX)ar$(HOST_EXECUTABLE_SUFFIX)
    TARGET_OBJCOPY := $(TARGET_TOOLS_PREFIX)objcopy$(HOST_EXECUTABLE_SUFFIX)
    TARGET_LD := $(TARGET_TOOLS_PREFIX)ld$(HOST_EXECUTABLE_SUFFIX)
    TARGET_STRIP := $(TARGET_TOOLS_PREFIX)strip$(HOST_EXECUTABLE_SUFFIX)
    ifeq ($(TARGET_BUILD_VARIANT),user)
        TARGET_STRIP_COMMAND = $(TARGET_STRIP) --strip-all $< -o $@
    else
        TARGET_STRIP_COMMAND = $(TARGET_STRIP) --strip-all $< -o $@ && \
            $(TARGET_OBJCOPY) --add-gnu-debuglink=$< $@
    endif
endif

TOOLCHAIN_FLOAT_TYPE := $(findstring softfp, $(TARGET_TOOLS_PREFIX))
ifeq ($(strip $(TOOLCHAIN_FLOAT_TYPE)), )
TOOLCHAIN_FLOAT_TYPE := $(findstring hard, $(TARGET_TOOLS_PREFIX))
endif
ifeq ($(strip $(TOOLCHAIN_FLOAT_TYPE)), )
TOOLCHAIN_FLOAT_TYPE := softfp
endif

define transform-o-to-shared-lib-inner
$(hide) $(PRIVATE_CXX) \
	-shared \
	$(PRIVATE_TARGET_GLOBAL_LD_DIRS) \
	$(if $(filter true,$(PRIVATE_NO_CRT)),,$(PRIVATE_TARGET_CRTBEGIN_SO_O)) \
	$(PRIVATE_ALL_OBJECTS) \
	-Wl,--whole-archive \
	$(call normalize-target-libraries,$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES)) \
	-Wl,--no-whole-archive \
	$(if $(PRIVATE_GROUP_STATIC_LIBRARIES),-Wl$(comma)--start-group) \
	$(call normalize-target-libraries,$(PRIVATE_ALL_STATIC_LIBRARIES)) \
	$(if $(PRIVATE_GROUP_STATIC_LIBRARIES),-Wl$(comma)--end-group) \
	$(call normalize-target-libraries,$(PRIVATE_ALL_SHARED_LIBRARIES)) \
	-o $@ \
	$(PRIVATE_TARGET_GLOBAL_LDFLAGS) \
	$(PRIVATE_LDFLAGS) \
	$(PRIVATE_TARGET_FDO_LIB) \
	$(PRIVATE_TARGET_LIBGCC) \
	$(if $(filter true,$(PRIVATE_NO_CRT)),,$(PRIVATE_TARGET_CRTEND_SO_O))
endef

define transform-o-to-executable-inner
$(hide) $(PRIVATE_CXX) \
	-o $@ \
	$(PRIVATE_TARGET_GLOBAL_LD_DIRS) \
	-L$(TARGET_OUT_INTERMEDIATE_LIBRARIES) \
	$(call normalize-target-libraries,$(PRIVATE_ALL_SHARED_LIBRARIES)) \
	$(if $(filter true,$(PRIVATE_NO_CRT)),,$(PRIVATE_TARGET_CRTBEGIN_DYNAMIC_O)) \
	$(PRIVATE_ALL_OBJECTS) \
	-Wl,--whole-archive \
	$(call normalize-target-libraries,$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES)) \
	-Wl,--no-whole-archive \
	$(if $(PRIVATE_GROUP_STATIC_LIBRARIES),-Wl$(comma)--start-group) \
	$(call normalize-target-libraries,$(PRIVATE_ALL_STATIC_LIBRARIES)) \
	$(if $(PRIVATE_GROUP_STATIC_LIBRARIES),-Wl$(comma)--end-group) \
	$(PRIVATE_TARGET_GLOBAL_LDFLAGS) \
	$(PRIVATE_LDFLAGS) \
	$(PRIVATE_TARGET_FDO_LIB) \
	$(PRIVATE_TARGET_LIBGCC) \
	$(if $(filter true,$(PRIVATE_NO_CRT)),,$(PRIVATE_TARGET_CRTEND_O))
endef






