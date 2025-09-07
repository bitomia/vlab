# Manage a virtual lab with MacOS as host system

ISO_URL=https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2
ISO_FILE=debian-12-generic-amd64.qcow2

.PHONE: run_vmnet run1 run2 setup0 setup1 setup2

run_vmnet:
	sudo socket_vmnet --vmnet-gateway=192.168.105.1 /tmp/vde.ctl

run1:
	socket_vmnet_client /tmp/vde.ctl /usr/local/bin/qemu-system-x86_64 \
	  -drive file=seed1.iso,format=raw,media=cdrom \
	  -drive file=debian1.qcow2,format=qcow2 \
	  -drive file=zfs1.qcow2,if=virtio,format=qcow2 \
	  -m 2G \
	  --nographic -serial mon:stdio -vga none \
	  -machine type=q35,accel=hvf \
	  -device virtio-net-pci,netdev=net0,mac=52:54:00:12:34:56 -netdev socket,id=net0,fd=3

run2:
	socket_vmnet_client /tmp/vde.ctl /usr/local/bin/qemu-system-x86_64 \
	  -drive file=seed2.iso,format=raw,media=cdrom \
	  -drive file=debian2.qcow2,format=qcow2 \
	  -drive file=zfs2.qcow2,if=virtio,format=qcow2 \
	  -m 2G \
	  --nographic -serial mon:stdio -vga none \
	  -machine type=q35,accel=hvf \
	  -device virtio-net-pci,netdev=net0,mac=52:54:00:12:34:57 -netdev socket,id=net0,fd=3

setup0:
	@echo "Checking for $(ISO_FILE)..."
	@if [ ! -f "$(ISO_FILE)" ]; then \
		echo "Downloading $(ISO_FILE)..."; \
		curl -L -o $(ISO_FILE) $(ISO_URL); \
	else \
		echo "$(ISO_FILE) already exists, skipping download."; \
	fi

setup1:
	hdiutil makehybrid -o seed1.iso -hfs -joliet -iso -default-volume-name cidata seed
	cp $(ISO_FILE) debian1.qcow2
	qemu-img resize debian1.qcow2 +20G
	qemu-img create -f qcow2 zfs1.qcow2 20G

setup2:
	hdiutil makehybrid -o seed2.iso -hfs -joliet -iso -default-volume-name cidata seed
	cp $(ISO_FILE) debian2.qcow2
	qemu-img resize debian2.qcow2 +20G
	qemu-img create -f qcow2 zfs2.qcow2 20G

clean:
	rm -f $(ISO_FILE)
	rm -f debian1.qcow2
	rm -f debian2.qcow2
	rm -f seed1.iso
	rm -f seed2.iso
	rm -f zfs1.qcow2
	rm -f zfs2.qcow2
