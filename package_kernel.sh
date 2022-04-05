#!/bin/bash
echo "Packaging Kernel"

rm -rf release
mkdir -p out

git clone https://github.com/iamSlightlyWind/AnyKernel3
mkdir -p AnyKernel3/modules/system/vendor/lib/modules
rm -rf AnyKernel3/.git
mv AnyKernel3 release

cp -f out/arch/arm64/boot/Image release/
cat out/arch/arm64/boot/dts/vendor/qcom/kona-v2.1.dtb \
    out/arch/arm64/boot/dts/vendor/qcom/kona-v2.dtb \
    out/arch/arm64/boot/dts/vendor/qcom/kona.dtb \
    > release/dtb

find out -type f -name "*.ko" -exec cp -Rf "{}" release/modules/system/vendor/lib/modules/ \;

cd release
gzip Image
tree