#!/bin/bash
set -euo pipefail

# Install required packages
pacman -Syu --noconfirm --needed sudo git svn

# ls -l within ubuntu-latest shows owner of clone is runner and group is docker
# id of runner user: uid=1001(runner) gid=123(docker) groups=123(docker),4(adm),101(systemd-journal)
# So lets match that from now on...

# Add docker group
groupadd -g 123 docker

# Add runner user
useradd runner -m -u 1001 -g 123
# When installing dependencies, makepkg will use sudo
# Give user `runner` passwordless sudo access
echo "runner ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers

# Give all users (particularly runner) full access to these files
chmod -R a+rw .

# Set up sudo cmd to make life a little easier
sudoCMD="sudo -H -u runner"

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
