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
    output = {@output, tostr($su:left($ansi:brwhite("Game "), 15), ":  ", `repo["game"] ! ANY => tostr($server["core_history"][1][1], " (Local)")')};
    output = {@output, tostr($su:right("Upstream ", 15), ":  ", repo["upstream"])};
    output = {@output, ""};
    output = {@output, tostr($su:left($ansi:brwhite("Last Change "), 15), ":  ", repo["last_commit_message"])};
    output = {@output, tostr($su:right("On ", 15), ":  ", ctime(repo["last_commit_datetime"]))};
    output = {@output, tostr($su:right("Id ", 15), ":  ", repo["last_commit_id"])};
    output = {@output, ""};
    if (maphaskey(repo, "changes") && repo["changes"])
      output = {@output, tostr($su:left($ansi:brwhite("Changes "), 15), ":")};
      for change in (repo["changes"])
        tag = change[1];
        if (tag == "Modified")
          tag = $ansi:yellow(tag);
        elseif (tag == "Renamed")
          tag = $ansi:cyan(tag);
        endif
        output = {@output, tostr("  [", $su:right(tag, 10), "] ", change[2])};
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
      obj_id = toobj(obj_spec["oid"]);
      obj_dump = this:get_objects(obj_spec["filename"]);
      load_object(obj_dump, ["target_object" -> obj_id]);
      commit();
    endwhile
  endverb

  verb update (this none this) owner: #2 flags: "rxd"
    {object} = args;
    "we commit before operation because if this is called after setting";
    "verb code, dump_object won't capture it";
    commit();
    obj_name = this:get_object_name(object);
    worker_request("vcs", {"update_object", obj_name, dump_object(object)});
  endverb

  verb rename_object (this none this) owner: #2 flags: "rxd"
    ":rename_object(OBJ object, STR new_name) => NONE";
    "  Renames an object in VCS to a new name";
    {object, new_name} = args;
    worker_request("vms", {this:get_object_name(object), new_name});
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

  verb vcs_commit (this none this) owner: #2 flags: "rxd"
    if (!argstr)
      return player:notify("Syntax: @vcs/commit <msg>");
    endif
    name = $cu:read("name to commit as");
    return player:tell(worker_request("vcs", {"commit", argstr, name}));
  endverb

  verb vcs_log (this none this) owner: #2 flags: "rxd"
    "@vcs/log";
    "  Shows a log of commit messages";
    player:tell($ansi:white("Recent Changes:"));
    commits = this:get_commits();
    for commit in (commits)
      player:tell($ansi:cyan("  ["), commit["id"], $ansi:cyan("]"), " ", commit["message"]);
    endfor
  endverb

  verb vcs_reset (this none this) owner: #2 flags: "rxd"
    ":@vcs/reset";
    changes = this:status()["changes"];
    if (!changes)
      return player:tell("No changes to discard; nothing to do.");
    elseif (!argstr || argstr != "confirm")
      return player:tell("@vcs/reset will !WIPE! everything back to the last change. To continue type @vcs/reset confirm.");
    endif
    player:tell_lines(this:reset());
    this:_clone();
  endverb

  verb vcs_pull (this none this) owner: #2 flags: "rxd"
    confirmed = "confirm" == argstr;
    "this will pull out our dry run";
    pull_details = this:pull(true);
    if (!pull_details)
      return player:tell("Nothing to do; we're caught up!");
    endif
    warnings = {};
    for commit in (pull_details)
      for deleted_obj in (commit["deleted_objects"])
        if (c = children(deleted_obj))
          warnings = setadd(warnings, tostr("  ", $ansi:bryellow("[WARNING] "), $su:nn(deleted_obj), " will be deleted; but it has ", length(c), " children which will be deleted as well."));
        endif
      endfor
    endfor
    if (warnings && !confirmed)
      player:tell("Unable to automatically pull as some changes contain destructive operations:");
      player:tell_lines(warnings);
      player:tell("To pull anyways type: ", $ansi:brwhite("@vcs/pull confirm"), ".");
      return;
    endif
    "do the actual pull";
    pull_details = this:pull(false);
    results = {$ansi:brwhite($su:left("Pulled Changes", 15), " :")};
    for commit in (pull_details)
      results = {@results, tostr($ansi:cyan("  ["), commit["commit_id"], $ansi:cyan("] "), commit["commit_message"], " (By ", commit["commit_author"], ")")};
      for deleted_obj in (commit["deleted_objects"])
        $recycler:nuke($ou:resolve_coreref(deleted_obj));
      endfor
      for added_obj in (commit["added_objects"])
        obj_def = worker_request("vcs", {"get_objects", tostr(added_obj)});
        load_object(obj_def);
      endfor
      for change in (commit["changes"])
        "these are all modified objects more or less";
        obj_def = worker_request("vcs", {"get_objects", tostr(change["obj_id"])});
        target_obj = $ou:resolve_coreref(change["obj_id"]);
        load_object(obj_def, ["target_object" -> target_obj]);
        for deleted_prop in (change["deleted_props"])
          delete_property(target_obj, deleted_prop);
        endfor
        for deleted_verb in (change["deleted_verbs"])
          delete_verb(target_obj, deleted_verb);
        endfor
      endfor
    endfor
    player:tell_lines(results);
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
    if (existing_object = $ou:resolve_coreref(object))
      "### STEP ONE: Delete any verbs or properties not on the object";
      "              This ensures a clean wipe for load object";
      for invalid_verb in ($set_utils:diff(verbs(existing_object), obj_data["verbs"]))
        `delete_verb(existing_object, invalid_verb) ! E_VERBNF';
      endfor
      for invalid_prop in ($set_utils:diff(properties(existing_object), obj_data["properties"]))
        `delete_property(existing_object, invalid_prop) ! E_PROPNF';
      endfor
      "### STEP TWO: Load the new object onto the now clean recipient";
      load_object(obj_data["obj_def"], ["target_object" -> existing_object]);
      "now we can return normally";
      return existing_object;
    endif
    return load_object(obj_data["obj_def"]);
  endverb
endobject