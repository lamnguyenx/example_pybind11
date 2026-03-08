"""
pybind11 example plugin
"""
from __future__ import annotations
import typing
__all__: list[str] = ['add']
def add(arg0: typing.SupportsInt | typing.SupportsIndex, arg1: typing.SupportsInt | typing.SupportsIndex) -> int:
    """
    A function that adds two numbers
    """
