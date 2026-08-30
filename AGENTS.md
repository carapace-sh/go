# AGENTS.md

## What is this?

A fork of [golang/go](https://github.com/golang/go) at `release-branch.go1.27`, maintained by [carapace-sh](https://github.com/carapace-sh). The purpose is to distribute a patched Go runtime via `ghcr.io/carapace-sh/go` Docker images. Based on the approach from [DomBlack/ForkingGoRuntime](https://github.com/DomBlack/ForkingGoRuntime).

## Project structure

```
go/
  go-src/              # Git submodule -> https://github.com/golang/go (release-branch.go1.27)
  1-plugin-patch/      # Lenient plugin loading patch
    patch.diff
  termux/              # Termux (Android) patches
    1-hardcoded-etc-resolv-conf/patch.diff
    2-fix-GOPROXY-and-GOSUMDB-default-is-empty/patch.diff
    3-src-crypto-x509-root_linux.go/patch.diff
    4-src-os-file_unix.go.patch/patch.diff
    5-src-runtime-cgo-cgo.go.patch/patch.diff
    6-src-runtime-cgo-gcc_fatalf.c.patch/patch.diff
    7-src-cmd-go-internal-lockedfile-internal-filelock-filelock_fcntl.go.patch/patch.diff
    8-src-cmd-go-internal-lockedfile-internal-filelock-filelock_unix.go.patch/patch.diff
    9-remove-pidfd/patch.diff
    10-remove-futex_time64/patch.diff
  go-android.sh        # CC wrapper for Android NDK cross-compilation
  go-termux.sh         # Same but for Termux-patched Go binary
  Dockerfile           # Multi-stage build for both regular and Termux Go
  Makefile             # build, build-termux, clean, patch targets
```

## Essential commands

### Initialize submodule (first time)

```bash
git submodule update --init
```

### Build

```bash
make build            # Applies plugin patch + builds Go
make build-termux     # Applies plugin + all Termux patches + builds Go
```

### Clean

```bash
make clean            # Resets go-src/ to pristine state (git restore + clean)
```

### Create a new patch

```bash
make patch            # Runs `git diff` in go-src/ -> top-level patch.diff
```

### Docker

```bash
docker build . --tag ghcr.io/carapace-sh/go:latest
```

## Patches

| Patch | What it does |
|-------|-------------|
| `1-plugin-patch` | **Core patch.** Comments out the `pkghashes` check in `src/runtime/plugin.go` so Go plugins built with different versions of shared packages can still be loaded. This is the reason this fork exists. |
| `termux/1` | Changes DNS config paths from `/etc/` to `/data/data/com.termux/files/usr/etc/` for Android/Termux; adds `//go:build !android` / `android` build tags to net source files |
| `termux/2` | Sets default `GOPROXY` and `GOSUMDB` for Termux (normally empty on Android) |
| `termux/3` | Adds Termux CA cert path to `crypto/x509/root_linux.go` |
| `termux/4` | Changes `os.TempDir()` on Android from `/data/local/tmp` to `/data/data/com.termux/files/usr/tmp` |
| `termux/5` | Removes `-llog` LDFLAG for Android cgo (comments out the line) |
| `termux/6` | Adds `!defined(__TERMUX__)` guard to `gcc_fatalf.c` so Termux skips Android logcat path |
| `termux/7` | Adds `android` to build tag for `filelock_fcntl.go` (use fcntl-based file locking instead of flock on Android) |
| `termux/8` | Excludes Android from `filelock_unix.go` build tag — paired with termux/7 |
| `termux/9` | Disables pidfd on Android (seccomp sends SIGSYS on `pidfd_open`);
            adds `//go:build linux && !android` to pidfd files, creates `export_pidfd_test.go` |
| `termux/10` | Skips `futex_time64`/`timer_settime64` on Android (32-bit); adds `GOOS != "android"` guards |

## Source of truth for Termux patches

The termux patches (1-10) are derived from the [official Termux Go package](https://github.com/termux/termux-packages/tree/master/packages/golang). When updating Go, always compare against that repo to catch missing patches:

```
https://github.com/termux/termux-packages/tree/master/packages/golang
```

Patches from the official repo that are **not applicable** to this fork:
- `patch-script/remove-pidfd.sh` / `remove-futex_time64.sh` — these are wrapper scripts that substitute `@TERMUX_PREFIX@` at build time. In this repo the paths are hard-coded to `/data/data/com.termux/files/usr`.
- `patch-script/fix-hardcoded-etc-resolv-conf.sh` — not needed here; the Makefile handles the `cp -T` step manually.
- `golang-doc.subpackage.sh` — not relevant; this repo distributes binary images, not Termux `.deb` packages.

## Gotchas

- **`go-src/` is a git submodule.** It is empty after `git clone` unless you run `git submodule update --init`. Most commands will fail without it.
- **`make build` always runs `make clean` first.** This resets `go-src/` to pristine state before applying the plugin patch. Any manual changes in `go-src/` are discarded.
- **`make build-termux`** copies files (`cp -T`) before applying patches — `conf.go` -> `conf_android.go`, `dnsclient_unix.go` -> `dnsclient_android.go`. These copies are needed because the patches modify the `_android` variants.
- **`make patch` writes to the top-level `patch.diff`** (not inside a directory). This file is `.gitignore`'d.
- **CI only builds Docker images.** The GitHub Actions workflow (`docker.yml`) pushes to `ghcr.io/carapace-sh/go` on master push and tag creation. Tags are used as Docker image tags.
- **Dockerfile has two stages** — `build` (regular Go) and `build-termux` (Termux Go). The final stage copies both and also installs Android NDK (`r27b`) and SDK for cross-compilation.
- **`go-android.sh` and `go-termux.sh`** are convenience wrappers that set the CC environment variable for the NDK cross-compiler based on `$GOARCH`. They live in the Docker image at `/usr/local/bin/go-android` and `/usr/local/bin/go-termux`.
- **No tests, no linting, no CI beyond Docker build.** This is a patch-packaging repo, not a library. There are no Go modules, no `go.mod`, no test runners.
- **The `plugin` patch is the critical one.** The `-llog` and `logcat` patches are conveniences for Termux. The entire reason this fork exists is the lenient plugin loading — without it, the other patches are irrelevant.