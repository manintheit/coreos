## CoreOS Ignition Experiment

It is my first experiment with CoreOS before installing Red Hat Openshift Container Platform with ```UPI``` method. In this experiment, FCOS is configured with static IP address.

Download necessary files and images to the HTTP server. HTTP server in my lab listening at port ```80``` at IP address ```192.168.122.84```.


```console
[root@rhel84 html]# pwd
/var/www/html
[root@rhel84 html]# ls -ltr
total 1425580
-rw-r--r--. 1 root root  12189584 Aug  6 13:06 fcos-kernel
-rw-r--r--. 1 root root  86420180 Aug  6 13:06 fcos-initramfs
-rw-r--r--. 1 root root 677981184 Aug  6 13:43 fcos-rootfs
-rw-r--r--. 1 root root 683184864 Aug  7 14:44 fcos-raw.xz
-rw-r--r--. 1 root root       566 Aug  7 14:44 fcos-raw.xz.sig
-rw-r--r--. 1 root root      1538 Aug  7 15:40 sample.ign
```


```bash
#!/bin/bash

ip_arg="ip=192.168.122.31::192.168.122.1:255.255.255.0:fcos1:enp1s0:none:192.168.122.1"
fcos_kernel_args="${ip_arg} rd.neednet=1 console=tty0 console=ttyS0 coreos.inst.install_dev=/dev/vda coreos.inst.image_url=http://192.168.122.84/fcos-raw.xz coreos.inst.insecure=true coreos.live.rootfs_url=http://192.168.122.84/fcos-rootfs coreos.inst.ignition_url=http://192.168.122.84/sample.ign"

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

```


```console
192.168.122.31 - - [07/Aug/2022:15:40:45 -0400] "HEAD /fcos-rootfs HTTP/1.1" 200 - "-" "curl/7.82.0"
192.168.122.31 - - [07/Aug/2022:15:40:45 -0400] "GET /fcos-rootfs HTTP/1.1" 200 677981184 "-" "curl/7.82.0"
192.168.122.31 - - [07/Aug/2022:15:40:52 -0400] "GET /sample.ign HTTP/1.1" 200 1538 "-" "-"
192.168.122.31 - - [07/Aug/2022:15:40:52 -0400] "GET /fcos-raw.xz.sig HTTP/1.1" 200 566 "-" "-"
192.168.122.31 - - [07/Aug/2022:15:40:52 -0400] "GET /fcos-raw.xz HTTP/1.1" 200 683184864 "-" "-"
```

You can use https://fcct.techoverflow.net/ in order to convert CoreOS config to Transpiled Ignition Config


## Fedore CoreOS Config (sample.yaml)

```yaml
variant: fcos
version: 1.0.0
passwd:
  users:
    - name: tesla
      ssh_authorized_keys:
        - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDcI5XrViPuFfxBNzEUgPMF7CVyS4t/ysX+sphrTxYg0TBLQQ+CSsWZjWHuGahIPEc/aUgHHKYKafmbvG2/edg1bNcsNoTGYwrz3JI8rUgx4zkIYYap0YhcVTV8im/h/ejop7GEwEubupP1lmarrwkg5T1Xgqkq1ifEDEkHmh+aT3XqKsHOIyR39q1zpSuEOAmXUN9gFvgoqfTjL0ZQWoHCf2/H85x0srFKZHWxJPFqUbqYGXPzysUCUURCEOZae8iiEKRRWooscqROxRaoAdNVkIYZeS/G0z0JUIGGDGkU6OKvOii7AUenJYlcc+2WkahOHSx4+LrFSNhFGjOU6D9tQ/KId2vndcvQfj7prxhX3ZKs5eF84oDy/WZlQ/F4VXjyx9rdsePUaqlH0xvVsgorAz3Rf3Zgw+zowHyc8RB235/ciLNVbFFy+5Oydrqa+p+P4W9sd5ABWr+2Rs0EB0+iL50z5MTF36gTLUrYvLN3y8TF9Bwt6HCfgLvolXxDOFlZvj857o+iJ/P6AXeodZh3Ic+EPCevMAOF/6yFz6uTcBSyIFPAE8WVs6YPmoCMAvkkRbzJ3xI2dTTVUSEP5TYKisFwRh4SmpKCfkGFElThru6f2vcUVFlh0Z/HaF3ssjdvLW0EKDs+cNN/FFylzOHGPztqS/oaOJ7EbH1q/dkN+Q=="
      groups: [ sudo ]
storage:
  files:
    - path: /etc/hostname
      overwrite: true
      contents:
        inline: fcos1
    - path: /etc/NetworkManager/system-connections/enp1s0.nmconnection
      mode: 0600
      contents:
        inline: |
          [connection]
          id=enp1s0
          type=ethernet
          interface-name=enp1s0
          [ipv4]
          address1=192.168.122.31/24,192.168.122.1
          dns=192.168.122.1;
          dns-search=homelab.io
          may-fail=false
          method=manual
```

