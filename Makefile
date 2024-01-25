include buildScripts/cfg.mk

all: $(BUILD_DIR)/$(OUT_FILENAME)

$(BUILD_DIR)/$(OUT_FILENAME): bootloader# kernel
	@dd if=/dev/zero of=$@ bs=512 count=2880 > /dev/null
	@mkfs.fat -F 12 -n "KEKOS" $@ > /dev/null
	@dd if=$(BUILD_DIR)/stage1.bin of=$@ conv=notrunc > /dev/null
	@mcopy -i $@ $(BUILD_DIR)/stage2.bin "::stage2.bin"
	@echo "--> Created " $@

bootloader: stage1 stage2
#@mcopy -i $@ $(BUILD_DIR)/kernel.bin "::kernel.bin"
stage1: $(BUILD_DIR)/stage1.bin

$(BUILD_DIR)/stage1.bin: $(wildcard $(SRC_DIR)/bootloader/stage1/*.asm)
	@$(MAKE) -C $(SRC_DIR)/bootloader/stage1 BUILD_DIR=$(abspath $(BUILD_DIR)) > /dev/null

stage2: $(BUILD_DIR)/stage2.bin

$(BUILD_DIR)/stage2.bin: $(wildcard $(SRC_DIR)/bootloader/stage2/*)
	@$(MAKE) -C $(SRC_DIR)/bootloader/stage2 BUILD_DIR=$(abspath $(BUILD_DIR)) TARGET_CC=$(TARGET_CC)
kernel: $(BUILD_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin:
	@$(MAKE) -C $(SRC_DIR)/kernel BUILD_DIR=$(abspath $(BUILD_DIR))

run:
	@qemu-system-i386 -drive file=$(BUILD_DIR)/$(OUT_FILENAME),format=raw

debug:
	bochs -f bochs_cfg

clean:
	rm -rf build/*
