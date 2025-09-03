# Generated via dconf2nix: https://github.com/nix-commmunity/dconf2nix
{lib, ...}:
with lib.hm.gvariant; {
  dconf.settings = {
    "ca/desrt/dconf-editor" = {
      saved-pathbar-path = "/org/gnome/shell/extensions/dash-to-panel/";
      saved-view = "/org/gnome/shell/extensions/dash-to-panel/";
      window-height = 500;
      window-is-maximized = false;
      window-width = 540;
    };

    "org/gnome/Console" = {
      last-window-size = mkTuple [652 480];
    };

    "org/gnome/GWeather4" = {
      temperature-unit = "centigrade";
    };

    "org/gnome/Geary" = {
      ask-open-attachment = true;
      compose-as-html = true;
      formatting-toolbar-visible = false;
      images-trusted-domains = [
        "linkedin.com"
        "amazon.de"
        "hoefer-shop.de"
        "magentatv.telekom.de"
        "telekom.de"
        "doctolib.de"
        "steampowered.com"
        "indeed.com"
        "mail.clark.de"
        "battle.net"
        "ebay.com"
        "my.tado.com"
        "immobilienscout24.de"
        "e-mails.microsoft.com"
        "info.ebay.de"
        "paypal.de"
        "email.openai.com"
        "github.com"
        "freenet-mobilfunk.de"
        "news.traderepublic.com"
        "spotify.com"
        "hetzner.com"
        "google.com"
        "accounts.google.com"
        "firefox.com"
        "mail.instagram.com"
        "mail.adobe.com"
        "kovenuk.com"
        "privacy.faceit.com"
      ];
      migrated-config = true;
      run-in-background = true;
      window-maximize = true;
    };

    "org/gnome/Snapshot" = {
      is-maximized = false;
    };

    "org/gnome/Weather" = {
      locations = [(mkVariant (mkTuple [(mkUint32 2) (mkVariant (mkTuple ["Frankfurt" "EDDF" false [(mkTuple [(mkDouble "0.8735372906231619") (mkDouble "0.15009831567151233")])] (mkArray "(dd)" [])]))])) (mkVariant (mkTuple [(mkUint32 2) (mkVariant (mkTuple ["Frankfurt" "EDDF" true [(mkTuple [(mkDouble "0.8735372906231619") (mkDouble "0.15009831567151233")])] [(mkTuple [(mkDouble "0.874700849275589") (mkDouble "0.15155275089707676")])]]))]))];
      window-height = 512;
      window-maximized = false;
      window-width = 992;
    };

    "org/gnome/calendar" = {
      active-view = "month";
      window-maximized = true;
    };

    "org/gnome/clocks" = {
      world-clocks = [
        [
          (mkDictionaryEntry ["location" (mkVariant (mkTuple [(mkUint32 2) (mkVariant (mkTuple ["Los Angeles" "KCQT" true [(mkTuple [(mkDouble "0.5937028397045019") (mkDouble "-2.064433611082862")])] [(mkTuple [(mkDouble "0.5943236009595587") (mkDouble "-2.063741622941031")])]]))]))])
        ]
        [
          (mkDictionaryEntry ["location" (mkVariant (mkTuple [(mkUint32 2) (mkVariant (mkTuple ["Chicago" "KMDW" true [(mkTuple [(mkDouble "0.7292712893531614") (mkDouble "-1.5316185371029443")])] [(mkTuple [(mkDouble "0.7304208679182801") (mkDouble "-1.529781996944241")])]]))]))])
        ]
        [
          (mkDictionaryEntry ["location" (mkVariant (mkTuple [(mkUint32 2) (mkVariant (mkTuple ["New York" "KNYC" true [(mkTuple [(mkDouble "0.7118034407872564") (mkDouble "-1.2909618758762367")])] [(mkTuple [(mkDouble "0.7105980465926592") (mkDouble "-1.2916478949920254")])]]))]))])
        ]
        [
          (mkDictionaryEntry ["location" (mkVariant (mkTuple [(mkUint32 2) (mkVariant (mkTuple ["London" "EGWU" true [(mkTuple [(mkDouble "0.8997172294030767") (mkDouble "-7.272211034407213e-3")])] [(mkTuple [(mkDouble "0.8988445647770796") (mkDouble "-2.0362232784242244e-3")])]]))]))])
        ]
        [
          (mkDictionaryEntry ["location" (mkVariant (mkTuple [(mkUint32 2) (mkVariant (mkTuple ["Moscow" "UUWW" true [(mkTuple [(mkDouble "0.9712757287348442") (mkDouble "0.6504260403943176")])] [(mkTuple [(mkDouble "0.9730598392028181") (mkDouble "0.6565153021683081")])]]))]))])
        ]
      ];
    };

    "org/gnome/desktop/default-applications/terminal" = {
      exec = "ghostty";
    };

    "org/gnome/clocks/state/window" = {
      maximized = false;
      panel-id = "world";
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///home/konrad/Pictures/Wallpapers/Desktop/blobs-l.svg";
      picture-uri-dark = "file:///home/konrad/Pictures/Wallpapers/Desktop/blobs-d.svg";
      primary-color = "#241f31";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/datetime" = {
      automatic-timezone = false;
    };

    "org/gnome/desktop/input-sources" = {
      current = mkUint32 0;
      mru-sources = [(mkTuple ["xkb" "us"])];
      sources = [(mkTuple ["xkb" "de+nodeadkeys"])];
      xkb-options = ["terminate:ctrl_alt_bksp"];
    };

    "org/gnome/desktop/interface" = {
      clock-show-seconds = false;
      clock-show-weekday = false;
      enable-hot-corners = false;
      color-scheme = "prefer-dark";
      enable-animations = true;
      font-antialiasing = "grayscale";
      font-hinting = "slight";
      gtk-theme = "adw-gtk3-dark";
      toolkit-accessibility = false;
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      click-method = "areas";
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/privacy" = {
      old-files-age = mkUint32 30;
      recent-files-max-age = -1;
      report-technical-problems = true;
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///home/konrad/Pictures/Wallpapers/Desktop/blobs-d.svg";
      primary-color = "#241f31";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 900;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":close";
    };

    "org/gnome/evince/default" = {
      continuous = true;
      dual-page = false;
      dual-page-odd-left = true;
      enable-spellchecking = true;
      fullscreen = false;
      inverted-colors = false;
      show-sidebar = true;
      sidebar-page = "thumbnails";
      sidebar-size = 148;
      sizing-mode = "free";
      window-ratio = mkTuple [(mkDouble "1.0081699346405228") (mkDouble "0.7138445458000761")];
      zoom = mkDouble "0.5";
    };

    "org/gnome/evolution-data-server" = {
      migrated = true;
    };

    "org/gnome/evolution-data-server/calendar" = {
      reminders-past = [];
    };

    "org/gnome/gnome-system-monitor" = {
      current-tab = "processes";
      network-total-in-bits = false;
      show-dependencies = false;
      show-whose-processes = "user";
    };

    "org/gnome/login-screen" = {
      enable-fingerprint-authentication = true;
      enable-password-authentication = true;
      enable-smartcard-authentication = false;
    };

    "org/gnome/mutter" = {
      edge-tiling = true;
      center-new-windows = true;
      dynamic-workspaces = true;
      overlay-key = "Super_L";
      workspaces-only-on-primary = false;
      check-alive-timeout = mkUint32 15000;
    };

    "org/gnome/nautilus/compression" = {
      default-compression-format = "zip";
    };

    "org/gnome/nautilus/icon-view" = {
      captions = ["none" "none" "none"];
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
      show-create-link = true;
    };

    "org/gnome/nautilus/window-state" = {
      initial-size = mkTuple [1398 802];
      maximized = false;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-timeout = 7200;
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/shell/app-switcher" = {
      current-workspace-only = false;
    };

    "org/gnome/desktop/notifications/application/com-spotify-client" = {
      enable = false;
      enable-sound-alerts = true;
    };

    "org/gnome/desktop/notifications/application/spotify" = {
      enable = false;
      enable-sound-alerts = true;
    };

    "org/gnome/shell/extensions/blur-my-shell" = {
      settings-version = 2;
    };

    "org/gnome/shell/extensions/blur-my-shell/coverflow-alt-tab" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      pipeline = "pipeline_default_rounded";
    };

    "org/gnome/shell/extensions/blur-my-shell/lockscreen" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/shell/extensions/blur-my-shell/overview" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      blur = false;
    };

    "org/gnome/shell/extensions/blur-my-shell/screenshot" = {
      pipeline = "pipeline_default";
    };

    "org/gnome/shell/extensions/dash-to-panel" = {
      animate-appicon-hover = true;
      animate-appicon-hover-animation-convexity = [
        (mkDictionaryEntry ["RIPPLE" (mkDouble "2.0")])
        (mkDictionaryEntry ["PLANK" (mkDouble "1.0")])
        (mkDictionaryEntry ["SIMPLE" (mkDouble "0.0")])
      ];
      animate-appicon-hover-animation-extent = [
        (mkDictionaryEntry ["RIPPLE" 4])
        (mkDictionaryEntry ["PLANK" 4])
        (mkDictionaryEntry ["SIMPLE" 1])
      ];
      animate-appicon-hover-animation-rotation = [
        (mkDictionaryEntry ["SIMPLE" 0])
        (mkDictionaryEntry ["RIPPLE" 10])
        (mkDictionaryEntry ["PLANK" 0])
      ];
      animate-appicon-hover-animation-travel = [
        (mkDictionaryEntry ["SIMPLE" (mkDouble "0.15")])
        (mkDictionaryEntry ["RIPPLE" (mkDouble "0.4")])
        (mkDictionaryEntry ["PLANK" (mkDouble "0.0")])
      ];
      animate-appicon-hover-animation-type = "SIMPLE";
      appicon-margin = 8;
      appicon-padding = 4;
      available-monitors = [1 0 2];
      dot-position = "BOTTOM";
      dot-style-focused = "SQUARES";
      dot-style-unfocused = "DOTS";
      hotkeys-overlay-combo = "TEMPORARILY";
      leftbox-padding = -1;
      panel-anchors = ''
        {"AUS-LBLMQS007558":"MIDDLE","LEN-URHDTW17":"MIDDLE","LEN-URHDTW1X":"MIDDLE","SHP-0x00000000":"MIDDLE"}
      '';
      panel-element-positions = ''
        {"0":[{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":true,"position":"stackedTL"},{"element":"rightBox","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"centerMonitor"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}],
        "1":[{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":true,"position":"stackedTL"},{"element":"rightBox","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"centerMonitor"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}],
        "2":[{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":true,"position":"stackedTL"},{"element":"rightBox","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"centerMonitor"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}]}
      '';
      panel-element-positions-monitors-sync = false;
      panel-lengths = ''
        {"AUS-LBLMQS007558":100,"LEN-URHDTW17":100,"LEN-URHDTW1X":100,"SHP-0x00000000":100}
      '';
      panel-sizes = ''
        {"AUS-LBLMQS007558":48,"LEN-URHDTW17":40,"LEN-URHDTW1X":40,"SHP-0x00000000":40}
      '';
      primary-monitor = "AUS-LBLMQS007558";
      status-icon-padding = -1;
      trans-panel-opacity = mkDouble "0.7";
      trans-use-custom-bg = false;
      trans-use-custom-gradient = false;
      trans-use-custom-opacity = true;
      tray-padding = -1;
      window-preview-title-position = "TOP";
    };

    "org/gnome/shell/extensions/phi" = {
      hideui = false;
      interval = mkUint32 10;
      url1 = "https://pihole.local.yakweide.de/admin/api.php";
    };

    "org/gnome/shell/extensions/gtk4-ding" = {
      add-volumes-opposite = false;
      dark-text-in-labels = false;
      icon-size = "standard";
      show-drop-place = true;
      show-home = false;
      show-link-emblem = false;
      show-trash = false;
      show-volumes = false;
    };

    "org/gnome/shell/extensions/sp-tray" = {
      album-max-length = 50;
      artist-max-length = 50;
      title-max-length = 50;
      display-mode = 0;
      hidden-when-inactive = true;
      hidden-when-paused = false;
      logo-position = 0;
      position = 2;
      metadata-when-paused = true;
      paused = "";
    };

    "org/gnome/shell/weather" = {
      automatic-location = true;
      locations = [(mkVariant (mkTuple [(mkUint32 2) (mkVariant (mkTuple ["Frankfurt" "EDDF" false [(mkTuple [(mkDouble "0.8735372906231619") (mkDouble "0.15009831567151233")])] (mkArray "(dd)" [])]))])) (mkVariant (mkTuple [(mkUint32 2) (mkVariant (mkTuple ["Frankfurt" "EDDF" true [(mkTuple [(mkDouble "0.8735372906231619") (mkDouble "0.15009831567151233")])] [(mkTuple [(mkDouble "0.874700849275589") (mkDouble "0.15155275089707676")])]]))]))];
    };

    "org/gnome/shell/world-clocks" = {
      locations = [(mkVariant (mkTuple [(mkUint32 2) (mkVariant (mkTuple ["Los Angeles" "KCQT" true [(mkTuple [(mkDouble "0.5937028397045019") (mkDouble "-2.064433611082862")])] [(mkTuple [(mkDouble "0.5943236009595587") (mkDouble "-2.063741622941031")])]]))])) (mkVariant (mkTuple [(mkUint32 2) (mkVariant (mkTuple ["Chicago" "KMDW" true [(mkTuple [(mkDouble "0.7292712893531614") (mkDouble "-1.5316185371029443")])] [(mkTuple [(mkDouble "0.7304208679182801") (mkDouble "-1.529781996944241")])]]))])) (mkVariant (mkTuple [(mkUint32 2) (mkVariant (mkTuple ["New York" "KNYC" true [(mkTuple [(mkDouble "0.7118034407872564") (mkDouble "-1.2909618758762367")])] [(mkTuple [(mkDouble "0.7105980465926592") (mkDouble "-1.2916478949920254")])]]))])) (mkVariant (mkTuple [(mkUint32 2) (mkVariant (mkTuple ["London" "EGWU" true [(mkTuple [(mkDouble "0.8997172294030767") (mkDouble "-7.272211034407213e-3")])] [(mkTuple [(mkDouble "0.8988445647770796") (mkDouble "-2.0362232784242244e-3")])]]))])) (mkVariant (mkTuple [(mkUint32 2) (mkVariant (mkTuple ["Moscow" "UUWW" true [(mkTuple [(mkDouble "0.9712757287348442") (mkDouble "0.6504260403943176")])] [(mkTuple [(mkDouble "0.9730598392028181") (mkDouble "0.6565153021683081")])]]))]))];
    };

    "org/gnome/simple-scan" = {
      save-directory = "file:///home/konrad/Documents/Scan";
      save-format = "application/pdf";
    };

    "org/gnome/system/location" = {
      enabled = false;
    };

    "org/gnome/terminal/legacy" = {
      default-show-menubar = false;
    };

    "org/gnome/terminal/legacy/keybindings" = {
      paste = "<Primary>v";
    };

    "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
      background-transparency-percent = 15;
      default-size-columns = 80;
      default-size-rows = 23;
      font = "JetBrainsMono Nerd Font Medium 12";
      use-system-font = false;
      use-transparent-background = true;
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

    "org/gtk/gtk4/settings/color-chooser" = {
      custom-colors = [(mkTuple [(mkDouble "0.75") (mkDouble "0.25") (mkDouble "0.25") (mkDouble "1.0")]) (mkTuple [(mkDouble "0.1411764770746231") (mkDouble "0.1411764770746231") (mkDouble "0.1411764770746231") (mkDouble "0.8533333539962769")]) (mkTuple [(mkDouble "0.1411764770746231") (mkDouble "0.1411764770746231") (mkDouble "0.1411764770746231") (mkDouble "0.9133333563804626")]) (mkTuple [(mkDouble "0.1882352977991104") (mkDouble "0.1882352977991104") (mkDouble "0.1921568661928177") (mkDouble "0.9800000190734863")])];
      selected-color = mkTuple [true (mkDouble "0.2078431397676468") (mkDouble "0.5176470875740051") (mkDouble "0.8941176533699036") (mkDouble "1.0")];
    };

    "org/gtk/gtk4/settings/emoji-chooser" = {
      recent-emoji = [(mkTuple [(mkTuple [[(mkUint32 128516)] "grinning face with smiling eyes" ["eye" "face" "mouth" "open" "smile"] (mkUint32 0)]) (mkUint32 0)])];
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 140;
      sort-column = "name";
      sort-directories-first = true;
      sort-order = "ascending";
      type-format = "category";
      view-type = "list";
      window-size = mkTuple [859 372];
    };

    "org/gtk/settings/file-chooser" = {
      show-volumes = false;
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 165;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "descending";
      type-format = "category";
      window-position = mkTuple [35 32];
      window-size = mkTuple [1203 902];
    };

    "system/locale" = {
      region = "de_DE.UTF-8";
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = ["ebb4a864-8e0d-4efb-9cf3-396e9b66c109" "5d3de8f3-46d0-44d0-994e-34dcba42ba17" "22213c86-bf18-4d86-a47d-050ddec90177" "b7f1bd08-58dc-44cd-9a8b-439e07678f8f"];
    };

    "org/gnome/desktop/app-folders/folders/22213c86-bf18-4d86-a47d-050ddec90177" = {
      apps = ["rust-rover.desktop" "clion.desktop" "rider.desktop" "idea-community.desktop" "code.desktop" "pycharm-community.desktop" "org.qt-project.qtcreator.desktop" "org.gnome.Builder.desktop" "arduino-ide.desktop"];
      name = "Programming";
    };

    "org/gnome/desktop/app-folders/folders/5d3de8f3-46d0-44d0-994e-34dcba42ba17" = {
      apps = ["org.gnome.SystemMonitor.desktop" "org.gnome.clocks.desktop" "org.gnome.Totem.desktop" "org.gnome.Music.desktop" "org.wireshark.Wireshark.desktop" "com.github.flxzt.rnote.desktop" "org.gnome.Snapshot.desktop" "simple-scan.desktop" "org.gnome.Calculator.desktop" "org.gnome.TextEditor.desktop" "org.gnome.Maps.desktop" "com.google.Chrome.desktop" "org.filezillaproject.Filezilla.desktop" "com.bitwarden.desktop.desktop" "org.gnome.Boxes.desktop" "com.github.marhkb.Pods.desktop" "org.cvfosammmm.Setzer.desktop" "org.gnome.Software.desktop" "org.torproject.torbrowser-launcher.desktop" "dev.vencord.Vesktop.desktop" "org.pulseaudio.pavucontrol.desktop" "gimp.desktop" "webcord.desktop" "com.cassidyjames.butler.desktop" "google-chrome.desktop" "org.gnome.Terminal.desktop" "org.gnome.Showtime.desktop" "org.gnome.Decibels.desktop"];
      name = "Applications";
      translate = false;
    };

    "org/gnome/desktop/app-folders/folders/b7f1bd08-58dc-44cd-9a8b-439e07678f8f" = {
      apps = ["minecraft-launcher.desktop" "steam.desktop" "Anno 1800.desktop" "Counter-Strike 2.desktop" "Crusader Kings III.desktop" "Cyberpunk 2077.desktop" "Europa Universalis IV.desktop" "Factorio.desktop" "Fall Guys.desktop" "Farthest Frontier.desktop" "Hearts of Iron IV.desktop" "Hogwarts Legacy.desktop" "Horizon Forbidden West Complete Edition.desktop" "Marvels Spider-Man Remastered.desktop" "Palworld.desktop" "Pummel Party.desktop" "Rise of the Tomb Raider.desktop" "Rocket League.desktop" "Sid Meier's Civilization VI.desktop" "Stardew Valley.desktop" "Stellaris.desktop" "Total War PHARAOH.desktop" "Victoria 3.desktop" "org.prismlauncher.PrismLauncher.desktop" "Diablo IV.desktop" "DEATH STRANDING DIRECTOR'S CUT.desktop"];
      name = "Games";
    };

    "org/gnome/desktop/app-folders/folders/ebb4a864-8e0d-4efb-9cf3-396e9b66c109" = {
      apps = ["org.gnome.Extensions.desktop" "polychromatic.desktop" "com.mattjakeman.ExtensionManager.desktop" "OpenRGB.desktop" "org.gnome.Weather.desktop" "org.gnome.Loupe.desktop" "org.gnome.DiskUtility.desktop" "org.gnome.baobab.desktop" "org.gnome.Evince.desktop" "org.gnome.Contacts.desktop" "com.github.wwmm.easyeffects.desktop" "org.gnome.Settings.desktop" "com.github.tchx84.Flatseal.desktop" "io.github.Foldex.AdwSteamGtk.desktop" "org.gnome.tweaks.desktop" "timeshift-gtk.desktop" "windows11-qemu.desktop" "windows10-qemu.desktop" "org.fedoraproject.MediaWriter.desktop" "org.raspberrypi.rpi-imager.desktop" "postman.desktop" "vlc.desktop" "com.protonvpn.www.desktop" "nvidia-settings.desktop" "chromium-browser.desktop" "intune-portal.desktop" "net.nokyan.Resources.desktop" "com.github.Matoking.protontricks.desktop"];
      name = "Utilities";
      translate = false;
    };

    "org/gnome/shell" = {
      app-picker-layout = [
        [
          (mkDictionaryEntry [
            "5d3de8f3-46d0-44d0-994e-34dcba42ba17"
            (mkVariant [
              (mkDictionaryEntry ["position" (mkVariant 0)])
            ])
          ])
          (mkDictionaryEntry [
            "22213c86-bf18-4d86-a47d-050ddec90177"
            (mkVariant [
              (mkDictionaryEntry ["position" (mkVariant 1)])
            ])
          ])
          (mkDictionaryEntry [
            "ebb4a864-8e0d-4efb-9cf3-396e9b66c109"
            (mkVariant [
              (mkDictionaryEntry ["position" (mkVariant 2)])
            ])
          ])
          (mkDictionaryEntry [
            "b7f1bd08-58dc-44cd-9a8b-439e07678f8f"
            (mkVariant [
              (mkDictionaryEntry ["position" (mkVariant 3)])
            ])
          ])
        ]
      ];
      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "sp-tray@sp-tray.esenliyim.github.com"
        "phi@ziyagenc.github.com"
        "gtk4-ding@smedius.gitlab.com"
        "dash-to-panel@jderose9.github.com"
        "blur-my-shell@aunetx"
        "appindicatorsupport@rgcjonas.gmail.com"
        "app-hider@lynith.dev"
      ];
      favorite-apps = ["org.gnome.Nautilus.desktop" "firefox.desktop" "com.discordapp.Discord.desktop" "spotify.desktop" "org.gnome.Geary.desktop" "org.gnome.Calendar.desktop" "com.mitchellh.ghostty.desktop"];
    };
    # org.mozilla.firefox.desktop

    "org/gnome/shell/extensions/app-hider" = {
      hidden-apps = ["org.gnome.Characters.desktop" "cups.desktop" "org.gnome.font-viewer.desktop" "nvim.desktop" "org.gnome.FileRoller.desktop" "org.gnome.Logs.desktop" "xterm.desktop" "org.gnome.Console.desktop" "org.gnome.seahorse.Application.desktop" "org.gnome.Connections.desktop" "nixos-manual.desktop" "org.torproject.torbrowser-launcher.settings.desktop" "btop.desktop" "julia.desktop" "org.gnome.Console.desktop" "Steam Linux Runtime 3.0 (sniper).desktop" "Proton EasyAntiCheat Runtime.desktop" "Proton Experimental.desktop" "remote-viewer.desktop" "virt-manager.desktop" "Steam Linux Runtime 1.0 (scout).desktop" "Steam Linux Runtime 2.0 (soldier).desktop" "com.desktop.ding.desktop" "syncthing-ui.desktop"];
      hidden-search-apps = ["org.gnome.Characters.desktop" "cups.desktop" "org.gnome.font-viewer.desktop" "nvim.desktop" "org.gnome.FileRoller.desktop" "org.gnome.Logs.desktop" "xterm.desktop" "org.gnome.Connections.desktop" "nixos-manual.desktop" "org.torproject.torbrowser-launcher.settings.desktop" "btop.desktop" "julia.desktop" "org.gnome.Console.desktop" "org.gnome.seahorse.Application.desktop" "Steam Linux Runtime 3.0 (sniper).desktop" "Proton EasyAntiCheat Runtime.desktop" "Proton Experimental.desktop" "remote-viewer.desktop" "virt-manager.desktop" "Steam Linux Runtime 1.0 (scout).desktop" "Steam Linux Runtime 2.0 (soldier).desktop" "com.desktop.ding.desktop"];
    };
  };
}
