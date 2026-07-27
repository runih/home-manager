{
  # Renders the waybar stylesheet for a given palette (see themes.nix).
  mkWaybarStyle = p: ''
    * {
      font-family: "Hack Nerd Font", monospace;
      font-size: 13px;
      min-height: 0;
      border: none;
    }

    window#waybar {
      background-color: transparent;
      color: #${p.fg};
    }

    .modules-left, .modules-right, .modules-center {
      padding: 0 4px;
    }

    #left-island,
    #submap,
    #clock {
      background-color: rgba(${p.bgRgb}, 0.5);
      border-radius: 8px;
      margin: 4px 3px;
      padding: 2px 10px;
    }

    #workspaces {
      background-color: transparent;
      border-radius: 0;
      margin: 0;
      padding: 0;
    }

    #window {
      color: #${p.fg2};
      padding: 0 6px;
    }

    .modules-right {
      background-color: rgba(${p.bgRgb}, 0.5);
      border-radius: 8px;
      margin: 4px 6px;
      padding: 2px 4px;
    }

    #cpu,
    #memory,
    #network,
    #wireplumber,
    #tray,
    #custom-power {
      background-color: transparent;
      border-radius: 0;
      margin: 0;
      padding: 2px 6px;
    }

    #workspaces button {
      padding: 0 4px;
      color: #${p.muted};
      background: transparent;
      border-radius: 6px;
    }

    #workspaces button.active {
      color: #${p.blue};
      background: rgba(${p.blueRgb}, 0.15);
    }

    #workspaces button.urgent {
      color: #${p.red};
    }

    #clock {
      color: #${p.cyan};
      font-weight: bold;
    }

    #custom-power {
      color: #${p.green};
    }

    #custom-power.warning {
      color: #${p.yellow};
    }

    #custom-power.critical {
      color: #${p.red};
      animation: blink 1s linear infinite;
    }

    @keyframes blink {
      0%   { color: #${p.red}; }
      50%  { color: transparent; }
      100% { color: #${p.red}; }
    }

    #network {
      color: #${p.netCyan};
    }

    #cpu {
      color: #${p.purple};
    }

    #memory {
      color: #${p.teal};
    }

    #wireplumber {
      color: #${p.orange};
    }

    #wireplumber.muted {
      color: #${p.muted};
    }

    #tray {
      padding: 2px 6px;
    }

    #custom-tmux {
      background-color: rgba(${p.bgRgb}, 0.5);
      border-radius: 8px;
      color: #${p.green};
      margin: 4px 3px;
      padding: 2px 10px;
    }

    #submap {
      color: #${p.red};
      font-weight: bold;
    }

    tooltip {
      background: rgba(${p.bgRgb}, 0.95);
      border: 1px solid #${p.border};
      border-radius: 8px;
    }
  '';

  # Renders the wofi stylesheet for a given palette (see themes.nix).
  mkWofiStyle = p: ''
    window {
      background-color: rgba(${p.bgRgb}, 0.95);
      border: 1px solid #${p.border};
      border-radius: 8px;
    }

    #input {
      background-color: #${p.bg2};
      color: #${p.fg};
      border: 1px solid #${p.border};
      border-radius: 4px;
      padding: 8px 12px;
      margin: 8px;
      font-size: 14px;
    }

    #input:focus {
      border-color: #${p.blue};
    }

    #scroll {
      margin: 0 8px 8px 8px;
    }

    #inner-box {
      background-color: transparent;
    }

    #outer-box {
      background-color: transparent;
      padding: 4px;
    }

    #entry {
      padding: 6px 10px;
      border-radius: 4px;
      color: #${p.fg2};
    }

    #entry:selected {
      background-color: rgba(${p.blueRgb}, 0.2);
      color: #${p.fg};
    }

    #text {
      font-size: 13px;
    }

    #img {
      margin-right: 8px;
    }
  '';
}
