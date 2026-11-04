{pkgs, ...}: {
  home.packages = with pkgs; [
    wlogout
    material-symbols
    jq
  ];

  xdg.configFile."wlogout/layout".text = ''
    {
        "label" : "lock",
        "action" : "loginctl lock-session",
        "text" : "lock",
        "keybind" : "l"
    }
    {
        "label" : "hibernate",
        "action" : "systemctl hibernate || loginctl hibernate",
        "text" : "downloading",
        "keybind" : "h"
    }
    {
        "label" : "logout",
        "action" : "hyprctl clients -j | jq -r '.[].pid' | xargs kill; pkill Hyprland || pkill sway || pkill niri || loginctl terminate-user $USER",
        "text" : "logout",
        "keybind" : "e"
    }
    {
        "label" : "shutdown",
        "action" : "hyprctl clients -j | jq -r '.[].pid' | xargs kill; systemctl poweroff || loginctl poweroff",
        "text" : "power_settings_new",
        "keybind" : "s"
    }
    {
        "label" : "suspend",
        "action" : "systemctl suspend || loginctl suspend",
        "text" : "bedtime",
        "keybind" : "u"
    }
    {
        "label" : "reboot",
        "action" : "hyprctl clients -j | jq -r '.[].pid' | xargs kill; systemctl reboot || loginctl reboot",
        "text" : "restart_alt",
        "keybind" : "r"
    }
  '';

  xdg.configFile."wlogout/style.css".text = ''
    * {
      all: unset;
      background-image: none;
      transition: 400ms cubic-bezier(0.05, 0.7, 0.1, 1);
    }

    window {
      background: rgba(0, 0, 0, 0.5);
    }

    button {
      font-family: 'Material Symbols Outlined';
      font-size: 5rem;
      background-color: rgba(11, 11, 11, 0.4);
      color: #FFFFFF;
      margin: 1rem;
      border-radius: 1rem;
      padding: 1.5rem;
    }

    button:focus,
    button:active,
    button:hover {
      background-color: rgba(51, 51, 51, 0.5);
      border-radius: 2rem;
    }
  '';
}
