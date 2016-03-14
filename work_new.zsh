#!/usr/bin/zsh

function() {

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

# TODO: Put the disk image directly onto a partition.

local disk_image='/Media/Fast/Images/work.qcow2'
local firmware=$(xdg-user-dir SCRIPTS)/'ovmf_x64.bin'
local qemu_bin='qemu-system-x86_64'
local spice_port=5910

if [[ ! -f "${firmware}" ]]; then
  return
fi

network_options=(

-net bridge,br=br0 
-net nic,model=virtio
-spice port="${spice_port}",addr=0.0.0.0,disable-ticketing,seamless-migration=on 

)

machine_options=(

# -cpu host
-m 4086 
-machine pc-i440fx-2.3,accel=kvm,usb=off,vmport=off 
-smp 2,sockets=2,cores=1,threads=1 

-cpu kvm64,+lahf_lm 

)

video_options=(

-vga qxl

)

disk_options=(

-drive file="${disk_image}",if=virtio,format=qcow2,cache=none,aio=native 

)

input_options=(

-usbdevice tablet

)

firmware_options=(

-pflash "${firmware}"

)

default_options=(

-daemonize
-enable-kvm
-no-shutdown 

)

instance_options=(

-name windows_8 

)

qemu_options=(

"${default_options[@]}"
"${disk_options[@]}"
"${firmware_options[@]}"
"${input_options[@]}"
"${instance_options[@]}"
"${machine_options[@]}"
"${network_options[@]}"
"${video_options[@]}"

)

"${qemu_bin}" "${qemu_options[@]}" 

}


