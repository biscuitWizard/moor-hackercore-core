object #9
  name: "Version Management System Feature"
  parent: #74
  location: #83
  owner: #36
  readable: true

  override aliases = {
    "Version",
    "Management",
    "System",
    "Feature",
    "Version Management System Feature"
  };

  verb "@vcs @vcs/*" (any any any) owner: #2 flags: "rxd"
    if ($cu:switched_command(verb, "vcs"))
      return;
    endif
    repo = this:status();
    output = {};
    output = {@output, tostr($su:left($ansi:brwhite("Game "), 15), ":  ", `repo["game_name"] ! ANY => $server["core_history"][1][1]')};
    output = {@output, tostr($su:right("Upstream ", 15), ":  ", repo["remote_url"] || "Local")};
    output = {@output, tostr("Logged in as ", worker_request("vcs", {"user/stat"})[1..3]:join(", "))};
    output = {@output, ""};
    if (repo["latest_merged_change"])
      change = repo["latest_merged_change"];
      output = {@output, tostr($su:left($ansi:brwhite("Last Change "), 15), ":  ", change["message"])};
      output = {@output, tostr($su:right("On ", 15), ":  ", ctime(change["timestamp"]))};
      output = {@output, tostr($su:right("Id ", 15), ":  ", change["short_id"])};
      output = {@output, ""};
      output = {@output, tostr($su:left("Index Size ", 15), ":  ", $su:size_string(repo["index_partition_size"]))};
      output = {@output, tostr($su:left("Refs Size ", 15), ":  ", $su:size_string(repo["refs_partition_size"]))};
      output = {@output, tostr($su:left("Objects Size ", 15), ":  ", $su:size_string(repo["objects_partition_size"]))};
      output = {@output, ""};
    else
      output = {@output, "There are currently no changes."};
    endif
    if (repo["top_change_short_id"] && (!repo["latest_merged_change"] || repo["latest_merged_change"]["id"] != repo["top_change_id"]))
      output = {@output, tostr($su:left($ansi:brwhite("Changes "), 15), ":")};
      change_status = worker_request("vcs", {"change/status"});
      for change in (change_status["changes"])
        tag = "";
        if (change["obj_id"] in change_status["objects_added"])
          tag = $ansi:green("Added");
        elseif (change["obj_id"] in change_status["objects_deleted"])
          tag = $ansi:red("Deleted");
        elseif (change["obj_id"] in change_status["objects_modified"])
          tag = $ansi:yellow("Modified");
        else
          tag = $ansi:cyan("Renamed");
        endif
        output = {@output, tostr("  [", $su:right(tag, 10), "] ", change["obj_id"])};
        stats = {};
        if (change["props_added"])
          stats = {@stats, $ansi:green(length(change["props_added"]), " Props Added")};
        endif
        if (change["props_renamed"])
          stats = {@stats, $ansi:cyan(length(mapkeys(change["props_renamed"])), " Props Renamed")};
        endif
        if (change["props_modified"])
          stats = {@stats, $ansi:yellow(length(change["props_modified"]), " Props Modded")};
        endif
        if (change["props_deleted"])
          stats = {@stats, $ansi:red(length(change["props_deleted"]), " Props Deleted")};
        endif
        if (change["verbs_added"])
          stats = {@stats, $ansi:green(length(change["verbs_added"]), " Verbs Added")};
        endif
        if (change["verbs_renamed"])
          stats = {@stats, $ansi:cyan(length(mapkeys(change["verbs_renamed"])), " Verbs Renamed")};
        endif
        if (change["verbs_modified"])
          stats = {@stats, $ansi:yellow(length(change["verbs_modified"]), " Verbs Modded")};
        endif
        if (change["verbs_deleted"])
          stats = {@stats, $ansi:red(length(change["verbs_deleted"]), " Verbs Deleted")};
        endif
        if (stats)
          output = {@output, tostr("    ", $ansi:brwhite("-"), " ", $su:from_list(stats, " / "))};
        endif
      endfor
    else
      output = {@output, "There are currently no changes."};
    endif
    player:tell_lines(output);
  endverb

  verb _clone (this none this) owner: #2 flags: "rxd"
    remaining_objects = all_objects = this:list_objects();
    all_obj_ids = {};
    for obj_spec in (all_objects)
      all_obj_ids = setadd(all_obj_ids, toobj(obj_spec["oid"]));
    endfor
    "## STEP 1: Halt all tasks";
    for t in (queued_tasks())
      kill_task(t[1]);
    endfor
    "## STEP 2: Clean unused objects";
    for i in [1..max_object()]
      if (!valid(obj_id = toobj(i)))
        continue;
      elseif (obj_id in all_obj_ids)
        continue;
      endif
      $recycler:nuke(obj_id);
    endfor
    "## STEP 3: Load new and existing objects in order";
    while (remaining_objects)
      {obj_spec, remaining_objects} = $lu:dequeue(remaining_objects);
      this:load_object(obj_spec["filename"]);
      commit();
    endwhile
  endverb

  verb update (this none this) owner: #2 flags: "rxd"
    {object} = args;
    "we commit before operation because if this is called after setting";
    "verb code, dump_object won't capture it";
    if ($ou:is_uuobjid(object))
      "we don't commit uuobjids";
      return;
    endif
    commit();
    obj_name = this:get_object_name(object);
    worker_request("vcs", {"object/update", obj_name, dump_object(object)});
  endverb

  verb rename_object (this none this) owner: #2 flags: "rxd"
    ":rename_object(OBJ object, STR new_name[, STR old_name]) => NONE";
    "  Renames an object in VCS to a new name";
    {object, new_name, ?old_name = this:get_object_name(object)} = args;
    worker_request("vcs", {"object/rename", old_name, new_name});
  endverb

  verb get_object_name (this none this) owner: #36 flags: "rxd"
    ":get_object_name(OBJ object) => STR";
    "  all objects in VCS get saved by a unique name";
    "  This defaults to the value in $sysobj; but if not defined it's just the obj id";
    {object} = args;
    obj_name = "";
    for prop in (properties($sysobj))
      value = $sysobj.(prop);
      if (value == object && length(prop) > length(obj_name))
        obj_name = prop;
      endif
    endfor
    return obj_name || tostr(object);
  endverb

  verb "vcs_log vcs_history" (this none this) owner: #2 flags: "rxd"
    "@vcs/log";
    "  Shows a log of commit messages";
    if (argstr)
      if ($cu:object_match_failed(object = player:match(argstr), argstr))
        return;
      endif
      changes = $lu:reverse(this:object_history(object));
      player:system_tell($ansi:white("Displaying object VCS history for ", $su:nn(object), ":"));
      for change in (changes)
        if (!maphaskey(change, "change_description"))
          continue;
        endif
        player:system_tell($ansi:cyan("  ["), change["short_change_id"], $ansi:cyan("] "), change["change_description"], $ansi:white(" (", $time_utils:short_english_time(time() - change["timestamp"], time(), 2), " ago)"));
        stats = {};
        details = change["details"];
        if (details["props_added"])
          stats = {@stats, $ansi:green(length(details["props_added"]), " Props Added")};
        endif
        if (details["props_renamed"])
          stats = {@stats, $ansi:cyan(length(mapkeys(details["props_renamed"])), " Props Renamed")};
        endif
        if (details["props_modified"])
          stats = {@stats, $ansi:yellow(length(details["props_modified"]), " Props Modded")};
        endif
        if (details["props_deleted"])
          stats = {@stats, $ansi:red(length(details["props_deleted"]), " Props Deleted")};
        endif
        if (details["verbs_added"])
          stats = {@stats, $ansi:green(length(details["verbs_added"]), " Verbs Added")};
        endif
        if (details["verbs_renamed"])
          stats = {@stats, $ansi:cyan(length(mapkeys(details["verbs_renamed"])), " Verbs Renamed")};
        endif
        if (details["verbs_modified"])
          stats = {@stats, $ansi:yellow(length(details["verbs_modified"]), " Verbs Modded")};
        endif
        if (details["verbs_deleted"])
          stats = {@stats, $ansi:red(length(details["verbs_deleted"]), " Verbs Deleted")};
        endif
        if (!stats)
          continue;
        endif
        player:system_tell($ansi:white("    - "), $su:from_list(stats, " / "));
      endfor
      return;
    endif
    index_list = $lu:reverse(this:index_list());
    player:system_tell($ansi:white("Recent Changes:"));
    for commit in (index_list)
      player:system_tell($ansi:cyan("  ["), commit["short_id"], $ansi:cyan("]"), " ", commit["message"]);
    endfor
  endverb

  verb changes (this none this) owner: #2 flags: "rxd"
    ":changes() => Returns a list of active changes in our source control";
    result = worker_request("vcs", {"changes"});
    if (typeof(result) == ERR)
      raise(result, error_message(result));
    endif
    return result;
  endverb

  verb status (this none this) owner: #2 flags: "rxd"
    result = worker_request("vcs", {"status"});
    if (typeof(result) == ERR)
      raise(result, error_message(result));
    endif
    return result;
  endverb

  verb get_commits (this none this) owner: #2 flags: "rxd"
    result = worker_request("vcs", {"get_commits"});
    if (typeof(result) == ERR)
      raise(result, error_message(result));
    endif
    return result;
  endverb

  verb get_objects (this none this) owner: #2 flags: "rxd"
    result = worker_request("vcs", {"get_objects", @args});
    if (typeof(result) == ERR)
      raise(result, error_message(result));
    endif
    return result;
  endverb

  verb list_objects (this none this) owner: #2 flags: "rxd"
    result = worker_request("vcs", {"list_objects"});
    if (typeof(result) == ERR)
      raise(result, error_message(result));
    endif
    return result;
  endverb

  verb get_object (this none this) owner: #2 flags: "rxd"
    {object} = args;
    if (typeof(object) == OBJ)
      object = this:get_object_name(object);
    endif
    result = worker_request("vcs", {"object/get", object});
    if (typeof(result) == ERR)
      raise(result, error_message(result));
    endif
    return result;
  endverb

  verb load_object (this none this) owner: #2 flags: "rxd"
    ":load_object(OBJ/STR object) => OBJ";
    "  Loads a copy of an object from virtual control";
    "  This is destructive and will typically blitz an object";
    {object} = args;
    obj_data = this:get_object(object);
    if (valid(existing_object = $ou:resolve_coreref(object)))
      "### STEP ONE: Delete any verbs or properties not on the object";
      "              This ensures a clean wipe for load object";
      for v, i in (obj_verbs = verbs(existing_object))
        obj_verbs[i] = verb_info(existing_object, v)[3];
      endfor
      for invalid_verb in ($set_utils:diff(obj_verbs, obj_data["verbs"]))
        delete_verb(existing_object, invalid_verb);
      endfor
      for invalid_prop in ($set_utils:diff(properties(existing_object), obj_data["properties"]))
        delete_property(existing_object, invalid_prop);
      endfor
      commit();
      "### STEP TWO: Load the new object onto the now clean recipient";
      load_object(obj_data["obj_def"], ["target_object" -> existing_object]);
      "now we can return normally";
      return existing_object;
    endif
    load_object(obj_data["obj_def"]);
  endverb

  verb "vcs_commit vcs_submit" (this none this) owner: #2 flags: "rxd"
    if (!argstr)
      return player:notify(tostr("Syntax: @", verb, " <msg>"));
    endif
    errors = {};
    active_changes = this:change_status();
    tracked_objects = this:object_list();
    for object in ($set_utils:union(active_changes["objects_modified"], active_changes["objects_added"], mapvalues(active_changes["objects_renamed"])))
      objid = $ou:resolve_coreref(object);
      if ($ou:is_uuobjid(objid.owner))
        errors = {@errors, tostr($ansi:red("[ERROR]"), " Object ", objid, " is owned by uuobjid ", objid.owner, "; it should be owned by a numbered object.")};
      endif
      owner_coreref = this:get_object_name(objid.owner);
      if (!(owner_coreref in tracked_objects))
        errors = {@errors, tostr($ansi:red("[ERROR]"), " Object ", objid, " is not owned by a tracked object; make sure the owner is valid and exists in the repository.")};
      endif
      for verbstr in (verbs(objid))
        {owner, perms, name} = verb_info(objid, verbstr);
        owner_coreref = this:get_object_name(owner);
        if ($ou:is_uuobjid(owner))
          errors = {@errors, tostr($ansi:red("[ERROR]"), " Verb ", objid, ":", verbstr, " is owned by uuobjid ", owner, "; it should be owned by a numbered object.")};
        endif
        if (!(owner_coreref in tracked_objects))
          errors = {@errors, tostr($ansi:red("[ERROR]"), " Verb ", objid, ":", verbstr, " is not owned by a tracked object; make sure the owner is valid and exists in the repository.")};
        endif
      endfor
      for propstr in (properties(objid))
        {owner, perms} = property_info(objid, propstr);
        owner_coreref = this:get_object_name(owner);
        if ($ou:is_uuobjid(owner))
          errors = {@errors, tostr($ansi:red("[ERROR]"), " Property ", objid, ".", propstr, " is owned by uuobjid ", owner, "; it should be owned by a numbered object.")};
        endif
        if (!(owner_coreref in tracked_objects))
          errors = {@errors, tostr($ansi:red("[ERROR]"), " Property ", objid, ".", propstr, " is not owned by a tracked object; make sure the owner is valid and exists in the repository.")};
        endif
      endfor
    endfor
    if (errors)
      return player:tell_lines({"Unable to submit changes as change validation has failed. Please fix the following errors:", @errors});
    endif
    result = this:submit(argstr);
    if (result && !result["changes"])
      player:tell("Changes have been submitted successfully.");
      $broadcast:staff_alerts($su:nn(player), " has submitted changes to VCS with comment: ", argstr);
    endif
  endverb

  verb submit (this none this) owner: #2 flags: "rxd"
    result = worker_request("vcs", {"change/submit", @args});
    if (typeof(result) == ERR)
      raise(result, error_message(result));
    endif
    return result;
  endverb

  verb index_list (this none this) owner: #2 flags: "rxd"
    result = worker_request("vcs", {"index/list", @args});
    if (typeof(result) == ERR)
      raise(result, error_message(result));
    endif
    return result;
  endverb

  verb change_status (this none this) owner: #2 flags: "rxd"
    result = worker_request("vcs", {"change/status"});
    if (typeof(result) == ERR)
      raise(result, error_message(result));
    endif
    return result;
  endverb

  verb object_list (this none this) owner: #2 flags: "rxd"
    result = worker_request("vcs", {"object/list"});
    if (typeof(result) == ERR)
      raise(result, error_message(result));
    endif
    return result;
  endverb

  verb object_history (this none this) owner: #2 flags: "rxd"
    {object_id} = args;
    if (typeof(object_id) == OBJ)
      object_id = this:get_object_name(object_id);
    endif
    result = worker_request("vcs", {"object/history", object_id});
    if (typeof(result) == ERR)
      raise(result, error_message(result));
    endif
    return result;
  endverb

  verb create_user (this none this) owner: #36 flags: "rxd"
    "create_user(OBJ user[, str email-address])";
    "Creates a user in moov. Does not assign permissions or API keys.";
    {user, ?email = E_NONE} = args;
    valid(user) && is_player(user) || raise(E_INVARG, "User is not a valid object or has no player flag");
    user.name != "" || raise(E_INVARG, "User " + toliteral(user) + " must have a name set");
    set_task_perms(player);
    name = user.name;
    default_email = tostr(name, "@", $network.site);
    if (email == E_NONE && user.email_address)
      email = user.email_address;
    endif
    res = worker_request("vcs", {"user/create", user, email != E_NONE ? email | default_email, name});
    return res;
  endverb

  verb list_users (this none this) owner: #2 flags: "rxd"
    "$vcs:list_users() - returns a list... of users. format unknown. More to follow.";
    "set_task_perms(player)";
    return worker_request("vcs", {"user/list"});
  endverb

  verb apply_change_diff (this none this) owner: #2 flags: "rxd"
    ":apply_change_diff(STR/OBJ object_name, MAP changes, LIST object_dump) => NONE";
    "  Applies a change diff to an object";
    {object_name, changes, object_dump} = args;
    player:tell("Updating object ", object_name);
    player:tell("Changes: ", toliteral(changes));
    player:tell_lines(object_dump);
    "quick data validation";
    change_fields = {"props_added", "props_renamed", "props_modified", "props_deleted", "verbs_added", "verbs_renamed", "verbs_modified", "verbs_deleted"};
    for field in (change_fields)
      if (!maphaskey(changes, field))
        raise(E_INVARG, tostr("Changes structure is missing required key: ", field));
      endif
    endfor
    if (typeof(object_dump) != LIST)
      raise(E_INVARG, "Invalid objdef dump provided. Must be a list of strings.");
    endif
    "validate our object target";
    object = typeof(object_name) == OBJ ? object_name | $ou:resolve_coreref(object_name);
    if (!$recycler:valid(object))
      raise(E_INVARG, tostr(object_name, " resolved to ", object, ", which is invalid."));
    endif
    "delete any data that isn't needed";
    for verb_name in ({@changes["verbs_deleted"], @mapkeys(changes["verbs_renamed"])})
      `delete_verb(object, verb_name) ! ANY';
    endfor
    for prop_name in ({@changes["props_deleted"], @mapkeys(changes["props_renamed"])})
      `delete_property(object, prop_name) ! ANY';
    endfor
    "now to apply the dump";
    load_object(object_dump, ["target_object" -> object]);
  endverb

  verb vcs_abandon (this none this) owner: #36 flags: "rxd"
    diff = this:abandon();
    this:apply_game_diff(diff);
  endverb

  verb abandon (this none this) owner: #2 flags: "rxd"
    result = worker_request("vcs", {"change/abandon"});
    if (typeof(result) == ERR)
      raise(result, error_message(result));
    endif
    return result;
  endverb

  verb apply_game_diff (this none this) owner: #2 flags: "rxd"
    {diff} = args;
    for change in (diff["changes"])
      obj_id = change["obj_id"];
      dump = this:get_object(obj_id);
      "obj_id can be a bit special, if it's renamed we might not have the rename yet";
      "so it's good practice to just look up at the rename table";
      for value, key in (diff["objects_renamed"])
        if (obj_id == value)
          obj_id = key;
          break;
        endif
      endfor
      this:apply_change_diff(obj_id, change, dump);
    endfor
    for deleted_obj in (diff["objects_deleted"])
      `recycle(deleted_obj) ! ANY';
    endfor
  endverb
endobject