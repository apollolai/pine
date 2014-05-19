

SHOW_COMMANDS := 1
###########################################################
## Output the command lines, or not
###########################################################

ifeq ($(strip $(SHOW_COMMANDS)),)
hide := @
else
hide :=
endif

###########################################################
## Retrieve the directory of the current makefile
###########################################################

# Figure out where we are.
define my-dir
$(strip \
  $(eval LOCAL_MODULE_MAKEFILE := $$(lastword $$(MAKEFILE_LIST))) \
  $(if $(filter $(CLEAR_VARS),$(LOCAL_MODULE_MAKEFILE)), \
    $(error LOCAL_PATH must be set before including $$(CLEAR_VARS)) \
   , \
    $(patsubst %/,%,$(dir $(LOCAL_MODULE_MAKEFILE))) \
   ) \
 )
endef

###########################################################
## For legacy build
###########################################################

define legacy_module_build
@echo "[LEGACY BUILD] Build $(1)"
$(call $(1)_build_steps)
@echo "[LEGACY BUILD] End Build $(1)"
endef

define legacy_module_clean
@echo "[LEGACY BUILD] Clean $(1)"
$(call $(1)_clean_steps)
@echo "[LEGACY BUILD] End Clean $(1)"
endef

define module_release
@echo "[LEGACY BUILD] Release $(1)"
$(call $(1)_$(RELEASE_LEVEL)_release_steps)
@echo "[LEGACY BUILD] End Release $(1)"
endef

