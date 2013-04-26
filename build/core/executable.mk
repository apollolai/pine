ifeq ($(strip $(LOCAL_MODULE_CLASS)),)
LOCAL_MODULE_CLASS := EXECUTABLES
endif
ifeq ($(strip $(LOCAL_MODULE_SUFFIX)),)
LOCAL_MODULE_SUFFIX := $(TARGET_EXECUTABLE_SUFFIX)
endif

include $(BUILD_SYSTEM)/dynamic_binary.mk

# Define PRIVATE_ variables from global vars
my_target_global_ld_dirs := $(TARGET_GLOBAL_LD_DIRS)
my_target_global_ldflags := $(TARGET_GLOBAL_LDFLAGS)
my_target_fdo_lib := $(TARGET_FDO_LIB)
my_target_libgcc := $(TARGET_LIBGCC)
my_target_crtbegin_dynamic_o := $(TARGET_CRTBEGIN_DYNAMIC_O)
my_target_crtbegin_static_o := $(TARGET_CRTBEGIN_STATIC_O)
my_target_crtend_o := $(TARGET_CRTEND_O)



ifeq ($(LOCAL_FORCE_STATIC_EXECUTABLE),true)
$(linked_module): $(my_target_crtbegin_static_o) $(all_objects) $(all_libraries) $(my_target_crtend_o)
        $(transform-o-to-static-executable)
else
$(linked_module): $(my_target_crtbegin_dynamic_o) $(all_objects) $(all_libraries) $(my_target_crtend_o)
        $(transform-o-to-executable)
endif

