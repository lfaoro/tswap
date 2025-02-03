#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
# Copyright (c) 2024 Leonardo Faoro. All rights reserved.
# Use of this source code is governed by the AGPL-3.0 license
# found in the LICENSE file.

#!/bin/bash

set -e

check_permissions() {
    DIR="$1"
    local temp_file="permission_check_$(date +%s%N)"
    if touch "$DIR/$temp_file" 2>/dev/null; then
        echo "You have permission to write to $DIR without sudo."
        rm "$DIR/$temp_file"
    else
        INSTALL_DIR="/tmp"
    fi
}

REPO="lfaoro/troca"
LATEST_RELEASE_URL="https://github.com/${REPO}/releases/latest"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download"

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "${ARCH}" in
    x86_64|amd64) ARCH="x86_64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) echo "Unsupported architecture: ${ARCH}"; exit 1 ;;
esac

case "${OS}" in
    linux) BINARY_NAME="troca_linux_${ARCH}" ;;
    darwin) BINARY_NAME="troca_darwin_${ARCH}" ;;
    msys*|mingw*) 
        OS="windows"
        BINARY_NAME="troca_windows_${ARCH}.exe" 
        ;;
    *) echo "Unsupported operating system: ${OS}"; exit 1 ;;
esac

VERSION=$(curl -sL ${LATEST_RELEASE_URL} | grep -o "v[0-9]\.[0-9]\.[0-9]" | head -n1)
if [ -z "${VERSION}" ]; then
    echo "Failed to get latest version"
    exit 1
fi

INSTALL_DIR="/usr/local/bin"
if [ "${OS}" = "windows" ]; then
    INSTALL_DIR="$HOME/bin"
fi
mkdir -p "${INSTALL_DIR}"
check_permissions "$INSTALL_DIR"

DOWNLOAD_BINARY_URL="${DOWNLOAD_URL}/${VERSION}/${BINARY_NAME}"

echo "Downloading troca ${VERSION} for ${OS}/${ARCH}..."
if [ "${OS}" = "windows" ]; then
    curl -L "${DOWNLOAD_BINARY_URL}" -o "${INSTALL_DIR}/troca.exe"
    chmod +x "${INSTALL_DIR}/troca.exe"
else
    curl -L "${DOWNLOAD_BINARY_URL}" -o "${INSTALL_DIR}/troca"
    chmod +x "${INSTALL_DIR}/troca"
fi

echo "Successfully installed troca to"
echo "$ ${INSTALL_DIR}/troca"

if [ "${OS}" = "windows" ]; then
    "${INSTALL_DIR}/troca.exe" --debug
else
    "${INSTALL_DIR}/troca" --debug
fi
