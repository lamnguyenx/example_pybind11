# Calling C from Python - Minimal Example

This repository demonstrates **pybind11** - the recommended way to create Python bindings for C/C++ code with automatic type safety and full IDE support.

We also include a **ctypes** alternative for comparison, useful for quick scripts when you don't want additional dependencies.

---

## Recommended: pybind11

Creates a proper Python module with automatic type conversion and full IDE support. Requires a C++ wrapper but leaves your C code untouched.

### Why pybind11?

- **Type safety**: Automatic type conversion between C++ and Python
- **IDE support**: Auto-completion, type hints, and go-to-definition work out of the box
- **Clean API**: No manual type declarations needed
- **Documentation**: Can embed docstrings in C++
- **Production ready**: Used by major libraries (PyTorch, TensorFlow, etc.)

### Files
- `src/example.c` - C source code (unchanged)
- `src/example.h` - C header file
- `src/example_py_bindings.cpp` - C++ wrapper with pybind11
- `setup.py` - Build configuration
- `pyproject.toml` - Build system configuration
- `tests/test_pybind.py` - Python test script
- `src/example.pyi` - Auto-generated type stubs (in src/ for IDE support)

### Quick Start

#### Method 1: Install with pip (Recommended)

Installs the compiled module into Python's site-packages for permanent use:

```bash
pip install -r requirements.txt
pip install .
python tests/test_pybind.py
```

Or use the Makefile:
```bash
make pybind11     # Build and test with pybind11
make stubs        # Generate type stubs for IDE support
```

**What `pip install .` does:**
1. Compiles the C++ extension into a shared library (`.so` file)
2. Copies it to Python's `site-packages` directory
3. Names it with the platform-specific suffix (e.g., `example.cpython-311-aarch64-linux-gnu.so`)
4. Python can now find it via `sys.path` when you run `import example`

#### Method 2: Manual Build with Environment Variables

Build the `.so` manually and use environment variables to make it discoverable (useful for development without installing):

```bash
# 1. Build the shared library manually
mkdir -p build
gcc -shared -o build/libexample.so -fPIC src/example.c

# 2. Set environment variables to point to the build directory
export PYTHONPATH="/home/lamnt45/git/example_pybind11/build:$PYTHONPATH"
export LD_LIBRARY_PATH="/home/lamnt45/git/example_pybind11/build:$LD_LIBRARY_PATH"

# 3. Now you can import it
python -c "import example; print(example.add(1, 2))"
```

**Key differences:**

| Aspect | Method 1: `pip install .` | Method 2: Manual + Env Vars |
|--------|---------------------------|----------------------------|
| Installation | Copies `.so` to site-packages | `.so` stays in build/ directory |
| Persistence | Permanent (survives reboots) | Temporary (session only) |
| Use case | Production, distribution | Development, testing |
| Import mechanism | Python's `sys.path` | `PYTHONPATH` environment variable |
| IDE support | Full (with type stubs) | Limited |

#### Method 2b: Automated Portable Test Script

For convenience, use the provided portable test script that automates Method 2:

```bash
./tests/test_pybind-portable.sh
```

This script will:
1. Automatically detect the script location (works from any directory)
2. Check for the compiled pybind11 module in `build/lib.linux-aarch64-cpython-311/`
3. Set `PYTHONPATH` and `LD_LIBRARY_PATH` environment variables
4. Run `tests/test_pybind.py`

**Requirements:** The pybind11 module must be built first using:
```bash
pip install .                    # Method 1
# OR
python setup.py build_ext --inplace  # Build without installing
```

**Python code** (`tests/test_pybind.py`):
```python
import example

result = example.add(1, 2)  # Returns: 3
```

### VS Code Setup for IDE Support

To get full IDE support (auto-completion, go-to-definition) in VS Code:

1. The `.vscode/settings.json` file is already configured with `python.analysis.extraPaths: ["./src"]`
2. This tells Pylance to look in `src/` for imports and type stubs
3. Run `make stubs` to generate type stubs in `src/example.pyi`

The stub file will be picked up automatically, giving you full type hints and navigation.

### Auto-Generating Type Stubs

Type stubs (`.pyi` files) provide IDE support for compiled modules. Generate them automatically:

```bash
make stubs    # Auto-generate src/example.pyi
```

Or manually:
```bash
pip install -r requirements.dev.txt
pybind11-stubgen example -o src
```

---

## Alternative: ctypes (Built-in)

Use ctypes when you want zero dependencies and don't need IDE support.

### Files
- `src/example.c` - C source code
- `test.py` - Python script using ctypes

### Usage
```bash
make all      # Build and test with ctypes
```

**Python code** (`test.py`):
```python
import ctypes
import os

lib = ctypes.CDLL("./build/libexample.so")
lib.add.argtypes = (ctypes.c_int, ctypes.c_int)
lib.add.restype = ctypes.c_int

result = lib.add(1, 2)  # Returns: 3
```

---

## Comparison

| Feature | pybind11 | ctypes |
|---------|----------|--------|
| Type safety | Automatic | Manual |
| IDE support | Full (auto-completion, navigation) | None |
| Dependencies | pybind11 | None (built-in) |
| Build | pip + setuptools | gcc |
| Best for | Production libraries | Quick scripts |

---

## Requirements

- Python 3.x
- GCC compiler (`apt install build-essential` on Ubuntu/Debian)
- For pybind11: `pip install -r requirements.txt`
- For stubs: `pip install -r requirements.dev.txt`

---

## Makefile Targets

```bash
make pybind11     # Build and test with pybind11 (recommended)
make stubs        # Auto-generate type stubs
make all          # Build and test with ctypes (alternative)
make build        # Build ctypes library only
make test         # Run ctypes test
make clean        # Clean all build artifacts
make help         # Show all commands
```
