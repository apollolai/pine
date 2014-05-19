
###########################################################
## Standard rules for building an executable file.
##
## Additional inputs from base_rules.make:
## None.
###########################################################

ifeq ($(strip $(LOCAL_MODULE_CLASS)),)
LOCAL_MODULE_CLASS := EXECUTABLES
endif
ifeq ($(strip $(LOCAL_MODULE_SUFFIX)),)
LOCAL_MODULE_SUFFIX := $(TARGET_EXECUTABLE_SUFFIX)
endif

LOCAL_MODULE_STEM := $(strip $(LOCAL_MODULE_STEM))
ifeq ($(LOCAL_MODULE_STEM),)
  LOCAL_MODULE_STEM := $(LOCAL_MODULE)
endif
LOCAL_INSTALLED_MODULE_STEM := $(LOCAL_MODULE_STEM)$(LOCAL_MODULE_SUFFIX)
LOCAL_BUILT_MODULE_STEM := $(LOCAL_INSTALLED_MODULE_STEM)

guessed_intermediates := $(call local-intermediates-dir)
linked_module := $(guessed_intermediates)/$(LOCAL_BUILT_MODULE_STEM)
ALL_ORIGINAL_DYNAMIC_BINARIES += $(linked_module)
LOCAL_INTERMEDIATE_TARGETS := $(linked_module)

####################################################
## Add profiling libraries if aprof is turned
####################################################

include $(BUILD_SYSTEM)/binary.mk

$(linked_module): $(all_objects) $(all_libraries)
	$(transform-o-to-executable)
