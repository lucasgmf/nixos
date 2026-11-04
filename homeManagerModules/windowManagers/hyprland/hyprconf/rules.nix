{...}: {
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      # Disable blur for empty windows and all windows (quickshell handles blur via layerrules)
      "match:class ^()$, match:title ^()$, no_blur on"
      "match:class .*, no_blur on"

      # Floating file dialogs
      "match:title ^(Open File)(.*)$, float on"
      "match:title ^(Open File)(.*)$, center on"
      "match:title ^(Select a File)(.*)$, float on"
      "match:title ^(Select a File)(.*)$, center on"
      "match:title ^(Choose wallpaper)(.*)$, float on"
      "match:title ^(Choose wallpaper)(.*)$, center on"
      "match:title ^(Choose wallpaper)(.*)$, size (monitor_w*.60) (monitor_h*.65)"
      "match:title ^(Open Folder)(.*)$, float on"
      "match:title ^(Open Folder)(.*)$, center on"
      "match:title ^(Save As)(.*)$, float on"
      "match:title ^(Save As)(.*)$, center on"
      "match:title ^(Library)(.*)$, float on"
      "match:title ^(Library)(.*)$, center on"
      "match:title ^(File Upload)(.*)$, float on"
      "match:title ^(File Upload)(.*)$, center on"
      "match:title ^(.*)(wants to save)$, float on"
      "match:title ^(.*)(wants to save)$, center on"
      "match:title ^(.*)(wants to open)$, float on"
      "match:title ^(.*)(wants to open)$, center on"

      # Floating apps
      "match:class ^(blueberry\\.py)$, float on"
      "match:class ^(pavucontrol)$, float on"
      "match:class ^(pavucontrol)$, size (monitor_w*.45) (monitor_h*.45)"
      "match:class ^(pavucontrol)$, center on"
      "match:class ^(org.pulseaudio.pavucontrol)$, float on"
      "match:class ^(org.pulseaudio.pavucontrol)$, size (monitor_w*.45) (monitor_h*.45)"
      "match:class ^(org.pulseaudio.pavucontrol)$, center on"
      "match:class ^(nm-connection-editor)$, float on"
      "match:class ^(nm-connection-editor)$, size (monitor_w*.45) (monitor_h*.45)"
      "match:class ^(nm-connection-editor)$, center on"
      "match:title .*Welcome, float on"
      "match:title ^(illogical-impulse Settings)$, float on"
      "match:class org.freedesktop.impl.portal.desktop.kde, float on"
      "match:class org.freedesktop.impl.portal.desktop.kde, size (monitor_w*.60) (monitor_h*.65)"

      # Picture-in-Picture
      "match:title ^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$, float on"
      "match:title ^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$, keep_aspect_ratio on"
      "match:title ^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$, move (monitor_w*.73) (monitor_h*.72)"
      "match:title ^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$, size (monitor_w*.25) (monitor_h*.25)"
      "match:title ^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$, pin on"

      # Tearing for games/wine
      "match:title .*\\.exe, immediate on"
      "match:title .*minecraft.*, immediate on"
      "match:class ^(steam_app).*, immediate on"

      # JetBrains IDEs focus fix
      "match:class ^jetbrains-.*$, match:float 1, match:title ^$|^\\s$|^win\\d+$, no_initial_focus on"

      # No shadow for tiled windows
      "match:float 0, no_shadow on"
    ];

    workspace = [
      "special:special, gapsout:30"
    ];

    layerrule = [
      # Global xray
      "match:namespace .*, xray on"

      # No anim for overlays
      "match:namespace walker, no_anim on"
      "match:namespace selection, no_anim on"
      "match:namespace overview, no_anim on"
      "match:namespace anyrun, no_anim on"
      "match:namespace indicator.*, no_anim on"
      "match:namespace osk, no_anim on"
      "match:namespace hyprpicker, no_anim on"
      "match:namespace noanim, no_anim on"
      "match:namespace gtk4-layer-shell, no_anim on"

      # Blur for shell layers
      "match:namespace gtk-layer-shell, blur on"
      "match:namespace gtk-layer-shell, ignore_alpha 0"
      "match:namespace launcher, blur on"
      "match:namespace launcher, ignore_alpha 0.5"
      "match:namespace notifications, blur on"
      "match:namespace notifications, ignore_alpha 0.69"
      "match:namespace logout_dialog, blur on"

      # Quickshell layers
      "match:namespace quickshell:.*, blur_popups on"
      "match:namespace quickshell:.*, blur on"
      "match:namespace quickshell:.*, ignore_alpha 0.79"
      "match:namespace quickshell:bar, animation slide"
      "match:namespace quickshell:actionCenter, no_anim on"
      "match:namespace quickshell:cheatsheet, animation slide bottom"
      "match:namespace quickshell:dock, animation slide bottom"
      "match:namespace quickshell:screenCorners, animation popin 120%"
      "match:namespace quickshell:lockWindowPusher, no_anim on"
      "match:namespace quickshell:notificationPopup, animation fade"
      "match:namespace quickshell:overlay, no_anim on"
      "match:namespace quickshell:overlay, ignore_alpha 1"
      "match:namespace quickshell:overview, no_anim on"
      "match:namespace quickshell:osk, animation slide bottom"
      "match:namespace quickshell:polkit, no_anim on"
      "match:namespace quickshell:popup, xray off"
      "match:namespace quickshell:popup, ignore_alpha 1"
      "match:namespace quickshell:mediaControls, ignore_alpha 1"
      "match:namespace quickshell:reloadPopup, animation slide"
      "match:namespace quickshell:regionSelector, no_anim on"
      "match:namespace quickshell:screenshot, no_anim on"
      "match:namespace quickshell:session, blur on"
      "match:namespace quickshell:session, no_anim on"
      "match:namespace quickshell:session, ignore_alpha 0"
      "match:namespace quickshell:sidebarRight, animation slide right"
      "match:namespace quickshell:sidebarLeft, animation slide left"
      "match:namespace quickshell:verticalBar, animation slide"
      "match:namespace quickshell:osk, order -1"

      # Quickshell: waffle panel family
      "match:namespace quickshell:wallpaperSelector, animation slide top"
      "match:namespace quickshell:wNotificationCenter, no_anim on"
      "match:namespace quickshell:wOnScreenDisplay, no_anim on"
      "match:namespace quickshell:wStartMenu, no_anim on"
      "match:namespace quickshell:wTaskView, ignore_alpha 0"
      "match:namespace quickshell:wTaskView, no_anim on"
    ];
  };
}
