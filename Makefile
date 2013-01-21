# TODO: Check for the pkg squashfs-tools
# TODO: Check for the pkg cdrkit

BUILD_DIR=./build
CUSTOM_ISO_DIR=$(BUILD_DIR)/custom_iso
ISO_MOUNT_DIR=$(BUILD_DIR)/mnt/archiso

ROOT_IMG32=$(BUILD_DIR)/root-image-i686
ROOT_IMG64=$(BUILD_DIR)/root-image-x86_64

ROOTFS_32=$(BUILD_DIR)/mnt/rootfs_32
ROOTFS_64=$(BUILD_DIR)/mnt/rootfs_64

build-all: _base build-32 build-64

build-32: _base
	@echo "#############################"
	@echo "Starting i686 customization..."
	@mkdir -p $(ROOTFS_32)
	@mkdir $(ROOT_IMG32)

	@cp $(CUSTOM_ISO_DIR)/arch/i686/root-image.fs.sfs $(ROOT_IMG32)
	@echo -n "Unsquasing root image..."
	@cd $(ROOT_IMG32) && unsquashfs root-image.fs.sfs > /dev/null
	@echo " OK"

	@echo "Mounting Root Image..."
	@sudo mount $(ROOT_IMG32)/squashfs-root/root-image.fs $(ROOTFS_32)
	@echo -n "Copying files..."
	@sudo cp anarchy.sh $(ROOTFS_32)/root/
	@echo " OK"

	@echo "Umounting image..."
	@sudo umount $(ROOTFS_32)

	@echo -n "Squashing new image...."
	@cd $(ROOT_IMG32) && mksquashfs squashfs-root root-image.fs.sfs
	@echo " OK"

	@echo "Copying the new root-image"
	@cp $(ROOT_IMG32)/root-image.fs.sfs $(CUSTOM_ISO_DIR)/arch/i686/root-image.fs.sfs

	@echo "#############################"
	@echo " *** Finished successfully the i686 customizations!"
	@echo ""


build-64: _base
	@echo "#############################"
	@echo "Starting i686 customization..."
	@mkdir -p $(ROOTFS_64)
	@mkdir $(ROOT_IMG64)

	@cp $(CUSTOM_ISO_DIR)/arch/x86_64/root-image.fs.sfs $(ROOT_IMG64)
	@echo -n "Unsquasing root image..."
	@cd $(ROOT_IMG64) && unsquashfs root-image.fs.sfs > /dev/null
	@echo " OK"

	@echo "Mounting Root Image..."
	@sudo mount $(ROOT_IMG64)/squashfs-root/root-image.fs $(ROOTFS_64)
	@echo -n "Copying files..."
	@sudo cp anarchy.sh $(ROOTFS_64)/root/
	@echo " OK"

	@echo "Umounting image..."
	@sudo umount $(ROOTFS_64)

	@echo -n "Squashing new image...."
	@cd $(ROOT_IMG64) && mksquashfs squashfs-root root-image.fs.sfs
	@echo " OK"

	@echo "Copying the new root-image"
	@cp $(ROOT_IMG64)/root-image.fs.sfs $(CUSTOM_ISO_DIR)/arch/x86_64/root-image.fs.sfs

	@echo "#############################"
	@echo " *** Finished successfully the x86_64 customizations!"
	@echo ""


iso:
	@echo "#############################"
	@echo "Building new ISO..."

	@genisoimage -l -r -J -V "ANARCHY_`date +%Y%m%d`" -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -c isolinux/boot.cat -o ./anarchy-archlinux-`date +%Y.%m.%d`-dual.iso $(CUSTOM_ISO_DIR)

	@echo "#############################"
	@echo " *** Finished the new ISO!"
	@echo ""


_base:
	@echo -n "Building base dirs..."
	@mkdir -p $(ISO_MOUNT_DIR)
	@mkdir -p $(CUSTOM_ISO_DIR)
	@echo " OK"

	@echo "Mounting ISO"
	sudo mount -t iso9660 -o loop ./archlinux-2013.01.04-dual.iso $(ISO_MOUNT_DIR)
	@echo -n "Coping files..."
	@cp -a $(ISO_MOUNT_DIR)/* $(CUSTOM_ISO_DIR)
	@echo " OK"
	@echo ""


clean:
	@echo "Cleaning files..."
	@-sudo umount $(ISO_MOUNT_DIR)
	@-sudo umount $(ROOTFS_32)
	@-sudo umount $(ROOTFS_64)
	@rm -rf $(BUILD_DIR)/*
	@echo "All done!"
	@echo ""