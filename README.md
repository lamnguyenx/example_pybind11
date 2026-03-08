# Calling C from Python - Minimal Example

This repository demonstrates calling C code from Python using **ctypes** - the built-in, non-invasive approach that requires no modifications to your C code.

## Why ctypes?

- **Non-invasive**: No changes needed to your C/C++ source code
- **Built-in**: Part of Python standard library (no pip install needed)
- **Simple**: Just compile to a shared library and call from Python

---

## Files

- `src/example.c` - C source code with `add()` function
- `test.py` - Python script to call C code
- `Makefile` - Build automation

---

## Usage

### Using Make (Recommended)

```bash
make all      # Build and test
make build    # Build only
make test     # Run test
make clean    # Clean build artifacts
make help     # Show all commands
```

### Manual Build

```bash
# Compile C code to shared library
mkdir -p build
gcc -shared -o build/libexample.so -fPIC src/example.c

# Run Python script
python test.py
```

### Expected Output

```
1 + 2 = 3
```

---

## How it works

**C code** (`src/example.c`):
```c
int add(int a, int b) {
    return a + b;
}
```

**Python code** (`test.py`):
```python
import ctypes
import os

# Load the shared library
lib_path = os.path.join(os.path.dirname(__file__), "build/libexample.so")
lib = ctypes.CDLL(lib_path)

# Define argument and return types
lib.add.argtypes = (ctypes.c_int, ctypes.c_int)
lib.add.restype = ctypes.c_int

# Call C function from Python
result = lib.add(1, 2)  # Returns: 3
print(f"1 + 2 = {result}")
```

---

## Calling C++ Code

To call C++ code without modifying it, compile with `extern "C"` linkage in a wrapper:

```cpp
// wrapper.cpp
extern "C" {
    #include "your_cpp_code.h"
}
```

Or compile your C++ with:
```bash
g++ -shared -o build/libexample.so -fPIC src/example.cpp
```

Then use the same Python code to call it.

---

## Requirements

- Python 3.x
- GCC compiler (`apt install build-essential` on Ubuntu/Debian)

---

## Quick Start

```bash
# Clone/download the repo, then:
make all
```

That's it! No dependencies, no complex setup.
