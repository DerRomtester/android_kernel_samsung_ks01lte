#!/bin/bash
if [ "$CPU_JOB_NUM" = "" ] ; then
CPU_JOB_NUM=`grep -c processor /proc/cpuinfo`
fi
echo "Cleaning old files"
rm -f ../android_kernel*/zip/Tyr*
rm -f ../android_kernel*/zip/boot.img
rm -f ../ram*/image-new*
rm -f ../ram*/ramdisk-new.cpio*
rm -f ../ram*/spl*/boot.img-dtb
rm -f ../ram*/spl*/boot.img-zImage
echo "Making oneplus one kernel"
DATE_START=$(date +"%s")

make clean && make mrproper

export ARCH=arm
export SUBARCH=arm
make cyanogenmod_ks01lte_defconfig
make -j$CPU_JOB_NUM
echo "End of compiling kernel!"

DATE_END=$(date +"%s")
echo
DIFF=$(($DATE_END - $DATE_START))
echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."

if [ $# -gt 0 ]; then
echo $1 > .version
fi
make -j6
../ramdisk_one_plus_one/dtbToolCM -2 -o ../ramdisk_one_plus_one/split_img/boot.img-dtb -s 2048 -p ../android_kernel*/scripts/dtc/ ../android_kernel*/arch/arm/boot/
cp arch/arm/boot/zImage ../ramdisk_i9506/split_img/boot.img-zImage
cd ../ramdisk_i9506/
./repackimg.sh
cd ../android_kernel*/
zipfile="TyrV.zip"
echo "making zip file"
cp ../ramdisk_i9506/image-new.img zip/boot.img
cd zip/
rm -f *.zip
zip -r -9 $zipfile *
rm -f /tmp/*.zip
cp *.zip /tmp

