#!/bin/bash -xve

# Builds manylinux-compatible wheels using Docker.
#
# The sdist must already be built in the `../dist/` directory.

script_dir="$(dirname "$0")"
project_root="$(realpath "${script_dir}/../..")"

for image in quay.io/pypa/manylinux2010_x86_64; do
  echo "Building wheels for $image"
  docker run --rm \
         -w /io \
         -v "${project_root}:/io" \
         -v ${HOME}/.cache/pip:/tmp/.cache/pip \
         -e HOME=/tmp \
         --user ${UID}:${GID} \
         ${image} \
         ./python/build_tools/build_manylinux_wheels_inside_container.sh
done
