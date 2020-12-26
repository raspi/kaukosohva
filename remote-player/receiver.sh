#!/bin/bash
set -eu
set -o pipefail

LANG=C

SRC=224.0.0.1
SRCIF=wg0

VRTPPORT=8000
VRTCPPORT=8001
VRTCPSRCPORT=5005

# this adjusts the latency in the receiver
LATENCY=0

VIDEO_CAPS="application/x-rtp,media=(string)video,clock-rate=(int)90000,encoding-name=(string)H264"
VIDEO_DEC="avdec_h264"
VIDEO_SINK="autovideosink"

gst-launch-1.0 -v rtpbin name=rtpbin buffer-mode=none drop-on-latency=true latency=$LATENCY \
     udpsrc caps=$VIDEO_CAPS port=$VRTPPORT address=$SRC multicast-iface=$SRCIF ! rtpbin.recv_rtp_sink_0 \
       rtpbin. ! rtph264depay ! $VIDEO_DEC ! $VIDEO_SINK \
     udpsrc port=$VRTCPPORT address=$SRC multicast-iface=$SRCIF ! rtpbin.recv_rtcp_sink_0 \
       rtpbin.send_rtcp_src_0 ! udpsink port=$VRTCPSRCPORT host=$SRC multicast-iface=$SRCIF sync=false async=false 
