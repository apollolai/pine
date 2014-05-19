

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := mesh
LOCAL_SRC_FILES := mesh.cpp \
		$(PINETOP)/core/pine/PineFile.cpp \
                $(PINETOP)/core/pine/PineFile.cpp

include $(HOST_EXECUTABLE_BUILD)

