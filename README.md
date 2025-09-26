# Virtual lab

Manage a virtual lab.

Dependencies:
* QEMU >= 10.1.0
* socket_vmnet >= 1.2.1


## MacOS 

Installing dependencies:

```shell
brew install qemu
brew install socket_vmnet
```

## Linux (Debian12)

Verify if your system does support hardware virtualization:

```shell
egrep -c '(vmx|svm)' /proc/cpuinfo
```

If the output is 0, your CPU does not support virtualization (or it’s disabled in BIOS/UEFI).
If greater than 0, you’re good to go.

Now install qemu, kvm and other support tools:

```shell
sudo apt update
sudo apt install curl genisoimage qemu-system-x86 -y
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients virt-manager bridge-utils -y
```

Now configure the bridge network. Edit `/etc/network/interfaces`, by default you have an iface configure to use dhcp, you have to update it to use manual and add the bridge interface later with "bridge_ports" pointing to the previous interface. For example:

```
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

allow-hotplug ens33
iface ens33 inet manual

# Bridge interface: gets IP from DHCP and bridge to the main iface
auto br0
iface br0 inet dhcp
    bridge_ports ens33
    bridge_stp off
    bridge_fd 0
    bridge_maxwait 0
```

Now restart the networking service:

```shell
sudo systemctl restart networking
```

Now configure qemu bridge running as root:

```shell
mkdir -p /etc/qemu
cat > /etc/qemu/bridge.conf << EOF
allow br0
EOF
```
