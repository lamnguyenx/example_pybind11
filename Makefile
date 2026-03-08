# Makefile for calling C from Python using ctypes

.PHONY: all clean test build

# Default target: build and test
all: build test

# Build ctypes shared library
build:
	@mkdir -p build
	gcc -shared -o build/libexample.so -fPIC src/example.c
	@echo "Built: build/libexample.so"

# Run test
test: build
	python test.py

# Clean build artifacts
clean:
	rm -rf build/
	rm -rf __pycache__
	rm -rf src/__pycache__
	@echo "Cleaned build artifacts"

# Show help
help:
	@echo "Available targets:"
	@echo "  make all     - Build and test"
	@echo "  make build   - Build ctypes shared library"
	@echo "  make test    - Run test"
	@echo "  make clean   - Remove build artifacts"
	@echo "  make help    - Show this help"
