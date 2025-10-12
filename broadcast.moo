object #71
  name: "Channel Broadcaster Proxy"
  parent: #17
  owner: #36

  property channels (owner: #36, flags: "r") = [
    "build" -> #85,
    "build_alerts" -> #85,
    "code" -> #81,
    "prog" -> #81,
    "prog_alerts" -> #81,
    "staff_alerts" -> #80
  ];

  verb "code build_alerts build prog prog_alerts staff_alerts" (this none this) owner: #36 flags: "rxd"
    return this.channels[verb]:transmit(tostr(@args));
  endverb
endobject