object BUILDER_FEATURE
  name: "Builder Feature"
  parent: FEATURE
  location: FEATURE_WAREHOUSE
  owner: HACKER
  readable: true

  override aliases = {"Builder", "Feature", "Builder Feature"};

  verb "@children @kids" (any none any) owner: HACKER flags: "rxd"
    "Usage:  @tree <object> [-d] [search objects by name]";
    "Shows an object hierarchy beginning with the given object. All fertile children";
    "and children with children are included in the tree.  The output includes the";
    "object number, the object name, and the total number of children the object has.";
    "With option '-d', number of verbs and properties defined.";
    if (!dobjstr)
      return player:tell("@children <object> [-d] [search objects by name]");
    endif
    parameters = dobjstr;
    details = 0;
    if (index(dobjstr, "-d"))
      details = 1;
      parameters = $string_utils:subst(parameters, {{"-d", ""}});
    endif
    parts = $string_utils:explode(parameters);
    root = player:match(parts[1]);
    search_text = "";
    if (length(parts) > 1)
      search_text = $string_utils:from_list(parts[2..$]);
    endif
    if (!valid(root))
      return player:tell("Invalid object reference: ", dobjstr);
    endif
    player:tell("Fertile kids of ", root.name, ": (this may take a while)");
    this:do_tree(root, "", search_text, details, $false);
    player:tell("----- End of @tree listing for ", $string_utils:nn(root), details ? " [kids, verbs and properties]" | "");
  endverb

  verb "@tree" (any none any) owner: HACKER flags: "rxd"
    "Usage:  @tree <object> [-d] [search objects by name]";
    "Shows an object hierarchy beginning with the given object. All fertile children";
    "and children with children are included in the tree.  The output includes the";
    "object number, the object name, and the total number of children the object has.";
    "With option '-d', number of verbs and properties defined.";
    if (!dobjstr)
      return player:tell("@tree <object> [-d] [search objects by name]");
    endif
    parameters = dobjstr;
    details = 0;
    if (index(dobjstr, "-d"))
      details = 1;
      parameters = $string_utils:subst(parameters, {{"-d", ""}});
    endif
    parts = $string_utils:explode(parameters);
    root = player:match(parts[1]);
    search_text = "";
    if (length(parts) > 1)
      search_text = $string_utils:from_list(parts[2..$]);
    endif
    if (!valid(root))
      return player:tell("Invalid object reference: ", dobjstr);
    endif
    player:tell("Fertile kids of ", root.name, ": (this may take a while)");
    this:do_tree(root, "", search_text, details);
    player:tell("----- End of @tree listing for ", $string_utils:nn(root), details ? " [kids, verbs and properties]" | "");
  endverb

  verb do_tree (this none this) owner: HACKER flags: "rxd"
    ":do_tree(OBJ root, INT indent, STR search_text, [INT details, BOOL require_fertile = 1, STR color = \"normal\"])";
    "traverse fertile kids of given root object";
    {root, indent, search_text, ?details = 0, ?require_fertile = 1, ?color = "normal"} = args;
    kids = children(root);
    limit = 70;
    if (length(search_text) > 0 ? index(root.name, search_text) | 1)
      line = tostr($string_utils:space(indent, "  | | | | | | | | |"), "|-", $string_utils:nn(root));
      len = length(line);
      if (len > limit)
        line = line[1..limit];
      elseif (len < limit)
        line = $su:left(line, limit);
      endif
      line = tostr(line, $string_utils:right(length(kids), 4));
      if (details)
        v = verbs(root);
        p = properties(root);
        line = tostr(line, " ", $string_utils:right(v ? length(v) | " ", 3), " ", $string_utils:right(p ? length(p) | " ", 4));
      endif
      player:tell($ansi:(color)(line));
      color = color == "normal" ? "bright" | "normal";
    endif
    indent = indent + "  ";
    hadfertile = 0;
    for kid in (kids)
      if (!require_fertile || kid.f || children(kid))
        {color, spaced} = this:do_tree(kid, indent, search_text, details, require_fertile, color);
        hadfertile = 1;
      endif
      if (kid == kids[$] && hadfertile && !spaced)
        if (callers()[1][2] == "do_tree" && children(parent(root))[$] != root)
          player:tell($ansi:(color)($string_utils:space(indent, "  | | | | | | | | |")));
          color = color == "normal" ? "bright" | "normal";
        endif
      endif
    endfor
    return {color, hadfertile};
  endverb

  verb "@unlock" (any none none) owner: #2 flags: "rd"
    set_task_perms(player);
    dobj = player:match(dobjstr);
    if ($command_utils:object_match_failed(dobj, dobjstr))
      return;
    endif
    try
      dobj.key = 0;
      player:notify(tostr("Unlocked ", dobj.name, "."));
    except error (ANY)
      player:notify(error[2]);
    endtry
  endverb

  verb "@lock" (any with any) owner: #2 flags: "rd"
    set_task_perms(player);
    dobj = player:match(dobjstr);
    if ($command_utils:object_match_failed(dobj, dobjstr))
      return;
    endif
    key = $lock_utils:parse_keyexp(iobjstr, player);
    if (typeof(key) == STR)
      player:notify("That key expression is malformed:");
      player:notify(tostr("  ", key));
    else
      try
        dobj.key = key;
        player:notify(tostr("Locked ", dobj.name, " to this key:"));
        player:notify(tostr("  ", $lock_utils:unparse_key(key)));
      except error (ANY)
        player:notify(error[2]);
      endtry
    endif
  endverb

  verb "@newmess*age" (any any any) owner: #2 flags: "rd"
    "Usage:  @newmessage <message-name> [<message>] [on <object>]";
    "Add a message property to an object (default is player), and optionally";
    "set its value.  For use by non-programmers, who aren't allowed to add";
    "properties generally.";
    "To undo the effects of this, use @unmessage.";
    set_task_perms(player);
    dobjwords = $string_utils:words(dobjstr);
    if (!dobjwords)
      player:notify(tostr("Usage:  ", verb, " <message-name> [<message>] [on <object>]"));
      return;
    endif
    object = valid(iobj) ? iobj | player;
    name = this:_messagify(dobjwords[1]);
    value = dobjstr[length(dobjwords[1]) + 2..$];
    nickname = "@" + name[1..$ - 4];
    e = `add_property(object, name, value, {player, "rc"}) ! ANY';
    if (typeof(e) != ERR)
      player:notify(tostr(nickname, " on ", object.name, " is now \"", object.(name), "\"."));
    elseif (e != E_INVARG)
      player:notify(tostr(e));
    elseif ($object_utils:has_property(object, name))
      "object already has property";
      player:notify(tostr(object.name, " already has a ", nickname, " message."));
    else
      player:notify(tostr("Unable to add ", nickname, " message to ", object.name, ": ", e));
    endif
  endverb

  verb "@unmess*age" (any any any) owner: #2 flags: "rd"
    "Usage:  @unmessage <message-name> [from <object>]";
    "Remove a message property from an object (default is player).";
    set_task_perms(player);
    if (!dobjstr || length($string_utils:words(dobjstr)) > 1)
      player:notify(tostr("Usage:  ", verb, " <message-name> [from <object>]"));
      return;
    endif
    object = valid(iobj) ? iobj | player;
    name = this:_messagify(dobjstr);
    nickname = "@" + name[1..$ - 4];
    try
      delete_property(object, name);
      player:notify(tostr(nickname, " message removed from ", object.name, "."));
    except (E_PROPNF)
      player:notify(tostr("No ", nickname, " message found on ", object.name, "."));
    except error (ANY)
      player:notify(error[2]);
    endtry
  endverb

  verb _messagify (this none this) owner: #2 flags: "rxd"
    "Given any of several formats people are likely to use for a @message";
    "property, return the canonical form (\"foobar_msg\").";
    name = args[1];
    if (name[1] == "@")
      name = name[2..$];
    endif
    if (length(name) < 4 || name[$ - 3..$] != "_msg")
      name = name + "_msg";
    endif
    return name;
  endverb

  verb "@par*ents" (any none none) owner: #2 flags: "rxd"
    "'@parents <thing>' - List <thing> and its ancestors, all the way back to the Root Class (#1).";
    if (!dobjstr)
      player:notify(tostr("Usage:  ", verb, " <object>"));
      return;
    endif
    set_task_perms(player);
    o = player:match(dobjstr);
    if (!$command_utils:object_match_failed(o, dobjstr))
      object_parents = $string_utils:names_of_indented($list_utils:remove_duplicates({o, parent(o), @$object_utils:ancestors(o)}));
      for x in (object_parents)
        player:tell(x);
      endfor
    endif
  endverb

  verb "@location*s" (any none none) owner: #2 flags: "rd"
    "@locations <thing> - List <thing> and its containers, all the way back to the outermost one.";
    set_task_perms(player);
    if (!dobjstr)
      what = player;
    elseif (!valid(what = player:match(dobjstr)) && !valid(what = $string_utils:match_player(dobjstr)))
      $command_utils:object_match_failed(dobj, dobjstr);
      return;
    endif
    player:notify($string_utils:names_of({what, @$object_utils:locations(what)}));
  endverb

  verb "@chparent" (any at any) owner: HACKER flags: "rd"
    set_task_perms(player);
    if ($command_utils:object_match_failed(object = player:match(dobjstr), dobjstr))
      "...bogus object...";
    elseif ($command_utils:object_match_failed(parent = player:match(iobjstr), iobjstr))
      "...bogus new parent...";
    elseif (this != player && !$object_utils:isa(player, $player))
      "...They chparented to #1 and want to chparent back to $prog.  Probably for some nefarious purpose...";
      player:notify("You don't seem to already be a valid player class.  Perhaps chparenting away from the $player hierarchy was not such a good idea.  Permission denied.");
    elseif (is_player(object) && !$object_utils:isa(parent, $player))
      player:notify(tostr(object, " is a player and ", parent, " is not a player class."));
      player:notify("You really *don't* want to do this.  Trust me.");
    else
      if ($object_utils:isa(object, $mail_recipient))
        if (!$command_utils:yes_or_no("Chparenting a mailing list is usually a really bad idea.  Do you really want to do it?  (If you don't know why we're asking this question, please say 'no'.)"))
          return player:tell("Aborted.");
        endif
      endif
      try
        result = player:_chparent(object, parent);
        player:notify("Parent changed.");
      except (E_INVARG)
        if (valid(object) && valid(parent))
          player:notify(tostr("Some property existing on ", parent, " is defined on ", object, " or one of its descendants."));
          player:notify(tostr("Try @check-chparent ", dobjstr, " to ", iobjstr));
        else
          player:notify("Either that is not a valid object or not a valid parent");
        endif
      except (E_PERM)
        player:notify("Either you don't own the object, don't own the parent, or the parent is not fertile.");
      except (E_RECMOVE)
        player:notify("That parent object is a descendant of the object!");
      endtry
    endif
  endverb

  verb "@grep*all @egrep*all" (any any any) owner: HACKER flags: "rd"
    "Copied from Generic Agent (#58):@grep [verb author FishPot (#2)] at Thu Jan  5 08:47:14 2023 UTC";
    if (!this.programmer)
      return this:tell("This can only be used by programmers.");
    endif
    set_task_perms(player);
    if (prepstr == "in")
      pattern = dobjstr;
      objlist = player:eval_cmd_string(iobjstr, 0);
      if (!objlist[1])
        player:notify(tostr("Had trouble reading `", iobjstr, "':  "));
        player:notify_lines(@objlist[2]);
        return;
      elseif (typeof(objlist[2]) == OBJ)
        objlist = {objlist[2..2]};
      elseif (typeof(objlist[2]) != LIST)
        player:notify(tostr("Value of `", iobjstr, "' is not an object or list:  ", toliteral(objlist[2])));
        return;
      else
        objlist = objlist[2..2];
      endif
    elseif (prepstr == "from" && (player.wizard && (n = toint(toobj(iobjstr)))))
      pattern = dobjstr;
      objlist = {n};
    elseif (args)
      pattern = argstr;
      objlist = {};
    else
      player:notify(tostr("Usage:  ", verb, " <pattern> ", player.wizard ? "[in {<objectlist>} | from <number>]" | "in {<objectlist>}"));
      return;
    endif
    start = ftime();
    player:notify(tostr("Searching for verbs ", @prepstr ? {prepstr, " ", iobjstr, " "} | {}, verb == "@egrep" ? "matching the pattern " | "containing the string ", toliteral(pattern), " ..."));
    player:notify("");
    egrep = verb[2] == "e";
    all = index(verb, "a");
    $code_utils:((all ? egrep ? "find_verb_lines_matching" | "find_verb_lines_containing" | (egrep ? "find_verbs_matching" | "find_verbs_containing")))(pattern, @objlist);
    player:notify("Grep completed in: ", ftime() - start, "s");
  endverb

  verb "@check-p*roperty" (any none none) owner: #2 flags: "rd"
    "@check-prop object.property";
    "  checks for descendents defining the given property.";
    set_task_perms(player);
    if (!(spec = $code_utils:parse_propref(dobjstr)))
      player:notify(tostr("Usage:  ", verb, " <object>.<prop-name>"));
    elseif ($command_utils:object_match_failed(object = player:match(spec[1]), spec[1]))
      "...bogus object...";
    elseif (!($perm_utils:controls(player, object) || object.w))
      player:notify("You can't create a property on that object anyway.");
    elseif ($object_utils:has_property(object, prop = spec[2]))
      player:notify("That object already has that property.");
    elseif (olist = $object_utils:descendants_with_property(object, prop))
      player:notify("The following descendents have this property defined:");
      player:notify("  " + $string_utils:from_list(olist, " "));
    else
      player:notify("No property name conflicts found.");
    endif
  endverb

  verb "@dig" (any any any) owner: #2 flags: "rxd"
    set_task_perms(player);
    nargs = length(args);
    if (nargs == 1)
      room = args[1];
      exit_spec = "";
    elseif (nargs >= 3 && args[2] == "to")
      exit_spec = args[1];
      room = $string_utils:from_list(args[3..$], " ");
    elseif (argstr && !prepstr)
      room = argstr;
      exit_spec = "";
    else
      player:notify(tostr("Usage:  ", verb, " <new-room-name>"));
      player:notify(tostr("    or  ", verb, " <exit-description> to <new-room-name-or-old-room-object-number>"));
      return;
    endif
    if (room != tostr(other_room = toobj(room)))
      room_kind = player:build_option("dig_room");
      if (room_kind == 0)
        room_kind = $room;
      endif
      other_room = player:_create(room_kind);
      if (typeof(other_room) == ERR)
        player:notify(tostr("Cannot create new room as a child of ", $string_utils:nn(room_kind), ": ", other_room, ".  See `help @build-options' for information on how to specify the kind of room this command tries to create."));
        return;
      endif
      for f in ($string_utils:char_list(player:build_option("create_flags") || ""))
        other_room.(f) = 1;
      endfor
      other_room.name = room;
      other_room.aliases = {room};
      move(other_room, $nothing);
      player:notify(tostr(other_room.name, " (", other_room, ") created."));
    elseif (nargs == 1)
      player:notify("You can't dig a room that already exists!");
      return;
    elseif (!valid(player.location) || !($room in $object_utils:ancestors(player.location)))
      player:notify(tostr("You may only use the ", verb, " command from inside a room."));
      return;
    elseif (!valid(other_room) || !($room in $object_utils:ancestors(other_room)))
      player:notify(tostr(other_room, " doesn't look like a room to me..."));
      return;
    endif
    if (exit_spec)
      exit_kind = player:build_option("dig_exit");
      if (exit_kind == 0)
        exit_kind = $exit;
      endif
      exits = $string_utils:explode(exit_spec, "|");
      if (length(exits) < 1 || length(exits) > 2)
        player:notify("The exit-description must have the form");
        player:notify("     [name:]alias,...,alias");
        player:notify("or   [name:]alias,...,alias|[name:]alias,...,alias");
        return;
      endif
      do_recreate = !player:build_option("bi_create");
      to_ok = $building_utils:make_exit(exits[1], player.location, other_room, do_recreate, exit_kind);
      if (to_ok && length(exits) == 2)
        $building_utils:make_exit(exits[2], other_room, player.location, do_recreate, exit_kind);
      endif
    endif
  endverb

  verb "@edit" (any any any) owner: #2 flags: "rxd"
    if (!(verbref = $code_utils:parse_verbref(argstr)))
      return player:notify("Syntax: @edit obj:verb");
    elseif ($command_utils:object_match_failed(target = player:match(verbref[1]), verbref[1]))
      return;
    endif
    code = verb_code(target, verbref[2]);
    editor = {tostr("#$# edit name: ", target, ":", verbref[2], " upload: @program ", target, ":", verbref[2])};
    editor = {@editor, @code};
    editor = {@editor, "", ".", ""};
    player:tell_lines(editor);
  endverb

  verb props_all (this none this) owner: #2 flags: "rxd"
    return this:props_view(args[1], $ou:all_properties(args[1]));
  endverb

  verb "@props @props/* @properties/* @properties" (any any any) owner: #2 flags: "rxd"
    if (!argstr)
      return this:ooc_tell("Syntax is @props <obj>.");
    endif
    object = player:match(argstr);
    if ($command_utils:object_match_failed(object, argstr))
      return;
    elseif ($cu:switched_command(verb, "props", {object}, "props_view"))
      return;
    endif
  endverb

  verb props_view (this none this) owner: #2 flags: "rxd"
    ":props_view(OBJ object[, LIST properties]) => NONE";
    "  Prints out a list of all properties for player";
    {object, ?props = properties(object)} = args;
    if (!props)
      return player:tell("No properties are defined on ", $su:nn(object), ".");
    endif
    player:tell("Properties on ", $su:nn(object), " =>");
    idx = 1;
    lines = {$ansi:bright("IDX  TYPE   NAME                                             SYS LEVEL")};
    for prop in (props)
      try
        if (!$perm_utils:can_read_prop(player, object, prop))
          raise(E_PERM);
        endif
        {owner, perms} = property_info(object, prop);
      except e (ANY)
        lines = {@lines, tostr(" ", $su:left(idx, 4), $su:left("N/A", -5), $ansi:red(prop))};
        idx = idx + 1;
        continue;
      endtry
      clear_prop = !is_clear_property(object, prop) ? $ansi:brmagenta("*") | " ";
      defined = $ou:defines_property(object, prop) ? " " | $ansi:brgreen(">");
      type = "OBJ";
      if (typeof(object.(prop)) == MAP)
        type = "MAP";
      elseif (typeof(object.(prop)) == INT)
        type = "INT";
      elseif (typeof(object.(prop)) == LIST)
        type = "LIST";
      elseif (typeof(object.(prop)) == ERR)
        type = "ERR";
      elseif (typeof(object.(prop)) == STR)
        type = "STR";
      endif
      sys_level = $ansi:(($perm_utils:can_write_prop(player, object, prop) ? "brgreen" | "brred"))(owner:name());
      idx_col = $ansi:((idx % 2 ? "GreyCharcoal" | "GreyWheat"))($su:left(idx, 4));
      type = $ansi:((idx % 2 ? "GreyCharcoal" | "GreyWheat"))(type);
      lines = {@lines, tostr(" ", idx_col, $su:left(type, -5), $su:left(tostr(defined, clear_prop, $ansi:yellow(prop)), -51), sys_level)};
      idx = idx + 1;
    endfor
    player:tell_lines(lines);
    player:tell($ansi:brmagenta("*"), " => Not-Clear Property, ", $ansi:brgreen(">"), " => Defined on Parent");
  endverb

  verb "@show" (any any any) owner: #2 flags: "rxd"
    set_task_perms(player);
    if (dobjstr == "")
      player:notify(tostr("Usage:  ", verb, " <object-or-property-or-verb>"));
      return;
    endif
    if (index(dobjstr, ".") && (spec = $code_utils:parse_propref(dobjstr)))
      if (valid(object = player:match(spec[1])))
        return $code_utils:show_property(object, spec[2]);
      endif
    elseif (index(dobjstr, ":") && (spec = $code_utils:parse_verbref(dobjstr)))
      if (valid(object = player:match(spec[1])) && player.programmer)
        return $code_utils:show_verbdef(object, spec[2]);
      else
        player:tell("You must be a programmer to show verbs.");
        return;
      endif
    elseif (dobjstr[1] == "$" && (pname = dobjstr[2..$]) in properties(#0) && typeof(#0.(pname)) == OBJ)
      if (valid(object = #0.(pname)))
        return $code_utils:show_object(object);
      endif
    elseif (dobjstr[1] == "$" && (spec = $code_utils:parse_propref(dobjstr)))
      return $code_utils:show_property(#0, spec[2]);
    else
      if (valid(object = player:match(dobjstr)))
        return $code_utils:show_object(object);
      endif
    endif
    $command_utils:object_match_failed(object, dobjstr);
  endverb

  verb "@features @feature/* @features/*" (any any any) owner: #2 flags: "rxd"
    "Usage:  @features [<name>] for <player>";
    "List the feature objects matching <name> used by <player>.";
    if (!argstr)
      player:tell("Generating list of Features:");
      player:tell($ansi:bryellow(" ", $su:left("OBJ", 8), " ", $su:left("Type", 10), " ", "Feature"));
      player:tell("-", $su:space(8, "-"), "-", $su:space(10, "-"), "-", $su:space(57, "-"));
      for feature in ($ou:descendants($feature))
        if ($ou:is_generic(feature))
          continue;
        endif
        type = $ansi:bryellow("PLAYER");
        player:tell(" ", $su:left(feature, -8), " ", $su:left(type, -10), " ", feature:name());
      endfor
      return player:tell("  Type @feature/add <feature> to <thing> to add a feature to an object.");
    elseif ((switch = $su:explode(verb, "/")[$]) && switch != verb)
      if (switch in {"add"})
        if (!$ou:isa(feature = player:match(dobjstr), $feature))
          return player:tell("Unable to found a feature named '", dobjstr, "'.");
        elseif (!$recycler:valid(target = player:match(iobjstr)))
          return player:tell("Can't find anything named '", iobjstr, "' to add a feature to.");
        elseif (feature in target.features)
          return player:tell("Feature already exists in ", $su:nn(target), "'s features.");
        endif
        target:add_feature(feature);
        return player:tell("Successfully added feature ", $su:nn(feature), " to ", $su:nn(target), ".");
      elseif (switch in {"remove", "rem", "del", "delete"})
        if (!$ou:isa(feature = this:match(dobjstr), $feature))
          return player:tell("Unable to found a feature named '", dobjstr, "'.");
        elseif (!$recycler:valid(target = this:match(iobjstr)))
          return player:tell("Can't find anything named '", iobjstr, "' to remove a feature from.");
        elseif (!(feature in target.features))
          return player:tell("Feature is not present in target's feature list.");
        endif
        target:remove_feature(feature);
        return player:tell("Successfully removed feature ", $su:nn(feature), " from ", $su:nn(target), ".");
      else
        player:tell_lines($help:retrieve("@features"));
      endif
      return;
    elseif (!$recycler:valid(target = this:match(argstr)))
      return player:tell($ru.idun_msg);
    elseif ($ou:isa(target, $feature))
      return player:tell("Features can't have features, choom.");
    endif
    player:tell("Displaying features currently enabled on ", $su:nn(target), ":");
    if (!target.features)
      return player:tell("  No features are currently enabled...");
    endif
    player:tell($ansi:bryellow(" ", $su:left("OBJ", 8), " ", "Feature"));
    player:tell("-", $su:space(8, "-"), "-", $su:space(57, "-"));
    for feature in (target.features)
      player:tell(" ", $su:left(feature, -8), " ", feature:name());
    endfor
  endverb

  verb "@set*prop" (any at any) owner: #2 flags: "rxd"
    "Syntax:  @set <object>.<prop-name> to <value>";
    "";
    "Changes the value of the specified object's property to the given value.";
    "You must have permission to modify the property, either because you own the property or if it is writable.";
    set_task_perms(player);
    l = $code_utils:parse_propref(dobjstr);
    if (l)
      dobj = player:match(l[1]);
      if ($command_utils:object_match_failed(dobj, l[1]))
        return;
      endif
      prop = l[2];
      to_i = "to" in args;
      at_i = "at" in args;
      i = to_i && at_i ? min(to_i, at_i) | to_i || at_i;
      iobjstr = argstr[$string_utils:word_start(argstr)[i][2] + 1..$];
      iobjstr = $string_utils:trim(iobjstr);
      if (!iobjstr)
        try
          if (prop == "name")
            return player:system_tell("Please use @rename instead of setting .name directly.");
          endif
          val = dobj.(prop) = "";
        except e (ANY)
          return player:system_tell("Unable to set ", dobj, ".", prop, ": ", e[2]);
        endtry
        iobjstr = "\"\"";
      else
        val = $string_utils:to_value(iobjstr);
        if (!val[1])
          player:system_tell("Could not parse: ", iobjstr);
          return;
        elseif (!$object_utils:has_property(dobj, prop))
          player:system_tell("That object does not define that property.");
          return;
        endif
        try
          if (!$perm_utils:can_write_property(player, dobj, prop))
            return player:system_tell("Unable to set ", dobj, ".", prop, ".");
          elseif ($ou:has_callable_verb(dobj, "can_set_" + prop) && (reason = dobj:(tostr("can_set_", prop))(val[2])))
            return player:system_tell("Unable to set ", dobj, ".", prop, ": ", reason);
          endif
          val = dobj.(prop) = val[2];
        except e (ANY)
          return player:system_tell("Unable to set ", dobj, ".", prop, ": ", e[2]);
        endtry
      endif
      player:system_tell("Property ", dobj, ".", prop, " set to ", $string_utils:print(val), ".");
      $broadcast:build($su:nn(player), " @set ", $su:nn(dobj), ".", prop, " to ", $string_utils:print(val), ".");
      $vcs:update(dobj);
    else
      player:system_tell("Property ", dobjstr, " not found.");
    endif
  endverb

  verb "@chown" (any any any) owner: #2 flags: "rxd"
    "@chown <verb or prop> to <player>";
    set_task_perms(player);
    args = setremove(args, "to");
    if (length(args) != 2 || !args[2])
      player:system_tell(tostr("Usage:  ", verb, " <object-or-property-or-verb> <owner>"));
      return;
    endif
    what = args[1];
    owner = $string_utils:match_player(args[2]);
    bynumber = verb == "@chown#";
    if ($command_utils:player_match_result(owner, args[2])[1])
    elseif (spec = $code_utils:parse_verbref(what))
      object = player:match(spec[1]);
      if (!$command_utils:object_match_failed(object, spec[1]))
        vname = spec[2];
        if (bynumber)
          vname = $code_utils:toint(vname);
          if (vname == E_TYPE)
            return player:system_tell("Verb number expected.");
          elseif (vname < 1 || vname > length(verbs(object)))
            return player:system_tell("Verb number out of range.");
          endif
        endif
        info = `verb_info(object, vname) ! ANY';
        if (info == E_VERBNF)
          player:system_tell("That object does not define that verb.");
        elseif (typeof(info) == ERR)
          player:system_tell(tostr(info));
        else
          try
            result = set_verb_info(object, vname, listset(info, owner, 1));
            player:system_tell("Verb owner set.");
            $broadcast:staff_alerts($su:nn(player), " has @chown'd verb ", object, ":", vname, " to ", $su:nn(owner), ".");
          except e (ANY)
            player:system_tell(e[2]);
          endtry
        endif
      endif
    elseif (bynumber)
      player:notify("@chown# can only be used with verbs.");
    elseif (index(what, ".") && (spec = $code_utils:parse_propref(what)))
      object = player:match(spec[1]);
      if (!$command_utils:object_match_failed(object, spec[1]))
        pname = spec[2];
        e = $wiz_utils:set_property_owner(object, pname, owner);
        if (e == E_NONE)
          player:system_tell("+c Property owner set.  Did you really want to do that?");
        else
          player:system_tell(tostr(e && "Property owner set."));
        endif
        $broadcast:staff_alerts($su:nn(player), " has @chown'd prop ", object, ".", pname, " to ", $su:nn(owner), ".");
      endif
    else
      object = player:match(what);
      if (!$command_utils:object_match_failed(object, what))
        player:system_tell(tostr($wiz_utils:set_owner(object, owner) && "Object ownership changed."));
        $broadcast:staff_alerts($su:nn(player), " has @chown'd ", $su:nn(object), " to ", $su:nn(owner), ".");
      endif
    endif
  endverb
endobject