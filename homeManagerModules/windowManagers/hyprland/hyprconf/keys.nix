{...}: {
  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";
    "$qsConfig" = "ii";

    # Shell / quickshell toggles
    # bindid = [
    #   "Super, Super_L, Toggle search, global, quickshell:searchToggleRelease"
    #   "Super, Super_R, Toggle search, global, quickshell:searchToggleRelease"
    # ];

    bind = [
      # Quickshell IPC fallbacks / toggles
      "Super, Super_L, exec, qs -c $qsConfig ipc call TEST_ALIVE || pkill fuzzel || fuzzel"
      "Super, Super_R, exec, qs -c $qsConfig ipc call TEST_ALIVE || pkill fuzzel || fuzzel"
      "Ctrl, Super_L, global, quickshell:searchToggleReleaseInterrupt"
      "Ctrl, Super_R, global, quickshell:searchToggleReleaseInterrupt"
      "Super, Tab, global, quickshell:overviewWorkspacesToggle"
      "Super, A, global, quickshell:sidebarLeftToggle"
      "Super, N, global, quickshell:sidebarRightToggle"
      "Super, <, global, quickshell:cheatsheetToggle"
      "Super, K, global, quickshell:oskToggle"
      "Super, M, global, quickshell:mediaControlsToggle"
      "Super, G, global, quickshell:overlayToggle"
      "Super, J, global, quickshell:barToggle"
      "Ctrl+Alt, Delete, global, quickshell:sessionToggle"
      "Ctrl+Alt, Delete, exec, qs -c $qsConfig ipc call TEST_ALIVE || pkill wlogout || wlogout -p layer-shell"
      "Ctrl+Super, T, global, quickshell:wallpaperSelectorToggle"
      "Ctrl+Super+Alt, T, global, quickshell:wallpaperSelectorRandom"
      "Ctrl+Super, R, exec, killall qs quickshell; qs -c $qsConfig &"
      "Ctrl+Super, P, global, quickshell:panelFamilyCycle"

      # Clipboard / emoji
      "Super, V, global, quickshell:overviewClipboardToggle"
      "Super, V, exec, qs -c $qsConfig ipc call TEST_ALIVE || pkill fuzzel || cliphist list | fuzzel --match-mode fzf --dmenu | cliphist decode | wl-copy"
      "Super+Shift, Period, global, quickshell:overviewEmojiToggle"
      "Super+Shift, Period, exec, qs -c $qsConfig ipc call TEST_ALIVE || pkill fuzzel || ~/.config/quickshell/ii/scripts/fuzzel-emoji.sh copy"

      # Screenshot
      # "Super+Shift, S, global, quickshell:regionScreenshot"
      # "Super+Shift, S, exec, qs -c $qsConfig ipc call TEST_ALIVE || pidof slurp || hyprshot --freeze --clipboard-only --mode region --silent"
      "Super+Shift, S, exec, grimblast save area - | swappy -f -"
      "Super+Shift, A, global, quickshell:regionSearch"
      "Super+Shift, X, global, quickshell:regionOcr"
      "Super+Shift, C, exec, hyprpicker -a"
      ", Print, exec, grim - | wl-copy"
      "Ctrl, Print, exec, mkdir -p $(xdg-user-dir PICTURES)/Screenshots && grim $(xdg-user-dir PICTURES)/Screenshots/Screenshot_\"$(date '+%Y-%m-%d_%H.%M.%S')\".png"

      # Recording
      "Super+Shift, R, global, quickshell:regionRecord"
      "Super+Shift+Alt, R, exec, ~/.config/quickshell/ii/scripts/videos/record.sh --fullscreen --sound"

      # Session
      "Super, L, exec, loginctl lock-session"
      "Super+Shift, L, exec, systemctl suspend || loginctl suspend"

      # Window management
      "Super, Q, killactive,"
      "Super+Shift+Alt, Q, exec, hyprctl kill"
      "Super+Alt, Space, togglefloating,"
      "Super, D, fullscreen, 1"
      "Super, F, fullscreen, 0"
      "Super+Alt, F, fullscreenstate, 0 3"
      "Super, P, pin,"

      # Focus
      "Super, Left, movefocus, l"
      "Super, Right, movefocus, r"
      "Super, Up, movefocus, u"
      "Super, Down, movefocus, d"
      # vim-style focus (keeping from your original config)
      "Super, h, movefocus, l"
      "Super, l, movefocus, r"
      "Super, k, movefocus, u"
      "Super, j, movefocus, d"

      # Move windows
      "Super+Shift, Left, movewindow, l"
      "Super+Shift, Right, movewindow, r"
      "Super+Shift, Up, movewindow, u"
      "Super+Shift, Down, movewindow, d"

      # Split ratio
      "Super, Semicolon, layoutmsg, splitratio -0.1"
      "Super, Apostrophe, layoutmsg, splitratio +0.1"

      # Workspaces — switch
      "Super, 1, workspace, 1"
      "Super, 2, workspace, 2"
      "Super, 3, workspace, 3"
      "Super, 4, workspace, 4"
      "Super, 5, workspace, 5"
      "Super, 6, workspace, 6"
      "Super, 7, workspace, 7"
      "Super, 8, workspace, 8"
      "Super, 9, workspace, 9"
      "Super, 0, workspace, 10"
      "Ctrl+Super, Right, workspace, r+1"
      "Ctrl+Super, Left, workspace, r-1"
      "Super, Page_Down, workspace, +1"
      "Super, Page_Up, workspace, -1"
      "Super, mouse_up, workspace, +1"
      "Super, mouse_down, workspace, -1"

      # Workspaces — move window
      "Super+Shift, 1, movetoworkspace, 1"
      "Super+Shift, 2, movetoworkspace, 2"
      "Super+Shift, 3, movetoworkspace, 3"
      "Super+Shift, 4, movetoworkspace, 4"
      "Super+Shift, 5, movetoworkspace, 5"
      "Super+Shift, 6, movetoworkspace, 6"
      "Super+Shift, 7, movetoworkspace, 7"
      "Super+Shift, 8, movetoworkspace, 8"
      "Super+Shift, 9, movetoworkspace, 9"
      "Super+Shift, 0, movetoworkspace, 10"
      "Super+Shift, Page_Down, movetoworkspace, r+1"
      "Super+Shift, Page_Up, movetoworkspace, r-1"
      "Ctrl+Super+Shift, Right, movetoworkspace, r+1"
      "Ctrl+Super+Shift, Left, movetoworkspace, r-1"

      # Scratchpad
      "Super, S, togglespecialworkspace,"
      "Super+Alt, S, movetoworkspacesilent, special"
      "Ctrl+Super, S, togglespecialworkspace,"

      # Apps
      "Super, Return, exec, alacritty"
      "Super, T, exec, alacritty"
      "Ctrl+Alt, T, exec, alacritty"
      "Super, E, exec, nautilus"
      "Super, W, exec, firefox"
      "Super, R, exec, fuzzel"
      "Super, I, exec, XDG_CURRENT_DESKTOP=gnome qs -p ~/.config/quickshell/$qsConfig/settings.qml"
      "Ctrl+Super, V, exec, pavucontrol"
      "Ctrl+Shift, Escape, exec, gnome-system-monitor"

      # Media
      "Super+Shift, N, exec, playerctl next"
      "Super+Shift, B, exec, playerctl previous"
      "Super+Shift, P, exec, playerctl play-pause"

      # Zoom
      "Super, Minus, exec, ~/.config/hypr/hyprland/scripts/zoom.sh decrease 0.3"
      "Super, Equal, exec, ~/.config/hypr/hyprland/scripts/zoom.sh increase 0.3"

      # Mute
      "Super+Shift, M, exec, wpctl set-mute @DEFAULT_SINK@ toggle"
      "Super+Alt, M, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle"

      "SUPER SHIFT, c, exec, apply-colors"
    ];

    # bindit = [
    #   ", Super_L, global, quickshell:workspaceNumber"
    #   ", Super_R, global, quickshell:workspaceNumber"
    # ];

    bindm = [
      "Super, mouse:272, movewindow"
      "Super, mouse:273, resizewindow"
      "Super, mouse:274, movewindow"
    ];

    bindel = [
      ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+ -l 1.5"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
      ", XF86MonBrightnessUp, exec, qs -c $qsConfig ipc call brightness increment || brightnessctl s 5%+"
      ", XF86MonBrightnessDown, exec, qs -c $qsConfig ipc call brightness decrement || brightnessctl s 5%-"
    ];

    bindl = [
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle"
      ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle"
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPrev, exec, playerctl previous"
    ];

    binde = [
      "Super, Semicolon, layoutmsg, splitratio -0.1"
      "Super, Apostrophe, layoutmsg, splitratio +0.1"
    ];
  };
}
