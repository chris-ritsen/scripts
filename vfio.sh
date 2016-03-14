

# "DEVICES="0000:02:00.0 0000:02:00.1"
DEVICES="0000:01:00.0 0000:01:00.1"
vfio-bind $DEVICES

ls /sys/bus/pci/drivers/vfio-pci/
# lspci -vvv -s 0000:02:00.
lspci -vvv -s 0000:01:00.

