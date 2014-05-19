

LOCAL_UNSTRIPPED_PATH := $(strip $(LOCAL_UNSTRIPPED_PATH))
ifeq ($(LOCAL_UNSTRIPPED_PATH),)
  ifeq ($(LOCAL_MODULE_PATH),)
    LOCAL_UNSTRIPPED_PATH := $(TARGET_OUT_$(LOCAL_MODULE_CLASS)_UNSTRIPPED)
  else
    # We have to figure out the corresponding unstripped path if LOCAL_MODULE_PATH is customized.
    LOCAL_UNSTRIPPED_PATH := $(TARGET_OUT_UNSTRIPPED)/$(patsubst $(PRODUCT_OUT)/%,%,$(LOCAL_MODULE_PATH))
  endif
endif

LOCAL_MODULE_STEM := $(strip $(LOCAL_MODULE_STEM))
ifeq ($(LOCAL_MODULE_STEM),)
  LOCAL_MODULE_STEM := $(LOCAL_MODULE)
endif
LOCAL_INSTALLED_MODULE_STEM := $(LOCAL_MODULE_STEM)$(LOCAL_MODULE_SUFFIX)
LOCAL_BUILT_MODULE_STEM := $(LOCAL_INSTALLED_MODULE_STEM)

guessed_intermediates := $(call local-intermediates-dir)
linked_module := $(guessed_intermediates)/LINKED/$(LOCAL_BUILT_MODULE_STEM)
ALL_ORIGINAL_DYNAMIC_BINARIES += $(linked_module)
LOCAL_INTERMEDIATE_TARGETS := $(linked_module)


###################################
include $(BUILD_SYSTEM)/binary.mk
###################################

# Make sure that our guess at the value of intermediates was correct.
ifneq ($(intermediates),$(guessed_intermediates))
$(error Internal error: guessed path '$(guessed_intermediates)' doesn't match '$(intermediates))
endif

###########################################################
## Compress
###########################################################
compress_input := $(linked_module)

ifeq ($(strip $(LOCAL_COMPRESS_MODULE_SYMBOLS)),)
  LOCAL_COMPRESS_MODULE_SYMBOLS := $(strip $(TARGET_COMPRESS_MODULE_SYMBOLS))
endif

ifeq ($(LOCAL_COMPRESS_MODULE_SYMBOLS),true)
$(error Symbol compression not yet supported.)
compress_output := $(intermediates)/COMPRESSED-$(LOCAL_BUILT_MODULE_STEM)

#TODO: write the real $(STRIPPER) rule.
#TODO: define a rule to build TARGET_SYMBOL_FILTER_FILE, and
#      make it depend on ALL_ORIGINAL_DYNAMIC_BINARIES.
$(compress_output): $(compress_input) $(TARGET_SYMBOL_FILTER_FILE)
	@echo "target Compress Symbols: $(PRIVATE_MODULE) ($@)"
	$(copy-file-to-target-with-cp)
else
# Skip this step.
compress_output := $(compress_input)
endif

###########################################################
## Store a copy with symbols for symbolic debugging
###########################################################
symbolic_input := $(compress_output)
symbolic_output := $(LOCAL_UNSTRIPPED_PATH)/$(LOCAL_BUILT_MODULE_STEM)
$(symbolic_output) : $(symbolic_input)
	@echo "target Symbolic: $(PRIVATE_MODULE) ($@)"
	$(copy-file-to-target-with-cp)


###########################################################
## Strip
###########################################################
strip_input := $(symbolic_output)
strip_output := $(LOCAL_BUILT_MODULE)

ifeq ($(strip $(LOCAL_STRIP_MODULE)),)
  LOCAL_STRIP_MODULE := $(strip $(TARGET_STRIP_MODULE))
endif

ifeq ($(LOCAL_STRIP_MODULE),true)
# Strip the binary
$(strip_output): $(strip_input) | $(TARGET_STRIP)
	$(transform-to-stripped)
else
$(strip_output): $(strip_input)
	@echo "target Unstripped: $(PRIVATE_MODULE) ($@)"
	$(copy-file-to-target-with-cp)
endif # LOCAL_STRIP_MODULE


$(cleantarget): PRIVATE_CLEAN_FILES := \
			$(PRIVATE_CLEAN_FILES) \
			$(linked_module) \
			$(symbolic_output) \
			$(compress_output)
