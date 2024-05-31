#!/bin/bash

bindir=/opt/android-sdk/ndk/${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/bin
[ "$GOARCH" = "amd64" ] && export CC="$bindir/x86_64-linux-android34-clang"
[ "$GOARCH" = "arm64" ] && export CC="$bindir/aarch64-linux-android34-clang"
[ "$GOARCH" = "arm" ] && export CC="$bindir/armv7a-linux-androideabi34-clang"

exec /usr/local/go-termux/bin/go "$@"
