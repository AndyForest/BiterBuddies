#!/bin/bash
# Build script for Biter Buddies mod
# Packages only the files Factorio needs into a distributable zip

set -e

# Read version from info.json
VERSION=$(grep -o '"version": *"[^"]*"' info.json | grep -o '[0-9][^"]*')
MOD_NAME="Biter_Buddies"
DIST_DIR="dist"
MOD_DIR="${DIST_DIR}/${MOD_NAME}_${VERSION}"

echo "Building ${MOD_NAME} v${VERSION}..."

# Clean previous build
rm -rf "${DIST_DIR}"
mkdir -p "${MOD_DIR}"

# Copy mod files
cp info.json "${MOD_DIR}/"
cp data.lua "${MOD_DIR}/"
cp control.lua "${MOD_DIR}/"
cp thumbnail.png "${MOD_DIR}/"
cp LICENSE "${MOD_DIR}/"

# Copy locale
if [ -d "locale" ]; then
  cp -r locale "${MOD_DIR}/"
fi

# Create zip (Factorio expects ModName_Version.zip containing ModName_Version/ folder)
cd "${DIST_DIR}"
"/c/Program Files/7-Zip/7z.exe" a -tzip "${MOD_NAME}_${VERSION}.zip" "${MOD_NAME}_${VERSION}/"
cd ..

echo ""
echo "Built: ${DIST_DIR}/${MOD_NAME}_${VERSION}.zip"
echo ""
echo "To install: copy the zip to your Factorio mods folder:"
echo "  Windows: %APPDATA%/Factorio/mods/"
echo "  Linux:   ~/.factorio/mods/"
echo "  macOS:   ~/Library/Application Support/factorio/mods/"
