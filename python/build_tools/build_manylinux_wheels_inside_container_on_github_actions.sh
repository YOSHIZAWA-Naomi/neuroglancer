#!/bin/bash -xve
# Wrapper around `build_manylinux_wheels_inside_container.sh` that handles PIP_CACHE_DIR
#
# Github actions runs docker containers as root, and when running as uid 0, pip refuses to use a
# cache directory that is not owned by uid 0.

if [ ! -z "${PIP_CACHE_DIR}" ]; then
  mkdir -p "${PIP_CACHE_DIR}"
  chown $UID "${PIP_CACHE_DIR}"
  chmod 777 "${PIP_CACHE_DIR}"
fi

exec "$(dirname "$0")/build_manylinux_wheels_inside_container.sh" "$@"
