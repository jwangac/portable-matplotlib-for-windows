# Variables
PYTHON_VERSION := 3.7.9
PYTHON_VERSION_SHORT := 37
PYTHON_ZIP := python-$(PYTHON_VERSION)-embed-amd64.zip
PYTHON_URL := https://www.python.org/ftp/python/$(PYTHON_VERSION)/$(PYTHON_ZIP)
WHEELS_DIR := wheels
BUILD_DIR := build
PYTHON_DIR := python
VC_RUNTIME_DIR := vcruntime

# Default target
all: clean compress

# Clean existing build directory
clean:
	@echo "Cleaning build directory..."
	@rm -rf $(BUILD_DIR)/

# Download Python embeddable zip
python:
	@rm -rf $(PYTHON_DIR) && mkdir -p $(PYTHON_DIR)
	@echo "Downloading Python embeddable zip..."
	@cd $(PYTHON_DIR) && wget "$(PYTHON_URL)"

# Download wheels
wheels:
	@mkdir -p $(WHEELS_DIR)
	@echo "Downloading wheels..."
	@cd $(WHEELS_DIR) && pip download matplotlib --only-binary=:all: --python-version $(PYTHON_VERSION_SHORT) --platform win_amd64

# Extract Python and wheels
extract: python wheels
	@mkdir -p $(BUILD_DIR)/packages

	@echo "Extracting Python..."
	@unzip -q -o -d $(BUILD_DIR)/ $(PYTHON_DIR)/$(PYTHON_ZIP)

	@echo "Extracting wheels..."
	@for wheel in $(wildcard $(WHEELS_DIR)/*.whl); do \
		echo "Extracting $$wheel..."; \
		unzip -q -o -d $(BUILD_DIR)/packages/ $$wheel; \
	done
	@rm -rf $(BUILD_DIR)/packages/*.dist-info
	@echo "packages" >> $(BUILD_DIR)/python$(PYTHON_VERSION_SHORT)._pth

# Copy MSVC runtime
copy-vc-runtime:
	@echo "Copying MSVC runtime..."
	@cp $(VC_RUNTIME_DIR)/* $(BUILD_DIR)/

# Compress the build directory
compress: extract copy-vc-runtime
	@echo "Compressing to portable-matplotlib-for-windows.zip..."
	@cd $(BUILD_DIR) && zip -r ../portable-matplotlib-for-windows.zip * >/dev/null

.PHONY: all clean extract copy-vc-runtime compress
