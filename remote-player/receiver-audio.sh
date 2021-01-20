#!/bin/bash
set -eu
set -o pipefail

LANG=C

# change this to send the RTP data and RTCP to another host
SRC=224.0.0.1
SRCIF=wg0

ARTPSINKPORT=8100
ARTCPSINKPORT=8101
ARTCPSRCPORT=5105

LATENCY=0

AUDIO_CAPS="application/x-rtp,media=(string)audio,clock-rate=(int)48000,encoding-name=(string)OPUS"

AUDIO_DEC="rtpopusdepay ! opusdec"
AUDIO_SINK="audioconvert ! audioresample ! autoaudiosink"

gst-launch-1.0 -v rtpbin name=rtpbin buffer-mode=none drop-on-latency=true latency=$LATENCY \
     udpsrc caps=$AUDIO_CAPS port=$ARTPSINKPORT address=$SRC multicast-iface=$SRCIF ! rtpbin.recv_rtp_sink_0 \
       rtpbin. ! $AUDIO_DEC ! $AUDIO_SINK \
     udpsrc port=$ARTCPSRCPORT address=$SRC multicast-iface=$SRCIF ! rtpbin.recv_rtcp_sink_0 \
       rtpbin.send_rtcp_src_0 ! udpsink port=$ARTCPSINKPORT host=$SRC multicast-iface=$SRCIF sync=false async=false 

