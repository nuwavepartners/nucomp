# NuCOMPv5 Project Goals

## Overview
The primary goal of the NuCOMPv5 project is to streamline the deployment of hypervisor servers on Intel NUC hardware. The process is designed to be "zero-touch" after the initial boot, enabling IT technicians with minimal experience to successfully deploy fully configured servers.

## Key Objectives

1.  **Simplicity**: Reduce the deployment process to a single action: booting from a USB stick.
2.  **Automation**: Eliminate manual configuration steps. The installer (Kickstart) handles the OS installation, and Ansible handles the system configuration.
3.  **Consistency**: Ensure every deployed server is identical in configuration, security posture, and installed software.
4.  **Hardware Targeting**: Specifically optimized for Intel NUC 12+ hardware with at least 16GB RAM and 500GB SSD.
5.  **Remote Management**: Automatically provision ConnectWise RMM and Cockpit for immediate remote access and management upon completion.

## Target Audience
This documentation and tooling are built for:
*   **Field Technicians**: Who physically deploy the hardware.
*   **System Administrators**: Who maintain the Ansible playbooks and Kickstart configurations.
