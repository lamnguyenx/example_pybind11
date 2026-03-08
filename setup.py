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
