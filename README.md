# [ The Linux🐧KVM Servers Configuration ]

VDI-KVM Environments -> [ *Server1(192.168.1.1/32), Server2(192.168.1.2/32), Client-PC* ]

## [ *Server(1,2) - Step.1* ]

- *1) Network interface settings.*

```vim
vim /etc/netplan/config.yaml
```
>```yaml
>network:
>  version: 2
>  renderer: networkd
>  ethernets:
>    ens33:
>      dhcp4: false
>  bridges:
>    br0:
>      dhcp4: false
>      addresses:
>        - 192.168.1.1/24
>      gateway4: 192.168.1.254
>      interfaces:
>        - ens33
>      parameters:
>        stp: false
>        forward-delay: 0
>        max-age: 0
>```
```bash
netplan apply
```

- *2) Configure KVM environments.*

```vim
apt install -y qemu-kvm libvirt-daemon libvirt-daemon-system libvirt-clients virtinst virt-manager
virsh net-start default -disable
virsh net-autostart default -disable
modprobe vhost_net
```
```vim
vim /etc/modules
```
>```vim
>vhost_net
>```

## [ *Server1 - Step.2* ]
```vim
mkdir /VM/
chown libvirt-qemu /VM/
mkdir /CDROM/
chmod +x /CDROM/
```

- 💿 Ubuntu Live Server ISO 파일 /CDROM/에 마운트 시킴 (VMware Shared Folder 사용하여 iso파일 위치함)
  - [ #mount /mnt/Ubuntu-24.04.1-Live-Server-AMD64.iso /CDROM/ ]

```vim
virt-install --name VDI-VM --os-type linux --os-variant ubuntu24 --vcpu 2 --ram 2048 --diskpath=/VM/VDI-VM.qcow2,size=10 --graphics vnc,listen=0.0.0.0 --noautoconsole --hvm --cdrom /CDROM/Ubuntu-24.04.1-Live-Server-AMD64.iso --boot cdrom,hd
```

## [ *Client-PC* ]
- 🖥 Open the remote desktop viewer & Connect to vnc 192.168.1.1 & Install ubuntu server (설치 완료되면 VM 종료)

## [ *Server1 - VM power-on* ]
```vim
umount /CDROM/
virsh start VDI-VM
```

## [ *Client-PC* ]
- 🖥 VDI-VM Connection. (VDI-VM Server CLI)
```vim
apt update -y
apt install -y vim net-tools dnsutils tcpdump curl lynx wget ssh psmisc
echo -e "set number\nset ignorecase" >> /etc/vim/vimrc
echo -e "PermitRootLogin yes" >> /etc/ssh/sshd_config
systemctl restart sshd
systemctl stop systemd-timesyncd
systemctl disable systemd-timesyncd
hostnamectl set-hostname VDI-VM
echo -e "127.0.1.1  VDI-VM.vdi.local  VDI-VM" >> /etc/hosts
poweroff
```

## [ *Server(1,2) - Set up hosts* ]
```vim
vim /etc/hosts
```
>```vim
>192.168.1.1    VDI-SRV1.vdi.local
>192.168.1.2    VDI-SRV2.vdi.local
>```

## [ *Server2 - SSH Link* ]
```vim
ssh-keygen     👉 # All enter
ssh-copy-id root@192.168.1.1
ssh root@192.168.1.1
```

## [ *Server1 - Step. 2* ]
```vim
ssh-keygen     👉 # All enter
ssh-copy-id root@192.168.1.2
ssh root@192.168.1.2
```
```vim
virsh edit VDI-VM
```
>```vim
><disk type='file' device='disk'>
>  <driver name='qemu' type='qcow2' cache='none'/>
></disk>
>```
```vim
virsh start VDI-VM
```
```vim
vim /usr/sbin/vdi-move.sh
```
>```vim
>### VDI-VM Live Migrations
>case $1 in
>  VDI-SRV1)
>    ssh 192.168.1.2 "virsh migrate --live VDI-VM qemu+ssh://192.168.1.1/system"
>    ;;
>  VDI-SRV2)
>    virsh migrate --live VDI-VM qemu+ssh://192.168.1.2/system
>    ;;
>esac
>```
```vim
chmod 700 /usr/sbin/vdi-move.sh
```
```vim
vim /root/.bashrc
```
>```vim
>alias vdi-move='/usr/sbin/vdi-move.sh'
>```
```vim
source /root/.bashrc
```

## [ *Server2 - Step. 2* ]
```vim
scp root@192.168.1.2:/usr/sbin/vdi-move.sh /usr/sbin/
chmod 700 /usr/sbin/vdi-move.sh
```
```vim
vim /usr/sbin/vdi-move.sh
```
>```vim
>### VDI-VM Live Migrations
>case $1 in
>  VDI-SRV2)
>    ssh 192.168.1.1 "virsh migrate --live VDI-VM qemu+ssh://192.168.1.2/system"
>    ;;
>  VDI-SRV1)
>    virsh migrate --live VDI-VM qemu+ssh://192.168.1.1/system
>    ;;
>esac
>```
```vim
vim /root/.bashrc
```
>```vim
>alias vdi-move='/usr/sbin/vdi-move.sh'
>```
```vim
source /root/.bashrc
```

## [ *Server(1,2) - VM live migration* ]
```vim
vdi-move vdi-srv1      👉 # 이 명령어 입력시 Server2에 있던 VDI-VM이 Server1으로 실시간 마이그레이션 됨
vdi-move vdi-srv2      👉 # Server1에 있던 VM이 Server2으로 마이그레이션
```
