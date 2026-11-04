{...}: {
  programs.kitty = {
    enable = true;

    settings = {
      font_family = "JetBrains Mono Nerd Font";
      font_size = "11.0";

      # Cursor
      cursor_shape = "beam";
      cursor_trail = 1;

      # Padding
      window_margin_width = "21.75";

      # No close confirmation
      confirm_os_window_close = 0;

      # Shell
      shell = "fish";
    };

    keybindings = {
      "ctrl+c" = "copy_or_interrupt";
      "page_up" = "scroll_page_up";
      "page_down" = "scroll_page_down";
      "ctrl+plus" = "change_font_size all +1";
      "ctrl+equal" = "change_font_size all +1";
      "ctrl+minus" = "change_font_size all -1";
      "ctrl+underscore" = "change_font_size all -1";
      "ctrl+0" = "change_font_size all 0";
    };
  };
}
