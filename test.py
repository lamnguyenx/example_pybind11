import ctypes
import os

# Compile the C code first:
# mkdir -p build && gcc -shared -o build/libexample.so -fPIC src/example.c

# Load the shared library
lib_path = os.path.join(os.path.dirname(__file__), "build/libexample.so")
lib = ctypes.CDLL(lib_path)

# Specify argument and return types
lib.add.argtypes = (ctypes.c_int, ctypes.c_int)
lib.add.restype = ctypes.c_int

# Call the function
result = lib.add(1, 2)
print(f"1 + 2 = {result}")
