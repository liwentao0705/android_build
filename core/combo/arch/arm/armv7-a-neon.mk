# Configuration for Linux on ARM.
# Generating binaries for the ARMv7-a architecture and higher with NEON
#
ARCH_ARM_HAVE_ARMV7A            := true
ARCH_ARM_HAVE_VFP               := true
ARCH_ARM_HAVE_VFP_D32           := true
ARCH_ARM_HAVE_NEON              := true

CORTEX_A15_TYPE := \
	cortex-a15 \
	krait \
	denver

ifndef USE_GCC_DEFAULTS
ifneq (,$(filter $(CORTEX_A15_TYPE),$(TARGET_$(combo_2nd_arch_prefix)CPU_VARIANT)))
	# TODO: krait is not a cortex-a15, we set the variant to cortex-a15 so that
	#       hardware divide operations are generated. This should be removed and a
	#       krait CPU variant added to GCC. For clang we specify -mcpu for krait in
	#       core/clang/arm.mk.
	arch_variant_cflags := -mcpu=cortex-a15

	# Fake an ARM compiler flag as these processors support LPAE which GCC/clang
	# don't advertise.
	arch_variant_cflags += -D__ARM_FEATURE_LPAE=1
	arch_variant_ldflags := \
		-Wl,--no-fix-cortex-a8
else
ifeq ($(strip $(TARGET_$(combo_2nd_arch_prefix)CPU_VARIANT)),cortex-a9)
	arch_variant_cflags := -mcpu=cortex-a9 -mfpu=neon
else
ifneq (,$(filter cortex-a8 scorpion,$(TARGET_$(combo_2nd_arch_prefix)CPU_VARIANT)))
	arch_variant_cflags := -mcpu=cortex-a8 -mfpu=neon
	arch_variant_ldflags := \
		-Wl,--fix-cortex-a8
else
ifeq ($(strip $(TARGET_$(combo_2nd_arch_prefix)CPU_VARIANT)),cortex-a7)
	arch_variant_cflags := -mcpu=cortex-a7 -mfpu=neon-vfpv4
	arch_variant_ldflags := \
		-Wl,--no-fix-cortex-a8
else
	arch_variant_cflags := -march=armv7-a -mfpu=neon
	# Generic ARM might be a Cortex A8 -- better safe than sorry
	arch_variant_ldflags := \
		-Wl,--fix-cortex-a8
endif
endif
endif
endif
else
	arch_variant_cflags := $(USE_GCC_DEFAULTS)
endif

# arm64 doesn't like cortex-a15 in the kernel
ifeq (denver,$(TARGET_$(combo_2nd_arch_prefix)CPU_VARIANT))
	# Export cflags and cpu variant to the kernel.
	export kernel_arch_variant_cflags := -march=armv8-a
endif

arch_variant_cflags += \
    -mfloat-abi=softfp

neon_vfpv4_type := \
	cortex-a15 \
	krait

ifneq ($(filter $(neon_vfpv4_type),$(TARGET_$(combo_2nd_arch_prefix)CPU_VARIANT)),)
    arch_variant_cflags += -mfpu=neon-vfpv4

    # Export cflags and cpu variant to the kernel.
    export kernel_arch_variant_cflags := $(arch_variant_cflags)
endif

