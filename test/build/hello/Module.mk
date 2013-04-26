

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := hello
LOCAL_MODULE_TAGS := eng
LOCAL_SRC_FILES := hello.c
LOCAL_IS_HOST_MODULE:= true
include $(BUILD_HOST_EXECUTABLE)

