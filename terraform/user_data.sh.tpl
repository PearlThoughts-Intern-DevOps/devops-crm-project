#!/bin/bash
set -euxo pipefail

# --- System packages ---
dnf update -y
dnf install -y git python3 docker

systemctl enable --now docker
usermod -aG docker ec2-user

# --- Clone the app repo at the target branch FIRST, so .nvmrc is
#     available for nvm to read when installing the pinned Node version. ---
mkdir -p /opt/app
git clone --branch ${github_branch} --single-branch ${github_repo_url} /opt/app/devops-crm-project
chown -R ec2-user:ec2-user /opt/app/devops-crm-project

# --- Everything else runs as ec2-user (not root), since nvm/yarn/docker
#     group membership are all set up per-user. ---
sudo -u ec2-user bash <<'ASUSER'
set -euxo pipefail
cd /opt/app/devops-crm-project

# Node.js via nvm, using the exact version pinned in .nvmrc
export NVM_DIR="$HOME/.nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source "$NVM_DIR/nvm.sh"
nvm install
nvm use

# Yarn 4 via Corepack (bundled with Node >=16.9) — .yarnrc.yml pins the
# exact version, corepack reads that automatically.
corepack enable
corepack prepare --activate

# Run the project's own setup automation script. It ends in a
# foreground, blocking `yarn twenty dev` call (per its own design), so
# run it detached in the background and log to a file we can tail.
nohup python3 setup_crm.py > /opt/app/setup.log 2>&1 &
disown
ASUSER
