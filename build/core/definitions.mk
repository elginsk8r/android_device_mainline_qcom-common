#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

ifeq ($(USES_DEVICE_MAINLINE_QCOM_COMMON),true)

# lk2nd
LK2ND_SOURCE := external/lk2nd
ifneq ($(wildcard $(LK2ND_SOURCE)/makefile),)
INSTALLED_LK2NDIMAGE_TARGET := $(PRODUCT_OUT)/lk2nd.img
ifneq ($(BOARD_BOOTIMAGE_PARTITION_SIZE),)
INSTALLED_LK2ND_BOOTIMAGE_TARGET := $(PRODUCT_OUT)/lk2nd-boot.img
endif
ifneq ($(BOARD_RECOVERYIMAGE_PARTITION_SIZE),)
INSTALLED_LK2ND_RECOVERYIMAGE_TARGET := $(PRODUCT_OUT)/lk2nd-recovery.img
endif
endif

endif # USES_DEVICE_MAINLINE_QCOM_COMMON
