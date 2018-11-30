# USB UEFI Shell
Automatic creation of bootable USB-drive with UefiShell.
## Requirements
* dosfstools (mkfs.fat)
* util-linux (fdisk)
## Usage
In terminal: `sudo ./usb_uefi_shell.sh "path to Shell.efi" "path to device"`
## Example
`sudo ./usb_uefi_shell.sh Shell.efi /dev/sdc`
