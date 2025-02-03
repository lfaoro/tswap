#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
# Copyright (c) 2024 Leonardo Faoro. All rights reserved.
# Use of this source code is governed by the AGPL-3.0 license
# found in the LICENSE file.

#!/bin/bash

set -e

REPO="lfaoro/troca"
LATEST_RELEASE_URL="https://github.com/${REPO}/releases/latest"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download"

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "${ARCH}" in
    x86_64|amd64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) echo "Unsupported architecture: ${ARCH}"; exit 1 ;;
esac

case "${OS}" in
    linux) BINARY_NAME="troca-linux-${ARCH}" ;;
    darwin) BINARY_NAME="troca-darwin-${ARCH}" ;;
    msys*|mingw*) 
        OS="windows"
        BINARY_NAME="troca-windows-${ARCH}.exe" 
        ;;
    *) echo "Unsupported operating system: ${OS}"; exit 1 ;;
esac

VERSION=$(curl -sL ${LATEST_RELEASE_URL} | grep -o "v[0-9]\.[0-9]\.[0-9]" | head -n1)
if [ -z "${VERSION}" ]; then
    echo "Failed to get latest version"
    exit 1
fi

# Create installation directory
INSTALL_DIR="/usr/local/bin"
if [ "${OS}" = "windows" ]; then
    INSTALL_DIR="$HOME/bin"
fi
mkdir -p "${INSTALL_DIR}"

DOWNLOAD_BINARY_URL="${DOWNLOAD_URL}/${VERSION}/${BINARY_NAME}"

echo "Downloading troca ${VERSION} for ${OS}/${ARCH}..."
if [ "${OS}" = "windows" ]; then
    curl -L "${DOWNLOAD_BINARY_URL}" -o "${INSTALL_DIR}/troca.exe"
    chmod +x "${INSTALL_DIR}/troca.exe"
else
    curl -L "${DOWNLOAD_BINARY_URL}" -o "${INSTALL_DIR}/troca"
    chmod +x "${INSTALL_DIR}/troca"
fi

echo "Successfully installed troca to ${INSTALL_DIR}"
echo "Make sure ${INSTALL_DIR} is in your PATH"

if [ "${OS}" = "windows" ]; then
    "${INSTALL_DIR}/troca.exe" --version
else
    "${INSTALL_DIR}/troca" --version
fi