

.PHONY: $(LOCAL_MODULE) $(LOCAL_MODULE)-clean

ALL_MODULES += $(LOCAL_MODULE)

ifeq ($(strip $($(LOCAL_MODULE)_$(RELEASE_LEVEL)_release_steps)), )
$(LOCAL_MODULE)_$(RELEASE_LEVEL)_release_steps := $($(LOCAL_MODULE)_release_steps)
endif

#$(info $(legacy_module_build))

$(LOCAL_MODULE): $(LOCAL_MODULE_PREREQ)
	$(call legacy_module_build, $@)

$(LOCAL_MODULE)-clean: 
	$(call legacy_module_clean, $(patsubst %-clean,%,$@))

$(LOCAL_MODULE)-release: 
	$(call module_release, $(patsubst %-release,%,$@))


