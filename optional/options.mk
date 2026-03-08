#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# SoC - keep this on top
include device/mainline/qcom-common/soc/qcom_defs.mk
ifeq ($(TARGET_QCOM_SOC_FAMILY),)
    ifeq ($(TARGET_QCOM_SOC),)
        $(error Please define either TARGET_QCOM_SOC or TARGET_QCOM_SOC_FAMILY)
    else
        ifneq ($(filter $(MSM89XX_FAMILY),$(TARGET_QCOM_SOC)),)
            TARGET_QCOM_SOC_FAMILY := msm89xx
        else ifneq ($(filter $(SDM670_FAMILY),$(TARGET_QCOM_SOC)),)
            TARGET_QCOM_SOC_FAMILY := sdm670
        else ifneq ($(filter $(SM7150_FAMILY),$(TARGET_QCOM_SOC)),)
            TARGET_QCOM_SOC_FAMILY := sm7150
        else ifneq ($(filter $(SM8550_FAMILY),$(TARGET_QCOM_SOC)),)
            TARGET_QCOM_SOC_FAMILY := sm8550
        else
            $(error Please add the SoC to this section)
        endif
    endif
endif

ifneq ($(filter $(MSM89XX_FAMILY),$(TARGET_QCOM_SOC)),)
TARGET_QCOM_SOC_FAMILY_IS_LEGACY := true
endif

# Audio HAL
ifneq ($(TARGET_INITIAL_BRINGUP),true)
TARGET_AUDIO_HAL ?= tinyhal
endif

# Boot HAL
ifeq ($(AB_OTA_UPDATER),true)
TARGET_BOOT_HAL ?= qcom-caf-aidl
endif

# Graphics HALs
TARGET_GRAPHICS_ALLOCATOR_HAL ?= minigbm-upstream

# Inherit from mainline/common
include device/mainline/common/optional/options.mk

##### Do not add statements below the inherit in above unless necessary #####
