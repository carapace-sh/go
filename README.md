# Golang

Fork of [golang/go](https://github.com/golang/go) at `release-branch.go1.27`, maintained by [carapace-sh](https://github.com/carapace-sh). Based on [DomBlack/ForkingGoRuntime](https://github.com/DomBlack/ForkingGoRuntime).

Distributes a patched Go runtime via `ghcr.io/carapace-sh/go` Docker images.

## Patches

| # | Description |
|---|-------------|
| `1-plugin-patch` | Lenient plugin loading — comments out the `pkghashes` check so plugins built with different package versions can still load ([golang/go#31354](https://github.com/golang/go/issues/31354#issuecomment-848824708)) |
| `termux/1-10` | Android/Termux compatibility patches derived from the [official Termux Go package](https://github.com/termux/termux-packages/tree/master/packages/golang) |

See [AGENTS.md](AGENTS.md) for the full patch list and build commands.
