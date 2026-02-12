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

    blueman
    pavucontrol

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
    pix

    # GUI apps
    firefox
    vesktop # alternative discord client
    # stremio
    obsidian
    vscode-fhs
    spotify
    google-chrome
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
    ffmpeg_7

    # hyprland cursor
    # TODO: remove this from here
    rose-pine-hyprcursor
    thunar # file explorer
    # adjust screen color temperature to reduce blue light
    gammastep
    mpvpaper

    # remote control
    sunshine
    moonlight-qt

    foliate
  ];
}
