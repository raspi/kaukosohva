#!/bin/bash
set -eu
set -o pipefail

#export GST_DEBUG="GST_TRACER:7"
#export GST_DEBUG_DUMP_DOT_DIR=.
export GST_DEBUG_FILE="trace.log"
export GST_TRACERS="latency(flags=pipeline+element+reported);interlatency"
export GST_DEBUG_COLOR_MODE=off

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
#VIDEO_DEC="nvh264dec"
VIDEO_SINK="autovideosink"
#VIDEO_SINK="location=capture1.jpeg"

gst-launch-1.0 rtpbin name=rtpbin buffer-mode=none drop-on-latency=true latency=$LATENCY max-dropout-time=500 \
     udpsrc caps=$VIDEO_CAPS port=$VRTPPORT address=$SRC multicast-iface=$SRCIF ! rtpbin.recv_rtp_sink_0 \
       rtpbin. ! rtph264depay ! $VIDEO_DEC ! $VIDEO_SINK \
     udpsrc port=$VRTCPPORT address=$SRC multicast-iface=$SRCIF ! rtpbin.recv_rtcp_sink_0 \
       rtpbin.send_rtcp_src_0 ! udpsink port=$VRTCPSRCPORT host=$SRC multicast-iface=$SRCIF sync=false async=false 
