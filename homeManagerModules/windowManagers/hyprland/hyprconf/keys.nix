{lib, ...}: {
  wayland.windowManager.hyprland.settings = {

	input = {
		touchpad = {
			natural_scroll = lib.mkForce true;
			scroll_factor = 0.45;
			drag_3fg = 1; # 3 fingers drag to move windows + super
		};
		# kb_options = caps:swapescape;
	};

	# 4 finger swipe to change between workspaces
	gesture = [
		"4, horizontal, scale:1.5, workspace"
	];

	bind = [
          # Keybindings
          "$mainMod, return, exec, $terminal"
          "$mainMod, B, exec, firefox"
          "$mainMod, Q, killactive,"
          "$mainMod, M, exit,"
          "$mainMod, E, exec, $fileManager"
          "$mainMod, V, togglefloating,"
          "$mainMod, R, exec, $menu"
          "$mainMod, P, pseudo,"
          "$mainMod, J, togglesplit,"
          "$mainMod, F, fullscreen, 0"
          
          # Move focus
          "$mainMod, l, movefocus, l"
          "$mainMod, h, movefocus, r"
          "$mainMod, k, movefocus, u"
          "$mainMod, j, movefocus, d"
          
          # Switch workspaces
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"
          
          # Move windows to workspaces
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"
          
          # Special workspace
          "$mainMod, S, togglespecialworkspace, magic"
          "$mainMod SHIFT, S, movetoworkspace, special:magic"
          
	  ];

	  bindm = [
          # Move/resize windows
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
	  ];
          
	  bindel = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"

          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

          ", XF86MonBrightnessUp, exec, brightnessctl s 5%+"
          ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
	  ];
	};
}
