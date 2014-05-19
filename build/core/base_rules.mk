

###########################################################
## Common instructions for a generic module.
###########################################################

LOCAL_MODULE := $(strip $(LOCAL_MODULE))
ifeq ($(LOCAL_MODULE),)
  $(error $(LOCAL_PATH): LOCAL_MODULE is not defined)
endif

LOCAL_IS_HOST_MODULE := $(strip $(LOCAL_IS_HOST_MODULE))
ifdef LOCAL_IS_HOST_MODULE
  ifneq ($(LOCAL_IS_HOST_MODULE),true)
    $(error $(LOCAL_PATH): LOCAL_IS_HOST_MODULE must be "true" or empty, not "$(LOCAL_IS_HOST_MODULE)")
  endif
  my_prefix:=HOST_
  my_host:=host-
else
  my_prefix:=TARGET_
  my_host:=
endif


LOCAL_MODULE_CLASS := $(strip $(LOCAL_MODULE_CLASS))
ifneq ($(words $(LOCAL_MODULE_CLASS)),1)
  $(error $(LOCAL_PATH): LOCAL_MODULE_CLASS must contain exactly one word, not "$(LOCAL_MODULE_CLASS)")
endif

LOCAL_MODULE_PATH := $(strip $(LOCAL_MODULE_PATH))
ifeq ($(LOCAL_MODULE_PATH),)
  LOCAL_MODULE_PATH := $($(my_prefix)OUT$(partition_tag)_$(LOCAL_MODULE_CLASS))
  ifeq ($(strip $(LOCAL_MODULE_PATH)),)
    $(error $(LOCAL_PATH): unhandled LOCAL_MODULE_CLASS "$(LOCAL_MODULE_CLASS)")
  endif
endif

ifneq ($(strip $(LOCAL_BUILT_MODULE)$(LOCAL_INSTALLED_MODULE)),)
  $(error $(LOCAL_PATH): LOCAL_BUILT_MODULE and LOCAL_INSTALLED_MODULE must not be defined by component makefiles)
endif

# Make sure that this IS_HOST/CLASS/MODULE combination is unique.
module_id := MODULE.$(if \
    $(LOCAL_IS_HOST_MODULE),HOST,TARGET).$(LOCAL_MODULE_CLASS).$(LOCAL_MODULE)
ifdef $(module_id)
$(error $(LOCAL_PATH): $(module_id) already defined by $($(module_id)))
endif
$(module_id) := $(LOCAL_PATH)

intermediates := $(call local-intermediates-dir)
intermediates.COMMON := $(call local-intermediates-dir,COMMON)

###########################################################
# Pick a name for the intermediate and final targets
###########################################################
LOCAL_MODULE_STEM := $(strip $(LOCAL_MODULE_STEM))
ifeq ($(LOCAL_MODULE_STEM),)
  LOCAL_MODULE_STEM := $(LOCAL_MODULE)
endif
LOCAL_INSTALLED_MODULE_STEM := $(LOCAL_MODULE_STEM)$(LOCAL_MODULE_SUFFIX)

LOCAL_BUILT_MODULE_STEM := $(strip $(LOCAL_BUILT_MODULE_STEM))
ifeq ($(LOCAL_BUILT_MODULE_STEM),)
  LOCAL_BUILT_MODULE_STEM := $(LOCAL_INSTALLED_MODULE_STEM)
endif

# OVERRIDE_BUILT_MODULE_PATH is only allowed to be used by the
# internal SHARED_LIBRARIES build files.
OVERRIDE_BUILT_MODULE_PATH := $(strip $(OVERRIDE_BUILT_MODULE_PATH))
ifdef OVERRIDE_BUILT_MODULE_PATH
  built_module_path := $(OVERRIDE_BUILT_MODULE_PATH)
else
  built_module_path := $(intermediates)
endif
LOCAL_BUILT_MODULE := $(built_module_path)/$(LOCAL_BUILT_MODULE_STEM)
built_module_path :=

LOCAL_INSTALLED_MODULE := $(LOCAL_MODULE_PATH)/$(LOCAL_INSTALLED_MODULE_STEM)

# Assemble the list of targets to create PRIVATE_ variables for.
LOCAL_INTERMEDIATE_TARGETS += $(LOCAL_BUILT_MODULE)

###########################################################
## make targets -clean
###########################################################
cleantarget := $(LOCAL_MODULE)-clean
$(cleantarget) : PRIVATE_MODULE := $(LOCAL_MODULE)
$(cleantarget) : PRIVATE_CLEAN_FILES := \
    $(PRIVATE_CLEAN_FILES) \
    $(LOCAL_BUILT_MODULE) \
    $(LOCAL_INSTALLED_MODULE) \
    $(intermediates)
$(cleantarget)::
	@echo "Clean: $(PRIVATE_MODULE)"
	$(hide) rm -rf $(PRIVATE_CLEAN_FILES)

###########################################################
## make targets -release
###########################################################
ifeq ($(strip $($(LOCAL_MODULE)_$(RELEASE_LEVEL)_release_steps)), )
$(LOCAL_MODULE)_$(RELEASE_LEVEL)_release_steps := $($(LOCAL_MODULE)_release_steps)
endif

releasetarget := $(LOCAL_MODULE)-release
$(releasetarget): PRIVATE_MODULE := $(LOCAL_MODULE)
$(releasetarget):
	@echo "Release: $(PRIVATE_MODULE)"
	$(call module_release, $(patsubst %-release,%,$@))

###########################################################
## Common definitions for module.
###########################################################

# Tell the module and all of its sub-modules who it is.
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_MODULE:= $(LOCAL_MODULE)

.PHONY: $(LOCAL_MODULE)
$(LOCAL_MODULE): $(LOCAL_BUILT_MODULE) $(LOCAL_INSTALLED_MODULE)


###########################################################
## Module installation rule
###########################################################
$(LOCAL_INSTALLED_MODULE): $(LOCAL_BUILT_MODULE)
	@echo "Install: $@"
	$(copy-file-to-target-with-cp)

###########################################################
## Register with ALL_MODULES
###########################################################

ALL_MODULES += $(LOCAL_MODULE)



