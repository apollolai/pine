

# ###############################################################
# Build system internal files
# ###############################################################

BUILD_COMBOS:= $(BUILD_SYSTEM)/combo

CLEAR_VARS:= $(BUILD_SYSTEM)/clear_vars.mk
LEGACY_BUILD:= $(BUILD_SYSTEM)/legacy/legacy_build.mk
EXECUTABLE_BUILD:= $(BUILD_SYSTEM)/executable.mk
SHARED_LIBRARY_BUILD:= $(BUILD_SYSTEM)/shared_library.mk
HOST_EXECUTABLE_BUILD:= $(BUILD_SYSTEM)/host_executable.mk
HOST_STATIC_LIBRARY_BUILD:= $(BUILD_SYSTEM)/host_static_library.mk


# ###############################################################
# Parse out any modifier targets.
# ###############################################################

# The 'showcommands' goal says to show the full command
# lines being executed, instead of a short message about
# the kind of operation being done.
SHOW_COMMANDS:= $(filter showcommands,$(MAKECMDGOALS))


# ---------------------------------------------------------------
# figure out the output directories

ifeq (,$(strip $(BUILD_DIR)))
BUILD_DIR := $(TOPDIR)build
endif

ifeq (,$(strip $(RELEASE_DIR)))
RELEASE_DIR := $(OUT_DIR)/release
endif
RELEASE_PINE_DIR := $(RELEASE_DIR)/PINE


#RSYNC exclude rules for release
RSYNC_EXCLUDE_RULES := --exclude=.git
RSYNC_EXCLUDE_RULES += --exclude=.svn
RSYNC_EXCLUDE_RULES += --exclude=.repo
RSYNC_EXCLUDE_RULES += --exclude=.temp
RSYNC_EXCLUDE_RULES += --exclude=*.la

RSYNC := rsync -lprt --force $(RSYNC_EXCLUDE_RULES)


include $(BUILD_SYSTEM)/envsetup.mk

combo_target := HOST_
include $(BUILD_SYSTEM)/combo/select.mk

combo_target := TARGET_
include $(BUILD_SYSTEM)/combo/select.mk



