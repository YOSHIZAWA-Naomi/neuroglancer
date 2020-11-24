#!/bin/bash -xve
# Builds wheels inside a manylinux container for all supported Python
# versions.

export LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"

dist_dir="python/dist"

build_wheel () {
  local python_version="$1"
  PYBIN=/opt/python/${python_version}/bin

  # Determine the package name/version and path to the existing source distribution.
  local version_info="$("${PYBIN}/python" python/setup.py --name --version)"
  local package_name
  local version
  { read package_name; read version; } <<< "${version_info}"
  if [ "${package_name}" == "" -o "${version}" == "" ]; then
     echo "Unable to determine package name/version"
     exit 1
  fi
  local sdist_path="${dist_dir}/${package_name}-${version}.tar.gz"

  if [ ! -e "${sdist_path}" ]; then
    echo "Source distribution ${sdist_path} must already exist."
    exit 1
  fi

  local temp_wheel_dir="/tmp/wheels_${python_version}"

  # Compile wheel from source distribution.  As a side effect, this also builds/downloads wheels for
  # all dependencies.
  "${PYBIN}/python" -m pip wheel "${sdist_path}" -w "${temp_wheel_dir}"

  # Bundle external shared libraries into the wheel.
  for whl in ${temp_wheel_dir}/${package_name}-${version}-*.whl; do
    auditwheel repair "$whl" -w "${temp_wheel_dir}"
    # Remove original (non-audited) wheel
    rm ${whl}
  done

  # Install wheel to verify that it installs correctly, and then run tests.
  #
  # Do this from the `tests` directory to avoid problems with the PYTHONPATH.
  ( cd python/tests;
    "${PYBIN}/python" -m pip --disable-pip-version-check \
                      install --user \
                      neuroglancer \
                      --no-index -f "${temp_wheel_dir}" \
                      --no-warn-script-location && \
    "${PYBIN}/python" -m pip install pytest && \
    "${PYBIN}/python" -m pytest -vv -s --skip-browser-tests
  )

  # Copy audited manylinux wheels to ${dist_dir}
  cp ${temp_wheel_dir}/${package_name}-${version}-*-manylinux*.whl ${dist_dir}/
}

for python_version in $(cd /opt/python; echo cp3*); do
  build_wheel $python_version
done
