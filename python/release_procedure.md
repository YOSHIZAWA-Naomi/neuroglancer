This package is maintained at [PyPI](https://pypi.python.org/pypi/neuroglancer/).

The published package consists of the source distribution (sdist) along with binary wheels for each
supported Python version and platform.

1. The version number is determined automatically from a git tag:

   ```shell
   git tag vX.Y.Z
   ```

2. To build the source distribution (sdist):

   ```shell
   python setup.py sdist --format=gztar
   ```

   The source distribution is written to the `dist/` directory.

3. For Linux, binary wheels are built using a manylinux docker container (this depends on the source
   distribution built by the previous step):

   ```shell
   ./build_tools/build_manylinux_wheels.sh
   ```

   The manylinux binary wheels are written to the `dist/` directory.

4. For Windows, binary wheels are built on any Windows environment:

   ```shell
   pip install wheel
   python setup.py bdist_wheel
   ```

5. For macOS, binary wheels are built on any macOS environment:

   ```shell
   pip install wheel
   python setup.py bdist_wheel
   ```

   Then the `delocate` package must be used to make the wheel portable:

   ```shell
   pip install delocate
   delocate-wheel dist/*.whl
   ```

6. The source distribution and binary wheels should be copied to a single machine, and then uploaded
   use twine:

   ```shell
   pip install twine
   twine upload dist/*
   ```
