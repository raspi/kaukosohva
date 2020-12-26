#!/bin/bash
set -eu
set -o pipefail

LANG=C

DEST=224.0.0.1
DESTIF=wg0

VRTPPORT=8000
VRTCPPORT=8001
VRTCPSRCPORT=5005

# this adjusts the latency in the receiver
LATENCY=0

VIDEO_CAPS="application/x-rtp,media=(string)video,clock-rate=(int)90000,encoding-name=(string)H264"
VIDEO_DEC="avdec_h264"
VIDEO_SINK="autovideosink"

gst-launch-1.0 -v rtpbin name=rtpbin buffer-mode=none drop-on-latency=true latency=$LATENCY \
     udpsrc caps=$VIDEO_CAPS port=$VRTPPORT address=$DEST multicast-iface=$DESTIF ! rtpbin.recv_rtp_sink_0 \
       rtpbin. ! rtph264depay ! $VIDEO_DEC ! $VIDEO_SINK \
     udpsrc port=$VRTCPPORT address=$DEST multicast-iface=$DESTIF ! rtpbin.recv_rtcp_sink_0 \
       rtpbin.send_rtcp_src_0 ! udpsink port=$VRTCPSRCPORT host=$DEST multicast-iface=$DESTIF sync=false async=false 
