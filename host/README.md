# Host

Requirements:

* [usbip](http://usbip.sourceforge.net/) for connecting to remote player's gamepad(s), joystick(s) and such
* WireGuard
* `vhci-hcd` kernel module
* Lots of upload bandwidth (depends on remote player count and video encoding used)
  * You also can stream to some outside machine which has more streaming capacity
* Enough CPU and/or GPU power to encode video stream real time
  * NVENC for GPU accelerated streaming with nvidia cards

To decrease latency issues: 

* Use direct wired ethernet connection to your router

First time only (might need reboot):

    # systemctl enable usbip
    # systemctl start usbip

Load kernel module to accept remote USB devices:

    # echo "vhci-hcd" > /etc/modules-load.d/vhci-hcd.conf
    
## Stream a window (game/app)

    $ xwininfo -int
    $ ./sender.sh <WID from xwininfo>

Connect remote player(s) gamepad(s), joystick(s) and such to your machine:

For each remote player:

List shared USB device(s) (here `192.168.123.123` is remote player's IP address):

    $ usbip list --remote 192.168.123.123

Connect remote player's USB device to your machine:

    $ usbip attach --remote 192.168.123.123 --busid 1-1.4

After connecting you can list the USB devices to see they exist:

    $ lsusb
