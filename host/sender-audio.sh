#!/bin/bash
set -eu
set -o pipefail

LANG=C

# change this to send the RTP data and RTCP to another host
DEST=224.0.0.1
DESTIF=wg0

ARTPSINKPORT=8100
ARTCPSINKPORT=8101
ARTCPSRCPORT=5105

ASOURCE="autoaudiosrc"
#ASOURCE="audiotestsrc"
AENC="opusenc ! rtpopuspay"

ARTPSINK="udpsink port=$ARTPSINKPORT host=$DEST multicast-iface=$DESTIF name=vrtpsink"
ARTCPSINK="udpsink port=$ARTCPSINKPORT host=$DEST multicast-iface=$DESTIF sync=false async=false name=vrtcpsink"
ARTCPSRC="udpsrc port=$ARTCPSRCPORT address=$DEST multicast-iface=$DESTIF name=vrtpsrc"

gst-launch-1.0 -v -e rtpbin name=rtpbin buffer-mode=none latency=0 drop-on-latency=true \
    $ASOURCE ! $AENC ! rtpbin.send_rtp_sink_0 \
        rtpbin.send_rtp_src_0 ! $ARTPSINK     \
        rtpbin.send_rtcp_src_0 ! $ARTCPSINK   \
      $ARTCPSRC ! rtpbin.recv_rtcp_sink_0     
