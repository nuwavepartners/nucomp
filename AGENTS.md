# Agent Guidelines

This repository is configured for automatic system deployment using **Rocky Linux** kickstart and **Ansible**, specifically designed for use with `ansible-pull`.

## 1. Build, Lint, and Test Commands

Since this is an Ansible project, "building" refers to verifying the playbooks and configurations.

### Verification & Linting
*   **Syntax Check:**
    ```bash
    ansible-playbook ansible/local.yml --syntax-check
    ```
*   **Linting:**
    Use `ansible-lint` to check for best practices and errors.
    ```bash
    ansible-lint ansible/local.yml
    ```
    *If `ansible-lint` is not installed, standard YAML linters can also be used.*

### Testing
*   **Local Dry Run:**
    To test the playbook without making changes:
    ```bash
    ansible-playbook ansible/local.yml --check --diff
    ```
*   **Single Task Test:**
    To run or test specific tags (ensure tags are added to tasks):
    ```bash
    ansible-playbook ansible/local.yml --tags "tag_name"
    ```

### Ansible Pull Simulation
To simulate how the client will execute the playbook:
```bash
ansible-pull -U . -C main -d /tmp/ansible-pull-test ansible/local.yml --check
```

## 2. Code Style & Conventions

### General
*   **Format:** All files must be valid YAML. Start files with `---`.
*   **Indentation:** Use **2 spaces** for indentation. Do not use tabs.

### Naming
*   **Tasks:** Every task **must** have a descriptive `name`.
    *   *Bad:* `- service: name=httpd state=started`
    *   *Good:* `- name: Ensure httpd service is started`
*   **Variables:** Use `snake_case` for variable names (e.g., `app_port`, `db_password`).
*   **Roles:** Role names should be lowercase and hyphen-separated if necessary.

### Variables & Templating
*   Always quote Jinja2 templates when they start the value.
    *   *Correct:* `msg: "{{ var }}"`
    *   *Incorrect:* `msg: {{ var }}`
*   Keep variables in `defaults/main.yml` or `vars/main.yml` within roles, rather than hardcoding in tasks.

### Error Handling
*   Use `ignore_errors: true` sparingly and only when a failure is genuinely acceptable.
*   Use `failed_when` to define specific failure conditions if the command's return code is insufficient.
*   Use `block/rescue/always` for complex logic requiring error recovery.

### Imports vs Includes
*   Prefer `import_role`/`import_tasks` (static) for core logic that must always run.
*   Use `include_role`/`include_tasks` (dynamic) when looping or using conditionals that affect the file loading.

### Directory Structure
Files are located in the `ansible/` directory:
*   `ansible/local.yml`: Main entry point for `ansible-pull`.
*   `ansible/ansible.cfg`: Local configuration.
*   `ansible/inventory`: Local execution inventory.

## 3. Tool Rules

### File Operations
*   When editing YAML files, ensure strict indentation preservation.
*   When creating new roles, follow the standard Ansible role structure (`tasks/`, `vars/`, `templates/`, `handlers/`).

### Safety
*   When writing tasks that modify system state (installing packages, changing files), always verify the `state` parameter (e.g., `state: present`, `state: latest`).
*   Check for idempotency—running the playbook twice should not produce different results or errors.
