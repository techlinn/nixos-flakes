# Sets up Claude Code from the files in ~/Flakes/claude by itself: its skills,
# its MCP servers and the npm programs they need (see claude/README.md).
#
# It runs at every login, and again whenever Claude Code's own install changes
# (a first install, or an update), so a reinstalled machine ends up with the
# same setup without a command. Everything it does is skipped when already done.
{ ... }:
{
  systemd.user.services.claude-sync = {
    Unit.Description = "Claude Code skills, MCP servers and npm programs from ~/Flakes/claude";
    Service = {
      Type = "oneshot";
      ExecStart = "%h/.scripts/claude-sync auto";
      TimeoutStartSec = 900;
      # Exit 75 means the network was missing: try again in a few minutes.
      Restart = "on-failure";
      RestartSec = 300;
    };
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.paths.claude-sync = {
    Unit.Description = "Run claude-sync when Claude Code is installed or updated";
    Path.PathChanged = "%h/.local/bin/claude";
    Install.WantedBy = [ "default.target" ];
  };
}
