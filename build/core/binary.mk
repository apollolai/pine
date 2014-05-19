


installed_shared_library_module_names := \
      $(LOCAL_SYSTEM_SHARED_LIBRARIES) $(LOCAL_SHARED_LIBRARIES)
LOCAL_REQUIRED_MODULES += $(installed_shared_library_module_names)
#######################################
include $(BUILD_SYSTEM)/base_rules.mk
#######################################
###########################################################
## Explicitly declare assembly-only __ASSEMBLY__ macro for
## assembly source
###########################################################
LOCAL_ASFLAGS += -D__ASSEMBLY__

###########################################################
## Define PRIVATE_ variables used by multiple module types
###########################################################
ifeq ($(strip $(LOCAL_CC)),)
    LOCAL_CC := $($(my_prefix)CC)
endif
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_CC := $(LOCAL_CC)

ifeq ($(strip $(LOCAL_CXX)),)
  LOCAL_CXX := $($(my_prefix)CXX)
endif
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_CXX := $(LOCAL_CXX)

LOCAL_CPP_EXTENSION := $(strip $(LOCAL_CPP_EXTENSION))
ifeq ($(LOCAL_CPP_EXTENSION),)
  LOCAL_CPP_EXTENSION := .cpp
endif
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_CPP_EXTENSION := $(LOCAL_CPP_EXTENSION)

ifeq (true,$(LOCAL_GROUP_STATIC_LIBRARIES))
$(LOCAL_BUILT_MODULE): PRIVATE_GROUP_STATIC_LIBRARIES := true
else
$(LOCAL_BUILT_MODULE): PRIVATE_GROUP_STATIC_LIBRARIES :=
endif


###########################################################
## C++: Compile .cpp files to .o.
###########################################################

# we also do this on host modules, even though
# it's not really arm, because there are files that are shared.
cpp_normal_sources := $(filter %$(LOCAL_CPP_EXTENSION),$(LOCAL_SRC_FILES))
cpp_normal_objects := $(addprefix $(intermediates)/,$(cpp_normal_sources:$(LOCAL_CPP_EXTENSION)=.o))

$(cpp_normal_objects): PRIVATE_ARM_MODE := $(normal_objects_mode)
$(cpp_normal_objects): PRIVATE_ARM_CFLAGS := $(normal_objects_cflags)

cpp_objects        := $(cpp_normal_objects)

ifneq ($(strip $(cpp_objects)),)
$(cpp_objects): $(intermediates)/%.o: \
    $(TOPDIR)$(LOCAL_PATH)/%$(LOCAL_CPP_EXTENSION) \
    $(my_compiler_dependencies) \
    $(LOCAL_ADDITIONAL_DEPENDENCIES)
	$(transform-$(PRIVATE_HOST)cpp-to-o)
-include $(cpp_objects:%.o=%.P)
endif

###########################################################
## C: Compile .c files to .o.
###########################################################

c_normal_sources := $(filter %.c,$(LOCAL_SRC_FILES))
c_normal_objects := $(addprefix $(intermediates)/,$(c_normal_sources:.c=.o))

$(c_normal_objects): PRIVATE_ARM_MODE := $(normal_objects_mode)
$(c_normal_objects): PRIVATE_ARM_CFLAGS := $(normal_objects_cflags)

c_objects        := $(c_normal_objects)

ifneq ($(strip $(c_objects)),)
$(c_objects): $(intermediates)/%.o: $(TOPDIR)$(LOCAL_PATH)/%.c  \
    $(my_compiler_dependencies) $(LOCAL_ADDITIONAL_DEPENDENCIES)
	$(transform-$(PRIVATE_HOST)c-to-o)
-include $(c_objects:%.o=%.P)
endif

###########################################################
## AS: Compile .S files to .o.
###########################################################

asm_sources_S := $(filter %.S,$(LOCAL_SRC_FILES))
asm_objects_S := $(addprefix $(intermediates)/,$(asm_sources_S:.S=.o))

ifneq ($(strip $(asm_objects_S)),)
$(asm_objects_S): $(intermediates)/%.o: $(TOPDIR)$(LOCAL_PATH)/%.S \
    $(my_compiler_dependencies) $(LOCAL_ADDITIONAL_DEPENDENCIES)
	$(transform-$(PRIVATE_HOST)s-to-o)
-include $(asm_objects_S:%.o=%.P)
endif

asm_sources_s := $(filter %.s,$(LOCAL_SRC_FILES))
asm_objects_s := $(addprefix $(intermediates)/,$(asm_sources_s:.s=.o))

ifneq ($(strip $(asm_objects_s)),)
$(asm_objects_s): $(intermediates)/%.o: $(TOPDIR)$(LOCAL_PATH)/%.s \
    $(my_compiler_dependencies) $(LOCAL_ADDITIONAL_DEPENDENCIES)
	$(transform-$(PRIVATE_HOST)s-to-o-no-deps)
-include $(asm_objects_s:%.o=%.P)
endif

asm_objects := $(asm_objects_S) $(asm_objects_s)

###########################################################
## Common object handling.
###########################################################

# some rules depend on asm_objects being first.  If your code depends on
# being first, it's reasonable to require it to be assembly
all_objects := \
    $(cpp_objects) \
    $(c_objects) \
    $(asm_objects) 

so_suffix := $($(my_prefix)SHLIB_SUFFIX)
a_suffix := $($(my_prefix)STATIC_LIB_SUFFIX)

built_static_libraries := \
    $(foreach lib,$(LOCAL_STATIC_LIBRARIES), \
      $(call intermediates-dir-for, \
        STATIC_LIBRARIES,$(lib),$(LOCAL_IS_HOST_MODULE))/$(lib)$(a_suffix))

LOCAL_C_INCLUDES += $(TOPDIR)$(LOCAL_PATH) $(intermediates)

$(all_objects) : | $(LOCAL_GENERATED_SOURCES) $(import_includes)



built_shared_libraries := \
    $(addprefix $($(my_prefix)OUT_INTERMEDIATE_LIBRARIES)/, \
      $(addsuffix $(so_suffix), \
        $(LOCAL_SHARED_LIBRARIES)))

###########################################################
# Rule-specific variable definitions
###########################################################
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_CFLAGS := $(LOCAL_CFLAGS)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_ASFLAGS := $(LOCAL_ASFLAGS)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_CPPFLAGS := $(LOCAL_CPPFLAGS)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_DEBUG_CFLAGS := $(debug_cflags)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_C_INCLUDES := $(LOCAL_C_INCLUDES)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_LDFLAGS := $(LOCAL_LDFLAGS)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_LDLIBS := $(LOCAL_LDLIBS)

$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_ALL_SHARED_LIBRARIES := $(built_shared_libraries)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_ALL_STATIC_LIBRARIES := $(built_static_libraries)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_ALL_OBJECTS := $(all_objects)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_HOST:= $(my_host)

###########################################################
# Define library dependencies.
###########################################################
# all_libraries is used for the dependencies on LOCAL_BUILT_MODULE.
all_libraries := \
    $(built_shared_libraries) \
    $(built_static_libraries) \
    $(built_whole_libraries)






