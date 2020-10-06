# Linux Payload
This repo contains necessary patches to build a basic Linux payload conforming to universal payload standard.

Current approach resued the UEFI stub entry point as the univeral payload stub entry point. This universal payload stub will parse the HOB passed
from the bootloader, build the boot parameter block required by Linux kernal, load kernel image into proper location and finally jump into kernel
actual entry point for execution.

**Build Steps**

To build Linux payload, please follow the steps below:

- Prepare a Linux build system with standard development installed, including make, gcc, git, ...

- Clone required repo into a workspace on in Linux environment
  - Clone repo (https://github.com/universalpayload/linuxpayload.git) into "linux_pld" folder.
  - Clone repo (https://github.com/universalpayload/tools.git) into "tools" folder, checkout "universal_payload" branch.
  - Clone repo (https://github.com/universalpayload/slimbootloader.git) into "slimboot" folder  

- Switch into "linux_pld" folder and run "mk.sh" from root. It will build busybox initramfs and Linux kernel EFI image.

- The final generated Linux kernel EFI image "bzImage" is at "output" folder under "linux_pld".

- Switch back to workspace and convert kernel image into unviersal payload format. 
   - python slimboot/BootloaderCorePkg/Tools/GenerateKeys.py -k SblKeys    
   - mkdir  slimboot/PayloadPkg/PayloadBins
   - python tools/pack_payload.py -i linux_pld/output/bzImage -t pecoff -o slimboot/PayloadPkg/PayloadBins/linux.efi -k SblKeys/OS1_TestKey_Priv_RSA3072.pem -a 0x1000 -ai

- Build final Slim Bootloader image with Linux Payload.      
    - echo   "GEN_CFG_DATA.PayloadId | 'LINX'"  > slimboot/Platform/QemuBoardPkg/CfgData/CfgData_PayloadId.dlt
    - python slimboot/BuildLoader.py build qemu -p "OsLoader.efi:LLDR:lz4;linux.efi:LINX:Dummy"
    
- Run QEMU to launch Slim Bootloader as descirbed [here](https://slimbootloader.github.io/how-tos/boot-with-linux-payload.html?highlight=qemu)    


