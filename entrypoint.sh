#!/bin/bash
set -euo pipefail

# Install required packages
pacman -Syu --noconfirm --needed sudo git svn

# Added builder as seen in edlanglois/pkgbuild-action - mainly for permissions
useradd builder -m
# When installing dependencies, makepkg will use sudo
# Give user `builder` passwordless sudo access
echo "builder ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers

# Give all users (particularly builder) full access to these files
chmod -R a+rw .

# Set up sudo cmd to make life a little easier
sudoCMD="sudo -H -u builder"

if [ "${INPUT_SVNTARGET:-false}" == true ]; then
    echo "Cloning: ${INPUT_REPOURL} into: ${INPUT_REPOPKG##*/}"
    ${sudoCMD} git svn clone "${INPUT_REPOURL}" --trunk=trunk/"${INPUT_REPOPKG}" "${INPUT_REPOPKG##*/}"
    ref=$(${sudoCMD} git -C "${INPUT_REPOPKG##*/}" rev-parse HEAD)
    echo "pkg=${INPUT_REPOPKG##*/}" >>$GITHUB_OUTPUT
    echo "pkgRef=${ref}" >>$GITHUB_OUTPUT
else
    echo "Cloning: ${INPUT_REPOURL} into: ${INPUT_REPOPKG}"
    ${sudoCMD} git clone "${INPUT_REPOURL}" "${INPUT_REPOPKG}"
    ref=$(${sudoCMD} git -C "${INPUT_REPOPKG}" rev-parse HEAD)
    echo "pkg=${INPUT_REPOPKG}" >>$GITHUB_OUTPUT
    echo "pkgRef=${ref}" >>$GITHUB_OUTPUT
fi
