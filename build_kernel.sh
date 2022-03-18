#!/bin/bash
rm -rf out

export ARCH=arm64
export SUBARCH=arm64

BUILD_CROSS_COMPILE=$(pwd)/toolchain/gcc/bin/aarch64-linux-android-
KERNEL_LLVM_BIN=$(pwd)/toolchain/clang/bin/clang
CLANG_TRIPLE=aarch64-linux-gnu-
KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

make clean
make mrproper
mkdir -p out

echo "Generate .config from defconfig"
make -j$(nproc) -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE CONFIG_DEBUG_SECTION_MISMATCH=y vendor/gts7l_eur_open_defconfig
echo "Build kernel"
make -j$(nproc) -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE CONFIG_DEBUG_SECTION_MISMATCH=y

#cp out/arch/arm64/boot/Image $(pwd)/arch/arm64/boot/Image