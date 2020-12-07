# kaukosohva

Play games remotely with Linux.

## Current state 

This is proof of concept for technical users. Security and latency issues are everywhere. Can be used to play turn-based or other non-time-critical games.

## Main problems TODO

* Security
* Lower the latency for streaming
  * Streaming with `ffmpeg` from the host is the biggest latency issue
    * Currently latency is about 0.5 seconds LOCALLY
    * Get rid of all streaming buffer(s)

## Optional requirements for both host and remote player(s)

* WireGuard or other VPN software for increased security

## Host

Requirements:

* [usbip](http://usbip.sourceforge.net/) for connecting to remote player's gamepad(s), joystick(s) and such
* `vhci-hcd` kernel module
* [ffmpeg](https://ffmpeg.org/) for streaming display to RTP server
* RTP server which works as multiplexer for streaming the video to remote player(s)
* Lots of upload bandwidth (depends on remote player count and video encoding used)
  * You also can stream to some outside machine which has more streaming capacity
* Enough CPU and/or GPU power to encode video stream real time

First time only (might need reboot):

    # systemctl enable usbip
    # systemctl start usbip

### Sharing screen

Start your X normally.

#### Run application in a virtual display

Requirements:

* [Xephyr](https://freedesktop.org/wiki/Software/Xephyr/) for creating virtual display

Generate a new virtual display (`:99` in this case):

    $ Xephyr -br -ac -reset -screen 1280x720 :99

Run some program in the virtual display (`:99` in this case):

    $ DISPLAY=:99.0 some game

### Stream display

Stream the display (`:99` in this case) with `ffmpeg`:

    $ ffmpeg -hide_banner -f x11grab -i ":99" -c:v libx264rgb -crf 0 -preset ultrafast -tune zerolatency rtp://192.168.123.2:5555/live

Connect remote player(s) gamepad(s), joystick(s) and such to your machine:

Load kernel module to accept remote USB devices:

    # modprobe vhci-hcd

For each remote player:

List shared USB device(s) (here `192.168.123.123` is remote player's IP address):

    $ usbip list --remote 192.168.123.123

Connect remote player's USB device to your machine:

    $ usbip attach --remote 192.168.123.123 --busid 1-1.4

After connecting you can list the USB devices to see they exist:

    $ lsusb

## Remote player

Requirements:

* [usbip](http://usbip.sourceforge.net/) for sharing gamepad(s), joystick(s) and such to host machine
* Any stream viewer (NOTE: disable all buffering to decrease latency)
  * ffplay
  * mpv
  * VLC

To lower latency issues: 
* Use direct wired ethernet connection to your router
* Connect gamepad(s) via USB cable directly

### Share USB gamepad(s), joystick(s) and such to host machine

First time only (might need reboot):

    # systemctl enable usbip
    # systemctl start usbip

List USB devices:

    $ usbip list --local

Share USB device:

    $ usbip bind --busid 1-1.4
    
Now tell host your IP address. Please note that `usbip` uses TCP port 3240 which needs to pass possible firewall(s).
    
Connect to host stream:

    $ ffplay -hide_banner -fflags nobuffer rtp://192.168.123.2

You now should see the game and play it remotely.
