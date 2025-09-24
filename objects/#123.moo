object dns-com-awns-status
  name: "dns-com-awns-status"
  parent: #104
  owner: #98
  readable: true

  override aliases = {"dns-com-awns-status"};
  override messages_out = {{"", {"text"}}};

  verb status (this none this) owner: #98 flags: "rxd"
    {session, text} = args;
    if (caller == this || $perm_utils:controls(caller_perms(), session.connection))
      return this:send_(session, text);
    endif
  endverb
endobject