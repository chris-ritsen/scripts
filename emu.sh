#!/usr/bin/zsh

function () {

# Environment {{{

# Qemu {{{

export QEMU_AUDIO_DRV='pa'
export QEMU_PA_SAMPLES='128'

# }}}

# SDL {{{

export SDL_VIDEO_X11_DGAMOUSE='0'

# -alt-grab
# -no-frame

# }}}

# Spice {{{

# }}}

# }}}

# Qemu options {{{

local virtual_machines_dir='/Media/Fast/'

local boot_order='c'
local cpu_options='host'

local disk_image='windows.qcow2'

local disk_interface='virtio'
local machine_options='type=pc,accel=kvm'
local memory_size='4G'
local network_interface_options='tap,if=tap0,script=no'
local network_options='nic,model=virtio'
local qemu_bin='qemu-system-x86_64'
local socket_options='cpus=1,sockets=1,cores=6,threads=1'
local spice_port='5930'
local vga_options='qxl'

local disk_filename="${virtual_machines_dir}${disk_image}"
local disk_format='qcow2'

local disk_options='file='"${disk_filename}"',if='"${disk_interface},media=disk,format="${disk_format}",cache=none"
local spice_options='port='"${spice_port}"',disable-ticketing'

local spice_device='-device virtio-serial-pci -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 -chardev spicevmc,id=spicechannel0,name=vdagent'

qemu_options=(


# "${spice_device}"
# -device virtio-serial-pci -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 -chardev spicevmc,id=spicechannel0,name=vdagent
# -spice "${spice_options}"
-spice port=50930,disable-ticketing,addr=::1
-device virtio-serial-pci -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 -chardev spicevmc,id=spicechannel0,name=vdagent
-boot order="${boot_order}"
-cpu "${cpu_options}"
-daemonize
-drive "${disk_options}"
-enable-kvm
-m "${memory_size}"
-machine "${machine_options}"
# -show-cursor
-smp "${socket_options}"
-usb
-usbdevice tablet
-vga "${vga_options}"

)

# }}}

# Run {{{

"${qemu_bin}" "${qemu_options[@]}"

# }}}

}

# Dead {{{

# -D /var/log/qemu-out.log \
# -bios /usr/share/qemu/bios.bin -realtime mlock=on -vga none \
# -bios /usr/share/qemu/bios.bin -vga none \
# -cpu host \
# -cpu host,kvm=off -smp 4,sockets=1,cores=4,threads=1 \
# -curses \
# -device hda-duplex,id=sound0-codec0,bus=sound0.0,cad=0 \
# -device ich9-intel-hda,bus=pcie.0,addr=1b.0,id=sound0 \
# -device ide-hd,bus=ide.0,drive=disk \
# -device ioh3420,bus=pcie.0,addr=1c.0,multifunction=on,port=1,chassis=1,id=root.1 \
# -device vfio-pci,host=00:1d.0,bus=pcie.0 \
# -device vfio-pci,host=01:00.0,bus=root.1,addr=00.0,multifunction=on,x-vga=on \
# -device vfio-pci,host=01:00.1,bus=pcie.0 \
# -device vfio-pci,host=01:00.1,bus=root.1,addr=00.1 \
# -device vfio-pci,host=02:00.0,bus=root.1,addr=00.0,multifunction=on,x-vga=on \
# -device vfio-pci,host=02:00.1,bus=root.1,addr=00.1 \
# -device virtio-scsi-pci,id=scsi \
# -device virtio-scsi-pci,id=scsi2 \
# -drive file=$disk_image,id=disk,media=disk,format=raw,cache=none,if=virtio \
# -drive file=/Media/Large/fake.qcow2,if=virtio \
# -drive file=/Media/Large/windows.img,id=disk,format=raw,cache=none \
# -drive file=/Media/unsorted/iso/en-gb_windows_8.1_enterprise_with_update_x64_dvd_4048611.iso,id=isocd -device ide-cd,bus=ide.1,drive=isocd \
# -drive file=/dev/guest/Windaube_7,id=sys,format=raw -device scsi-hd,drive=sys \
# -drive file=/dev/guest/win7,id=data,format=raw -device scsi-hd,drive=data \
# -drive file=/dev/sde,id=disk,format=raw -device ide-hd,bus=ide.0,drive=disk \
# -drive file=/usr/share/virtio/virtio-win.iso,id=isocd -device ide-cd,bus=ide.1,drive=isocd \
# -machine type=pc,accel=kvm \
# -net "${network_options}" -net "${network_interface_options}" \
# -net nic,model=virtio -net bridge,br=virbr0
# -nographic \
# -runas chris \
# -spice port=5930,disable-ticketing \
# -usb -usbdevice host:045e:00dd \
# -usb -usbdevice host:045e:02d1 \
# -usb -usbdevice host:054c:05c5 \
# -usb -usbdevice host:2508:0001 \
# -usb -usbdevice host:2508:8001 \
# -usb -usbdevice host:4.4 \

# }}}

