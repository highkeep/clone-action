#!/bin/bash
set -euo pipefail

pacman -Syu --noconfirm --needed git svn

if "${INPUT_SVN}"; then
    git svn clone "${INPUT_REPOURL}" --trunk=trunk/${INPUT_REPOPKG} $(basename "${INPUT_REPOPKG}")
else
    git clone "${INPUT_REPOURL}" "${INPUT_REPOPKG}"
fi
