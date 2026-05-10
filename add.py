import lief
import sys

def add_dylib(binary_path, dylib_path):
    binary = lief.MachO.parse(binary_path).at(0)  # assuming single arch
    binary.add_library(dylib_path)
    binary.write(binary_path)
    print(f"Added {dylib_path} to {binary_path}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <macho> <dylib_path>")
        sys.exit(1)
    add_dylib(sys.argv[1], sys.argv[2])
