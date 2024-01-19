stage1: $(BUILD_DIR)/stage1.bin

$(BUILD_DIR)/stage1.bin: main.asm
	@$(ASM) $< -f bin -o $@
	@echo "--> assembled stage1.bin"
