# NuCOMPv5 Architecture

## Deployment Flow

The deployment process follows a linear, two-stage automated approach:

1.  **Stage 1: OS Installation (Kickstart)**
    *   **Trigger**: Booting from the prepared USB stick.
    *   **Mechanism**: The Rocky Linux installer reads the `kickstart.ks` file embedded in the install media or fetched via network.
    *   **Actions**:
        *   Partitions the NVMe drive (Encrypted LVM).
        *   Sets up the `root` user and password.
        *   Configures basic networking (DHCP).
        *   Installs a minimal set of packages including `git` and `ansible-core`.
        *   **Handoff**: In the `%post` script, it installs the `nuwave-ansible` systemd service and timer.

2.  **Stage 2: System Configuration (Ansible)**
    *   **Trigger**: The `nuwave-ansible.timer` (runs 15 min after boot and periodically).
    *   **Mechanism**: The `nuwave-ansible.service` executes `ansible-pull` to fetch the latest playbooks from the git repository (`https://vcs.nuwave.link/nucomp`).
    *   **Actions** (defined in `ansible/local.yml` and included roles):
        *   **System Basics**: Configures Cockpit, hostnames, and timezones.
        *   **Virtualization**: Sets up KVM/QEMU, libvirt, and networking bridges for virtual machines.
        *   **Management**: Installs and registers the ConnectWise RMM Agent.
    *   **Completion**: The system is continually maintained in the desired state.

## Component Overview

| Component | File/Path | Description |
| :--- | :--- | :--- |
| **Kickstart** | `setup/nucompv5.ks` | Defines the partition layout, base OS packages, and triggers the Ansible pull. |
| **Systemd Units** | `setup/nuwave-ansible.*` | Service and Timer units for periodic Ansible execution. |
| **Ansible Entry** | `ansible/local.yml` | The main playbook entry point. It orchestrates the configuration roles. |
| **Inventory** | `ansible/inventory` | Defines `localhost` for the local configuration run. |

## Hardware Specifications
*   **Platform**: Intel NUC 12 or newer.
*   **Storage**: Minimum 500GB NVMe SSD.
*   **Memory**: Minimum 16GB RAM.