define regular_release_steps
$(hide) mkdir -p $(2)
$(hide) rsync -lprt --force $(1)/* $(2)/ >/dev/null	
$(hide) mkdir -p $(3)
$(hide) rsync -lprt --force $(LOCAL_PATH)/* $(3) >/dev/null	
endef

define cleanup_release_package
$(shell find $(1) -name .svn | xargs rm -rf)
$(shell find $(1) -name *.la | xargs rm -rf)
$(shell find $(1) -name .git | xargs rm -rf)
$(shell find $(1) -name .repo | xargs rm -rf)
$(shell find $(1) -name .temp | xargs rm -rf)
endef

###########################################################
## Convert "path/to/libXXX.so" to "-lXXX".
## Any "path/to/libXXX.a" elements pass through unchanged.
###########################################################

define normalize-libraries
$(foreach so,$(filter %.so,$(1)),-l$(patsubst lib%.so,%,$(notdir $(so))))\
$(filter-out %.so,$(1))
endef

# TODO: change users to call the common version.
define normalize-host-libraries
$(call normalize-libraries,$(1))
endef

define normalize-target-libraries
$(call normalize-libraries,$(1))
endef

###########################################################
## The intermediates directory.  Where object files go for
## a given target.  We could technically get away without
## the "_intermediates" suffix on the directory, but it's
## nice to be able to grep for that string to find out if
## anyone's abusing the system.
###########################################################

# $(1): target class, like "APPS"
# $(2): target name, like "NotePad"
# $(3): if non-empty, this is a HOST target.
# $(4): if non-empty, force the intermediates to be COMMON
define intermediates-dir-for
$(strip \
    $(eval _idfClass := $(strip $(1))) \
    $(if $(_idfClass),, \
        $(error $(LOCAL_PATH): Class not defined in call to intermediates-dir-for)) \
    $(eval _idfName := $(strip $(2))) \
    $(if $(_idfName),, \
        $(error $(LOCAL_PATH): Name not defined in call to intermediates-dir-for)) \
    $(eval _idfPrefix := $(if $(strip $(3)),HOST,TARGET)) \
    $(if $(filter $(_idfPrefix)-$(_idfClass),$(COMMON_MODULE_CLASSES))$(4), \
        $(eval _idfIntBase := $($(_idfPrefix)_OUT_COMMON_INTERMEDIATES)) \
      , \
        $(eval _idfIntBase := $($(_idfPrefix)_OUT_INTERMEDIATES)) \
     ) \
    $(_idfIntBase)/$(_idfClass)/$(_idfName)_intermediates \
)
endef

# Uses LOCAL_MODULE_CLASS, LOCAL_MODULE, and LOCAL_IS_HOST_MODULE
# to determine the intermediates directory.
#
# $(1): if non-empty, force the intermediates to be COMMON
define local-intermediates-dir
$(strip \
    $(if $(strip $(LOCAL_MODULE_CLASS)),, \
        $(error $(LOCAL_PATH): LOCAL_MODULE_CLASS not defined before call to local-intermediates-dir)) \
    $(if $(strip $(LOCAL_MODULE)),, \
        $(error $(LOCAL_PATH): LOCAL_MODULE not defined before call to local-intermediates-dir)) \
    $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE),$(LOCAL_IS_HOST_MODULE),$(1)) \
)
endef

###########################################################
## Commands for munging the dependency files GCC generates
###########################################################
# $(1): the input .d file
# $(2): the output .P file
define transform-d-to-p-args
$(hide) cp $(1) $(2); \
	sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
		-e '/^$$/ d' -e 's/$$/ :/' < $(1) >> $(2); \
	rm -f $(1)
endef

define transform-d-to-p
$(call transform-d-to-p-args,$(@:%.o=%.d),$(@:%.o=%.P))
endef

###########################################################
## Commands for running gcc to compile a C++ file
###########################################################

define transform-cpp-to-o
@mkdir -p $(dir $@)
@echo "target $(PRIVATE_ARM_MODE) C++: $(PRIVATE_MODULE) <= $<"
$(hide) $(PRIVATE_CXX) \
	$(addprefix -I , $(PRIVATE_C_INCLUDES)) \
	-c \
	$(PRIVATE_CFLAGS) \
	$(PRIVATE_CPPFLAGS) \
	$(PRIVATE_DEBUG_CFLAGS) \
	-MD -MF $(patsubst %.o,%.d,$@) -o $@ $<
$(transform-d-to-p)
endef

###########################################################
## Commands for running gcc to compile a C file
###########################################################

# $(1): extra flags
define transform-c-or-s-to-o-no-deps
@mkdir -p $(dir $@)
$(hide) $(PRIVATE_CC) \
	$(addprefix -I , $(PRIVATE_C_INCLUDES)) \
	-c \
	$(PRIVATE_CFLAGS) \
	$(1) \
	$(PRIVATE_DEBUG_CFLAGS) \
	-MD -MF $(patsubst %.o,%.d,$@) -o $@ $<
endef

define transform-c-to-o-no-deps
@echo "target $(PRIVATE_ARM_MODE) C: $(PRIVATE_MODULE) <= $<"
$(call transform-c-or-s-to-o-no-deps, )
endef

define transform-s-to-o-no-deps
@echo "target asm: $(PRIVATE_MODULE) <= $<"
$(call transform-c-or-s-to-o-no-deps, $(PRIVATE_ASFLAGS))
endef

define transform-c-to-o
$(transform-c-to-o-no-deps)
$(transform-d-to-p)
endef

define transform-s-to-o
$(transform-s-to-o-no-deps)
$(transform-d-to-p)
endef

###########################################################
## Commands for copying files
###########################################################

define copy-file-to-target-with-cp
@mkdir -p $(dir $@)
$(hide) cp -fp $< $@
endef

###########################################################
## Retrieve a list of all makefiles immediately below some directory
###########################################################

define all-makefiles-under
$(wildcard $(1)/*/module.mk)
endef

###########################################################
## Look under a directory for makefiles that don't have parent
## makefiles.
###########################################################

# $(1): directory to search under
# Ignores $(1)/Android.mk
define first-makefiles-under
$(shell build/tools/findleaves.py --prune=out --prune=.repo --prune=.git \
        --mindepth=2 $(1) module.mk)
endef

###########################################################
## Retrieve a list of all makefiles immediately below your directory
###########################################################

define all-subdir-makefiles
$(call all-makefiles-under,$(call my-dir))
endef

