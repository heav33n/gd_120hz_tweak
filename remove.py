#!/usr/bin/env python3
import lief
import sys

def remove_dylib(binary_path, dylib_path):
    # Load first architecture slice (adjust if fat binary)
    binary = lief.MachO.parse(binary_path).at(0)

    # Find all DylibCommand entries with the given name
    to_remove = []
    for cmd in binary.commands:
        if isinstance(cmd, lief.MachO.DylibCommand) and cmd.name == dylib_path:
            to_remove.append(cmd)

    if not to_remove:
        print(f"{dylib_path} not found")
        return

    # Remove the matching commands
    for cmd in to_remove:
        binary.remove(cmd)   # This removes the Mach-O load command

    # Write the modified binary back
    binary.write(binary_path)
    print(f"Removed {dylib_path} ({len(to_remove)} occurrence(s))")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <macho> <dylib_path>")
        sys.exit(1)
    remove_dylib(sys.argv[1], sys.argv[2])
