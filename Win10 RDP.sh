#!/bin/bash

# Download necessary files
wget -O bios64.bin "https://github.com/BlankOn/ovmf-blobs/raw/master/bios64.bin"
wget -O win.iso "https://software-download.microsoft.com/download/sg/19041.508.190827-1006.vb_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"  # Updated link to Windows 10 ISO
wget -O ngrok.tgz "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-amd64.tgz"
tar -xf ngrok.tgz

# Insert your ngrok authtoken here
./ngrok authtoken <insert_authtoken_here>

# Start ngrok tunnel for VNC (make sure ngrok is running before starting QEMU)
./ngrok tcp 5900 &

# Install QEMU and create a raw disk image
sudo apt update
sudo apt install qemu-kvm -y
qemu-img create -f raw win.img 32G

# Run QEMU virtual machine
sudo qemu-system-x86_64 -m 12G -smp 4 -cpu host -boot order=c \
  -drive file=win.iso,media=cdrom \
  -drive file=win.img,format=raw \
  -device usb-ehci,id=usb,bus=pci.0,addr=0x4 \
  -device usb-tablet \
  -vnc :0 \
  -smp cores=4 \
  -device e1000,netdev=n0 \
  -netdev user,id=n0 \
  -vga qxl \
  -enable-kvm \
  -bios bios64.bin