###########################################################
## Commands for running gcc to link a shared library or package
###########################################################

define transform-o-to-shared-lib
@mkdir -p $(dir $@)
@echo "target SharedLib: $(PRIVATE_MODULE) ($@)"
$(transform-o-to-shared-lib-inner)
endef

define transform-o-to-package
@mkdir -p $(dir $@)
@echo "target Package: $(PRIVATE_MODULE) ($@)"
$(transform-o-to-shared-lib-inner)
endef


###########################################################
## Commands for running gcc to link an executable
###########################################################

define transform-o-to-executable
@mkdir -p $(dir $@)
@echo "target Executable: $(PRIVATE_MODULE) ($@)"
$(transform-o-to-executable-inner)
endef

###########################################################
## Commands for running gcc to compile a host C++ file
###########################################################

define transform-host-cpp-to-o
@mkdir -p $(dir $@)
@echo "host C++: $(PRIVATE_MODULE) <= $<"
$(hide) $(PRIVATE_CXX) \
	$(addprefix -I , $(PRIVATE_C_INCLUDES)) \
	$(shell cat $(PRIVATE_IMPORT_INCLUDES)) \
	$(addprefix -isystem ,\
	    $(if $(PRIVATE_NO_DEFAULT_COMPILER_FLAGS),, \
	        $(filter-out $(PRIVATE_C_INCLUDES), \
	            $(HOST_PROJECT_INCLUDES) \
	            $(HOST_C_INCLUDES)))) \
	-c \
	$(if $(PRIVATE_NO_DEFAULT_COMPILER_FLAGS),, \
	    $(HOST_GLOBAL_CFLAGS) \
	    $(HOST_GLOBAL_CPPFLAGS) \
	 ) \
	$(PRIVATE_CFLAGS) \
	$(PRIVATE_CPPFLAGS) \
	$(PRIVATE_DEBUG_CFLAGS) \
	-MD -MF $(patsubst %.o,%.d,$@) -o $@ $<
$(transform-d-to-p)
endef


###########################################################
## Commands for running gcc to compile a host C file
###########################################################

# $(1): extra flags
define transform-host-c-or-s-to-o-no-deps
@mkdir -p $(dir $@)
$(hide) $(PRIVATE_CC) \
	$(addprefix -I , $(PRIVATE_C_INCLUDES)) \
	$(addprefix -isystem ,\
	    $(if $(PRIVATE_NO_DEFAULT_COMPILER_FLAGS),, \
	        $(filter-out $(PRIVATE_C_INCLUDES), \
	            $(HOST_PROJECT_INCLUDES) \
	            $(HOST_C_INCLUDES)))) \
	-c \
	$(if $(PRIVATE_NO_DEFAULT_COMPILER_FLAGS),, \
	    $(HOST_GLOBAL_CFLAGS) \
	 ) \
	$(PRIVATE_CFLAGS) \
	$(1) \
	$(PRIVATE_DEBUG_CFLAGS) \
	-MD -MF $(patsubst %.o,%.d,$@) -o $@ $<
endef

define transform-host-c-to-o-no-deps
@echo "host C: $(PRIVATE_MODULE) <= $<"
$(call transform-host-c-or-s-to-o-no-deps, )
endef

define transform-host-s-to-o-no-deps
@echo "host asm: $(PRIVATE_MODULE) <= $<"
$(call transform-host-c-or-s-to-o-no-deps, $(PRIVATE_ASFLAGS))
endef

define transform-host-c-to-o
$(transform-host-c-to-o-no-deps)
$(transform-d-to-p)
endef

define transform-host-s-to-o
$(transform-host-s-to-o-no-deps)
$(transform-d-to-p)
endef

###########################################################
## Commands for running gcc to link a host executable
###########################################################

