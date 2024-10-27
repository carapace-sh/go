#!/bin/bash

bindir="/opt/android-sdk/ndk/${NDK_VERSION}/toolchains/llvm/prebuilt/linux-x86_64/bin"
[ "$GOARCH" = "amd64" ] && export CC="$bindir/x86_64-linux-android${ANDROID_VERSION}-clang"
[ "$GOARCH" = "arm64" ] && export CC="$bindir/aarch64-linux-android${ANDROID_VERSION}-clang"
[ "$GOARCH" = "arm" ] && export CC="$bindir/armv7a-linux-androideabi${ANDROID_VERSION}-clang"
[ "$GOARCH" = "386" ] && export CC="$bindir/i686-linux-android${ANDROID_VERSION}-clang"

exec /usr/local/go/bin/go "$@"
