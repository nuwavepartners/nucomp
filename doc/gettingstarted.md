# Getting Started Guide

This guide describes how to deploy a NuCOMPv5 Hypervisor on an Intel NUC.

## Prerequisites

*   **Hardware**: Intel NUC 12 (or newer)
    *   RAM: 16GB+
    *   Storage: 500GB+ NVMe SSD
    *   Ethernet cable connected to a network with DHCP and Internet access.
*   **USB Drive**: Minimum 8GB capacity.
*   **ISO Image**: Rocky Linux 10 Installer ISO (customized with NuCOMP kickstart).

## 1. Create the Bootable USB

### Option A: Use Pre-built Image
1.  **Download** the provided Rocky Linux ISO image for NuCOMPv5.
2.  **Burn** the ISO to your USB drive using a tool like [Rufus](https://rufus.ie/) (Windows) or `dd` (Linux/macOS).
    *   *Rufus Settings*: Select the ISO and ensure the Target System is set to "UEFI (non CSM)".
    *   *Linux Example*: `sudo dd if=nucomp-rocky10.iso of=/dev/sdX bs=4M status=progress && sync` (Replace `/dev/sdX` with your USB device).

### Option B: Build Image from Source (Admins)
You can generate the bootable image using the provided script in the `setup/` directory.

1.  **Mount** or extract a standard Rocky Linux ISO.
2.  **Run** the build script:
    ```bash
    cd setup
    # Usage: bash make_usb_remote.sh <path_to_extracted_iso_files>
    sudo bash make_usb_remote.sh /path/to/mounted/iso
    ```
3.  **Write** the resulting `rocky_nuc_boot.img` to your USB drive:
    ```bash
    sudo dd if=rocky_nuc_boot.img of=/dev/sdX bs=4M status=progress
    ```

## 2. Boot and Install

1.  **Connect** the Intel NUC to power, a monitor, a keyboard, and the wired network.
2.  **Insert** the USB stick into the NUC.
3.  **Power On** the NUC and immediately press **F10** repeatedly to enter the Boot Menu.
4.  **Select** the USB drive (UEFI) from the list.
5.  **Select** "Install Rocky Linux" from the menu.
    *   *Note*: The installation is fully automated. Do not interrupt the process.
    *   The screen may go black or show text logs for several minutes. This is normal.
6.  **Wait** for the system to reboot automatically.

## 3. Post-Install Verification

Once the system reboots, it should display a login prompt.

1.  **Check Remote Access**:
    *   You should be able to access the Cockpit web interface at `https://<DHCP-IP>:9090`.
2.  **Check RMM**:
    *   Verify the device appears in the ConnectWise RMM portal.

## Next Steps
No further action is required on the device itself. All further configuration is managed remotely via Ansible or the RMM agent.
