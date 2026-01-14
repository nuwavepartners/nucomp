# Troubleshooting Guide

## Common Issues

### 1. Installation Hangs or Fails
If the installation fails during the kickstart phase:
*   **Check Network**: Ensure the Ethernet cable is connected and the network provides DHCP. The installer requires internet access to fetch packages.
*   **Check Hardware**: Ensure the NUC has a valid NVMe drive installed. The kickstart script expects `nvme0n1`.

### 2. Ansible Configuration Failed (For CS Staff)
If the OS installs but the configuration (Cockpit, KVM, RMM) is missing:

*   **Service Status**: Check if the systemd service ran successfully.
    ```bash
    systemctl status nuwave-ansible.service
    ```
*   **Logs**: Check the systemd journal for execution logs.
    ```bash
    journalctl -u nuwave-ansible.service
    ```
*   **Kickstart Log**: Check the post-installation log located at `/root/ks-post.log` to see if the service was installed correctly.
    ```bash
    cat /root/ks-post.log
    ```
*   **Manual Run**: You can try running the configuration manually to see errors in real-time:
    ```bash
    ansible-pull -U https://vcs.nuwave.link/nucomp ansible/local.yml
    ```

### 3. "No Bootable Device"
*   Ensure Secure Boot is configured correctly in BIOS (usually Standard or Custom).
*   Verify the USB was created in UEFI mode.

## Support
For further assistance, please escalate to the Central Services team with the following info:
*   Screenshot of the error message (if visible).
*   The MAC address of the NUC.
