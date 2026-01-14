#!/bin/bash

ansible-galaxy collection init https://raw.githubusercontent.com/nuwavepartners/nucomp/refs/heads/main/ansible/requirements.yml

ansible-pull -U https://github.com/nuwavepartners/nucomp.git