## Transpiled Ignition Config (sample.ign)

```json
{
  "ignition": {
    "version": "3.0.0"
  },
  "passwd": {
    "users": [
      {
        "groups": [
          "sudo"
        ],
        "name": "tesla",
        "sshAuthorizedKeys": [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDcI5XrViPuFfxBNzEUgPMF7CVyS4t/ysX+sphrTxYg0TBLQQ+CSsWZjWHuGahIPEc/aUgHHKYKafmbvG2/edg1bNcsNoTGYwrz3JI8rUgx4zkIYYap0YhcVTV8im/h/ejop7GEwEubupP1lmarrwkg5T1Xgqkq1ifEDEkHmh+aT3XqKsHOIyR39q1zpSuEOAmXUN9gFvgoqfTjL0ZQWoHCf2/H85x0srFKZHWxJPFqUbqYGXPzysUCUURCEOZae8iiEKRRWooscqROxRaoAdNVkIYZeS/G0z0JUIGGDGkU6OKvOii7AUenJYlcc+2WkahOHSx4+LrFSNhFGjOU6D9tQ/KId2vndcvQfj7prxhX3ZKs5eF84oDy/WZlQ/F4VXjyx9rdsePUaqlH0xvVsgorAz3Rf3Zgw+zowHyc8RB235/ciLNVbFFy+5Oydrqa+p+P4W9sd5ABWr+2Rs0EB0+iL50z5MTF36gTLUrYvLN3y8TF9Bwt6HCfgLvolXxDOFlZvj857o+iJ/P6AXeodZh3Ic+EPCevMAOF/6yFz6uTcBSyIFPAE8WVs6YPmoCMAvkkRbzJ3xI2dTTVUSEP5TYKisFwRh4SmpKCfkGFElThru6f2vcUVFlh0Z/HaF3ssjdvLW0EKDs+cNN/FFylzOHGPztqS/oaOJ7EbH1q/dkN+Q=="
        ]
      }
    ]
  },
  "storage": {
    "files": [
      {
        "contents": {
          "source": "data:,fcos1"
        },
        "overwrite": true,
        "path": "/etc/hostname"
      },
      {
        "contents": {
          "source": "data:,%5Bconnection%5D%0Aid%3Denp1s0%0Atype%3Dethernet%0Ainterface-name%3Denp1s0%0A%5Bipv4%5D%0Aaddress1%3D192.168.122.31%2F24%2C192.168.122.1%0Adns%3D192.168.122.1%3B%0Adns-search%3Dhomelab.io%0Amay-fail%3Dfalse%0Amethod%3Dmanual"
        },
        "mode": 384,
        "path": "/etc/NetworkManager/system-connections/enp1s0.nmconnection"
      }
    ]
  }
}
```


## Experiment


```console
tonyukuk@msilap:/data/projects/coreos$ ssh -ltesla 192.168.122.31
The authenticity of host '192.168.122.31 (192.168.122.31)' can't be established.
ECDSA key fingerprint is SHA256:RtxuNRA6EamXjOr+UMlRJ4gkC1mHSRHCn4rdjnamRho.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.122.31' (ECDSA) to the list of known hosts.
Fedora CoreOS 36.20220716.3.1
Tracker: https://github.com/coreos/fedora-coreos-tracker
Discuss: https://discussion.fedoraproject.org/tag/coreos

[tesla@fcos1 ~]$ 
```


```bash
[tesla@fcos1 ~]$ ip route s
default via 192.168.122.1 dev enp1s0 proto static metric 100 
192.168.122.0/24 dev enp1s0 proto kernel scope link src 192.168.122.31 metric 100 
```