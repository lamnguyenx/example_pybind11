# Tutorial: Calling C Functions from Python with pybind11

This tutorial walks you through the process of exposing a C function to Python using pybind11, starting from just a C source file and header.

## Starting Point

You begin with two files:

**`src/example.c`** - Your C implementation:
```c
#include <stdio.h>

int add(int a, int b) {
    return a + b;
}
```

**`src/example.h`** - Your C header:
```c
#ifndef EXAMPLE_H
#define EXAMPLE_H

#ifdef __cplusplus
extern "C" {
#endif

int add(int a, int b);

#ifdef __cplusplus
}
#endif

#endif
```

## What You Need to Add

To call this C function from Python, you need to create a **pybind11 binding**. This is a C++ file that bridges your C code with Python.

### Step 1: Create the Binding File

Create **`src/example_py_bindings.cpp`**:

```cpp
#include <pybind11/pybind11.h>
#include "example.h"

namespace py = pybind11;

PYBIND11_MODULE(example, m) {
    m.doc() = "pybind11 example plugin";
    m.def("add", &add, "A function that adds two numbers");
}
```

**Key parts explained:**
- `#include <pybind11/pybind11.h>` - The pybind11 header
- `#include "example.h"` - Your C header (wrapped in `extern "C"` for C++ compatibility)
- `PYBIND11_MODULE(example, m)` - Creates a Python module named `example`
- `m.def("add", &add, ...)` - Exposes the C `add` function as `example.add()` in Python

### Step 2: Create Build Configuration

Create **`setup.py`** to tell Python how to compile the extension:

```python
from pybind11.setup_helpers import Pybind11Extension, build_ext
from pybind11 import get_cmake_dir
import pybind11
from setuptools import setup, Extension

ext_modules = [
    Pybind11Extension(
        "example",
        sources=["src/example_py_bindings.cpp", "src/example.c"],
        include_dirs=["src"],
    ),
]

setup(
    name="example",
    version="0.0.1",
    ext_modules=ext_modules,
    cmdclass={"build_ext": build_ext},
    zip_safe=False,
)
```

**Key parts explained:**
- `Pybind11Extension` - A helper that configures the build with pybind11 flags
- `sources` - List all your source files (both the binding .cpp and the C .c file)
- `include_dirs` - Where to find header files

### Step 3: Create Modern Python Packaging (Optional but Recommended)

Create **`pyproject.toml`** for modern Python packaging:

```toml
[build-system]
requires = ["pybind11>=2.10.0", "setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "example"
version = "0.1.0"
description = "Minimal example of calling C from Python using pybind11"
requires-python = ">=3.8"
dependencies = [
    "pybind11>=2.10.0",
]

[project.optional-dependencies]
dev = [
    "pybind11-stubgen>=0.15.0",
]
```

### Step 4: Create a Python Test Script

Create **`tests/test_pybind.py`**:

```python
# Build and install the module:
# pip install pybind11
# pip install .

# Then use it like this:
import example

result = example.add(1, 2)
print(f"1 + 2 = {result}")
```

### Step 5: Create a Portable Test Script

Create **`tests/test_pybind_portable.sh`**:

```bash
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
```

**Key Features:**

1. **Self-contained** - Combines environment setup and test execution in one script
2. **Build option** - `--build` flag compiles before testing
3. **Portable paths** - Automatically finds project root and build directory
4. **Environment setup** - Sets `PYTHONPATH` and `LD_LIBRARY_PATH` for the shared library
5. **Clean execution** - Runs the separate Python test file for modularity

## Build and Test

### Install Dependencies

```bash
pip install pybind11
```

### Build the Extension

```bash
python setup.py build_ext --inplace
```

This will:
1. Compile `src/example_py_bindings.cpp` and `src/example.c`
2. Create a shared library (`.so` file on Linux, `.pyd` on Windows)
3. Place it in the build directory

### Run the Test

```bash
# Build and test in one command
./tests/test_pybind_portable.sh --build

# Or build separately then test
python setup.py build_ext --inplace
./tests/test_pybind_portable.sh
```

### Direct Python Test

```bash
python tests/test_pybind.py
```

Output:
```
1 + 2 = 3
```

## How It Works

1. **Your C Code** (`example.c`) - The actual implementation
2. **pybind11 Binding** (`example_py_bindings.cpp`) - Creates the Python module
3. **Build System** (`setup.py`) - Compiles everything into a shared library
4. **Python Usage** - Import and use like any Python module

The pybind11 library handles:
- Type conversions between Python and C/C++
- Memory management
- Exception handling
- Python GIL (Global Interpreter Lock) management

## Troubleshooting

### "No module named 'pybind11'"
```bash
pip install pybind11
```

### "Cannot find example.h"
Make sure `include_dirs=["src"]` is set in `setup.py`

### "undefined symbol" errors
Ensure both `.cpp` and `.c` files are in the `sources` list in `setup.py`

### Architecture mismatch
The build directory in `test_pybind_portable.sh` is hardcoded for `aarch64`. Adjust for your platform:
- x86_64: `lib.linux-x86_64-cpython-311`
- aarch64: `lib.linux-aarch64-cpython-311`
