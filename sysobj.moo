object SYSOBJ
  name: "The System Object"
  owner: #2
  readable: true

  property ambiguous_match (owner: #2, flags: "r") = AMBIGUOUS_MATCH;
  property anon (owner: #2, flags: "r") = ANON;
  property ansi (owner: #2, flags: "r") = ANSI;
  property big_mail_recipient (owner: #2, flags: "r") = BIG_MAIL_RECIPIENT;
  property biglist (owner: #2, flags: "r") = BIGLIST;
  property broadcast (owner: #2, flags: "r") = BROADCAST;
  property builder (owner: #2, flags: "r") = BUILDER;
  property builder_feature (owner: #2, flags: "r") = BUILDER_FEATURE;
  property building_utils (owner: #2, flags: "r") = BUILDING_UTILS;
  property channel (owner: #2, flags: "r") = CHANNEL;
  property class_registry (owner: #2, flags: "r") = {
    {
      "generics",
      "Generic objects intended for use as the parents of new objects",
      {
        ROOM,
        EXIT,
        THING,
        VCS,
        #54,
        CONTAINER,
        ROOT_CLASS,
        PLAYER,
        PROG,
        WIZ,
        SCHEDULER,
        #45,
        #46
      },
      BUILDER
    },
    {
      "utilities",
      "Objects holding useful general-purpose verbs",
      {
        STRING_UTILS,
        LIST_UTILS,
        WIZ_UTILS,
        SET_UTILS,
        GENDER_UTILS,
        MATH_UTILS,
        TIME_UTILS,
        MATCH_UTILS,
        OBJECT_UTILS,
        LOCK_UTILS,
        COMMAND_UTILS,
        PERM_UTILS,
        BUILDING_UTILS,
        SEQ_UTILS,
        BIGLIST,
        ERROR,
        #81,
        CODE_UTILS,
        MATRIX_UTILS,
        CONVERT_UTILS,
        #99,
        EDIT_UTILS,
        MENU_UTILS,
        BUILDER_FEATURE
      },
      PROG
    },
    {
      "server",
      "Objects containing functionality that affects the server.",
      {TELNET, SERVER_OPTIONS, HELP},
      WIZ
    },
    {
      "prototypes",
      "Objects containing verbs that can be called on their corresponding types.",
      {MAP_PROTO, STR_PROTO, LIST_PROTO, PROTO, OBJ_PROTO},
      PROG
    }
  };
  property code_scanner (owner: #2, flags: "r") = CODE_SCANNER;
  property code_utils (owner: #2, flags: "r") = CODE_UTILS;
  property command_utils (owner: #2, flags: "r") = COMMAND_UTILS;
  property container (owner: #2, flags: "r") = CONTAINER;
  property convert_utils (owner: #2, flags: "r") = CONVERT_UTILS;
  property cu (owner: #2, flags: "r") = COMMAND_UTILS;
  property datastore (owner: #2, flags: "r") = DATASTORE;
  property diff_utils (owner: #2, flags: "r") = DIFF_UTILS;
  property edit_session (owner: #2, flags: "r") = EDIT_SESSION;
  property edit_state (owner: #2, flags: "r") = EDIT_STATE;
  property edit_utils (owner: #2, flags: "r") = EDIT_UTILS;
  property error (owner: #2, flags: "r") = ERROR;
  property exit (owner: #2, flags: "r") = EXIT;
  property failed_match (owner: #2, flags: "r") = FAILED_MATCH;
  property false (owner: #2, flags: "r") = 0;
  property feature (owner: #2, flags: "r") = FEATURE;
  property feature_warehouse (owner: #2, flags: "r") = FEATURE_WAREHOUSE;
  property frobs (owner: #2, flags: "r") = {};
  property garbage (owner: #2, flags: "r") = GARBAGE;
  property gender_utils (owner: #2, flags: "r") = GENDER_UTILS;
  property gendered_object (owner: #2, flags: "r") = GENDERED_OBJECT;
  property generic_help (owner: #2, flags: "r") = GENERIC_HELP;
  property generic_options (owner: #2, flags: "r") = GENERIC_OPTIONS;
  property generic_utils (owner: #2, flags: "r") = GENERIC_UTILS;
  property guest (owner: #2, flags: "r") = GUEST;
  property guest_log (owner: #2, flags: "r") = GUEST_LOG;
  property hacker (owner: #2, flags: "r") = HACKER;
  property help (owner: #2, flags: "r") = HELP;
  property int_proto (owner: #2, flags: "r") = INT_PROTO;
  property last_huh (owner: #2, flags: "r") = LAST_HUH;
  property limbo (owner: #2, flags: "r") = LIMBO;
  property list_proto (owner: #2, flags: "r") = LIST_PROTO;
  property list_utils (owner: #2, flags: "r") = LIST_UTILS;
  property lock_utils (owner: #2, flags: "r") = LOCK_UTILS;
  property login (owner: #2, flags: "r") = LOGIN;
  property lu (owner: #2, flags: "r") = LIST_UTILS;
  property map_proto (owner: #2, flags: "r") = MAP_PROTO;
  property match_utils (owner: #2, flags: "r") = MATCH_UTILS;
  property math_utils (owner: #2, flags: "r") = MATH_UTILS;
  property matrix_utils (owner: HACKER, flags: "r") = MATRIX_UTILS;
  property maxint (owner: #2, flags: "r") = 9223372036854775807;
  property mcp (owner: #2, flags: "r") = MCP;
  property menu_utils (owner: #2, flags: "r") = MENU_UTILS;
  property minint (owner: #2, flags: "r") = -9223372036854775807;
  property mu (owner: #2, flags: "r") = MATH_UTILS;
  property network (owner: #2, flags: "r") = NETWORK;
  property news (owner: #2, flags: "r") = NEWS;
  property no_one (owner: #2, flags: "r") = NO_ONE;
  property nothing (owner: #2, flags: "r") = NOTHING;
  property obj_proto (owner: #2, flags: "r") = OBJ_PROTO;
  property object_utils (owner: #2, flags: "r") = OBJECT_UTILS;
  property options (owner: #2, flags: "r") = [
    "ansi" -> #102,
    "build" -> #77,
    "display" -> #67,
    "edit" -> #66,
    "mail" -> #65,
    "prog" -> #76
  ];
  property ou (owner: #2, flags: "r") = OBJECT_UTILS;
  property pasting_feature (owner: #2, flags: "r") = PASTING_FEATURE;
  property perm_utils (owner: #2, flags: "r") = PERM_UTILS;
  property player (owner: #2, flags: "r") = PLAYER;
  property player_class (owner: #2, flags: "r") = PLAYER;
  property player_start (owner: #2, flags: "r") = PLAYER_START;
  property prog (owner: #2, flags: "r") = PROG;
  property prog_feature (owner: #2, flags: "r") = PROG_FEATURE;
  property proto (owner: #2, flags: "r") = PROTO;
  property recycler (owner: #2, flags: "r") = RECYCLER;
  property recycling_pool (owner: #2, flags: "r") = RECYCLING_POOL;
  property room (owner: #2, flags: "r") = ROOM;
  property root_class (owner: #2, flags: "r") = ROOT_CLASS;
  property scheduler (owner: HACKER, flags: "r") = SCHEDULER;
  property seq_utils (owner: #2, flags: "r") = SEQ_UTILS;
  property server (owner: #2, flags: "r") = [
    "core_history" -> {
      {"HackerCore", "2.7.2", 1721211497},
      {"ToastCore", "2.7.1", 1713940026},
      {"a 2018 LambdaCore", "2.6.0", 1576791887}
    },
    "last_restart_time" -> 1761539693,
    "name" -> "HackerCore-mooR",
    "shutdown_time" -> 0
  ];
  property server_options (owner: #2, flags: "r") = SERVER_OPTIONS;
  property set_utils (owner: #2, flags: "r") = SET_UTILS;
  property singleton (owner: #2, flags: "r") = SINGLETON;
  property singleton_warehouse (owner: #2, flags: "r") = SINGLETON_WAREHOUSE;
  property spell (owner: #2, flags: "r") = SPELL;
  property str_proto (owner: #2, flags: "r") = STR_PROTO;
  property string_utils (owner: #2, flags: "r") = STRING_UTILS;
  property su (owner: #2, flags: "r") = STRING_UTILS;
  property sysobj (owner: #2, flags: "r") = SYSOBJ;
  property telnet (owner: #2, flags: "r") = TELNET;
  property thing (owner: #2, flags: "r") = THING;
  property time_utils (owner: #2, flags: "r") = TIME_UTILS;
  property trig_utils (owner: #2, flags: "r") = MATH_UTILS;
  property true (owner: #2, flags: "r") = 1;
  property tu (owner: HACKER, flags: "r") = TIME_UTILS;
  property vcs (owner: #2, flags: "r") = VCS;
  property who (owner: HACKER, flags: "r") = WHO;
  property wiz (owner: #2, flags: "r") = WIZ;
  property wiz_utils (owner: #2, flags: "r") = WIZ_UTILS;
  property you (owner: HACKER, flags: "r") = YOU;

  verb do_login_command (this none this) owner: #2 flags: "rxd"
    "...This code should only be run as a server task...";
    if (callers())
      return E_PERM;
    endif
    if (typeof(h = $network:incoming_connection(player)) == OBJ)
      "connected to an object";
      return h;
    elseif (h)
      return 0;
    endif
    "...checks to see if the login is spamming the server with too many commands...";
    if (!$login:maybe_limit_commands())
      args = $login:parse_command(@args);
      return $login:((args[1]))(@listdelete(args, 1));
    endif
  endverb

  verb server_started (this none this) owner: #2 flags: "rxd"
    if (callers())
      raise(E_PERM, tostr(verb, " can only be called by the server daemon."));
    endif
    $server["last_restart_time"] = time();
    "call on_server_started hook for mortal objects";
    for object in ({$root_class, @$ou:descendants($root_class)})
      hook_verb_info = `verb_info(object, "on_server_started") ! ANY => {}';
      if (!hook_verb_info || !("x" in hook_verb_info[2]))
        "verb does not exist or is not callable";
        continue;
      elseif (!hook_verb_info[1].wizard)
        "insufficient permissions; hook must be owned by wizardly account.";
        continue;
      endif
      object:on_server_started();
    endfor
  endverb

  verb "user_created user_connected" (this none this) owner: #2 flags: "rxd"
    "Copied from The System Object (#0):user_connected by Slartibartfast (#4242) Sun May 21 18:14:16 1995 PDT";
    if (callers())
      return;
    endif
    "commented out as moor may handle sessions";
    "$mcp:(verb)(@args)";
    user = args[1];
    set_task_perms(user);
    try
      user.location:confunc(user);
      user:confunc();
    except id (ANY)
      user:tell("Confunc failed: ", id[2], ".");
      for tb in (id[4])
        user:tell("... called from ", tb[4], ":", tb[2], tb[4] != tb[1] ? tostr(" (this == ", tb[1], ")") | "", ", line ", tb[6]);
      endfor
      user:tell("(End of traceback)");
    endtry
  endverb

  verb "user_disconnected user_client_disconnected" (this none this) owner: #2 flags: "rxd"
    if (callers())
      return;
    endif
    if (args[1] < #0)
      "not logged in user.  probably should do something clever here involving Carrot's no-spam hack.  --yduJ";
      "...'forget' that we already performed a name lookup on this connection...";
      $login:delete_name_lookup(args[1]);
      return;
    endif
    $mcp:(verb)(@args);
    user = args[1];
    user.last_disconnect_time = time();
    set_task_perms(user);
    where = user.location;
    `user:disfunc() ! ANY => 0';
    if (user.location != where)
      `where.location:disfunc(user) ! ANY => 0';
    endif
    `user.location:disfunc(user) ! ANY => 0';
  endverb

  verb "bf_chparent chparent" (this none this) owner: #2 flags: "rxd"
    "chparent(object, new-parent) -- see help on the builtin.";
    who = caller_perms();
    {what, papa} = args;
    if (typeof(what) != OBJ)
      retval = E_TYPE;
    elseif (!valid(what))
      retval = E_INVARG;
    elseif (typeof(papa) != OBJ)
      retval = E_TYPE;
    elseif (!valid(papa) && papa != #-1)
      retval = E_INVIND;
    elseif (!$perm_utils:controls(who, what))
      retval = E_PERM;
    elseif (is_player(what) && !$object_utils:isa(papa, $player_class) && !who.wizard)
      retval = E_PERM;
    elseif (is_player(what) && !$object_utils:isa(what, $player_class) && !who.wizard)
      retval = E_PERM;
    elseif (children(what) && $object_utils:isa(what, $player_class) && !$object_utils:isa(papa, $player_class))
      retval = E_PERM;
    elseif (is_player(what) && what in $wiz_utils.chparent_restricted && !who.wizard)
      retval = E_PERM;
    elseif (!valid(papa) || ($perm_utils:controls(who, papa) || papa.f))
      retval = `chparent(@args) ! ANY';
    else
      retval = E_PERM;
    endif
    return typeof(retval) == ERR && $code_utils:dflag_on() ? raise(retval) | retval;
  endverb

  verb "bf_add_verb add_verb" (this none this) owner: #2 flags: "rxd"
    "add_verb() -- see help on the builtin for more information. This verb is called by the server when $server_options.protect_add_verb exists and is true and caller_perms() are not wizardly.";
    who = caller_perms();
    what = args[1];
    info = args[2];
    if (typeof(what) != OBJ)
      retval = E_TYPE;
    elseif (!valid(what))
      retval = E_INVARG;
    elseif (!$perm_utils:controls(who, what) && !what.w)
      "caller_perms() is not allowed to hack on the object in question";
      retval = E_PERM;
    elseif (!$perm_utils:controls(who, info[1]))
      "caller_perms() is not permitted to add a verb with the specified owner.";
      retval = E_PERM;
    elseif (index(info[2], "w") && !$server_options.permit_writable_verbs)
      retval = E_INVARG;
    elseif (what.owner != who && !who.wizard)
      retval = E_QUOTA;
    elseif (!who.programmer)
      retval = E_PERM;
    else
      "we now know that the caller's perms control the object or the object is writable, and we know that the caller's perms control the prospective verb owner (by more traditional means)";
      retval = `add_verb(@args) ! ANY';
    endif
    return typeof(retval) == ERR && $code_utils:dflag_on() ? raise(retval) | retval;
  endverb

  verb "bf_add_property add_property" (this none this) owner: #2 flags: "rxd"
    "add_property() -- see help on the builtin for more information. This verb is called by the server when $server_options.protect_add_property exists and is true and caller_perms() are not wizardly.";
    who = caller_perms();
    {what, propname, value, info} = args;
    if (typeof(what) != OBJ)
      retval = E_TYPE;
    elseif (!valid(what))
      retval = E_INVARG;
    elseif (!$perm_utils:controls(who, what) && !what.w)
      retval = E_PERM;
    elseif (!$perm_utils:controls(who, info[1]))
      retval = E_PERM;
    else
      "we now know that the caller's perms control the object (or the object is writable), and that the caller's perms are permitted to control the new property's owner.";
      retval = `add_property(@args) ! ANY';
    endif
    return typeof(retval) == ERR && $code_utils:dflag_on() ? raise(retval) | retval;
  endverb

  verb "bf_recycle recycle" (this none this) owner: #2 flags: "rxd"
    "recycle(object) -- see help on the builtin. This verb is called by the server when $server_options.protect_recycle exists and is true and caller_perms() are not wizardly.";
    {what} = args;
    if (!valid(what))
      retval = E_INVARG;
    elseif (!$perm_utils:controls(who = caller_perms(), what))
      retval = E_PERM;
    elseif ((p = `is_player(what) ! E_TYPE => 0') && !who.wizard)
      for p in ($wiz_utils:connected_wizards_unadvertised())
        p:tell($string_utils:pronoun_sub("%N (%#) is currently trying to destroy %t (%[#t])", who, what));
      endfor
      retval = E_PERM;
    else
      if (p)
        $wiz_utils:unset_player(what);
      endif
      $recycler:kill_all_tasks(what);
      retval = `recycle(what) ! ANY';
    endif
    return typeof(retval) == ERR && $code_utils:dflag_on() ? raise(retval) | retval;
  endverb

  verb user_reconnected (this none this) owner: #2 flags: "rxd"
    if (callers())
      return;
    endif
    $mcp:(verb)(@args);
    if ($object_utils:isa(user = args[1], $guest))
      "from $guest:boot";
      oldloc = user.location;
      move(user, $nothing);
      "..force enterfunc to be called so that the newbie gets a room description.";
      move(user, user.home);
      user:do_reset();
      if ($object_utils:isa(oldloc, $room))
        oldloc:announce("In the distance you hear someone's alarm clock going off.");
        if (oldloc != user.location)
          oldloc:announce(user.name, " wavers and vanishes into insubstantial mist.");
        else
          oldloc:announce(user.name, " undergoes a wrenching personality shift.");
        endif
      endif
      set_task_perms(user);
      `user:confunc() ! ANY';
    else
      set_task_perms(user);
      `user:reconfunc() ! ANY';
    endif
  endverb

  verb "bf_set_verb_info set_verb_info" (this none this) owner: #2 flags: "rxd"
    "set_verb_info() -- see help on the builtin for more information. This verb is called by the server when $server_options.protect_set_verb_info exists and is true and caller_perms() are not wizardly.";
    {o, v, i} = args;
    if (typeof(vi = `verb_info(o, v) ! ANY') == ERR)
      "probably verb doesn't exist";
      retval = vi;
    elseif (!$perm_utils:controls(cp = caller_perms(), vi[1]))
      "perms don't control the current verb owner";
      retval = E_PERM;
    elseif (typeof(i) != LIST || typeof(no = i[1]) != OBJ)
      "info is malformed";
      retval = E_TYPE;
    elseif (!valid(no) || !is_player(no))
      "invalid new verb owner";
      retval = E_INVARG;
    elseif (!$perm_utils:controls(cp, no))
      "perms don't control prospective verb owner";
      retval = E_PERM;
    elseif (index(i[2], "w") && !`$server_options.permit_writable_verbs ! E_PROPNF, E_INVIND => 1')
      retval = E_INVARG;
    else
      retval = `set_verb_info(o, v, i) ! ANY';
    endif
    return typeof(retval) == ERR && $code_utils:dflag_on() ? raise(retval) | retval;
  endverb

  verb "bf_match match" (this none this) owner: #2 flags: "rxd"
    m = `match(@args) ! ANY';
    return typeof(m) == ERR && $code_utils:dflag_on() ? raise(m) | m;
  endverb

  verb "bf_rmatch rmatch" (this none this) owner: #2 flags: "rxd"
    r = `rmatch(@args) ! ANY';
    return typeof(r) == ERR && $code_utils:dflag_on() ? raise(r) | r;
  endverb

  verb "do_out_of_band_command doobc" (this none this) owner: #2 flags: "rxd"
    "do_out_of_band_command -- a cheap and very dirty do_out_of_band verb.  Forwards to verb on player with same name if it exists, otherwise forwards to $login.  May only be called by the server in response to an out of band command, otherwise E_PERM is returned.";
    if (caller == #-1 && caller_perms() == #-1 && callers() == {})
      if (valid(player) && is_player(player))
        $mcp:(verb)(@args);
        set_task_perms(player);
        $object_utils:has_callable_verb(player, "do_out_of_band_command") && player:do_out_of_band_command(@args);
      elseif ($telnet:(verb)(@args))
        return;
      else
        $login:do_out_of_band_command(@args);
      endif
    else
      return E_PERM;
    endif
  endverb

  verb handle_uncaught_error (this none this) owner: #2 flags: "rxd"
    $error:log(args);
    if (!callers())
      "now let the player do something with it if e wants...";
      return `player:(verb)(@args) ! ANY';
    endif
  endverb

  verb bf_force_input (this none this) owner: #2 flags: "rxd"
    "Copied from Jay (#3920):bf_force_input Mon Jun 16 20:55:27 1997 PDT";
    "force_input(conn, line [, at-front])";
    "see help on the builtin for more information. This verb is called by the server when $server_options.protect_force_input exists and is true and caller_perms() are not wizardly.";
    {conn, line, ?at_front = 0} = args;
    if (caller_perms() != conn)
      retval = E_PERM;
    elseif (conn in $login.newted)
      retval = E_PERM;
    else
      retval = `force_input(@args) ! ANY';
    endif
    return typeof(retval) == ERR && $code_utils:dflag_on() ? raise(retval) | retval;
  endverb

  verb moveto (this none this) owner: #2 flags: "rxd"
    "Let's keep bozos from partying.  --Nosredna the partypooper";
    return pass(#-1);
  endverb

  verb "bf_set_property_info set_property_info" (this none this) owner: #2 flags: "rxd"
    who = caller_perms();
    retval = 0;
    try
      {what, propname, info} = args;
    except (E_ARGS)
      retval = E_ARGS;
    endtry
    try
      {owner, perms, ?newname = 0} = info;
    except (E_ARGS)
      retval = E_ARGS;
    except (E_TYPE)
      retval = E_TYPE;
    endtry
    if (retval != 0)
    elseif (newname in {"object_size", "size_quota", "queued_task_limit"} && !who.wizard)
      retval = E_PERM;
    else
      set_task_perms(who);
      retval = `set_property_info(@args) ! ANY';
    endif
    return typeof(retval) == ERR && $code_utils:dflag_on() ? raise(retval) | retval;
  endverb

  verb handle_task_timeout (this none this) owner: #2 flags: "rxd"
    if (!callers())
      {resource, stack, traceback} = args;
      if (!$object_utils:connected(player))
        "Mail the player the traceback if e isn't connected.";
        $mail_agent:send_message(#0, player, {"traceback", $wiz_utils.gripe_recipients}, traceback);
      endif
      "now let the player do something with it if e wants...";
      return `player:(verb)(@args) ! ANY';
    endif
  endverb

  verb bf_read (this none this) owner: #2 flags: "rxd"
    set_task_perms(caller_perms());
    `player.reading_input = 1 ! E_PROPNF, E_INVIND';
    input = `read(@args) ! ANY';
    `clear_property(player, "reading_input") ! E_PROPNF, E_INVARG';
    return typeof(input) == ERR && $code_utils:dflag_on() ? raise(input) | input;
  endverb

  verb "bf_chparents chparents" (this none this) owner: #2 flags: "rxd"
    who = caller_perms();
    {what, papas, ?anon_kids = {}} = args;
    if (typeof(what) != OBJ)
      retval = E_TYPE;
    elseif (!valid(what))
      retval = E_INVARG;
    elseif (typeof(papas) != LIST)
      retval = E_TYPE;
    elseif (!$perm_utils:controls(who, what))
      retval = E_PERM;
    elseif (is_player(what) && !occupants(papas, $player_class) && !who.wizard)
      retval = E_PERM;
    elseif (children(what) && $object_utils:isa(what, $player_class) && !occupants(papas, $player_class))
      retval = E_PERM;
    elseif (is_player(what) && what in $wiz_utils.chparent_restricted && !who.wizard)
      retval = E_PERM;
    elseif (what.location == $mail_agent && $object_utils:isa(what, $mail_recipient) && !$object_utils:isa(papa, $mail_recipient) && !who.wizard)
      retval = E_PERM;
    else
      for x in (papas)
        if (!$perm_utils:controls(who, x) && !x.f)
          retval = E_PERM;
          break;
        endif
      endfor
      if (`typeof(retval) ! ANY => 0' != ERR)
        retval = `chparents(@args) ! ANY';
      endif
    endif
    return typeof(retval) == ERR && $code_utils:dflag_on() ? raise(retval) | retval;
  endverb

  verb "s ies es" (this none this) owner: HACKER flags: "rxd"
    return $string_utils:pluralize(@args);
  endverb
endobject