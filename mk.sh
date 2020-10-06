#!/bin/bash

echo Checkout out busybox ...
if [ -d "busybox_upld" ]; then
	cd busybox_upld
	git checkout 1_28_0 -f
else
	git clone --depth 1 --branch 1_32_0  https://github.com/mirror/busybox.git busybox_upld
	cd busybox_upld
fi

echo Applying patch ...
git am --ignore-space-change ../patch/0001-Add-minimal-config-file-for-busybox.patch

echo Compling busybox ...
make mini_defconfig
make install -j8
cd ..

echo Generate RAMFS
if [ ! -d "initramfs" ]; then
	mkdir initramfs
fi
if [ ! -d "output" ]; then
	mkdir output
fi
cd initramfs
cd initramfs
mkdir -p bin lib dev home root sbin etc tmp proc sys usr/bin usr/sbin
cp -a ../busybox_upld/_install/* .
cp ../patch/init .
find . | cpio -H newc -o > ../output/initramfs.cpio
cd ..
cat output/initramfs.cpio | gzip > output/initrd

if [ -d 'linux_upld' ]; then
	echo Checking out linux kernel ...
	cd  ./linux_upld
	git checkout v5.8 -f
else
	echo Cloning linux kernel ...
	git clone --depth 1 --branch v5.8  https://github.com/torvalds/linux.git linux_upld
	cd  linux_upld
fi

echo Applying patch ...
git am --ignore-space-change ../patch/0001-Enable-universal-payload-x64-kernel.patch

echo Compling kernel ...
./build
cd ../
cp linux_upld/arch/x86/boot/bzImage output

