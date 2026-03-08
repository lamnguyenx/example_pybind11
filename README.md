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

```bash
make pybind11     # Build and test with pybind11
make stubs        # Generate type stubs for IDE support
```

Or manually:
```bash
pip install -r requirements.txt
pip install .
python tests/test_pybind.py
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
