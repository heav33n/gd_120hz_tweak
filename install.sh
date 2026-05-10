#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

read -r -p "Enter the path to the GeometryJump binary: " binary_path
dir=$(dirname "$binary_path")
payload_dir=$(realpath "$dir/../../")

echo "Detecting distribution..."

if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
elif [ -f /etc/arch-release ]; then
    DISTRO="arch"
elif [ -f /etc/debian_version ]; then
    DISTRO="debian"
else
    echo "Unknown distribution"
    exit 1
fi

echo "Detected: $DISTRO"

case "$DISTRO" in
    arch | manjaro | endeavouros)
        sudo pacman -Sy --needed git curl make perl

        if command -v yay &> /dev/null; then
            echo "Yay found!"
        else
            echo "Error: yay is not installed. Please install it first."
            exit 1
        fi

        if command -v ldid &> /dev/null; then
            echo "Already installed ldid, skipping..."
        else
            yay -S ldid
        fi
        ;;

    ubuntu | debian | pop | linuxmint | kali)
        sudo apt-get update
        sudo apt-get install -y git curl make perl
        # Note: ldid usually needs to be compiled or grabbed from a repo like Procursus for Debian
        ;;

    fedora)
        sudo dnf install -y git curl make perl
        ;;

    opensuse* | sles)
        sudo zypper install -y git curl make perl
        ;;
    *)
        echo "Unsupported distribution: $DISTRO"
        exit 1
        ;;
esac

echo "Checking if theos is installed..."
if [ ! -d "$HOME/theos" ]; then
    echo "Theos is not installed in $HOME. Please install it and retry."
    exit 1
else
    export THEOS="$HOME/theos"
    echo "Theos found at $THEOS"
fi

if ! command -v ldid &> /dev/null; then
    echo "Please install ldid for your distribution before continuing."
    exit 1
fi

echo "Setting up Python environment..."
python3 -m venv .venv

source .venv/bin/activate

pip install lief

echo "Compiling the tweak..."
make

echo "Getting the ANGLEGLKit framework..."
mkdir -p Frameworks
wget "https://github.com/khanhduytran0/ANGLEGLKit/releases/download/1.0/ANGLEGLKit.zip"
unzip "ANGLEGLKit.zip" -d "Frameworks/"


mv "build/gd120hz.dylib" "$dir/"
mv "Frameworks/" "$dir/"

llvm-install-name-tool -change \
    /System/Library/Frameworks/OpenGLES.framework/OpenGLES \
    @rpath/ANGLEGLKit.framework/ANGLEGLKit \
    "$binary_path"

llvm-install-name-tool -add_rpath "@executable_path/." "$binary_path"
python3 add.py "$binary_path" "@executable_path/gd120hz.dylib"
llvm-install-name-tool -add_rpath "@executable_path/Frameworks" "$binary_path"

cd "$payload_dir"

mkdir -p injected_ipa
zip "injected_ipa/GD120Hz.ipa" -r "Payload"

echo "Done! File is in $payload_dir. Now install it with some sideload or signing method."
