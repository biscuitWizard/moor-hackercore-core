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

  verb "@vms @vms/*" (any any any) owner: #2 flags: "rxd"
    if ($cu:switched_command(verb, "vms"))
      return;
    endif
    repo = worker_request("vms", {"repository_status"})[1];
    output = {};
    output = {@output, tostr($su:left("Game ", 15), ":  ", `repo["game"] ! E_RANGE => $server["core_history"][1] + " (Local)"')};
    output = {@output, tostr($su:right("Upstream ", 15), ":  ", repo["upstream"])};
    output = {@output, ""};
    output = {@output, tostr($su:left("Last Change ", 15), ":  ", "")};
    output = {@output, tostr($su:right("On ", 15), ":  ", "")};
    output = {@output, tostr($su:right("Id ", 15), ":  ", "")};
    output = {@output, ""};
    if (maphaskey(repo, "changes"))
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
    obj_name = "";
    for prop in (properties($sysobj))
      value = $sysobj.(prop);
      if (value == object && length(prop) > length(obj_name))
        obj_name = prop;
      endif
    endfor
    if (!obj_name)
      obj_name = tostr(object);
    endif
    worker_request("vms", {"update_object", obj_name, dump_object(object)});
  endverb
endobject