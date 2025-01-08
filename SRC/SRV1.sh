### VDI-VM Live Migrations
case $1 in
 VDI-SRV1)
   ssh 192.168.1.2 "virsh migrate --live VDI-VM qemu+ssh://192.168.1.1/system"
   ;;
 VDI-SRV2)
   virsh migrate --live VDI-VM qemu+ssh://192.168.1.2/system
   ;;
esac
