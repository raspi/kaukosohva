# kaukosohva

Play games remotely with Linux.

## Current state 

This is proof of concept prototype for technical users. 

# Architecture

![Architecture](https://github.com/raspi/kaukosohva/blob/master/doc/Architecture.png)

# Main problems TODO

* Lower the latency for streaming
  * Minimize streaming buffer(s)
  * Tune x264 parameters for lowest latency
  * Tune RTP parameters for lowest latency
  * Constant or variable bitrate (CBR or VBR)?

# FAQ

* Why x264 over RTP?
  * Because it's a standard - https://tools.ietf.org/html/rfc6184
  * Because GPU hardware acceleration in bot encoding and decoding
* Why multicast?
  * Eliminates need for extra server software as kernel sends host's stream to everyone connected to the VPN automatically
* Why GStreamer?
  * Lots of tuning options
* Does it matter who hosts VPN (WireGuard)?
  * No, anyone can host the main VPN server where host/remote player(s) connect

# See 

* [host](host) directory for how to host a game
* [remote-player](remote-player) directory for how to connect to a host as a remote player

# Research

* Network
  * https://en.wikipedia.org/wiki/Multicast_address
  * https://en.wikipedia.org/wiki/Reserved_IP_addresses
  * https://en.wikipedia.org/wiki/Private_network
* Video/Audio
  * https://en.wikipedia.org/wiki/Real-time_Transport_Protocol
  * https://en.wikipedia.org/wiki/Advanced_Video_Coding

# Tested, didn't work

* ffmpeg, mpv, vlc 
 * too many buffers
 * 1000-4000 ms+ latency even locally
