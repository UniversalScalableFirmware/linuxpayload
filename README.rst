Linux Payload
#############
This repo contains necessary patches to build a basic Linux payload conforming to universal payload standard.

Current approach reused the UEFI stub entry point as the universal payload stub entry point. This universal payload stub will parse the HOB passed from the bootloader, build the boot parameter block required by Linux kernel, load kernel image into proper location and finally jump into kernel actual entry point for execution.

Build Steps
===========
To build Linux payload, please follow the steps below:

- Prepare a Linux build system with standard development installed, including make, gcc, git, etc. Please refer to the details projects (Slim Bootloader, BusyBox, Linux) for their build environment setup.

- Clone required repos into a workspace in Linux environment

  - Clone repo (https://github.com/universalpayload/linuxpayload.git) into "linuxpayload" folder.

  - Clone repo (https://github.com/universalpayload/tools.git) into "tools" folder.

  - Clone repo (https://github.com/universalpayload/slimbootloader.git) into "slimboot" folder, checkout "dcd9de45e9d3137214338952be93b5372a0ab619" commit.

- Switch into "linuxpayload" folder and run "mk.sh" from root. It will build busybox initramfs image and Linux kernel EFI image.

- The final generated Linux kernel EFI image "bzImage" is located at "linuxpayload/output".

- Switch back to the workspace root and convert kernel image into unviversal payload format.

   - python slimboot/BootloaderCorePkg/Tools/GenerateKeys.py -k SblKeys

   - mkdir  slimboot/PayloadPkg/PayloadBins

   - python tools/pack_payload.py -i linuxpayload/output/bzImage -t pecoff -o slimboot/PayloadPkg/PayloadBins/linux.efi -k SblKeys/OS1_TestKey_Priv_RSA3072.pem -a 0x1000 -ai

- Build final Slim Bootloader image with Linux Payload.

    - echo   "GEN_CFG_DATA.PayloadId | 'LINX'"  > slimboot/Platform/QemuBoardPkg/CfgData/CfgData_PayloadId.dlt

    - python slimboot/BuildLoader.py build qemu -p "OsLoader.efi:LLDR:lz4;linux.efi:LINX:Dummy"

- Run QEMU to launch Slim Bootloader as below

    - qemu-system-x86_64 -m 256M -cpu Broadwell -machine q35 -serial mon:stdio -nographic -pflash slimboot/Outputs/qemu/SlimBootloader.bin

