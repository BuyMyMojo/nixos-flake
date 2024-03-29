# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, lib, ... }:

{

  # Binary caches?
  nix = {
    settings = {
      substituters = [
        "https://nix-gaming.cachix.org"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
    ./gpu-vm.nix

  ];

  specialisation."VFIO".configuration = {
    system.nixos.tags = [ "with-vfio" ];
    vfio.enable = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  boot.kernelParams = [ "amd_iommu=on" ];
  boot.supportedFilesystems = [ "ntfs" ];

  environment.shellInit = ''
    [ -n "$DISPLAY" ] && xhost +si:localuser:$USER || true
  '';

  # Bootloader.
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      # assuming /boot is the mount point of the  EFI partition in NixOS (as the installation section recommends).
      efiSysMountPoint = "/boot";
    };
    grub = {
      # despite what the configuration.nix manpage seems to indicate,
      # as of release 17.09, setting device to "nodev" will still call
      # `grub-install` if efiSupport is true
      # (the devices list is not used by the EFI grub install,
      # but must be set to some value in order to pass an assert in grub.nix)
      devices = [ "nodev" ];
      efiSupport = true;
      enable = true;
      # set $FS_UUID to the UUID of the EFI partition
      extraEntries = ''
        menuentry "Windows" {
          insmod part_gpt
          insmod fat
          insmod search_fs_uuid
          insmod chain
          search --fs-uuid --set=root DCD6-C23F
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
    };
  };


  boot = {
    kernel.sysctl = {
      "kernel.unprivileged_userns_clone" = 1; # for steam
    };
  };

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [ libGL openal glfw ];
    setLdLibraryPath = true;
  };

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
  };

  networking.hostName = "nixos-mojoPC"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
      DiscoverableTimeout = 0;
      NameResolving = true;
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Australia/Sydney";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.buymymojo = {
    isNormalUser = true;
    description = "BuyMyMojo";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = with pkgs; [

      firefox
      kate
      # chromium
      google-chrome
      betterbird-unwrapped
      vscode
      streamdeck-ui
      easyeffects
      qbittorrent
      stacer
      bitwarden-desktop
      imhex
      mplayer

      krita
      cura
      blender
      openscad
      aseprite
      gimp
      freecad

      # Gaming
      # lutris-unwrapped
      lutris
      # steam
      mangohud
      goverlay
      vkbasalt
      replay-sorcery
      protonup-qt
      protontricks
      wineWowPackages.staging
      winetricks
      bottles
      parsec-bin
      mcaselector
      prismlauncher-unwrapped
      #openjdk17
      #jdk17
      #libglvnd
      # libGL
      # zulu17
      steam-run
      heroic-unwrapped
      antimicrox
      oversteer
      steam-rom-manager
      xivlauncher
      steamtinkerlaunch
      inputs.nix-gaming.packages.${pkgs.system}.wine-discord-ipc-bridge
      # proton-ge-bin
      ludusavi

      # Games
      nethack
      retroarchFull
      pcsx2
      duckstation
      # rpcs3
      melonDS
      ryujinx
      xemu

      # Discord
      # discord
      # vencord
      # webcord-vencord
      discord-screenaudio
      vesktop
      hexchat

      # OBS
      # obs-studio
      # obs-studio-plugins.obs-nvfbc
      # obs-studio-plugins.obs-teleport
      # obs-studio-plugins.obs-vkcapture
      # obs-studio-plugins.obs-multi-rtmp
      gpu-screen-recorder
      gpu-screen-recorder-gtk
      peek

      # FFMPEG
      ffmpeg-full
      rav1e
      svt-av1
      libavif
      libaom
      dav1d
      losslesscut-bin

      audacity
      noisetorch

      libreoffice-qt
      hunspell
      hunspellDicts.uk_UA

      quickemu
      clamav

      distrobox
      boxbuddy
      bottles-unwrapped

    ];
  };

  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = { inherit inputs; };
    users = { "buymymojo" = import ./home.nix; };
  };

  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  hardware.steam-hardware.enable = true;
  hardware.xpadneo.enable = true;
  programs.gamemode.enable = true;

  programs.steam.extraCompatPackages = with pkgs; [ proton-ge-bin ];

  # programs.steam.package = pkgs.steam.override { withJava = true; };

  programs.chromium.enable = true;
  programs.chromium.extensions = [
    "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
    "lmcggcabhocpfkbddekmconplfjmmgmn" # Youtube ad speedup
    "igmilfmbmkmpkjjgoabaagaoohhhbjde" # 5e tools rivet
    "dbclpoekepcmadpkeaelmhiheolhjflj" # User agent switcher
    "cafgibgoaehhjoomjcndeogbcmfdbogd" # Smart upscale
  ];
  programs.chromium.enablePlasmaBrowserIntegration = true;
  programs.chromium.extraOpts = {
    "BrowserSignin" = 1;
    "SyncDisabled" = false;
    "PasswordManagerEnabled" = true;
    "SpellcheckEnabled" = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    # chromium

    # General cli tools
    wget
    curl
    neofetch
    nvtopPackages.full
    torrent7z
    p7zip
    croc
    pciutils
    partclone
    hexdump
    gparted
    nethogs
    bubblewrap

    # media
    mpv
    imagemagick
    jpegoptim

    # compiler junk
    clang
    llvmPackages.bintools
    glibc
    glib

    # rustup
    rustc
    cargo

    kitty # gpu terminal

    # nix stuff
    nixfmt

    # RDP
    sunshine

    # Needed for steam?
    libselinux

    # inputs.nix-gaming.packages.${pkgs.system}.wine-discord-ipc-bridge
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = lib.mkForce pkgs.pinentry-qt;
  };

  # List services that you want to enable:

  services = {
    syncthing = {
      enable = true;
      user = "myusername";
      dataDir =
        "/home/myusername/Documents"; # Default folder for new synced folders
      configDir =
        "/home/myusername/Documents/.config/syncthing"; # Folder for Syncthing's settings and keys
    };

    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      # require public key authentication for better security
      # settings.PasswordAuthentication = false;
      # settings.KbdInteractiveAuthentication = false;
      settings.PermitRootLogin = "yes";
    };

    flatpak.enable = true;

    xserver = {
      # Enable the X11 windowing system.
      enable = true;

      desktopManager.plasma5.enable = true;
      # desktopManager.plasma6.enable = true;

      displayManager = {
        # Enable the KDE Plasma Desktop Environment.
        sddm.enable = true;

        sddm.wayland.enable = true;

        # Enable automatic login for the user.
        autoLogin.enable = true;
        autoLogin.user = "buymymojo";
      };

      # Load nvidia driver for Xorg and Wayland
      videoDrivers = [ "nvidia" ]; # or "nvidiaLegacy470 etc.

      xkb.layout = "us";
      xkb.variant = "";
    };

    xrdp = {
      enable = false;
      defaultWindowManager = "startplasma-x11";
      openFirewall = true;
    };
  };

  # services.xserver.displayManager.defaultSession = "plasmawayland";

  #virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      # ovmf = {
      #   enable = true;
      #   packages = [(pkgs.unstable.OVMF.override {
      #     secureBoot = false;
      #     tpmSupport = true;
      #  }).fd];
      # };
    };
  };

  programs.virt-manager.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Fix for windows dualboot time
  time.hardwareClockInLocalTime = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
