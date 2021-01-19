# Remote player

Requirements:

* [usbip package](http://usbip.sourceforge.net/) for sharing gamepad(s), joystick(s) and such to host machine
* [GStreamer](https://gstreamer.freedesktop.org/)
* [WireGuard](https://www.wireguard.com/) (built into kernel)

To decrease latency issues:

* Use direct wired ethernet connection to your router
* Connect gamepad(s) via USB cable directly

First time only (might need reboot):

    % sudo systemctl enable usbipd
    % sudo systemctl start usbipd

## Share 

First connect to the host or proxy machine via WireGuard VPN.

Share USB gamepad(s), joystick(s) and such to host machine:

List USB devices:

    % usbip list --local

Share USB device:

    % usbip bind --busid 1-1.4
    
Now tell host your VPN IP address so that they can connect your shared device(s) to the host machine. Please note that `usbip` uses TCP port 3240 which needs to pass possible firewall(s).
   
Connect to host multicast stream:

    % ./receiver.sh

You should now see the shared game from the host in few seconds and play it remotely.
