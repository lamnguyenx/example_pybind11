# Makefile for calling C from Python

.PHONY: all clean build deps

all: build

# Install dependencies
deps:
	pip install -r requirements.txt -q
	pip install -r requirements.dev.txt -q

# Build ctypes shared library (alternative approach)
build:
	@mkdir -p build
	gcc -shared -o build/libexample.so -fPIC src/example.c
	@echo "Built: build/libexample.so (ctypes)"
	pip install . -q
	python tests/test_pybind.py
	pybind11-stubgen example -o src
	@echo "Generated: src/example.pyi"

# Clean build artifacts
clean:
	rm -rf build/
	rm -rf __pycache__
	rm -rf src/__pycache__
	rm -rf *.egg-info
	rm -f example*.so
	rm -f src/example.pyi
	@echo "Cleaned build artifacts"

# Show help
help:
	@echo "Available targets:"
	@echo "  make deps       - Install dependencies (requirements.txt and requirements.dev.txt)"
	@echo "  make pybind11   - Build and test with pybind11 (recommended)"
	@echo "  make stubs      - Auto-generate type stubs (requires pybind11)"
	@echo "  make all        - Build and test with ctypes (alternative)"
	@echo "  make build      - Build ctypes shared library"
	@echo "  make test       - Run ctypes test"
	@echo "  make clean      - Remove build artifacts"
	@echo "  make help       - Show this help"
