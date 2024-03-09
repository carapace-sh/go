define apply
	@echo "Patching Runtime with ./$1/patch.diff..."
	@git apply ./$1/patch.diff
endef

default:
	@echo "Select make target..."

clean: patch
	@echo "Resetting Go to clean state..."
	@git restore go-src

build: clean
	$(call apply,1-plugin-patch)
	@echo "Building Go from source..."
	@cd go-src/src && ./make.bash

patch:
	@echo "Creating patch..."
	@git diff go-src > patch.diff
