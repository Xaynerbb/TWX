#!/bin/bash

############################
# COLORS
############################
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

############################
# CONFIG
############################
VM_NAME="Windows10"
ISO_PATH="$HOME/Windows10.iso"
VM_DIR="$HOME/VirtualBox VMs/$VM_NAME"
VDI_PATH="$VM_DIR/$VM_NAME.vdi"
RAM_MB=2048   # 2GB for the VM, leaves 2GB for your Linux host
CPUS=2
VRAM_MB=128
DISK_MB=51200  # 50 GB

############################
# HELPERS
############################
info()  { echo -e "${CYAN}[INFO]${NC}  $1"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

echo ""
echo -e "${GREEN}=== Windows 10 VM Setup Script ===${NC}"
echo ""

############################
# 1. CHECK / INSTALL VIRTUALBOX
############################
if command -v VBoxManage &>/dev/null; then
    ok "VirtualBox is already installed: $(VBoxManage --version)"
else
    info "VirtualBox not found. Installing..."

    sudo apt update -y

    # Pre-accept the VirtualBox Extension Pack license to avoid interactive prompt
    echo "virtualbox-ext-pack virtualbox-ext-pack/license select true" | sudo debconf-set-selections

    sudo apt install -y virtualbox virtualbox-ext-pack

    if ! command -v VBoxManage &>/dev/null; then
        error "VirtualBox installation failed. Please install it manually and re-run."
    fi

    ok "VirtualBox installed successfully."
fi

############################
# 2. CHECK ISO / DOWNLOAD IF MISSING
############################
if [ ! -f "$ISO_PATH" ]; then
    warn "Windows 10 ISO not found at: $ISO_PATH"
    info "Downloading Windows 10 ISO from Microsoft using Mido..."
    info "This is ~5-6 GB — it may take a while depending on your connection."
    echo ""

    # Make sure curl is available
    if ! command -v curl &>/dev/null; then
        info "curl not found. Installing..."
        sudo apt install -y curl
    fi

    # Download Mido — a shell script that fetches ISOs directly from Microsoft
    MIDO_TMP="/tmp/Mido.sh"
    curl -fsSL "https://raw.githubusercontent.com/ElliotKillick/Mido/main/Mido.sh" -o "$MIDO_TMP" \
        || error "Failed to download Mido. Check your internet connection."
    chmod +x "$MIDO_TMP"

    # Run Mido in HOME so the ISO lands there
    (cd "$HOME" && bash "$MIDO_TMP" win10x64) \
        || error "Mido failed to download the Windows 10 ISO."

    # Mido names the file something like Win10_22H2_English_x64.iso — find and rename it
    WIN_ISO=$(find "$HOME" -maxdepth 1 -name "Win10*.iso" 2>/dev/null | head -1)

    if [ -z "$WIN_ISO" ]; then
        error "ISO download appeared to succeed but the file was not found in $HOME. Check manually."
    fi

    mv "$WIN_ISO" "$ISO_PATH"
    ok "Windows 10 ISO downloaded and saved to: $ISO_PATH"
else
    ok "ISO found at: $ISO_PATH"
fi

############################
# 3. DETECT AUDIO DRIVER
############################
detect_audio_driver() {
    if pactl info &>/dev/null; then
        # Could be PulseAudio or PipeWire (PipeWire exposes a PulseAudio interface)
        echo "pulse"
    elif aplay -l &>/dev/null 2>&1; then
        echo "alsa"
    else
        echo "null"
    fi
}

AUDIO_DRIVER=$(detect_audio_driver)
info "Detected audio driver: $AUDIO_DRIVER"

############################
# 4. CREATE VM (if not exists)
############################
if VBoxManage list vms | grep -q "\"$VM_NAME\""; then
    warn "VM '$VM_NAME' already exists. Skipping creation."
else
    info "Creating VM '$VM_NAME'..."

    # Register the VM — VirtualBox creates the VM directory automatically
    VBoxManage createvm \
        --name "$VM_NAME" \
        --ostype "Windows10_64" \
        --register

    # Configure hardware
    # Note: Using BIOS firmware (default) for maximum compatibility with Windows 10
    VBoxManage modifyvm "$VM_NAME" \
        --memory "$RAM_MB" \
        --cpus "$CPUS" \
        --vram "$VRAM_MB" \
        --graphicscontroller vboxsvga \
        --nic1 nat \
        --boot1 dvd \
        --boot2 disk \
        --boot3 none \
        --boot4 none \
        --chipset piix3 \
        --audio-driver "$AUDIO_DRIVER" \
        --audio-out on \
        --usb-ehci on \
        --clipboard-mode bidirectional \
        --draganddrop bidirectional

    # Resolve the actual VM directory VirtualBox chose
    ACTUAL_VM_DIR=$(VBoxManage showvminfo "$VM_NAME" --machinereadable \
        | grep "^CfgFile=" \
        | cut -d'"' -f2 \
        | xargs dirname)

    VDI_PATH="$ACTUAL_VM_DIR/$VM_NAME.vdi"

    # Create virtual hard disk
    VBoxManage createhd \
        --filename "$VDI_PATH" \
        --size "$DISK_MB" \
        --format VDI

    # Add SATA controller
    VBoxManage storagectl "$VM_NAME" \
        --name "SATA Controller" \
        --add sata \
        --controller IntelAhci \
        --portcount 2

    # Attach hard disk
    VBoxManage storageattach "$VM_NAME" \
        --storagectl "SATA Controller" \
        --port 0 \
        --device 0 \
        --type hdd \
        --medium "$VDI_PATH"

    # Attach Windows ISO
    VBoxManage storageattach "$VM_NAME" \
        --storagectl "SATA Controller" \
        --port 1 \
        --device 0 \
        --type dvddrive \
        --medium "$ISO_PATH"

    ok "VM '$VM_NAME' created and configured successfully."
fi

############################
# 5. START VM
############################
info "Starting VM '$VM_NAME'..."
VBoxManage startvm "$VM_NAME" --type gui
ok "VM launched. Complete the Windows 10 installation in the GUI."
echo ""
echo -e "${YELLOW}TIP:${NC} After Windows installs, install VirtualBox Guest Additions for better performance."
echo ""
