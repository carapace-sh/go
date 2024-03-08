define run
	@echo "Patching Runtime with ./$1/patch.diff..."
	@git apply ./$1/patch.diff
	@echo "Running $1 from source...\n"
	@cd $1 && ../go-src/bin/go run ./cmd
endef

default:
	@echo "Select make target..."

clean: patch
	@echo "Resetting Go to clean state..."
	@git restore go-src

build-go: clean
	@echo "Building Go from source..."
	@cd go-src/src && ./make.bash

patch:
	@echo "Creating patch..."
	@git diff go-src > patch.diff
