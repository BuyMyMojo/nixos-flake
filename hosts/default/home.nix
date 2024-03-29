{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "buymymojo";
  home.homeDirectory = "/home/buymymojo";

  home.sessionPath = [ "/home/buymymojo/.cargo/bin" ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  programs.obs-studio = {
    enable = true;
    plugins = [
      pkgs.obs-studio-plugins.obs-teleport
      pkgs.obs-studio-plugins.obs-vkcapture
      pkgs.obs-studio-plugins.obs-multi-rtmp
      pkgs.obs-studio-plugins.obs-vertical-canvas
      pkgs.obs-studio-plugins.obs-source-record
      pkgs.obs-studio-plugins.obs-composite-blur
    ];
  };

  programs.java = {
    enable = true;
    package = pkgs.zulu17;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "BuyMyMojo";
    userEmail = "hello@buymymojo.net";
    signing = {
      key = "69DC182D409D045B105924BE193A16330265B60A";
      signByDefault = true;
    };

    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      credential = {
        helper = "store";
      };
    };
  };

  programs.git-cliff.enable = true;

  programs.bat.enable = true;
  programs.aria2.enable = true;
  programs.btop.enable = true;
  programs.rtorrent.enable = true;
  
  programs.yt-dlp = {
    enable = true;
    settings = {
      embed-thumbnail = true;
      embed-subs = true;
      sub-langs = "en";
      downloader = "aria2c";
      downloader-args = "aria2c:'-c -x8 -s8'";
    };
  };
  
  

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/buymymojo/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = { EDITOR = "code"; };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
