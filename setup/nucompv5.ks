#version=RHEL10
# Setup Basics ############################################
graphical
lang en_US.UTF-8
keyboard --xlayouts='us'

timezone America/Detroit --utc

# Use network installation

# Network information
network  --onboot yes --bootproto dhcp
network  --hostname=nucomp.freeparking.nuwave.link
firewall --enabled --ssh

# Misc
firstboot --disabled
selinux --enforcing
reboot

# Auth
rootpw $2a$04$yG0CBH5WjBZX5PyFaTjoT.bxUWNFRY2uO6XB40.No.QfcwlBywbTW --iscrypted

# DISK ####################################################
# Partition clearing information
clearpart --all --initlabel
bootloader --iscrypted --password=grub.pbkdf2.sha512.10000.931ABE112B31AA11D97042AA24CD154ACDD4F0336A2B75898250DFB5B6A1AB6161A5B9867340587BF13CF66312E4BB66305CAEB2932E8492DE32517D5AE8195C.8486043D2900960F00D6030C8D43A57B322102C76C6E91491E1DCC76AA92F33A63968F046C10A2BBFCE5F9DFE41426AEC1D8F4F5B32F3AD5BA071D6153514CEF

part /boot/efi  --fstype="efi" --ondisk=nvme0n1 --size=512 --fsoptions="umask=0077"
part /boot      --fstype="ext4" --ondisk=nvme0n1 --size=1024

# 500 GB is about 476837 MiB
part pv.01      --fstype="lvmpv" --ondisk=nvme0n1 --size=88064        --label=partroot
volgroup lvroot pv.01

part pv.02      --fstype="lvmpv" --ondisk=nvme0n1 --size=32768 --grow --label=partdata
volgroup lvdata pv.02

logvol swap --fstype="swap" --size=8192 --name=swap --vgname=lvroot

logvol /              --vgname=lvroot --fstype="ext4" --size=16384 --name=root
logvol /var           --vgname=lvroot --fstype="ext4" --size=32768 --name=var            --fsoptions="nodev,nosuid"
logvol /var/log       --vgname=lvroot --fstype="ext4" --size=2048  --name=var_log        --fsoptions="nodev,nosuid,noexec"
logvol /var/log/audit --vgname=lvroot --fstype="ext4" --size=1024  --name=var_log_audit  --fsoptions="nodev,nosuid,noexec"
logvol /var/tmp       --vgname=lvroot --fstype="ext4" --size=2048  --name=var_tmp        --fsoptions="nodev,nosuid,noexec"
logvol /tmp           --vgname=lvroot --fstype="ext4" --size=16384 --name=tmp            --fsoptions="nodev,nosuid,noexec"

logvol /home          --vgname=lvdata --fstype="ext4" --size=16384 --name=home           --fsoptions="nodev,nosuid"
logvol /var/lib/libvirt --vgname=lvdata --fstype="ext4" --size=327680 --name=libvirt     --fsoptions="nodev,nosuid"


# ADDONs ##################################################

%addon com_redhat_kdump --disable
%end

%addon com_redhat_oscap
        content-type = scap-security-guide
        profile = xccdf_org.ssgproject.content_profile_cis
%end

# Packages ################################################

%packages
@^minimal-environment

ansible-core
git

%end

# Post ####################################################

%post --log=/root/ks-post.log
# Install and enable nuwave-ansible systemd units
curl -o /opt/nuwave/nuwave-ansible.sh https://raw.githubusercontent.com/nuwavepartners/nucomp/refs/heads/main/setup/nuwave-ansible.sh
curl -o /etc/systemd/system/nuwave-ansible.service https://raw.githubusercontent.com/nuwavepartners/nucomp/refs/heads/main/setup/nuwave-ansible.service
curl -o /etc/systemd/system/nuwave-ansible.timer https://raw.githubusercontent.com/nuwavepartners/nucomp/refs/heads/main/setup/nuwave-ansible.timer
systemctl daemon-reload
systemctl enable --now nuwave-ansible.timer
%end
