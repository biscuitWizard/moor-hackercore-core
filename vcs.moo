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
      changes = this:object_history(object);
      return;
    endif
    index_list = $lu:reverse(this:index_list());
    player:tell($ansi:white("Recent Changes:"));
    for commit in (index_list)
      player:tell($ansi:cyan("  ["), commit["short_id"], $ansi:cyan("]"), " ", commit["message"]);
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

  verb reset (this none this) owner: #2 flags: "rxd"
    result = worker_request("vcs", {"reset"});
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

  verb pull (this none this) owner: #2 flags: "rxd"
    {?dry_run = $true} = args;
    result = worker_request("vcs", {"pull", dry_run});
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
    result = worker_request("vcs", {"get_object", object});
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
      return player:tell("Changes have been submitted successfully.");
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
endobject