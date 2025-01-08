### VDI-VM Live Migrations
case $1 in
 VDI-SRV2)
   ssh 192.168.1.1 "virsh migrate --live VDI-VM qemu+ssh://192.168.1.2/system"
   ;;
 VDI-SRV1)
   virsh migrate --live VDI-VM qemu+ssh://192.168.1.1/system
   ;;
esac
