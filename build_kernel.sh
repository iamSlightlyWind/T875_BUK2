#!/bin/bash
rm -rf out

ccache -M 4.5

export ARCH=arm64

echo
echo "Clean Repository"
echo

make clean & make mrproper

echo
echo "Compile Source"
echo

mkdir -p out
mkdir -p release/modules/system/vendor/lib/modules
mkdir upload

BUILD_CROSS_COMPILE=$(pwd)/toolchain/gcc/bin/aarch64-linux-android-
KERNEL_LLVM_BIN=$(pwd)/toolchain/clang/bin/clang
CLANG_TRIPLE=aarch64-linux-gnu-
KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

echo "Generate .config from defconfig"
make -j$(nproc) -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE CONFIG_DEBUG_SECTION_MISMATCH=y vendor/gts7l_eur_open_defconfig
echo "Build kernel"
make -j$(nproc) -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE CONFIG_DEBUG_SECTION_MISMATCH=y

cat out/arch/arm64/boot/dts/vendor/qcom/kona-v2.1.dtb \
    out/arch/arm64/boot/dts/vendor/qcom/kona-v2.dtb \
    out/arch/arm64/boot/dts/vendor/qcom/kona.dtb \
    > out/arch/arm64/boot/dtb

echo
echo "Package Kernel"
echo

cp -f out/arch/arm64/boot/dtb release/
cp -f out/arch/arm64/boot/Image release/

find out -type f -name "*.ko" -exec cp -Rf "{}" release/modules/system/vendor/lib/modules/ \;

HASH=$(git rev-parse --short HEAD)

cd release
gzip Image
zip -r9 "Windstation-$HASH.zip" * -x *.DS_Store .git* README.md *placeholder LICENSE
mv Windstation* ../upload
cd ../