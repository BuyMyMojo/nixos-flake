# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/abbf1ba8-00b5-4f60-8157-b8bb8f38df10";
      fsType = "ext4";
    };

 fileSystems."/home/buymymojo/LinuxData" =
  { device = "/dev/disk/by-uuid/bcae1169-a4dc-4374-8c9b-e120dd344227";
    fsType = "ext4";
  };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/77BD-CED9";
      fsType = "vfat";
    };

   fileSystems."/home/buymymojo/WindowsDrives/Samsung SSD" =
   { device = "/dev/disk/by-partuuid/df09d735-01";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000"];
   };

   fileSystems."/home/buymymojo/WindowsDrives/2TB NVME" =
   { device = "/dev/disk/by-partuuid/405a6e0a-3369-4a23-8312-4352bce2717c";
    fsType = "ntfs-3g"; 
    options = [ "rw" "uid=1000"];
   };

   fileSystems."/home/buymymojo/WindowsDrives/Kingston SSD" =
   { device = "/dev/disk/by-partuuid/2c1aef37-1cee-45c1-a29d-6251b3042c40";
    fsType = "ntfs-3g"; 
    options = [ "rw" "uid=1000"];
   };

   fileSystems."/home/buymymojo/WindowsDrives/DATA" =
   { device = "/dev/disk/by-partuuid/05c2c9e1-83e7-4484-a10f-d9f158e6300b";
    fsType = "ntfs-3g"; 
    options = [ "rw" "uid=1000"];
   };

   fileSystems."/home/buymymojo/WindowsDrives/Gen4" =
   { device = "/dev/disk/by-partuuid/02473dc8-0bf7-44b5-a5c5-c033d93102d6";
    fsType = "ntfs-3g"; 
    options = [ "rw" "uid=1000"];
   };

   fileSystems."/home/buymymojo/WindowsDrives/C" =
   { device = "/dev/disk/by-partuuid/e0093462-d02d-4bf1-a97a-145fda71c8bd";
    fsType = "ntfs-3g"; 
    options = [ "rw" "uid=1000"];
   };

    #fileSystems."/mnt/PortableData" =
    #{ device = "/dev/disk/by-partuuid/2fed2c5e-1e06-4a77-8240-46634adc6f1e";
    #  fsType = "ext4";
    #};

  swapDevices =
    [ { device = "/dev/disk/by-uuid/427361c6-c015-4cda-995b-dfd789df6369"; }
    ];
  

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp10s0f3u5.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp9s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp8s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
