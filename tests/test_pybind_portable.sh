#!/bin/bash

set -Eeuo pipefail

SWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PRJ="$(cd "$(dirname "$(readlink -f "${SWD}/PROJECT_ROOT.md")")" &>/dev/null && pwd)"
BUILD_DIR="$PRJ/build/lib.linux-aarch64-cpython-311"

# Build if requested
ARGS=${1:-""}
[ "$ARGS" == "--build" ] && {
    echo "Building..."
    cd "$PRJ"
    python setup.py build_ext --inplace
    exit $?
}

# Find .so file
SO=$(ls "$BUILD_DIR"/example.*.so 2>/dev/null | head -1)
[ -z "$SO" ] && { echo "ERROR: No .so found in $BUILD_DIR. Use --build flag."; exit 1; }

# Set env vars
export PYTHONPATH="$BUILD_DIR${PYTHONPATH:+:$PYTHONPATH}"
export LD_LIBRARY_PATH="$BUILD_DIR${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# Run the test
python3 "$SWD/test_pybind.py"
