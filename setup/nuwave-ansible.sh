#!/bin/bash
#
# @file run_nucomp_ansible.sh
# @version 0.2.2
# @author Chris Stone
# @description Installs Ansible requirements from a remote source and executes ansible-pull
#              using `flock` to ensure a single instance runs at a time.
#

set -euo pipefail

# @const {string} REQ_URL URL to the Ansible requirements YAML file.
readonly REQ_URL="https://raw.githubusercontent.com/nuwavepartners/nucomp/refs/heads/main/ansible/requirements.yml"

# @const {string} REPO_URL URL to the Git repository for ansible-pull.
readonly REPO_URL="https://github.com/nuwavepartners/nucomp.git"

# @const {string} LOCKFILE Path to the file used for locking.
readonly LOCKFILE="/tmp/run_nucomp_ansible.lock"

# @const {string} TEMP_REQ_FILE Local path for the downloaded requirements file.
readonly TEMP_REQ_FILE="/tmp/nucomp_requirements.yml"

#
# @function log_msg
# @description Prints a formatted message with a timestamp to stdout.
# @param {string} $1 The message to print.
#
log_msg() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

#
# @function install_requirements
# @description Downloads and installs Ansible Galaxy requirements.
#
install_requirements() {
    log_msg "Downloading requirements from $REQ_URL..."
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$REQ_URL" -o "$TEMP_REQ_FILE"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$TEMP_REQ_FILE" "$REQ_URL"
    else
        log_msg "ERROR: Neither curl nor wget found."
        exit 1
    fi

    log_msg "Installing Ansible Galaxy requirements..."
    ansible-galaxy install -r "$TEMP_REQ_FILE"
}

#
# @function run_pull
# @description Executes the ansible-pull command.
#
run_pull() {
    log_msg "Starting ansible-pull..."
    ansible-pull -U "$REPO_URL" ansible/local.yml
}

#
# @function cleanup
# @description Removes the temporary requirements file. Note: The lock file is left intentionally
#              to avoid race conditions on next start, but the kernel releases the FD lock.
#
cleanup() {
    rm -f "$TEMP_REQ_FILE"
}

#
# @function main
# @description Entry point. Sets up locking and executes logic.
#
main() {
    # Open lock file for writing (create if needed) to file descriptor 200
    exec 200>|"$LOCKFILE"

    # Attempt exclusive, non-blocking lock
    if ! flock -x -n 200; then
        log_msg "ERROR: Another instance is already running. Exiting."
        exit 1
    fi

    log_msg "Lock acquired. Starting execution..."

    trap cleanup EXIT

    install_requirements
    run_pull

    log_msg "Execution completed successfully."
}

main "$@"