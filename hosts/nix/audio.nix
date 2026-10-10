# Per-host audio: pin default input/output so apps don't grab the wrong mic.
{ ... }:
{
  # Always use the Logitech G522 headset, never the webcam's microphone.
  #
  # Both microphones used to rank exactly the same (priority 2100), so which one
  # was the default was decided by a tie and could flip, for example when the
  # wireless headset went to sleep and woke up. Discord also opens a stream for
  # every microphone it can see, including the webcam's.
  #
  # The names below are this machine's; list yours with `wpctl status` and
  # `pw-dump | grep device.name`. The rules apply at the next WirePlumber start
  # (log out and in, or `systemctl --user restart wireplumber`).
  services.pipewire.wireplumber.extraConfig."51-nix-audio" = {
    "monitor.alsa.rules" = [
      {
        # The webcam's sound card is switched off, so it can never be picked.
        matches = [ { "device.name" = "alsa_card.usb-Novatek_Trust_Webcam-02"; } ];
        actions."update-props"."device.disabled" = true;
      }
      {
        # The headset wins whenever it is connected.
        matches = [
          { "node.name" = "~alsa_input.usb-Logitech_G522_LIGHTSPEED.*"; }
          { "node.name" = "~alsa_output.usb-Logitech_G522_LIGHTSPEED.*"; }
        ];
        actions."update-props" = {
          "priority.session" = 3000;
          "priority.driver" = 3000;
        };
      }
    ];
  };
}
