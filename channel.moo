object #70
  name: "Generic Channel"
  parent: #17
  owner: #36

  property color (owner: #36, flags: "r") = "yellow";
  property is_muted (owner: #36, flags: "r") = 0;
  property muted_players (owner: #36, flags: "r") = [];
  property player_whitelist (owner: #36, flags: "r") = {#6};
  property symbol (owner: #36, flags: "r") = "-";

  verb "nrtransmit transmit" (this none this) owner: #36 flags: "rxd"
    ":transmit(STR message) => NONE";
    "  transmits a message to the channel.";
    {message, @more} = args;
    formatted_message = $su:subst(this:format_msg(), {{"%msg", message}});
    for dude in (connected_players())
      if (this in dude.channels)
        dude:system_tell(formatted_message);
      endif
    endfor
  endverb

  verb format_msg (this none this) owner: #36 flags: "rxd"
    return tostr($ansi:((this.color))("[", this.symbol, "][", $su:uppercase(this:name()), "]", " %msg"));
  endverb

  verb is_on_channel (this none this) owner: #36 flags: "rxd"
    {dude} = args;
    return !(!(this in dude.channels));
  endverb

  verb can_join (this none this) owner: #36 flags: "rxd"
    {dude} = args;
    if (!this.player_whitelist)
      return $false;
    endif
    return $ou:isoneof(dude, this.player_whitelist);
  endverb

  verb why_cant_transmit (this none this) owner: #36 flags: "rxd"
    {dude} = args;
    if (this.is_muted)
      return tostr("The channel has been muted because: ", this.is_muted);
    elseif (maphaskey(this:muted_players(), dude))
      {reason, expiration} = this.muted_players[dude];
      if (expiration <= -1)
        expiration = "until further notice";
      else
        expiration = tostr("for ", expiration - time(), " more seconds");
      endif
      return tostr("You have been muted ", expiration, " for the reason: ", reason);
    endif
    return "";
  endverb

  verb muted_players (this none this) owner: #36 flags: "rxd"
    ":muted_players() => MAP of muted players";
    for data, dude in (this.muted_players)
      {reason, expiration} = data;
      if (expiration <= time())
        this.muted_players = mapdelete(this.muted_players, dude);
      endif
    endfor
    return this.muted_players;
  endverb

  verb player_title (this none this) owner: #36 flags: "rxd"
    return "";
  endverb
endobject