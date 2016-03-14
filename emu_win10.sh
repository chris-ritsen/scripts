#!/usr/bin/zsh

# /usr/sbin/qemu-system-x86_64

# -chardev spicevmc,id=charchannel0,name=vdagent
# -chardev spicevmc,id=charredir0,name=usbredir
# -chardev spicevmc,id=charredir1,name=usbredir

# -device hda-duplex,id=sound0-codec0,bus=sound0.0,cad=0
# -device i82801b11-bridge,id=pci.1,bus=pcie.0,addr=0x1e 
# -device ich9-usb-ehci1,id=usb,bus=pci.2,addr=0x3.0x7
# -device ich9-usb-uhci1,masterbus=usb.0,firstport=0,bus=pci.2,multifunction=on,addr=0x3
# -device ich9-usb-uhci2,masterbus=usb.0,firstport=2,bus=pci.2,addr=0x3.0x1
# -device ich9-usb-uhci3,masterbus=usb.0,firstport=4,bus=pci.2,addr=0x3.0x2
# -device intel-hda,id=sound0,bus=pci.2,addr=0x2
# -device pci-bridge,chassis_nr=2,id=pci.2,bus=pci.1,addr=0x1
# -device qxl-vga,id=video0,ram_size=67108864,vram_size=67108864,vgamem_mb=16,bus=pcie.0,addr=0x1
# -device usb-redir,chardev=charredir0,id=redir0
# -device usb-redir,chardev=charredir1,id=redir1
# -device virtio-balloon-pci,id=balloon0,bus=pci.2,addr=0x5
# -device virtio-serial-pci,id=virtio-serial0,bus=pci.2,addr=0x4
# -device virtserialport,bus=virtio-serial0.0,nr=1,chardev=charchannel0,id=channel0,name=com.redhat.spice.0

# -S
# -global PIIX4_PM.disable_s3=1 
# -global PIIX4_PM.disable_s4=1
# -global kvm-pit.lost_tick_policy=discard 
# -msg timestamp=on
# -no-hpet 
# -no-shutdown 
# -no-user-config
# -nodefaults 

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
local cpu_options='kvm64,+lahf_lm'

local disk_image='Images/windows_10.qcow2'
local install_disk='/Media/unsorted/''en_windows_8.1_enterprise_with_update_x64_dvd_6054382.iso'

local disk_interface='virtio'
local machine_options='pc-q35-2.3,accel=kvm,usb=off,vmport=off'
local memory_size='4G'
local network_interface_options='tap,if=tap0,script=no'
local network_options='nic,model=virtio'
local qemu_bin='qemu-system-x86_64'
local socket_options='1,sockets=1,cores=1,threads=1'
# local spice_port='50933'
local vga_options='qxl'

local disk_filename="${virtual_machines_dir}${disk_image}"
local disk_format='qcow2'

local disk_options='file='"${disk_filename}"',if='"${disk_interface},media=disk,format="${disk_format}",cache=none"
local spice_options='port='"${spice_port}"',disable-ticketing'

local spice_device='-device virtio-serial-pci -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 -chardev spicevmc,id=spicechannel0,name=vdagent'

qemu_options=(

# "${spice_device}"
# -boot order="${boot_order}"
# -device virtio-serial-pci -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 -chardev spicevmc,id=spicechannel0,name=vdagent
# -drive "${disk_options}"
# -spice "${spice_options}"
# -show-cursor

# -device virtio-serial-pci -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 -chardev spicevmc,id=spicechannel0,name=vdagent
# -drive file=/Media/unsorted/ ,id=isocd -device ide-cd,bus=ide.1,drive=isocd \
# -smbios file=/usr/share/ovmf/ovmf_x64.bin
# -spice port=50933,addr=::1,disable-ticketing,image-compression=off,seamless-migration=on
# -uuid 39c9e45d-5359-4e8a-8f66-b5818e0e6c8e 

# -daemonize
# -device ide-cd,bus=ide.1,drive=drive-sata0-0-1,id=sata0-0-1,bootindex=1
# -drive file=/Media/Fast/Images/windows_10.qcow2,if=none,id=drive-ide0-0-0,format=qcow2                    
# -drive if=none,media=cdrom,id=drive-sata0-0-1,readonly=on,format=raw,cache=none
# -machine "${machine_options}"
# -name Windows_10
# -net none
# -nodefaults         
# -realtime mlock=off 
# -rtc base=utc,driftfix=slew 
# -vga "${vga_options}"

-bios /usr/share/ovmf/ovmf_x64.bin
-boot menu=on
-cdrom "${install_disk}"
-cpu "${cpu_options}"
-device ide-hd,bus=ide.0,drive=drive-sata0-0-0,id=sata0-0-0,bootindex=2
-device usb-tablet,id=input0                                                                                              \
-drive file=/Media/Fast/Images/windows_10.qcow2,if=none,id=drive-sata0-0-0,format=qcow2,cache=none
-enable-kvm
-m "${memory_size}"
-smp "${socket_options}"
-usb

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

