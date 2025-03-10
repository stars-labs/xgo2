#!/bin/bash
#
# Contains the Go tool-chain bootstrapper, that retrieves all the configured
# distribution packages, extracts the binaries and deletes anything not needed.
#
# Usage: bootstrap.sh
#
# Needed environment variables:
#   FETCH - Remote file fetcher and checksum verifier (injected by image)
#   DIST_LINUX_64,  DIST_LINUX_64_SHA  - 64 bit Linux Go binaries and checksum
#   DIST_LINUX_32,  DIST_LINUX_32_SHA  - 32 bit Linux Go binaries and checksum
#   DIST_LINUX_ARM, DIST_LINUX_ARM_SHA - ARM v5 Linux Go binaries and checksum
#   DIST_OSX_64,    DIST_OSX_64_SHA    - 64 bit Mac OSX Go binaries and checksum
#   DIST_OSX_32,    DIST_OSX_32_SHA    - 32 bit Mac OSX Go binaries and checksum
#   DIST_WIN_64,    DIST_WIN_64_SHA    - 64 bit Windows Go binaries and checksum
#   DIST_WIN_32,    DIST_WIN_32_SHA    - 32 bit Windows Go binaries and checksum
set -e

# Download and verify all the binary packages
$FETCH $DIST_LINUX_64  $DIST_LINUX_64_SHA
$FETCH $DIST_LINUX_32  $DIST_LINUX_32_SHA
$FETCH $DIST_LINUX_ARM $DIST_LINUX_ARM_SHA
$FETCH $DIST_OSX_64    $DIST_OSX_64_SHA
$FETCH $DIST_OSX_32    $DIST_OSX_32_SHA
$FETCH $DIST_WIN_64    $DIST_WIN_64_SHA
$FETCH $DIST_WIN_32    $DIST_WIN_32_SHA

# Extract the 64 bit Linux package as the primary Go SDK
tar -C /usr/local -xzf `basename $DIST_LINUX_64`
rm -f `basename $DIST_LINUX_64`

export GOROOT=/usr/local/go
export GOROOT_BOOTSTRAP=$GOROOT

# Extract all other packages as secondary ones, keeping only the binaries
if [ "$DIST_LINUX_ARM" != "" ]; then
  tar -C /usr/local --wildcards -xzf `basename $DIST_LINUX_ARM` go/pkg/linux_arm*
  GOOS=linux GOARCH=arm /usr/local/go/pkg/tool/linux_amd64/dist bootstrap
  rm -f `basename $DIST_LINUX_ARM`
fi

if [ "$DIST_OSX_64" != "" ]; then
  tar -C /usr/local --wildcards -xzf `basename $DIST_OSX_64` go/pkg/darwin_amd64*
  GOOS=darwin GOARCH=amd64 /usr/local/go/pkg/tool/linux_amd64/dist bootstrap
  rm -f `basename $DIST_OSX_64`
fi

if [ "$DIST_WIN_64" != "" ]; then
  unzip -d /usr/local -q `basename $DIST_WIN_64` go/pkg/windows_amd64*
  GOOS=windows GOARCH=amd64 /usr/local/go/pkg/tool/linux_amd64/dist bootstrap
  rm -f `basename $DIST_WIN_64`
fi
if [ "$DIST_WIN_32" != "" ]; then
  unzip -d /usr/local -q `basename $DIST_WIN_32` go/pkg/windows_386*
  GOOS=windows GOARCH=386 /usr/local/go/pkg/tool/linux_amd64/dist bootstrap
  rm -f `basename $DIST_WIN_32`
fi

# Install xgo within the container to enable internal cross compilation
echo "Installing xgo-in-xgo..."
go get -u github.com/karalabe/xgo
