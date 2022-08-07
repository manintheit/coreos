#!/bin/bash

#fcos_kernel="http://192.168.122.84/fcos-kernel"
#fcos_initrd="http://192.168.122.84/fcos-initramfs"
ip_arg="ip=192.168.122.31::192.168.122.1:255.255.255.0:fcos1:enp1s0:none:192.168.122.1"
fcos_kernel_args="${ip_arg} rd.neednet=1 console=tty0 console=ttyS0 coreos.inst.install_dev=/dev/vda coreos.inst.image_url=http://192.168.122.84/fcos-raw.xz coreos.inst.insecure=true coreos.live.rootfs_url=http://192.168.122.84/fcos-rootfs coreos.inst.ignition_url=http://192.168.122.84/sample.ign"

# ip=dhcp removed

#virt-install --connect qemu:///system --name fcos --ram 2048 --vcpus 2 --disk pool=KVM,size=10 --os-variant fedora-unknown \
#               --network network=default --graphics=none \
#               --install kernel="${fcos_kernel}",initrd="${fcos_initrd}",kernel_args_overwrite=yes,kernel_args="${fcos_kernel_args}"


virt-install \
	     --connect qemu:///system \
	     --name fcos \
	     --ram 2048 \
	     --vcpus 2 \
	     --disk pool=KVM,size=10 \
	     --os-variant fedora-unknown \
             --network network=default \
	     --graphics=none \
             --location "/data/KVM/fedora-coreos-36.20220716.3.1-live.x86_64.iso,initrd=/images/pxeboot/initrd.img,kernel=/images/pxeboot/vmlinuz" \
	     --install kernel_args_overwrite=yes,kernel_args="${fcos_kernel_args}"
