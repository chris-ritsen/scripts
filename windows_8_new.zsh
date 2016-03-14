#!/usr/bin/zsh

function() {

qemu_options=(

# -drive file=/Media/Fast/Images/Install/en_windows_8.1_enterprise_with_update_x64_dvd_6054382.iso,if=none,id=drive-ide0-0-0,readonly=on,format=raw,cache=none
# -drive file=/Media/Fast/Images/Install/virtio-win.iso,if=none,id=drive-ide0-0-1,readonly=on,format=raw,cache=none

# -chardev socket,id=charmonitor,path=/var/lib/libvirt/qemu/domain-windows_8-clone/monitor.sock,server,nowait
# -mon chardev=charmonitor,id=monitor,mode=control

# -netdev tap,fd=23,id=hostnet0,vhost=on,vhostfd=24
# -device virtio-net-pci,netdev=hostnet0,id=net0,mac=52:54:00:c1:27:f9,bus=pci.0,addr=0x3

# -device hda-duplex,id=sound0-codec0,bus=sound0.0,cad=0

-S
-bios /usr/share/ovmf/ovmf_x64.bin
-boot strict=on
# -chardev pty,id=charserial0
# -chardev spicevmc,id=charchannel0,name=vdagent
# -chardev spicevmc,id=charredir0,name=usbredir
# -chardev spicevmc,id=charredir1,name=usbredir
-cpu kvm64,+lahf_lm
-device ahci,id=sata0,bus=pci.0,addr=0x8
-device ide-cd,bus=ide.0,unit=0,drive=drive-ide0-0-0,id=ide0-0-0
-device ide-cd,bus=ide.0,unit=1,drive=drive-ide0-0-1,id=ide0-0-1
-device intel-hda,id=sound0,bus=pci.0,addr=0x4
# -device isa-serial,chardev=charserial0,id=serial0
-device nec-usb-xhci,id=usb,bus=pci.0,addr=0x6
# -device qxl-vga,id=video0,ram_size=67108864,vram_size=67108864,vgamem_mb=16,bus=pci.0,addr=0x2
# -device usb-redir,chardev=charredir0,id=redir0
# -device usb-redir,chardev=charredir1,id=redir1
-device usb-tablet,id=input0
-device virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x7
-device virtio-blk-pci,scsi=off,bus=pci.0,addr=0x9,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=1
-device virtio-serial-pci,id=virtio-serial0,bus=pci.0,addr=0x5
# -device virtserialport,bus=virtio-serial0.0,nr=1,chardev=charchannel0,id=channel0,name=com.redhat.spice.0
-drive file=/Media/Fast/Images/windows_8_alt.qcow2,if=none,id=drive-virtio-disk0,format=qcow2,cache=none,aio=native
-drive if=none,id=drive-ide0-0-0,readonly=on,format=raw,cache=none
-drive if=none,id=drive-ide0-0-1,readonly=on,format=raw,cache=none
-global PIIX4_PM.disable_s3=1
-global PIIX4_PM.disable_s4=1
-global kvm-pit.lost_tick_policy=discard
-k en-us
-m 4086
-machine pc-i440fx-2.3,accel=kvm,usb=off,vmport=off
-msg timestamp=on
-name windows_8-clone
-no-hpet
-no-shutdown
-no-user-config
-nodefaults
-realtime mlock=off
-rtc base=utc,driftfix=slew
-smp 2,sockets=2,cores=1,threads=1
-spice port=5907,addr=0.0.0.0,disable-ticketing,seamless-migration=on
-uuid b104a232-207f-4e7e-9109-8b67d575638b

)

local qemu_bin='qemu-system-x86_64'

"${qemu_bin}" "${qemu_options[@]}" 

}

