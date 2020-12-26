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
