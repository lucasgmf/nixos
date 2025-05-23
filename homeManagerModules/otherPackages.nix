{ pkgs, ... }:
{
  home.packages = with pkgs; [
    #network management
    networkmanagerapplet

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

    # GUI apps
    firefox
    vesktop # alternative discord client
    stremio
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
  ];
}
