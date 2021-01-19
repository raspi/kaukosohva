# Host

Requirements:

* [usbip package](https://github.com/torvalds/linux/tree/master/tools/usb/usbip) for connecting to remote player's gamepad(s), joystick(s) and such devices
* [WireGuard](https://www.wireguard.com/) (built into kernel)
* `vhci-hcd` kernel module
* Lots of upload bandwidth (~6-8 Mbps per remote player)
  * You also can stream to some outside machine (proxy) which has more streaming capacity to multiplex the multicast stream
* Enough CPU and/or GPU power to encode video stream real time
  * NVENC for GPU accelerated streaming with nvidia cards

The upload bandwidth needed depends on remote player count, resolution, fps, and how complex the picture is on the screen.

To decrease latency issues: 

* Use direct wired ethernet connection to your router

First time only (might need reboot):

    % sudo systemctl enable usbipd
    % sudo systemctl start usbipd

Load kernel module to accept remote USB devices:

    % sudo modprobe vhci-hcd
    
Or permanently:

    # echo "vhci-hcd" > /etc/modules-load.d/vhci-hcd.conf
    
Connect remote player(s) gamepad(s), joystick(s) and such to your machine:

For each remote player:

List shared USB device(s) (here `192.168.123.123` is remote player's IP address):

    % usbip list --remote 192.168.123.123

Connect remote player's USB device to your machine:

    % sudo usbip attach --remote 192.168.123.123 --busid 1-1.4

After connecting you can list the USB devices to see they exist locally:

    % lsusb

You can use for example `jstest` for testing gamepad inputs.

## Stream a window (game/app)

First, start your game in a window and use some resolution which doesn't require too much bandwidth and all players has at least that resolution available, such as 720p or 1080p.

Find the window ID:    

    % xwininfo -int -children
    
Now click the window you want to stream.

Find the correct window ID number and use it:    
    
    % ./sender.sh <WID from xwininfo>

If the sender doesn't start with the first ID listed by `xwininfo` the application might have spawned a secondary sub-window. So simply try with children's window ID. 

Example:

    % ./sender.sh 73457634
    
## FAQ

* I resized the window and streaming stopped?
  * You must restart the sender if you change the window's size that you are streaming, this is because video encoders are designed for constant resolution
* Remote player sees only black screen or some part of screen is black?
  * There can't be any windows on top of the window that's being streamed, this is because xorg doesn't render what's not seen
