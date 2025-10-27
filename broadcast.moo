object BROADCAST
  name: "Channel Broadcaster Proxy"
  parent: SINGLETON
  owner: HACKER

  property channels (owner: HACKER, flags: "r") = [
    "build" -> #85,
    "build_alerts" -> #85,
    "code" -> #81,
    "prog" -> #81,
    "prog_alerts" -> #81,
    "staff_alerts" -> #80
  ];

  verb "code build_alerts build prog prog_alerts staff_alerts" (this none this) owner: HACKER flags: "rxd"
    return this.channels[verb]:transmit(tostr(@args));
  endverb
endobject