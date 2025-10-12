object #71
  name: "Channel Broadcaster Proxy"
  parent: #17
  owner: #36

  property channels (owner: #36, flags: "r") = ["code" -> #81, "staff_alerts" -> #80];

  verb "code staff_alerts" (this none this) owner: #36 flags: "rxd"
    return this.channels[verb]:transmit(tostr(@args));
  endverb
endobject