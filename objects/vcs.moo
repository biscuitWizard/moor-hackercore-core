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
    repo = worker_request("vcs", {"status"})[1];
    output = {};
    output = {@output, tostr($su:left($ansi:brwhite("Game "), 15), ":  ", `repo["game"] ! ANY => tostr($server["core_history"][1][1], " (Local)")')};
    output = {@output, tostr($su:right("Upstream ", 15), ":  ", repo["upstream"])};
    output = {@output, ""};
    output = {@output, tostr($su:left($ansi:brwhite("Last Change "), 15), ":  ", repo["last_commit_message"])};
    output = {@output, tostr($su:right("On ", 15), ":  ", repo["last_commit_datetime"])};
    output = {@output, tostr($su:right("Id ", 15), ":  ", repo["last_commit_id"])};
    output = {@output, ""};
    if (maphaskey(repo, "changes"))
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
    remaining_objects = all_objects = worker_request("vms", {"list_objects"});
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
      obj_dump = worker_request("vms", {"get_objects", obj_spec["filename"]})[1];
      load_object(obj_dump, ["target_object" -> obj_id]);
      commit();
    endwhile
  endverb

  verb update (this none this) owner: #2 flags: "rxd"
    {object} = args;
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
    return player:tell_lines(worker_request("vcs", {"commit", argstr}));
  endverb

  verb vcs_log (this none this) owner: #2 flags: "rxd"
    "@vcs/log";
    "  Shows a log of commit messages";
    player:tell($ansi:white("Recent Commits:"));
    commits = worker_request("vcs", {"get_commits"});
    for commit in (commits)
      player:tell($ansi:cyan("  ["), commit["id"], $ansi:cyan("]"), " ", commit["message"]);
    endfor
  endverb
endobject