ifneq ($(HOST_CUSTOM_LD_COMMAND),true)
define transform-host-o-to-executable-inner
$(hide) $(PRIVATE_CC) \
	$(PRIVATE_ALL_OBJECTS) \
	-Wl,--whole-archive \
	$(call normalize-host-libraries,$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES)) \
	-Wl,--no-whole-archive \
	$(if $(PRIVATE_GROUP_STATIC_LIBRARIES),-Wl$(comma)--start-group) \
	$(call normalize-host-libraries,$(PRIVATE_ALL_STATIC_LIBRARIES)) \
	$(if $(PRIVATE_GROUP_STATIC_LIBRARIES),-Wl$(comma)--end-group) \
	$(call normalize-host-libraries,$(PRIVATE_ALL_SHARED_LIBRARIES)) \
	-Wl,-rpath-link=$(HOST_OUT_INTERMEDIATE_LIBRARIES) \
	-Wl,-rpath,\$$ORIGIN/../lib \
	$(HOST_GLOBAL_LD_DIRS) \
	$(PRIVATE_LDFLAGS) \
	$(if $(PRIVATE_NO_DEFAULT_COMPILER_FLAGS),, \
		$(HOST_GLOBAL_LDFLAGS) \
	) \
	-o $@ \
	$(PRIVATE_LDLIBS)
endef
endif

define transform-host-o-to-executable
@mkdir -p $(dir $@)
@echo "host Executable: $(PRIVATE_MODULE) ($@)"
$(transform-host-o-to-executable-inner)
endef

###########################################################
## Commands for running ar
###########################################################

define _concat-if-arg2-not-empty
$(if $(2),$(hide) $(1) $(2))
endef

# Split long argument list into smaller groups and call the command repeatedly
# Call the command at least once even if there are no arguments, as otherwise
# the output file won't be created.
#
# $(1): the command without arguments
# $(2): the arguments
define split-long-arguments
$(hide) $(1) $(wordlist 1,500,$(2))
$(call _concat-if-arg2-not-empty,$(1),$(wordlist 501,1000,$(2)))
$(call _concat-if-arg2-not-empty,$(1),$(wordlist 1001,1500,$(2)))
$(call _concat-if-arg2-not-empty,$(1),$(wordlist 1501,2000,$(2)))
$(call _concat-if-arg2-not-empty,$(1),$(wordlist 2001,2500,$(2)))
$(call _concat-if-arg2-not-empty,$(1),$(wordlist 2501,3000,$(2)))
$(call _concat-if-arg2-not-empty,$(1),$(wordlist 3001,99999,$(2)))
endef

###########################################################
## Commands for running host ar
###########################################################

# $(1): the full path of the source static library.
define _extract-and-include-single-host-whole-static-lib
@echo "preparing StaticLib: $(PRIVATE_MODULE) [including $(1)]"
$(hide) ldir=$(PRIVATE_INTERMEDIATES_DIR)/WHOLE/$(basename $(notdir $(1)))_objs;\
    rm -rf $$ldir; \
    mkdir -p $$ldir; \
    filelist=; \
    for f in `$(HOST_AR) t $(1) | \grep '\.o$$'`; do \
        $(HOST_AR) p $(1) $$f > $$ldir/$$f; \
        filelist="$$filelist $$ldir/$$f"; \
    done ; \
    $(HOST_AR) $(HOST_GLOBAL_ARFLAGS) $(PRIVATE_ARFLAGS) $@ $$filelist

endef

define extract-and-include-host-whole-static-libs
$(foreach lib,$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES), \
    $(call _extract-and-include-single-host-whole-static-lib, $(lib)))
endef

# Explicitly delete the archive first so that ar doesn't
# try to add to an existing archive.
define transform-host-o-to-static-lib
@mkdir -p $(dir $@)
@rm -f $@
$(extract-and-include-host-whole-static-libs)
@echo "host StaticLib: $(PRIVATE_MODULE) ($@)"
$(call split-long-arguments,$(HOST_AR) $(HOST_GLOBAL_ARFLAGS) $(PRIVATE_ARFLAGS) $@,$(filter %.o, $^))
endef

