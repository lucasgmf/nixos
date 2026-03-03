{pkgs, ...}: {
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

    python312
    discord

    # TODO: remove this from here
    rose-pine-hyprcursor
    nautilus

    # adjust screen color temperature to reduce blue light
    gammastep
    mpvpaper

    # remote control
    sunshine
    moonlight-qt

    # ebook reader
    foliate

    # nds emulator
    melonDS

    # password manager
    keepassxc

    grimblast
    satty
  ];
}
