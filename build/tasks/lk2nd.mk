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

ifeq ($(TARGET_LK2ND_COMPAT),true)

# $(1): output image
# $(2): mkbootimg image
# $(3): lk2nd image
define build-lk2nd-boot-image
	cp $(3) $(1)
	$(call assert-max-image-size,$(1),$(TARGET_LK2ND_ACTUAL_BOOTIMG_OFFSET))

	lk2nd_size=$$(stat -c%s $(1)); \
	lk2nd_gap=$$(expr $(TARGET_LK2ND_ACTUAL_BOOTIMG_OFFSET) - $$lk2nd_size); \
	dd if=/dev/zero bs=$$lk2nd_gap count=1 >> $(1)

	cat $(2) >> $(1)
endef

$(foreach b,$(INSTALLED_LK2ND_BOOTIMAGE_TARGET), $(eval $(call add-dependency,$(b),$(call bootimage-to-kernel,$(b)))))

ifneq ($(BOARD_BOOTIMAGE_PARTITION_SIZE),)

$(INSTALLED_LK2ND_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES) $(INSTALLED_LK2NDIMAGE_TARGET)
	$(call pretty,"Target boot image with lk2nd: $@")
	$(MKBOOTIMG) --kernel $(call bootimage-to-kernel,$@) $(INTERNAL_BOOTIMAGE_ARGS) $(INTERNAL_MKBOOTIMG_VERSION_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@.mkbootimg
	$(call build-lk2nd-boot-image,$@,$@.mkbootimg,$(INSTALLED_LK2NDIMAGE_TARGET))
	$(call assert-max-image-size,$@,$(call get-bootimage-partition-size,$@,boot))

.PHONY: lk2nd-boot
lk2nd-boot: $(INSTALLED_LK2ND_BOOTIMAGE_TARGET)

endif # BOARD_BOOTIMAGE_PARTITION_SIZE

ifneq ($(BOARD_RECOVERYIMAGE_PARTITION_SIZE),)

$(INSTALLED_LK2ND_RECOVERYIMAGE_TARGET): $(recoveryimage-deps) $(INSTALLED_LK2NDIMAGE_TARGET)
	$(call pretty,"Target recovery image with lk2nd: $@")
	$(call build-recoveryimage-target,$@.mkbootimg,$(recovery_kernel))
	$(call build-lk2nd-boot-image,$@,$@.mkbootimg,$(INSTALLED_LK2NDIMAGE_TARGET))
	$(call assert-max-image-size,$@,$(call get-hash-image-max-size,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE)))

.PHONY: lk2nd-recovery
lk2nd-boot: $(INSTALLED_LK2ND_RECOVERYIMAGE_TARGET)

endif # BOARD_RECOVERYIMAGE_PARTITION_SIZE

endif # TARGET_LK2ND_COMPAT

endif # TARGET_LK2ND_PLATFORM
endif # $(LK2ND_SOURCE)/makefile
endif # USES_DEVICE_MAINLINE_QCOM_COMMON
