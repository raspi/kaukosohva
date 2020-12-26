# kaukosohva

Play games remotely with Linux.

## Current state 

This is proof of concept for technical users. Security and latency issues are everywhere. Can be used to play turn-based or other non-time-critical games.


# Architecture

![Architecture](https://github.com/raspi/kaukosohva/blob/master/doc/Architecture.png)

# Main problems TODO

* Security
* Lower the latency for streaming
  * Get rid of all streaming buffer(s)
  * CBR or VBR?

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
  * https://en.wikipedia.org/wiki/Real_Time_Streaming_Protocol
  * https://en.wikipedia.org/wiki/Advanced_Video_Coding
  * https://en.wikipedia.org/wiki/MPEG_transport_stream
* Service discovery
  * https://en.wikipedia.org/wiki/Simple_Service_Discovery_Protocol
  * https://en.wikipedia.org/wiki/Service_Location_Protocol
 
