#!/bin/bash
#
# @file generate_boot_image.sh
# @author Chris Stone
# @version 1.3.1
# @description Creates a Secure Boot compatible USB image for Rocky Linux network install.
#              Requires root privileges for loopback mounting if not using mtools.
#              This script uses mtools to avoid requiring root.
#

# --- Configuration ---
IMAGE_NAME="rocky_nuc_boot.img"
IMAGE_SIZE_MB=200
# Path to extracted Rocky Linux ISO contents or mounted ISO
SOURCE_DIR="${1}"

# The URLs where the kickstart and repo are hosted
INST_REPO="https://mirrors.egr.msu.edu/rockylinux/10/BaseOS/x86_64/os/"
INST_KS="https://raw.githubusercontent.com/nuwavepartners/nucomp/refs/heads/main/setup/nucompv5.ks"

# --- Validation ---
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' not found."
    echo "Please mount the Rocky ISO and copy contents to this dir."
    exit 1
fi

echo "Creating blank image file..."
dd if=/dev/zero of="${IMAGE_NAME}" bs=1M count="${IMAGE_SIZE_MB}" status=none

echo "Formatting as FAT32..."
mkfs.vfat -n "NUCOMPV5" "${IMAGE_NAME}" > /dev/null

echo "Creating Directory Structure..."
mmd -i "${IMAGE_NAME}" ::/EFI
mmd -i "${IMAGE_NAME}" ::/EFI/BOOT
mmd -i "${IMAGE_NAME}" ::/linux

echo "Copying Signed Bootloaders..."
# Copy Shim (renamed to BOOTX64.EFI for auto-detection) and GRUB
# Note: Paths in Rocky ISO are usually EFI/BOOT/
mcopy -i "${IMAGE_NAME}" "${SOURCE_DIR}/EFI/BOOT/BOOTX64.EFI" ::/EFI/BOOT/BOOTX64.EFI
mcopy -i "${IMAGE_NAME}" "${SOURCE_DIR}/EFI/BOOT/grubx64.efi" ::/EFI/BOOT/GRUBX64.EFI
mcopy -i "${IMAGE_NAME}" "${SOURCE_DIR}/EFI/BOOT/grub.cfg" ::/EFI/BOOT/grub.cfg.bak

# Copy Signed Kernel and Initrd
# Note: Paths in Rocky ISO are usually images/pxeboot/
echo "Copying Kernel and Initrd..."
mcopy -i "${IMAGE_NAME}" "${SOURCE_DIR}/images/pxeboot/vmlinuz" ::/linux/vmlinuz
mcopy -i "${IMAGE_NAME}" "${SOURCE_DIR}/images/pxeboot/initrd.img" ::/linux/initrd.img

echo "Generating custom grub.cfg..."
# We create a temporary local file then copy it into the image
cat <<EOF > grub.cfg.tmp
set default="0"
set timeout=5

menuentry 'Install Rocky Linux (Remote HTTP)' --class fedora --class gnu-linux --class gnu --class os {

	echo "Loading from USB..."

    linuxefi /linux/vmlinuz inst.repo=${INST_REPO} inst.ks=${INST_KS} ip=dhcp
    initrdefi /linux/initrd.img
}

menuentry 'System Shutdown' {
    halt
}
EOF

mcopy -i "${IMAGE_NAME}" grub.cfg.tmp ::/EFI/BOOT/grub.cfg
rm grub.cfg.tmp

echo "Done. Image '${IMAGE_NAME}' created."
echo "Write to USB using: dd if=${IMAGE_NAME} of=/dev/sdX bs=4M status=progress"
