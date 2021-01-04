# Remote player

Requirements:

* [usbip](http://usbip.sourceforge.net/) for sharing gamepad(s), joystick(s) and such to host machine
* gstreamer
* WireGuard

To decrease latency issues:

* Use direct wired ethernet connection to your router
* Connect gamepad(s) via USB cable directly

## Share USB gamepad(s), joystick(s) and such to host machine

First time only (might need reboot):

    # systemctl enable usbipd
    # systemctl start usbipd

List USB devices:

    $ usbip list --local

Share USB device:

    $ usbip bind --busid 1-1.4
    
Now tell host your IP address. Please note that `usbip` uses TCP port 3240 which needs to pass possible firewall(s).
    
Connect to host stream:

    $ ./receiver.sh

You now should see the game and play it remotely.
 
