#!/bin/bash
set -eu
set -o pipefail

LANG=C

WID=$1

WIDTH=1280
HEIGHT=720

xdotool windowsize --sync $WID $WIDTH $HEIGHT

# change this to send the RTP data and RTCP to another host
DEST=224.0.0.1
DESTIF=wg0
VRTPSINKPORT=8000
VRTCPSINKPORT=8001
VRTCPSRCPORT=5005

VELEM="ximagesrc use-damage=false xid=$WID"
VCAPS="video/x-raw,width=$WIDTH,height=$HEIGHT"
VSOURCE="$VELEM ! queue ! videorate max-rate=60 ! videoconvert ! $VCAPS"
VENC="nvh264enc zerolatency=true ! video/x-h264,stream-format=byte-stream ! rtph264pay config-interval=1 pt=96 aggregate-mode=zero-latency"

VRTPSINK="udpsink port=$VRTPSINKPORT host=$DEST multicast-iface=$DESTIF name=vrtpsink"
VRTCPSINK="udpsink port=$VRTCPSINKPORT host=$DEST multicast-iface=$DESTIF sync=false async=false name=vrtcpsink"
VRTCPSRC="udpsrc port=$VRTCPSRCPORT address=$DEST multicast-iface=$DESTIF name=vrtpsrc"

gst-launch-1.0 -v -e rtpbin name=rtpbin buffer-mode=none latency=0 drop-on-latency=true \
    $VSOURCE ! $VENC ! rtpbin.send_rtp_sink_0 \
        rtpbin.send_rtp_src_0 ! $VRTPSINK     \
        rtpbin.send_rtcp_src_0 ! $VRTCPSINK   \
      $VRTCPSRC ! rtpbin.recv_rtcp_sink_0     
