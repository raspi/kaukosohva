#!/bin/bash
set -eu
set -o pipefail

beverbose=no
WID=-1
DESTIF=wg0

# options may be followed by one colon to indicate they have a required argument
if ! options=$(getopt -o hv:I:w: -l help,verbose,interface:,windowid: -- "$@")
then
    # something went wrong, getopt will put out an error message for us
    exit 1
fi

set -- $options

# Parse arguments
while [ $# -gt 0 ]
do
    case $1 in
    -h|--help)
      echo "Usage: $0"
      echo "  -I|--interface <interface>     Required. for example: wg0"
      echo "  -w|--windowid <window id>     Required. for example: 65746"
      echo ""
      exit 0
    ;;

    -v|--verbose) beverbose="yes" ;;

    # for options with required arguments, an additional shift is required
    -I|--interface) DESTIF="${2//\'/}" ; shift;;
    -w|--windowid) WID="${2//\'/}" ; shift;;

    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
    (*) break;;
    esac
    shift
done

if [[ ! -d "/sys/class/net/$DESTIF" ]]; then
  echo "Invalid interface: $DESTIF"
  exit 1
fi

if ! xwininfo -int -id "$WID"; then
  echo "Invalid window id: $WID"
  exit 1
fi

#export GST_DEBUG="GST_TRACER:7"
export GST_DEBUG_DUMP_DOT_DIR=.
export GST_DEBUG_FILE="trace.log"
export GST_TRACERS="latency(flags=pipeline+element+reported);interlatency"
export GST_DEBUG_COLOR_MODE=off

LANG=C

# change this to send the RTP data and RTCP to another host
DEST=224.0.0.1
MTU=1400

FPS=60
KBITRATE=7000
MAXKBITRATE=$(( $KBITRATE + 1000 ))
VRTPSINKPORT=8000
VRTCPSINKPORT=8001
VRTCPSRCPORT=5005

VELEM="ximagesrc use-damage=false xid=$WID"
VCAPS="video/x-raw,framerate=$FPS/1"
VSOURCE="$VELEM ! videoconvert n-threads=3 ! $VCAPS"
VENC="nvh264enc bitrate=$KBITRATE max-bitrate=$MAXKBITRATE rc-mode=cbr-ld-hq ! video/x-h264,stream-format=byte-stream ! rtph264pay config-interval=-1 pt=96 aggregate-mode=none mtu=$MTU"

VRTPSINK="udpsink port=$VRTPSINKPORT host=$DEST multicast-iface=$DESTIF name=vrtpsink"
VRTCPSINK="udpsink port=$VRTCPSINKPORT host=$DEST multicast-iface=$DESTIF sync=false async=false name=vrtcpsink"
VRTCPSRC="udpsrc port=$VRTCPSRCPORT address=$DEST multicast-iface=$DESTIF name=vrtpsrc"

gst-launch-1.0 -e rtpbin name=rtpbin buffer-mode=none latency=0 drop-on-latency=true max-dropout-time=500 \
    $VSOURCE ! $VENC ! rtpbin.send_rtp_sink_0 \
        rtpbin.send_rtp_src_0 ! queue max-size-buffers=$(( $FPS * 2 )) max-size-bytes=0 max-size-time=500000000 min-threshold-buffers=1 ! $VRTPSINK \
        rtpbin.send_rtcp_src_0 ! $VRTCPSINK \
      $VRTCPSRC ! rtpbin.recv_rtcp_sink_0
