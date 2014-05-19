


PRODUCT_OUT := $(TARGET_PRODUCT_OUT_ROOT)/$(TARGET_DEVICE)

TARGET_OUT := $(OUT_DIR)/target
#TARGET_APPLICATION_OUT := $(TARGET_OUT)/application
TARGET_APPLICATION_OUT := $(SDKDIR)/Customization_Data/File_Systems/application
TARGET_OUT_EXECUTABLES:= $(TARGET_APPLICATION_OUT)/bin
TARGET_OUT_SHARED_LIBRARIES:= $(TARGET_APPLICATION_OUT)/lib

TARGET_OUT_INTERMEDIATES := $(TARGET_OUT)/obj
TARGET_OUT_INTERMEDIATE_LIBRARIES := $(TARGET_OUT_INTERMEDIATES)/lib

TARGET_OUT_UNSTRIPPED := $(TARGET_OUT)/symbols
TARGET_OUT_EXECUTABLES_UNSTRIPPED := $(TARGET_OUT_UNSTRIPPED)/system/bin
TARGET_OUT_SHARED_LIBRARIES_UNSTRIPPED := $(TARGET_OUT_UNSTRIPPED)/system/lib

HOST_OUT := $(OUT_DIR)/host
HOST_OUT_EXECUTABLES := $(HOST_OUT)/bin
HOST_OUT_INTERMEDIATES := $(HOST_OUT)/obj

# ---------------------------------------------------------------
# Set up configuration for target machine.
# The following must be set:
# 		TARGET_OS = { linux }
# 		TARGET_ARCH = { arm | x86 | mips }

TARGET_OS := linux
TARGET_ARCH := arm

# ---------------------------------------------------------------
# Set up configuration for host machine.  We don't do cross-
# compiles except for arm/mips, so the HOST is whatever we are
# running on

UNAME := $(shell uname -sm)

# HOST_OS
ifneq (,$(findstring Linux,$(UNAME)))
	HOST_OS := linux
endif
ifneq (,$(findstring Darwin,$(UNAME)))
	HOST_OS := darwin
endif
ifneq (,$(findstring Macintosh,$(UNAME)))
	HOST_OS := darwin
endif
ifneq (,$(findstring CYGWIN,$(UNAME)))
	HOST_OS := windows
endif

# BUILD_OS is the real host doing the build.
BUILD_OS := $(HOST_OS)

# Under Linux, if USE_MINGW is set, we change HOST_OS to Windows to build the
# Windows SDK. Only a subset of tools and SDK will manage to build properly.
ifeq ($(HOST_OS),linux)
ifneq ($(USE_MINGW),)
	HOST_OS := windows
endif
endif

ifeq ($(HOST_OS),)
$(error Unable to determine HOST_OS from uname -sm: $(UNAME)!)
endif

# HOST_ARCH
ifneq (,$(findstring 86,$(UNAME)))
	HOST_ARCH := x86
endif

ifneq (,$(findstring Power,$(UNAME)))
	HOST_ARCH := ppc
endif

BUILD_ARCH := $(HOST_ARCH)

ifeq ($(HOST_ARCH),)
$(error Unable to determine HOST_ARCH from uname -sm: $(UNAME)!)
endif


