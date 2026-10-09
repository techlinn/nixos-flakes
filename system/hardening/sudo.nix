{ ... }:
{
  # Rust rewrite of sudo. Only wheel can sudo, must enter password.
  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = true;
  };
}
