{ pkgs, ... }:
{
  home.packages = with pkgs; [
    #network management
    networkmanagerapplet
    gnome-keyring
    seahorse

    # feup l2tp vpn
    networkmanager_strongswan
    networkmanager-l2tp
    xl2tpd

    # other Cli tools
    fastfetch
    ripgrep
    repgrep
    lazygit
    xclip
    unzip
    btop
    less
    dust
    bat
    jq
    fd
    gh

    kitty

    # GUI apps
    firefox
    vesktop # alternative discord client
    # stremio
    obsidian
    vscode-fhs
    spotify
    google-chrome
    mendeley # for master's thesis
    drawio
    postman
    wireshark

    picoprobe-udev-rules # probe-rs udev rules
    platformio-core.udev # platformio
    openocd # platformio
    platformio

    python312
    discord

    kdePackages.dolphin
    
    # hyprland cursor 
    # TODO: remove this from here
    rose-pine-hyprcursor
    xfce.thunar #file explorer
    # adjust screen color temperature to reduce blue light
    gammastep 
    mpvpaper
  ];
}
