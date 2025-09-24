object Generic Player
  name: "Generic Player"
  parent: #94
  owner: #2
  readable: true

  property all_connect_places (owner: #2, flags: "") = {};
  property brief (owner: #2, flags: "rc") = 0;
  property dict (owner: #2, flags: "rc") = {};
  property display_options (owner: #2, flags: "rc") = {};
  property edit_options (owner: #2, flags: "rc") = {};
  property email_address (owner: #2, flags: "") = "";
  property features (owner: #2, flags: "r") = {};
  property first_connect_time (owner: #2, flags: "r") = 2147483647;
  property home (owner: #2, flags: "rc") = #62;
  property inline_editor_options (owner: #2, flags: "") = [];
  property last_connect_attempt (owner: #2, flags: "") = 0;
  property last_connect_place (owner: #2, flags: "") = "?";
  property last_connect_time (owner: #2, flags: "r") = 0;
  property last_disconnect_time (owner: #2, flags: "r") = 0;
  property last_password_time (owner: #2, flags: "") = 0;
  property more_msg (owner: #2, flags: "rc") = "*** More ***  %n lines left.  Do @more [rest|flush] for more.";
  property out_of_band_session (owner: #2, flags: "r") = #-1;
  property page_absent_msg (owner: #2, flags: "rc") = "%N is not currently logged in.";
  property page_echo_msg (owner: #2, flags: "rc") = "Your message has been sent.";
  property page_origin_msg (owner: #2, flags: "rc") = "You sense that %n is looking for you in %l.";
  property password (owner: #2, flags: "") = "impossible password to type";
  property previous_connection (owner: #2, flags: "") = 0;
  property reading_input (owner: #2, flags: "") = 0;
  property size_quota (owner: #36, flags: "") = {};

  override aliases = {"Generic Player"};
  override description = "You see a player who should type '@describe me as ...'.";

  verb confunc (this none this) owner: #2 flags: "rxd"
    if (valid(cp = caller_perms()) && caller != this && !$perm_utils:controls(cp, this) && caller != #0)
      return E_PERM;
    endif
    this:("@last-connection")();
  endverb

  verb disfunc (this none this) owner: #2 flags: "rxd"
    if (valid(cp = caller_perms()) && caller != this && !$perm_utils:controls(cp, this) && caller != #0)
      return E_PERM;
    endif
    this:expunge_rmm();
    return;
  endverb

  verb initialize (this none this) owner: #2 flags: "rxd"
    if (caller == this || $perm_utils:controls(caller_perms(), this))
      this.help = 0;
      return pass(@args);
    else
      return E_PERM;
    endif
  endverb

  verb acceptable (this none this) owner: #2 flags: "rxd"
    return !is_player(args[1]);
  endverb

  verb my_huh (this none this) owner: #2 flags: "rxd"
    "Extra parsing of player commands.  Called by $command_utils:do_huh.";
    "This version of my_huh just handles features.";
    permissions = caller == this || $perm_utils:controls(caller_perms(), this) && $command_utils:validate_feature(@args) ? this | $no_one;
    "verb - obvious                 pass - would be args";
    "plist - list of prepspecs that this command matches";
    "dlist and ilist - likewise for dobjspecs, iobjspecs";
    verb = args[1];
    if (`$server_options.support_numeric_verbname_strings ! E_PROPNF => 0' && $string_utils:is_integer(verb))
      return;
    endif
    pass = args[2];
    plist = {"any", prepstr ? $code_utils:full_prep(prepstr) | "none"};
    dlist = dobjstr ? {"any"} | {"none", "any"};
    ilist = iobjstr ? {"any"} | {"none", "any"};
    for fobj in (this.features)
      if (!$recycler:valid(fobj))
        this:remove_feature(fobj);
      else
        fverb = 0;
        try
          "Ask the FO for a matching verb.";
          fverb = fobj:has_feature_verb(verb, dlist, plist, ilist);
        except e (E_VERBNF)
          "Try to match it ourselves.";
          if (`valid(loc = $object_utils:has_callable_verb(fobj, verb)[1]) ! ANY => 0')
            vargs = verb_args(loc, verb);
            if (vargs[2] in plist && (vargs[1] in dlist && vargs[3] in ilist))
              fverb = verb;
            endif
          endif
        endtry
        if (fverb)
          "(got rid of notify_huh - use @find to locate feature verbs)";
          set_task_perms(permissions);
          fobj:(fverb)(@pass);
          return 1;
        endif
      endif
    endfor
  endverb

  verb last_huh (this none this) owner: #2 flags: "rxd"
    ":last_huh(verb,args)  final attempt to parse a command...";
    set_task_perms(caller_perms());
    {verb, args} = args;
    if (verb[1] == "@" && prepstr == "is")
      "... set or show _msg property ...";
      set_task_perms(player);
      $last_huh:(verb)(@args);
      return 1;
    elseif (verb in {"give", "hand", "get", "take", "drop", "throw"})
      $last_huh:(verb)(@args);
      return 1;
    else
      return 0;
    endif
  endverb

  verb tell_contents (this none this) owner: #2 flags: "rxd"
    c = args[1];
    if (c)
      longear = {};
      gear = {};
      width = player:linelen();
      half = width / 2;
      player:tell("Carrying:");
      for thing in (c)
        cx = tostr(" ", thing:title());
        if (length(cx) > half)
          longear = {@longear, cx};
        else
          gear = {@gear, cx};
        endif
      endfor
      player:tell_lines($string_utils:columnize(gear, 2, width));
      player:tell_lines(longear);
    endif
  endverb

  verb titlec (this none this) owner: #2 flags: "rxd"
    return `this.namec ! E_PROPNF => this:title()';
  endverb

  verb notify (this none this) owner: #36 flags: "rxd"
    line = length(args) > 1 ? tostr(@args) | args[1];
    ansi_enabled = `this:player_option("ansi_enabled") ! ANY => $false';
    ansi_enabled = true;
    if (!ansi_enabled)
      line = $ansi:strip_tags(line);
    else
      line = $ansi:convert_tags_to_color(line, this);
    endif
    return pass(line);
  endverb

  verb notify_lines (this none this) owner: #2 flags: "rxd"
    if ($perm_utils:controls(caller_perms(), this) || caller == this || caller_perms() == this)
      set_task_perms(caller_perms());
      for line in (typeof(lines = args[1]) != LIST ? {lines} | lines)
        this:notify(tostr(line));
      endfor
    else
      return E_PERM;
    endif
  endverb

  verb page (any any any) owner: #2 flags: "rxd"
    nargs = length(args);
    if (nargs < 1)
      player:notify(tostr("Usage: ", verb, " <player> [with <message>]"));
      return;
    endif
    who = $string_utils:match_player(args[1]);
    if ($command_utils:player_match_result(who, args[1])[1])
      return;
    endif
    "for pronoun_sub's benefit...";
    dobj = who;
    iobj = player;
    header = player:page_origin_msg();
    text = "";
    if (nargs > 1)
      if (args[2] == "with" && nargs > 2)
        msg_start = 3;
      else
        msg_start = 2;
      endif
      msg = $string_utils:from_list(args[msg_start..nargs], " ");
      text = tostr($string_utils:pronoun_sub(($string_utils:index_delimited(header, player.name) ? "%S" | "%N") + " %<pages>, \""), msg, "\"");
    endif
    result = text ? who:receive_page(header, text) | who:receive_page(header);
    if (result == 2)
      "not connected";
      player:tell(typeof(msg = who:page_absent_msg()) == STR ? msg | $string_utils:pronoun_sub("%n is not currently logged in.", who));
    else
      player:tell(who:page_echo_msg());
    endif
  endverb

  verb receive_page (this none this) owner: #2 flags: "rxd"
    "called by $player:page.  Two args, the page header and the text, all pre-processed by the page command.  Could be extended to provide haven abilities, multiline pages, etc.  Indeed, at the moment it just does :tell_lines, so we already do have multiline pages, if someone wants to take advantage of it.";
    "Return codes:";
    "  1:  page was received";
    "  2:  player is not connected";
    "  0:  page refused";
    "If a specialization wants to refuse a page, it should return 0 to say it was refused.  If it uses pass(@args) it should propagate back up the return value.  It is possible that this code should interact with gagging and return 0 if the page was gagged.";
    if (this:is_listening())
      this:tell_lines(args);
      return 1;
    else
      return 2;
    endif
  endverb

  verb "page_origin_msg page_echo_msg page_absent_msg" (this none this) owner: #36 flags: "rxd"
    "set_task_perms(this.owner)";
    return (msg = `this.(verb) ! ANY') ? $string_utils:pronoun_sub(this.(verb), this) | "";
  endverb

  verb "i inv*entory" (none none none) owner: #2 flags: "rd"
    if (c = player:contents())
      this:tell_contents(c);
    else
      player:tell("You are empty-handed.");
    endif
  endverb

  verb look_self (this none this) owner: #2 flags: "rxd"
    player:tell(this:titlec());
    pass();
    if (!(this in connected_players()))
      player:tell($gender_utils:pronoun_sub("%{:He} %{!is} sleeping.", this));
    elseif ((idle = idle_seconds(this)) < 60)
      player:tell($gender_utils:pronoun_sub("%{:He} %{!is} awake and %{!looks} alert.", this));
    else
      time = $string_utils:from_seconds(idle);
      player:tell($gender_utils:pronoun_sub("%{:He} %{!is} awake, but %{!has} been staring off into space for ", this), time, ".");
    endif
    if (c = this:contents())
      this:tell_contents(c);
    endif
  endverb

  verb "@sethome" (none none none) owner: #2 flags: "rd"
    set_task_perms(this);
    here = this.location;
    if (!$perm_utils:controls(player, player))
      player:notify("Players who do not own themselves may not modify their home.");
    elseif (!$object_utils:has_callable_verb(here, "accept_for_abode"))
      player:notify("This is a pretty odd place.  You should make your home in an actual room.");
    elseif (here:accept_for_abode(this))
      this.home = here;
      player:notify(tostr(here.name, " is your new home."));
    else
      player:notify(tostr("This place doesn't want to be your home.  Contact ", here.owner.name, " to be added to the residents list of this place, or choose another place as your home."));
    endif
  endverb

  verb "where*is @where*is" (any any any) owner: #2 flags: "rxd"
    if (!args)
      them = connected_players();
    else
      who = $command_utils:player_match_result($string_utils:match_player(args), args);
      if (length(who) <= 1)
        if (!who[1])
          player:notify("Where is who?");
        endif
        return;
      elseif (who[1])
        player:notify("");
      endif
      them = listdelete(who, 1);
    endif
    lmax = rmax = 0;
    for p in (them)
      player:notify(tostr($string_utils:left($string_utils:nn(p), 25), " ", $string_utils:nn(p.location)));
    endfor
  endverb

  verb "@who" (any any any) owner: #2 flags: "rxd"
    if (caller != player)
      return E_PERM;
    endif
    plyrs = args ? listdelete($command_utils:player_match_result($string_utils:match_player(args), args), 1) | connected_players();
    if (!plyrs)
      return;
    elseif (length(plyrs) > 100)
      player:tell("You have requested a listing of ", length(plyrs), " players.  Please either specify individual players you are interested in, to reduce the number of players in any single request, or else use the `@users' command instead.  The lag thanks you.");
      return;
    endif
    $code_utils:show_who_listing(plyrs);
  endverb

  verb "@wizards" (any none none) owner: #2 flags: "rxd"
    "@wizards [all]";
    if (caller != player)
      return E_PERM;
    endif
    if (args)
      $code_utils:show_who_listing($wiz_utils:all_wizards());
    else
      $code_utils:show_who_listing($wiz_utils:connected_wizards()) || player:notify("No wizards currently logged in.");
    endif
  endverb

  verb display_option (this none this) owner: #2 flags: "rxd"
    ":display_option(name) => returns the value of the specified @display option";
    if (caller == this || $perm_utils:controls(caller_perms(), this))
      return $options["display"]:get(this.display_options, args[1]);
    else
      return E_PERM;
    endif
  endverb

  verb edit_option (this none this) owner: #2 flags: "rxd"
    ":edit_option(name) => returns the value of the specified edit option";
    if (caller == this || ($object_utils:isa(caller, $generic_editor) || $perm_utils:controls(caller_perms(), this)))
      return $options["edit"]:get(this.edit_options, args[1]);
    else
      return E_PERM;
    endif
  endverb

  verb "set_mail_option set_edit_option set_display_option" (this none this) owner: #2 flags: "rxd"
    ":set_edit_option(oname,value)";
    ":set_display_option(oname,value)";
    ":set_mail_option(oname,value)";
    "Changes the value of the named option.";
    "Returns a string error if something goes wrong.";
    if (!(caller == this || $perm_utils:controls(caller_perms(), this)))
      return tostr(E_PERM);
    endif
    "...this is kludgy, but it saves me from writing the same verb 3 times.";
    "...there's got to be a better way to do this...";
    verb[1..4] = "";
    foo_options = verb + "s";
    prop = verb[1..index(verb, "_") - 1];
    "...";
    if (typeof(s = $options[prop]:set(this.(foo_options), @args)) == STR)
      return s;
    elseif (s == this.(foo_options))
      return 0;
    else
      this.(foo_options) = s;
      return 1;
    endif
  endverb

  verb "@mailo*ptions @mail-o*ptions @edito*ptions @edit-o*ptions @displayo*ptions @display-o*ptions @generalo*ptions @general-o*ptions" (any any any) owner: #2 flags: "rd"
    "@<what>-option <option> [is] <value>   sets <option> to <value>";
    "@<what>-option <option>=<value>        sets <option> to <value>";
    "@<what>-option +<option>     sets <option>   (usually equiv. to <option>=1";
    "@<what>-option -<option>     resets <option> (equiv. to <option>=0)";
    "@<what>-option !<option>     resets <option> (equiv. to <option>=0)";
    "@<what>-option <option>      displays value of <option>";
    set_task_perms(player);
    what = {"mail", "edit", "display", "general"}[index("medg", verb[2])];
    options = what + "_options";
    option_pkg = $options[what];
    set_option = "set_" + what + "_option";
    if (!args)
      player:notify_lines({"Current " + what + " options:", "", @option_pkg:show(this.(options), option_pkg.names)});
      return;
    elseif (typeof(presult = option_pkg:parse(args)) == STR)
      player:notify(presult);
      return;
    else
      if (length(presult) > 1)
        if (typeof(sresult = this:(set_option)(@presult)) == STR)
          player:notify(sresult);
          return;
        elseif (!sresult)
          player:notify("No change.");
          return;
        endif
      endif
      player:notify_lines(option_pkg:show(this.(options), presult[1]));
    endif
  endverb

  verb set_name (this none this) owner: #2 flags: "rxd"
    "set_name(newname) attempts to change this.name to newname";
    "  => E_PERM   if you don't own this";
    "  => E_INVARG if the name is already taken or prohibited for some reason";
    "  => E_NACC   if the player database is not taking new names right now.";
    "  => E_ARGS   if the name is too long (controlled by $login.max_player_name)";
    "  => E_QUOTA  if the player is not allowed to change eir name.";
    if (!($perm_utils:controls(caller_perms(), this) || this == caller))
      return E_PERM;
    elseif (!is_player(this))
      "we don't worry about the names of player classes.";
      set_task_perms(caller_perms());
      return pass(@args);
    elseif ($player_db.frozen)
      return E_NACC;
    elseif (length(name = args[1]) > $login.max_player_name)
      return E_ARGS;
    elseif (!($player_db:available(name, this) in {this, 1}))
      return E_INVARG;
    else
      old = this.name;
      this.name = name;
      if (name != old && !(old in this.aliases))
        $player_db:delete(old);
      endif
      $player_db:insert(name, this);
      return 1;
    endif
  endverb

  verb set_aliases (this none this) owner: #2 flags: "rxd"
    "set_aliases(alias_list)";
    "For changing player aliases, we check to make sure that none of the aliases match existing player names/aliases.  Aliases containing spaces are not entered in the $player_db and so are not subject to this restriction ($string_utils:match_player will not match on them, however, so they only match if used in the immediate room, e.g., with match_object() or somesuch).";
    "Also we make sure that the .name is included in the .alias list.  In any situation where .name and .aliases are both being changed, do the name change first.";
    "  => 1        if successful, and aliases changed from previous setting.";
    "  => 0        if resulting work didn't change aliases from previous.";
    "  => E_PERM   if you don't own this";
    "  => E_NACC   if the player database is not taking new aliases right now.";
    "  => E_TYPE   if alias_list is not a list";
    "  => E_INVARG if any element of alias_list is not a string";
    if (!($perm_utils:controls(caller_perms(), this) || this == caller))
      return E_PERM;
    elseif (!is_player(this))
      "we don't worry about the names of player classes.";
      return pass(@args);
    elseif ($player_db.frozen)
      return E_NACC;
    elseif (typeof(aliases = args[1]) != LIST)
      return E_TYPE;
    elseif (length(aliases = setadd(aliases, this.name)) > ($object_utils:has_property($local, "max_player_aliases") ? $local.max_player_aliases | $maxint) && length(aliases) >= length(this.aliases))
      return E_INVARG;
    else
      for a in (aliases)
        if (typeof(a) != STR)
          return E_INVARG;
        endif
        if (!(index(a, " ") || index(a, "	")) && !($player_db:available(a, this) in {this, 1}))
          aliases = setremove(aliases, a);
        endif
      endfor
      old = this.aliases;
      this.aliases = aliases;
      for a in (old)
        if (!(a in aliases))
          $player_db:delete2(a, this);
        endif
      endfor
      for a in (aliases)
        if (!(index(a, " ") || index(a, "	")))
          $player_db:insert(a, this);
        endif
      endfor
      return this.aliases != old;
    endif
  endverb

  verb "@desc*ribe" (any as any) owner: #2 flags: "rd"
    set_task_perms(player);
    dobj = player:match(dobjstr);
    if ($command_utils:object_match_failed(dobj, dobjstr))
      "...lose...";
    elseif (e = dobj:set_description(iobjstr))
      player:notify("Description set.");
    else
      player:notify(tostr(e));
    endif
  endverb

  verb "@mess*ages" (any none none) owner: #2 flags: "rd"
    set_task_perms(player);
    if (dobjstr == "")
      player:notify(tostr("Usage:  ", verb, " <object>"));
      return;
    endif
    dobj = player:match(dobjstr);
    if ($command_utils:object_match_failed(dobj, dobjstr))
      return;
    endif
    found_one = 0;
    props = $object_utils:all_properties(dobj);
    if (typeof(props) == ERR)
      player:notify("You can't read the messages on that.");
      return;
    endif
    for pname in (props)
      len = length(pname);
      if (len > 4 && pname[len - 3..len] == "_msg")
        found_one = 1;
        msg = `dobj.(pname) ! ANY';
        if (msg == E_PERM)
          value = "isn't readable by you.";
        elseif (!msg)
          value = "isn't set.";
        elseif (typeof(msg) == LIST)
          value = "is a list.";
        elseif (typeof(msg) != STR)
          value = "is corrupted! **";
        else
          value = "is " + $string_utils:print(msg);
        endif
        player:notify(tostr("@", pname[1..len - 4], " ", dobjstr, " ", value));
      endif
    endfor
    if (!found_one)
      player:notify("That object doesn't have any messages to set.");
    endif
  endverb

  verb "@last-c*onnection" (any none none) owner: #2 flags: "rxd"
    "@last-c           reports when and from where you last connected.";
    "@last-c all       adds the 10 most recent places you connected from.";
    "@last-c confunc   is like `@last-c' but is silent on first login.";
    opts = {"all", "confunc"};
    i = 0;
    if (caller != this)
      return E_PERM;
    elseif (args && (length(args) > 1 || !(i = $string_utils:find_prefix(args[1], opts))))
      this:notify(tostr("Usage:  ", verb, " [all]"));
      return;
    endif
    opt_all = i && opts[i] == "all";
    opt_confunc = i && opts[i] == "confunc";
    if (!(prev = this.previous_connection))
      this:notify("Something was broken when you logged in; tell a wizard.");
    elseif (prev[1] == 0)
      opt_confunc || this:notify("Your previous connection was before we started keeping track.");
    elseif (prev[1] > time())
      this:notify("This is your first time connected.");
    else
      this:notify(tostr("Last connected ", this:ctime(prev[1]), " from ", prev[2]));
      if (opt_all)
        this:notify("Previous connections have been from the following sites:");
        for l in (this.all_connect_places)
          this:notify("   " + l);
        endfor
      endif
    endif
  endverb

  verb set_brief (this none this) owner: #2 flags: "rxd"
    "set_brief(value)";
    "set_brief(value, anything)";
    "If <anything> is given, add value to the current value; otherwise, just set the value.";
    if (!($perm_utils:controls(caller_perms(), this) || this == caller))
      return E_PERM;
    else
      if (length(args) == 1)
        this.brief = args[1];
      else
        this.brief = this.brief + args[1];
      endif
    endif
  endverb

  verb "@mode" (any any any) owner: #2 flags: "rd"
    "@mode <mode>";
    "Current modes are brief and verbose.";
    "General verb for setting player `modes'.";
    "Modes are coded right here in the verb.";
    if (caller != this)
      player:tell("You can't set someone else's modes.");
      return E_PERM;
    endif
    modes = {"brief", "verbose"};
    mode = `modes[$string_utils:find_prefix(dobjstr, modes)] ! E_TYPE, E_RANGE => 0';
    if (!mode)
      player:tell("Unknown mode \"", dobjstr, "\".  Known modes:");
      for mode in (modes)
        player:tell("  ", mode);
      endfor
      return 0;
    elseif (mode == "brief")
      this:set_brief(1);
    elseif (mode == "verbose")
      this:set_brief(0);
    endif
    player:tell($string_utils:capitalize(mode), " mode set.");
    return 1;
  endverb

  verb "exam*ine @exam*ine" (any none none) owner: #2 flags: "rd"
    set_task_perms(player);
    if (!dobjstr)
      player:notify(tostr("Usage:  ", verb, " <object>"));
      return E_INVARG;
    endif
    what = player.location:match_contents(dobjstr);
    if ($command_utils:object_match_failed(what, dobjstr))
      return;
    endif
    what:do_examine(player);
  endverb

  verb add_feature (this none this) owner: #36 flags: "rxd"
    "Add a feature to this player's features list.  Caller must be this or have suitable permissions (this or wizardly).";
    "If this is a nonprogrammer, then ask feature if it is feature_ok (that is, if it has a verb :feature_ok which returns a true value, or a property .feature_ok which is true).";
    "After adding feature, call feature:feature_add(this).";
    "Returns true if successful, E_INVARG if not a valid object, and E_PERM if !feature_ok or if caller doesn't have permission.";
    if (caller == this || $perm_utils:controls(caller_perms(), this))
      feature = args[1];
      if (typeof(feature) != OBJ || !valid(feature))
        return E_INVARG;
        "Not a valid object.";
      endif
      if ($code_utils:verb_or_property(feature, "feature_ok", this))
        "The object is willing to be a feature.";
        if (typeof(this.features) == LIST)
          "If list, we can simply setadd the feature.";
          this.features = setadd(this.features, feature);
        else
          "If not, we erase the old value and create a new list.";
          this.features = {feature};
        endif
        "Tell the feature it's just been added.";
        try
          feature:feature_add(this);
        except (ANY)
          "just ignore errors.";
        endtry
        return 1;
        "We're done.";
      else
        return E_PERM;
        "Feature isn't feature_ok.";
      endif
    else
      return E_PERM;
      "Caller doesn't have permission.";
    endif
  endverb

  verb remove_feature (this none this) owner: #36 flags: "rxd"
    "Remove a feature from this player's features list.  Caller must be this, or have permissions of this, a wizard, or feature.owner.";
    "Returns true if successful, E_PERM if caller didn't have permission.";
    feature = args[1];
    if (caller == this || $perm_utils:controls(caller_perms(), this) || caller_perms() == feature.owner)
      if (typeof(this.features) == LIST)
        "If this is a list, we can just setremove...";
        this.features = setremove(this.features, feature);
        "Otherwise, we leave it alone.";
      endif
      "Let the feature know it's been removed.";
      try
        feature:feature_remove(this);
      except (ANY)
        "just ignore errors.";
      endtry
      return 1;
      "We're done.";
    else
      return E_PERM;
      "Caller didn't have permission.";
    endif
  endverb

  verb "@version" (none none none) owner: #36 flags: "rd"
    if ($object_utils:has_property($local, "server_hardware"))
      hw = " on " + $local.server_hardware + ".";
    else
      hw = ".";
    endif
    server_version = server_version();
    if (server_version[1] == "v")
      server_version[1..1] = "";
    endif
    player:notify(tostr("The MOO is currently running version ", server_version, " of the ", $server["name"], " server code", hw));
    try
      {MOOname, sversion, coretime} = $server["core_history"][1];
      player:notify(tostr("The database was derived from a core created on ", $time_utils:time_sub("$n $t, $Y", coretime), " at ", MOOname, " for version ", sversion, " of the server."));
    except (E_RANGE)
      player:notify("The database was created from scratch.");
    except (ANY)
      player:notify("No information is available on the database version.");
    endtry
  endverb

  verb "@uptime" (none none none) owner: #36 flags: "rd"
    player:notify(tostr($network.MOO_name, " has been up for ", $time_utils:english_time(time() - $server["last_restart_time"], $server["last_restart_time"]), "."));
  endverb

  verb "@quit" (none none none) owner: #2 flags: "rd"
    boot_player(player);
    "-- argh, let the player decide; #3:disfunc() takes care of this --Rog";
    "player:moveto(player.home)";
  endverb

  verb examine_commands_ok (this none this) owner: #2 flags: "rxd"
    return this == args[1];
  endverb

  verb is_listening (this none this) owner: #2 flags: "rxd"
    "return true if player is active.";
    return typeof(`idle_seconds(this) ! ANY') != ERR;
  endverb

  verb moveto (this none this) owner: #2 flags: "rxd"
    if (args[1] == #-1)
      return E_INVARG;
      this:notify("You are now in #-1, The Void.  Type `home' to get back.");
    endif
    set_task_perms(caller_perms());
    pass(@args);
  endverb

  verb "announce*_all_but" (this none this) owner: #2 flags: "rxd"
    return this.location:(verb)(@args);
    "temporarily let player:announce be noisy to player";
    if (verb == "announce_all_but")
      if (this in args[1])
        return;
      endif
      args = args[2..$];
    endif
    this:tell("(from within you) ", @args);
  endverb

  verb tell_lines (this none this) owner: #2 flags: "rxd"
    lines = args[1];
    if (typeof(lines) != LIST)
      lines = {lines};
    endif
    this:notify_lines(lines);
  endverb

  verb "@lastlog" (any none none) owner: #2 flags: "rxd"
    "Copied from generic room (#3):@lastlog by Haakon (#2) Wed Dec 30 13:30:02 1992 PST";
    if (dobjstr != "")
      dobj = $string_utils:match_player(dobjstr);
      if (!valid(dobj))
        player:tell("Who?");
        return;
      endif
      folks = {dobj};
    else
      folks = players();
    endif
    if (length(folks) > 100)
      player:tell("You have requested a listing of ", length(folks), " players.  That is too long a list; specify individual players you are interested in.");
      return;
    endif
    day = week = month = ever = never = {};
    a_day = 24 * 60 * 60;
    a_week = 7 * a_day;
    a_month = 30 * a_day;
    now = time();
    for x in (folks)
      when = x.last_connect_time;
      how_long = now - when;
      if (when == 0 || when > now)
        never = {@never, x};
      elseif (how_long < a_day)
        day = {@day, x};
      elseif (how_long < a_week)
        week = {@week, x};
      elseif (how_long < a_month)
        month = {@month, x};
      else
        ever = {@ever, x};
      endif
    endfor
    for entry in ({{day, "the last day"}, {week, "the last week"}, {month, "the last 30 days"}, {ever, "recorded history"}})
      if (entry[1])
        player:tell("Players who have connected within ", entry[2], ":");
        for x in (entry[1])
          player:tell("  ", x.name, " last connected ", ctime(x.last_connect_time), ".");
        endfor
      endif
    endfor
    if (never)
      player:tell("Players who have never connected:");
      player:tell("  ", $string_utils:english_list($list_utils:map_prop(never, "name")));
    endif
  endverb

  verb set_home (this none this) owner: #2 flags: "rxd"
    "set_home(newhome) attempts to change this.home to newhome";
    "E_TYPE   if newhome doesn't have a callable :accept_for_abode verb.";
    "E_INVARG if newhome won't accept you as a resident.";
    "E_PERM   if you don't own this and aren't its parent.";
    "1        if it works.";
    newhome = args[1];
    if (caller == this || $perm_utils:controls(caller_perms(), this))
      if ($object_utils:has_callable_verb(newhome, "accept_for_abode"))
        if (newhome:accept_for_abode(this))
          return typeof(e = `this.home = args[1] ! ANY') != ERR || e;
        else
          return E_INVARG;
        endif
      else
        return E_TYPE;
      endif
    else
      return E_PERM;
    endif
  endverb

  verb "@registerme" (any any any) owner: #2 flags: "rd"
    "@registerme as <email-address> -- enter a new email address for player";
    "   will change the database entry, assign a new password, and mail the new password to the player at the given email address.";
    if (player != this)
      return player:notify(tostr(E_PERM));
    endif
    who = this;
    if ($object_utils:isa(this, $guest))
      who:notify("Sorry, guests should use the '@request' command to request a character.");
      return;
    endif
    connection = $string_utils:connection_hostname(who);
    if (!argstr)
      if ($wiz_utils:get_email_address(who))
        player:tell("You are currently registered as:  ", $wiz_utils:get_email_address(who));
      else
        player:tell("You are not currently registered.");
      endif
      player:tell("Use @registerme as <address> to change this.");
      return;
    elseif (prepstr != "as" || !iobjstr || dobjstr)
      player:tell("Usage: @registerme as <address>");
      return;
    endif
    email = iobjstr;
    if (email == $wiz_utils:get_email_address(this))
      who:notify("That is your current address.  Not changed.");
      return;
    elseif (reason = $wiz_utils:check_reregistration(this, email, connection))
      if (reason[1] == "-")
        if (!$command_utils:yes_or_no(reason[2..$] + ". Automatic registration not allowed. Ask to be registered at this address anyway?"))
          who:notify("Okay.");
          return;
        endif
      else
        return who:notify(tostr(reason, " Please try again."));
      endif
    endif
    if ($network.active && !reason)
      if (!$command_utils:yes_or_no(tostr("If you continue, your password will be changed, the new password mailed to `", email, "'. Do you want to continue?")))
        return who:notify("Registration terminated.");
      endif
      password = $wiz_utils:random_password(5);
      old = $wiz_utils:get_email_address(who) || "[ unregistered ]";
      who:notify(tostr("Registering you, and changing your password and mailing new one to ", email, "."));
      result = $network:sendmail(email, tostr("Your ", $network.MOO_Name, " character, ", who.name), "Reply-to: " + $login.registration_address, @$generic_editor:fill_string(tostr("Your ", $network.MOO_name, " character, ", $string_utils:nn(who), " has been registered to this email address (", email, "), and a new password assigned.  The new password is `", password, "'. Please keep your password secure. You can change your password with the @password command."), 75));
      if (result != 0)
        who:notify(tostr("Mail sending did not work: ", reason, ". Reregistration terminated."));
        return;
      endif
      who:notify(tostr("Mail with your new password forwarded. If you do not get it, send regular email to ", $login.registration_address, " with your character name."));
      $mail_agent:send_message($new_player_log, $new_player_log, "reg " + $string_utils:nn(this), {email, tostr("formerly ", old)});
      $registration_db:add(this, email, "Reregistered at " + ctime());
      $wiz_utils:set_email_address(this, email);
      who.password = $login:encrypt_password(password);
      who.last_password_time = time();
    else
      who:notify("No automatic reregistration: your request will be forwarded.");
      if (typeof(curreg = $registration_db:find(email)) == LIST)
        additional_info = {"Current registration information for this email address:", @$registration_db:describe_registration(curreg)};
      else
        additional_info = {};
      endif
      $mail_agent:send_message(this, $registration_db.registrar, "Registration request", {"Reregistration request from " + $string_utils:nn(who) + " connected via " + connection + ":", "", "@register " + who.name + " " + email, "@new-password " + who.name + " is ", "", "Reason this request was forwarded:", reason, @additional_info});
    endif
  endverb

  verb ctime (this none this) owner: #2 flags: "rxd"
    ":ctime([INT time]) => STR as the function.";
    "May be hacked by players and player-classes to reflect differences in time-zone.";
    return ctime(@args);
  endverb

  verb "@age" (any none none) owner: #36 flags: "rd"
    if (dobjstr == "" || dobj == player)
      dobj = player;
    else
      dobj = $string_utils:match_player(dobjstr);
      if (!valid(dobj))
        $command_utils:player_match_failed(dobj, dobjstr);
        return;
      endif
    endif
    time = dobj.first_connect_time;
    if (time == $maxint)
      duration = time() - dobj.last_disconnect_time;
      if (duration < 86400)
        notice = $string_utils:from_seconds(duration);
      else
        notice = $time_utils:english_time(duration / 86400 * 86400);
      endif
      player:notify(tostr(dobj.name, " has never connected.  It was created ", notice, " ago."));
    elseif (time == 0)
      player:notify(tostr(dobj.name, " first connected before initial connections were being recorded."));
    else
      player:notify(tostr(dobj.name, " first connected on ", ctime(time)));
      duration = time() - time;
      if (duration < 86400)
        notice = $string_utils:from_seconds(duration);
      else
        notice = $time_utils:english_time(duration / 86400 * 86400);
      endif
      player:notify(tostr($string_utils:pronoun_sub("%S %<is> ", dobj), notice, " old."));
    endif
  endverb

  verb _chparent (this none this) owner: #2 flags: "rxd"
    set_task_perms(caller_perms());
    return chparent(@args);
  endverb

  verb "@password" (any any any) owner: #2 flags: "rd"
    if (typeof(player.password) != STR)
      if (length(args) != 1)
        return player:notify(tostr("Usage:  ", verb, " <new-password>"));
      else
        new_password = args[1];
      endif
    elseif (length(args) != 2)
      player:notify(tostr("Usage:  ", verb, " <old-password> <new-password>"));
      return;
    elseif (!argon2_verify(player.password, args[1]))
      player:notify("That's not your old password.");
      return;
    elseif (is_clear_property(player, "password"))
      player:notify("Your password has a `clear' property.  Please refer to a wizard for assistance in changing it.");
      return;
    elseif (player in $wiz_utils.change_password_restricted)
      player:notify("You are not permitted to change your own password.");
      return;
    else
      new_password = args[2];
    endif
    if (r = $password_verifier:reject_password(new_password, player))
      player:notify(r);
      return;
    endif
    player.password = $login:encrypt_password(new_password);
    player.last_password_time = time();
    player:notify("New password set.");
  endverb

  verb recycle (this none this) owner: #2 flags: "rxd"
    if (caller == this || $perm_utils:controls(caller_perms(), this))
      pass(@args);
      features = this.features;
      for x in (features)
        "Have to do this, or :feature_remove thinks you're a liar and doesn't believe.";
        this.features = setremove(this.features, x);
        if ($object_utils:has_verb(x, "feature_remove"))
          try
            x:feature_remove(this);
          except (ANY)
            player:tell("Failure in ", x, ":feature_remove for player ", $string_utils:nn(this));
          endtry
        endif
      endfor
    endif
  endverb

  verb email_address (this none this) owner: #2 flags: "rxd"
    set_task_perms(caller_perms());
    return this.email_address;
  endverb

  verb set_email_address (this none this) owner: #2 flags: "rxd"
    set_task_perms(caller_perms());
    this.email_address = args[1];
  endverb

  verb reconfunc (this none this) owner: #2 flags: "rxd"
    if (valid(cp = caller_perms()) && caller != this && !$perm_utils:controls(cp, this) && caller != $sysobj)
      return E_PERM;
    endif
    return this:confunc(@args);
  endverb

  verb "@inline-o*ptions @editor-o*ptions" (any any any) owner: #2 flags: "rd"
    return $edit_utils:options(@args);
  endverb

  verb "@gender" (any none none) owner: #2 flags: "rd"
    set_task_perms(valid(caller_perms()) ? caller_perms() | player);
    if (!args)
      player:notify(tostr("Your gender is currently ", this.gender, "."));
      player:notify($string_utils:pronoun_sub("Your pronouns:  %s,%o,%p,%q,%r,%S,%O,%P,%Q,%R"));
      player:notify(tostr("Available genders:  ", $string_utils:english_list($gender_utils.genders, "", " or ")));
    else
      result = this:set_gender(args[1]);
      quote = result == E_NONE ? "\"" | "";
      player:notify(tostr("Gender set to ", quote, this.gender, quote, "."));
      if (typeof(result) != ERR)
        player:notify($string_utils:pronoun_sub("Your pronouns:  %s,%o,%p,%q,%r,%S,%O,%P,%Q,%R"));
      elseif (result != E_NONE)
        player:notify(tostr("Couldn't set pronouns:  ", result));
      else
        player:notify("Pronouns unchanged.");
      endif
    endif
  endverb

  verb "help @help help/* @help/*" (any any any) owner: #36 flags: "rd"
    if ($cu:switched_command(verb, "help"))
      return;
    endif
    if (!args || !(spec = $code_utils:parse_verbref(args[1])))
      if (!argstr)
        argstr = "index";
      endif
      if (!(results = $help:find(argstr, $help:permitted_categories(player))))
        return player:notify(tostr("Sorry, but no help is available on `", argstr, "'."));
      elseif (length(results) > 1)
        player:notify(tostr("Found multiple results for '", argstr, "', which of the following topics do you mean:"));
        for result in (results)
          player:notify(tostr("  ", result[$]));
        endfor
        return;
      endif
      "we only had one result";
      result = results[1];
      player:notify(tostr("Showing help for '", result[$], "':"));
      player:notify_lines(result[2]);
      return;
    elseif ($command_utils:object_match_failed(object = this:match(spec[1]), spec[1]))
      return;
    elseif (!(":" in args[1]) && $recycler:valid(object = this:match(args[1])))
      if ($ou:has_property(object, "help_msg"))
        return player:notify_lines(object.help_msg);
      elseif ($ou:has_property(object, "help_message"))
        return player:notify_lines(object.help_message);
      endif
      return player:notify("That object does not have help available.");
    elseif (!(hv = $object_utils:has_verb(object, spec[2])))
      return player:notify("That object does not define that verb.");
    elseif (typeof(verbdoc = $code_utils:verb_documentation(object = hv[1], spec[2])) == ERR)
      return player:notify(tostr(verbdoc));
    elseif (typeof(info = `verb_info(object, spec[2]) ! ANY') == ERR)
      return player:notify(tostr(info));
    endif
    objverb = tostr(object.name, "(", object, "):", strsub(info[3], " ", "/"));
    if (verbdoc)
      player:notify_lines({tostr("Information about ", objverb), "----", @verbdoc});
    else
      player:notify(tostr("No information about ", objverb));
    endif
  endverb
endobject