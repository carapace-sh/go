define apply
	@echo "Patching Runtime with ./$1/patch.diff..."
	@git -C go-src apply ../$1/patch.diff
endef

default:
	@echo "Select make target..."

clean: patch
	@echo "Resetting Go to clean state..."
	@git -C go-src restore .
	@git -C go-src clean -f .

build: clean
	$(call apply,1-plugin-patch)
	@echo "Building Go from source..."
	@cd go-src/src && ./make.bash

build-termux: clean
	$(call apply,1-plugin-patch)

	@cp -T go-src/src/net/conf.go go-src/src/net/conf_android.go
	@cp -T go-src/src/net/dnsclient_unix.go go-src/src/net/dnsclient_android.go
	$(call apply,termux/1-hardcoded-etc-resolv-conf)
	$(call apply,termux/2-fix-GOPROXY-and-GOSUMDB-default-is-empty)
	$(call apply,termux/3-src-crypto-x509-root_linux.go)
	$(call apply,termux/4-src-os-file_unix.go.patch)
	$(call apply,termux/5-src-runtime-cgo-cgo.go.patch)
	$(call apply,termux/6-src-runtime-cgo-gcc_android.c.patch)

	@echo "Building Go from source..."
	@cd go-src/src && ./make.bash

patch:
	@echo "Creating patch..."
	@git -C go-src diff > patch.diff
