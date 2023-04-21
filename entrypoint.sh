#!/bin/bash
set -euo pipefail

# Install required packages
pacman -Syu --noconfirm --needed sudo git svn

# Added builder as seen in edlanglois/pkgbuild-action
# mainly for permissions
useradd builder -m
# When installing dependencies, makepkg will use sudo
# Give user `builder` passwordless sudo access
echo "builder ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers

# Give all users (particularly builder) full access to these files
chmod -R a+rw .

if [ "${INPUT_SVNTARGET:-false}" == true ]; then
    sudo -u builder git svn clone "${INPUT_REPOURL}" --trunk=trunk/"${INPUT_REPOPKG}" "${INPUT_REPOPKG##*/}"
    echo "pkg=${INPUT_REPOPKG##*/}" >>$GITHUB_OUTPUT
    echo "pkgRef=$(git -C "${INPUT_REPOPKG##*/}" rev-parse HEAD)" >>$GITHUB_OUTPUT
else
    sudo -u builder git clone "${INPUT_REPOURL}" "${INPUT_REPOPKG}"
    echo "pkg=${INPUT_REPOPKG}" >>$GITHUB_OUTPUT
    echo "pkgRef=$(git -C "${INPUT_REPOPKG}" rev-parse HEAD)" >>$GITHUB_OUTPUT
fi
