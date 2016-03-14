#!/usr/bin/zsh

function () {

# Environment {{{

# LibVirt {{{

# TODO: run as session

export LIBVIRT_DEFAULT_URI='qemu:///system'

# }}}

# Qemu {{{

export QEMU_AUDIO_DRV='pa'
export QEMU_PA_SAMPLES='128'

# }}}

# SDL {{{

export SDL_VIDEO_X11_DGAMOUSE='0'

# }}}

# }}}

# Instance options {{{

local name='windows_8'

# }}}

# Boot {{{

# Paths {{{

local bios_image='/home/chris/scripts/ovmf_x64.bin'

# local bios_image='/usr/share/ovmf/ovmf_x64.bin'

# }}}

# Guard {{{

if [[ ! -f "${bios_image}"  ]]; then
  echo 'bios firmware image is missing';
fi

# }}}

local boot_order='c'

boot_options=(
  
# -boot menu=on
# -pflash "${bios_image}"

-bios "${bios_image}"
-boot strict=on

)

# }}}

# Network {{{

local network_interface_options='tap,if=tap0,script=no'
local network_options='nic,model=virtio'

network_options=(

-net none

)

# }}}

# Video {{{

local vga_mode='qxl'

video_options=(

-vga "${vga_mode}"

)

# }}}

# Disk {{{

local disk_format='qcow2'
local disk_interface='virtio'
local disk_size_gb='80g'

# Paths {{{

local virtual_machines_dir='/Media/Fast/Images/'
local windows_8_iso='en_windows_8.1_enterprise_with_update_x64_dvd_6054382.iso' 
local install_disk_dir='/Media/Fast/Images/Install/' 

local disk_image="${name}"'.'"${disk_format}"
local install_disk="${install_disk_dir}""${windows_8_iso}"

local disk_filename="${virtual_machines_dir}""${disk_image}"

# }}}

local disk_options='file='"${disk_filename}"',if='"${disk_interface},media=disk,format="${disk_format}",cache=none"

# Guard {{{

if [[ ! -f "${install_disk}"  ]]; then
  echo 'install disk is missing';
fi

# }}}

disk_options=(

-drive file="${disk_filename}",if=none,id=drive-ide0-0-0,format="${disk_format}"

-drive if=none,id=drive-ide0-0-1,readonly=on,format=raw

# -drive if=none,media=cdrom,id=drive-sata0-0-1,readonly=on,format=raw,cache=none
# -drive file=/Media/Fast/Images/windows_8.qcow2,if=none,id=drive-ide0-0-0,format=qcow2

# -cdrom "${install_disk}"
# -drive file="${disk_filename}",if=none,id=drive-sata0-0-0,format="${disk_format}",cache=none

)

# }}}

# Spice {{{

# Network {{{

local spice_port='50933'

# }}}

local spice_options='port='"${spice_port}"',disable-ticketing'

spice_options=(

# -spice port=50933,addr=::1,disable-ticketing,image-compression=off,seamless-migration=on

)

# }}}

# Devices {{{

# USB {{{

usb_options=(

-usb
-usbdevice tablet

)

# }}}

local spice_device='-device virtio-serial-pci -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 -chardev spicevmc,id=spicechannel0,name=vdagent'

device_options=(

# -device ide-cd,bus=ide.1,drive=drive-sata0-0-1,id=sata0-0-1,bootindex=1
# -device ide-hd,bus=ide.0,drive=drive-sata0-0-0,id=sata0-0-0,bootindex=1

# -device ide-cd,bus=ide.0,unit=1,drive=drive-ide0-0-1,id=ide0-0-1
-device ide-hd,bus=ide.0,unit=0,drive=drive-ide0-0-0,id=ide0-0-0,bootindex=1

# -device virtio-serial-pci -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 -chardev spicevmc,id=spicechannel0,name=vdagent

$usb_options

)

# }}}

# Machine {{{

# Clock {{{

clock_options=(

-realtime mlock=off 
-rtc base=utc,driftfix=slew 

)

# }}}

local cpu_options='kvm64,+lahf_lm'
local machine_options='pc-q35-2.3,accel=kvm,usb=off,vmport=off'
local memory_size_gb='4G'
local memory_size='4086'
local socket_options='1,sockets=1,cores=1,threads=1'

machine_options=(

$clock_options
-cpu "${cpu_options}"
-enable-kvm
-m "${memory_size_gb}"
-machine "${machine_options}"
-name "${name}"
-smp "${socket_options}"

)

# }}}

# Qemu options {{{

local qemu_bin='qemu-system-x86_64'

qemu_options=(

-daemonize
-uuid 683cb800-f89c-4916-848b-0259bcf03fc8
# -nodefaults

# -uuid 39c9e45d-5359-4e8a-8f66-b5818e0e6c8e 

)

qemu_options+=(

$boot_options
$device_options
$disk_options
$machine_options
$network_options
$spice_options
$vga_options

)

# echo "${qemu_bin}" "${qemu_options[@]}" 

# }}}

function install_windows_8() {

exit 

# Installation {{{

# Options {{{

install_boot_options=(

--boot=uefi 

--boot loader="${bios_image}"

)

install_options=(

$install_boot_options

--cdrom "${install_disk}"
--check path_in_use=off
--disk "${disk_filename}"
--input bus=usb,type=tablet
--memory "${memory_size}"
--name "${name}"
# --noautoconsole
--quiet
--video vga

)

# }}}

# Clean installation {{{

# Guard {{{

rm --force "${disk_filename}"

if [[ ! -f "${disk_filename}"  ]]; then

  qemu-img create -q -f "${disk_format}" "${disk_filename}" "${disk_size_gb}"
  # sudo chmod g+rw "${disk_filename}"
  # sudo chgrp kvm "${disk_filename}"
  # sudo chgrp "${USER}" "${disk_filename}"

fi

# }}}

# This isn't actually quiet

virsh --quiet destroy "${name}" 2>/dev/null 
virsh --quiet undefine "${name}" 2>/dev/null

# }}}

virt-install --connect="${LIBVIRT_DEFAULT_URI}" "${install_options[@]}" 

# virt-viewer --connect="${LIBVIRT_DEFAULT_URI}" --reconnect "${name}"

# }}}

}

# Run {{{

# "${qemu_bin}" "${qemu_options[@]}"


qemu_options=(

-S 
-bios /usr/share/ovmf/ovmf_x64.bin 
-boot strict=on
-chardev pty,id=charserial0
-chardev socket,id=charmonitor,path=/var/lib/libvirt/qemu/windows_8.monitor,server,nowait 
-chardev spicevmc,id=charchannel0,name=vdagent
-chardev spicevmc,id=charredir0,name=usbredir
-chardev spicevmc,id=charredir1,name=usbredir
-cpu SandyBridge 
-device ahci,id=sata0,bus=pci.0,addr=0x8
-device hda-duplex,id=sound0-codec0,bus=sound0.0,cad=0
-device ich9-usb-ehci1,id=usb,bus=pci.0,addr=0x6.0x7
-device ich9-usb-uhci1,masterbus=usb.0,firstport=0,bus=pci.0,multifunction=on,addr=0x6
-device ich9-usb-uhci2,masterbus=usb.0,firstport=2,bus=pci.0,addr=0x6.0x1
-device ich9-usb-uhci3,masterbus=usb.0,firstport=4,bus=pci.0,addr=0x6.0x2
-device ide-hd,bus=ide.0,unit=0,drive=drive-ide0-0-0,id=ide0-0-0,bootindex=1
-device intel-hda,id=sound0,bus=pci.0,addr=0x4
-device isa-serial,chardev=charserial0,id=serial0
-device qxl-vga,id=video0,ram_size=67108864,vram_size=67108864,vgamem_mb=16,bus=pci.0,addr=0x2
-device usb-redir,chardev=charredir0,id=redir0
-device usb-redir,chardev=charredir1,id=redir1
-device usb-tablet,id=input0
-device virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x7
-device virtio-net-pci,netdev=hostnet0,id=net0,mac=52:54:00:dd:eb:10,bus=pci.0,addr=0x3
-device virtio-serial-pci,id=virtio-serial0,bus=pci.0,addr=0x5
-device virtserialport,bus=virtio-serial0.0,nr=1,chardev=charchannel0,id=channel0,name=com.redhat.spice.0
-drive file=/Media/Fast/Images/work.img,if=none,id=drive-ide0-0-0,format=raw
-global PIIX4_PM.disable_s3=1
-global PIIX4_PM.disable_s4=1
-global kvm-pit.lost_tick_policy=discard
-i440fx-2.3,accel=kvm,usb=off,vmport=off 
-k en-us
-m 4086 
-machine pc
-mon chardev=charmonitor,id=monitor,mode=control 
-msg timestamp=on
-name windows_8 
-netdev tap,fd=21,id=hostnet0
-no-hpet
-no-shutdown
-no-user-config 
-nodefaults 
-realtime mlock=off 
-rtc base=utc,driftfix=slew
-smp 1,sockets=1,cores=1,threads=1 
-spice port=5902,addr=0.0.0.0,disable-ticketing,seamless-migration=on
-uuid 683cb800-f89c-4916-848b-0259bcf03fc8
sudo /usr/sbin/qemu-system-x86_64

)


# sudo virsh start "${name}"
# sudo virsh reset "${name}"

# virt-viewer --full-screen --connect="${LIBVIRT_DEFAULT_URI}" --reconnect "${name}"
spicec --host localhost --port 5902

# }}}

}

