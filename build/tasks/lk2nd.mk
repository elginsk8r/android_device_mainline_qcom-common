#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

ifeq ($(USES_DEVICE_MAINLINE_QCOM_COMMON),true)
ifneq ($(wildcard $(LK2ND_SOURCE)/makefile),)
ifneq ($(TARGET_LK2ND_PLATFORM),)

LK2ND_MAKE_CMD := $(BUILD_TOP)/prebuilts/build-tools/$(HOST_PREBUILT_TAG)/bin/make
LK2ND_OUT_DIR := $(TARGET_OUT_INTERMEDIATES)/LK2ND_OBJ
LK2ND_PATH_OVERRIDE :=  \
    $(BUILD_TOP)/prebuilts/tools-lineage/$(HOST_PREBUILT_TAG)/bin \
    $(BUILD_TOP)/prebuilts/kernel-build-tools/$(HOST_PREBUILT_TAG)/bin \
    $(BUILD_TOP)/prebuilts/gcc/$(HOST_PREBUILT_TAG)/arm/arm-none-eabi-10.2/bin
LK2ND_PATH_OVERRIDE := $(subst $(space),:,$(strip $(LK2ND_PATH_OVERRIDE)))
LK2ND_TOOLCHAIN_PREFIX := arm-none-eabi-

define make-lk2nd-target
@mkdir -p $(LK2ND_OUT_DIR)
PATH=$(LK2ND_PATH_OVERRIDE):$$PATH \
	$(LK2ND_MAKE_CMD) \
	-C $(LK2ND_SOURCE) \
	BOOTLOADER_OUT=$(BUILD_TOP)/$(1) \
	TOOLCHAIN_PREFIX=$(LK2ND_TOOLCHAIN_PREFIX) \
	$(TARGET_LK2ND_MAKE_FLAGS) \
	$(2)
endef

$(INSTALLED_LK2NDIMAGE_TARGET): $(HOST_OUT_EXECUTABLES)/dtc
	$(call pretty,"Target lk2nd image: $@")
	$(hide) $(call make-lk2nd-target,$(LK2ND_OUT_DIR),lk2nd-$(TARGET_LK2ND_PLATFORM))
	cp $(LK2ND_OUT_DIR)/build-lk2nd-$(TARGET_LK2ND_PLATFORM)/lk2nd.img $@

.PHONY: lk2nd
lk2nd: $(INSTALLED_LK2NDIMAGE_TARGET)

endif # TARGET_LK2ND_PLATFORM
endif # $(LK2ND_SOURCE)/makefile
endif # USES_DEVICE_MAINLINE_QCOM_COMMON
