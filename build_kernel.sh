#!/bin/bash
export ARCH=arm64

rm -rf release
mkdir -p out

git clone https://github.com/iamSlightlyWind/AnyKernel3
mkdir -p AnyKernel3/modules/system/vendor/lib/modules
rm -rf AnyKernel3/.git
mv AnyKernel3 release

########################
echo "Clean Repository"

make clean
make mrproper

########################
echo "Compile Source"

BUILD_CROSS_COMPILE=$(pwd)/toolchain/gcc/bin/aarch64-linux-android-
KERNEL_LLVM_BIN=$(pwd)/toolchain/clang/bin/clang
CLANG_TRIPLE=aarch64-linux-gnu-
KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

echo "Generate .config from defconfig"
make -j$(nproc) -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE CONFIG_DEBUG_SECTION_MISMATCH=y vendor/gts7l_eur_open_defconfig
echo "Build kernel"
make -j$(nproc) -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE CONFIG_DEBUG_SECTION_MISMATCH=y

########################
echo "Package kernel"

cp -f out/arch/arm64/boot/Image release/
cat out/arch/arm64/boot/dts/vendor/qcom/kona-v2.1.dtb \
    out/arch/arm64/boot/dts/vendor/qcom/kona-v2.dtb \
    out/arch/arm64/boot/dts/vendor/qcom/kona.dtb \
    > release/dtb

find out -type f -name "*.ko" -exec cp -Rf "{}" release/modules/system/vendor/lib/modules/ \;

cd release
gzip Image
tree