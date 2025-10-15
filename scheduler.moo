object #50
  name: "Moo Task Scheduler"
  parent: #78
  owner: #36

  property incoming_tasks (owner: #36, flags: "r") = {};
  property kill_tasks (owner: #36, flags: "r") = {};
  property killed_tasks (owner: #36, flags: "r") = {};
  property processing (owner: #36, flags: "r") = 0;
  property run_task (owner: #36, flags: "r") = 0;
  property scheduled_tasks (owner: #36, flags: "r") = {};

  override help_msg = {
    "OVERVIEW",
    "",
    "The scheduler will start when the first item is scheduled. You can schedule verbs to run once at a specific time (schedule_at), or once in a certain amount of seconds (schedule_for), or you can schedule verbs to run over and over at certain intervals (schedule_every).",
    "",
    "DEBUGGING",
    "",
    "There are a number of places in the $scheduler code where you can add debugging as you desire. Many of these are called out with comments.",
    "",
    "SCHEDULING VERBS",
    "",
    "schedule_for( INT time, OBJ object, STR verbname [, LIST optional_args]) =>",
    " add verbname on object to be run at time seconds from now.  If optional_args is given, then they are  passed to the verb when it's run",
    "",
    "schedule_at( INT time, OBJ object, STR verbname [, LIST optional_args]) =>",
    " add verbname on object to be run at time (as time() returns).  If optional_args is given, then they  are passed to the verb when it's run",
    "",
    "schedule_every( VARIES interval, OBJ object, STR verbname [, LIST optional_args, INT allow_duplicates])",
    " add verbname on object to be run every interval seconds from now.  If optional_args is given, then they are passed to the verb when it's run",
    " if allow_duplicates is passed and true, duplicate entries will be allowed, otherwise they will not",
    "",
    "interval args supported:",
    "  INT - fixed number of seconds",
    "  STR - hh:mm:ss time less than 24 hours, every day as close to this time as possible",
    "  {INT minimum, INT range} - between minimum and minimum+range seconds",
    "  {OBJ timing_obj, STR verbname, [LIST additional args]} - calculated by call to timing_obj:verbname",
    "",
    "UNSCHEDULING VERBS",
    "",
    "remove_scheduled( OBJ object, STR verbname, LIST iargs = \"THIS IS A NULL VALUE\") => remove object:verbname from scheduled tasks to be run.",
    " Returns 1 if the task was successfully removed, 0 if it wasn't",
    " Returns E_PERM if the caller is not the owner and not a wizard",
    "",
    "CHECKING IF VERBS ARE SCHEDULED",
    "",
    "is_scheduled(OBJ object, STR verbname) => returns 1 if the object:verbname is scheduled, 0 if it's not",
    "",
    ":when_scheduled(OBJ objt, STR verbname) => INT",
    " returns timestamp when a verb is scheduled for",
    "",
    "OTHER $SCHEDULER VERBS",
    "",
    "halt => stops scheduler",
    "start => starts scheduler",
    "",
    "VIEWING ALL SCHEDULED TASKS",
    "",
    "To view all scheduled tasks you can 'look $scheduler'",
    "",
    "If you have the Scheduler Wizard Verbs package installed, type '@scheduled' with no arguments.",
    "",
    "VIEWING A PORTION OF SCHEDULED TASKS",
    "",
    "@scheduled allows you to slice and dice scheduled tasks as you see fit. Here are the options at your disposal:",
    "",
    "@scheduled repeat                             => display only scheduled tasks that are repeating",
    "",
    "@scheduled norepeat                           => display only scheduled tasks that do no repeat",
    "",
    "@scheduled soon                               => display tasks that are scheduled to run in the next 5 minutes",
    "",
    "@scheduled later                              => display tasks that are scheduled to run later than 5 minutes",
    "",
    "@scheduled interval                           => display scheduled tasks that are set to run at a varied interval IE: [200, 300]",
    "",
    "@scheduled verb                               => display scheduled tasks who's reschedule time is determined by a verb",
    "",
    "@scheduled timestring                         => display scheduled tasks that are rescheduled based on a time string IE: 15:00",
    "",
    "@scheduled seconds                            => display scheduled tasks that are rescheduled based on a set second based interval IE: 300",
    "",
    "@scheduled duplicates                         => display duplicate obj&verb combinations in the $scheduler",
    "",
    "@scheduled by <obj or name>                   => display verbs scheduled by a specific person",
    "",
    "@scheduled for <obj|corified ref or verbname> => display verbs scheduled for a specific object or verb",
    "",
    "@scheduled without <verb>                     => display verbs scheduled, excluding <verb>"
  };

  verb run_scheduled (this none this) owner: #2 flags: "rxd"
    "run_scheduled( [INT kill]) => if kill is provided and true then kill the scheduler task, otherwise start it";
    if (caller_perms().wizard)
      {?kill = 0} = args;
      if (kill)
        count = 1;
        while (this.processing && count < 11)
          suspend(1);
          count = count + 1;
        endwhile
        `kill_task(this.run_task) ! ANY';
      else
        if ($code_utils:task_valid(this.run_task) && task_id() != this.run_task)
          return 1;
        else
          "do scheduled stuff here";
          delay = 3600;
          tt = time();
          to_do = this.scheduled_tasks;
          if (!to_do)
            `kill_task(this.run_task) ! ANY';
          else
            this.processing = 1;
            new_tasks = {};
            for event in (to_do)
              {repeat, object, verbo, runtime, owner, ?opargs = {}} = event;
              if (typeof(opargs) != LIST)
                "you may want to include some kind of error message surfacing here";
                opargs = {opargs};
              endif
              did_run = 0;
              if (tt >= runtime)
                fork (0)
                  try
                    "you can reset who the `player` is, possibly a generic $player_task_owner";
                    set_task_perms(owner);
                    if ($recycler:valid(object))
                      object:(verbo)(@opargs);
                    else
                      "TODO: you may want to include some kind of error message handling here";
                    endif
                  except ecodes (ANY)
                    $error:log(ecodes);
                  endtry
                endfork
                if (repeat && (runtime = this:next_runtime(@event)))
                  if (runtime - time() < 10 && verbo != "tick")
                    "You may want to add some kind of error logging here";
                  endif
                  new_tasks = {@new_tasks, {repeat, object, verbo, runtime, owner, opargs}};
                endif
                "we no longer mark not processing at this point, now doing it just before we set the tasks prop below - J 3/29/20";
                "this.processing = 0";
              else
                new_tasks = {@new_tasks, event};
              endif
              ticks_left() < 2000 || seconds_left() < 2 && suspend(min($login:current_lag(), 10));
            endfor
          endif
          if (this.incoming_tasks)
            "add any tasks that were scheduled while this was running";
            new_tasks = {@new_tasks, @this.incoming_tasks};
            this.incoming_tasks = {};
          endif
          if (`new_tasks ! E_VARNF => {}')
            new_tasks = $list_utils:sort_alist(1, new_tasks, 4);
            delay = new_tasks[1][4] - time();
            delay = max(delay, 1);
            fork SCHED (delay)
              try
                this:(verb)();
              except e (ANY)
                $error:log(e);
              endtry
            endfork
            this.run_task = SCHED;
          endif
          this.processing = 0;
          this.scheduled_tasks = `new_tasks ! E_VARNF => {}';
          return 1;
        endif
      endif
    else
      return E_PERM;
    endif
  endverb

  verb schedule_for (this none this) owner: #36 flags: "rxd"
    "schedule_for( INT time, OBJ object, STR verbname [, LIST optional_args]) =>";
    "add verbname on object to be run at time seconds from now.  If optional_args is given, then they are passed to the verb when it's run";
    {runtime, object, verbname, ?opargs = {}} = args;
    task = {0, object, verbname, time() + runtime, caller_perms(), opargs};
    if (this.processing)
      this.incoming_tasks = {@this.incoming_tasks, task};
    else
      this.scheduled_tasks = {@this.scheduled_tasks, task};
    endif
    this:halt();
    return this:start();
  endverb

  verb schedule_at (this none this) owner: #36 flags: "rxd"
    "schedule_at( INT time, OBJ object, STR verbname [, LIST optional_args]) =>";
    "add verbname on object to be run at time (as time() returns).  If optional_args is given, then they are passed to the verb when it's run";
    {runtime, object, verbname, ?opargs = {}} = args;
    repeat = 0;
    tasks = this.scheduled_tasks;
    objs = $list_utils:slice(tasks, 2);
    verbage = $list_utils:slice(tasks, 3);
    i = object in objs;
    if (i && verbage[i] == verbname)
      return E_INVARG;
    endif
    task = {repeat, object, verbname, runtime, caller_perms(), opargs};
    if (this.processing)
      this.incoming_tasks = {@this.incoming_tasks, task};
    else
      this.scheduled_tasks = {@this.scheduled_tasks, task};
    endif
    this:halt();
    return this:start();
  endverb

  verb "start halt" (this none this) owner: #36 flags: "rxd"
    "halt => stops scheduler";
    "start => starts scheduler";
    kill = 0;
    if (verb == "halt")
      kill = 1;
    endif
    return this:run_scheduled(kill);
  endverb

  verb schedule_every (this none this) owner: #36 flags: "rxd"
    "schedule_every( VARIES interval, OBJ object, STR verbname [, LIST optional_args, INT allow_duplicates]) =>";
    "add verbname on object to be run every interval seconds from now.  If optional_args is given, then they are passed to the verb when it's run";
    "if allow_duplicates is passed and true, duplicate entries will be allowed, otherwise they will not";
    "";
    "interval args supported:";
    "  INT - fixed number of seconds";
    "  STR - hh:mm:ss time less than 24 hours, every day as close to this time as possible";
    "  {INT minimum, INT range} - between minimum and minimum+range seconds";
    "  {OBJ timing_obj, STR verbname, [LIST additional args]} - calculated by call to timing_obj:verbname";
    {repeat, object, verbname, ?opargs = {}, ?allow_duplicates = 0} = args;
    "throw E_INVARG if the repeat arg is bad";
    this:check_repeat_args(repeat);
    runtime = time();
    if (!allow_duplicates)
      tasks = this.scheduled_tasks;
      objs = $list_utils:slice(tasks, 2);
      verbage = $list_utils:slice(tasks, 3);
      i = object in objs;
      if (i && verbage[i] == verbname)
        return E_INVARG;
      endif
    endif
    task = {repeat, object, verbname, runtime, caller_perms(), opargs};
    if (this.processing)
      this.incoming_tasks = {@this.incoming_tasks, task};
    else
      this.scheduled_tasks = {@this.scheduled_tasks, task};
    endif
    this:halt();
    return this:start();
  endverb

  verb look_Self (this none this) owner: #36 flags: "rxd"
    pass(@args);
    this:display_schedule();
  endverb

  verb remove_scheduled (this none this) owner: #36 flags: "rxd"
    "remove_scheduled( OBJ object, STR verbname, LIST iargs = \"THIS IS A NULL VALUE\") => remove object:verbname from scheduled tasks to be run.";
    " Returns 1 if the task was successfully removed, 0 if it wasn't";
    " Returns E_PERM if the caller is not the owner and not a wizard";
    {object, ?verbname = "", ?iargs = "THIS IS A NULL VALUE"} = args;
    cp = caller_perms();
    tasks = this.scheduled_tasks;
    killed = 0;
    for x in (tasks)
      $command_utils:suspend_if_needed(0);
      if (x[2] == object && (verbname == "" || x[3] == verbname) && (iargs == "THIS IS A NULL VALUE" || x[6] == iargs))
        if (cp == this.owner || cp.wizard || cp == x[5])
          this.scheduled_tasks = setremove(this.scheduled_tasks, x);
          killed = killed + 1;
        else
          return E_PERM;
        endif
      endif
    endfor
    tasks = this.incoming_tasks;
    for x in (tasks)
      $command_utils:suspend_if_needed(0);
      if (x[2] == object && (verbname == "" || x[3] == verbname) && (iargs == "THIS IS A NULL VALUE" || x[6] == iargs))
        if (cp == this.owner || cp.wizard || cp == x[5])
          this.incoming_tasks = setremove(this.incoming_tasks, x);
          killed = killed + 1;
        else
          return E_PERM;
        endif
      endif
    endfor
    return killed;
  endverb

  verb is_scheduled (this none this) owner: #36 flags: "rxd"
    ":is_scheduled(object OBJ, verbname STR) => returns 1 if the object:verbname is scheduled, 0 if it's not";
    {objt, verbname} = args;
    for tasks in ({this.scheduled_tasks, this.incoming_tasks})
      for x in (tasks)
        if (x[2] == objt && x[3] == verbname)
          return 1;
        endif
      endfor
    endfor
    return 0;
  endverb

  verb match (this none this) owner: #36 flags: "rxd"
    command = callers()[$][2];
    if (command in {"look", "l"})
      filter = args[1];
      thing = $string_utils:literal_object(filter, player);
      if (!$recycler:valid(thing))
        thing = `complex_match(filter, $list_utils:slice(this.scheduled_tasks, 2))[1] ! ANY => $failed_match';
        if (typeof(thing) != STR)
          return thing;
        endif
      endif
      this:look_self(thing);
      return "null";
    endif
    return pass(@args);
  endverb

  verb when_scheduled (this none this) owner: #36 flags: "rxd"
    ":when_scheduled(OBJ objt, STR verbname) => INT";
    "returns timestamp when a verb is scheduled for";
    {objt, verbname} = args;
    for tasks in ({this.scheduled_tasks, this.incoming_tasks})
      for x in (tasks)
        if (x[2] == objt && x[3] == verbname)
          return x[4];
        endif
      endfor
    endfor
    return 0;
  endverb

  verb next_runtime (this none this) owner: #36 flags: "rxd"
    ":next_runtime(@scheduled_task) => runtime INT (time value)";
    " given a scheduled task, calculates the next runtime";
    {repeat, object, verbo, runtime, owner, ?opargs = {}} = args;
    repeat_type = typeof(repeat);
    if (repeat)
      if (repeat_type == INT)
        "static repeat interval, the usual (integer number of seconds)";
        return time() + repeat;
      elseif (repeat_type == STR)
        "dynamic interval based on $time_utils:seconds_until_time";
        offset = $time_utils:seconds_until_time(repeat);
        return time() + (offset <= 0 ? offset + $time_utils.day | offset);
      elseif (repeat_type == LIST)
        "dynamic interval";
        {interval_obj, interval_verb, ?more_args = {}} = repeat;
        if (typeof(interval_obj) == INT && typeof(interval_verb) == INT)
          "simple random interval between two values {interval_minimum, interval_range} {10, 5} = 10 to 15 seconds";
          return time() + interval_obj + random(interval_verb);
        else
          "calculated interval by calling a specified verb {interval_obj, interval_verbo} {#1234, \"calc_verbo_runtime\"} = some number of seconds";
          try
            return time() + interval_obj:(interval_verb)(object, verbo, opargs, more_args);
          except e (ANY)
            "TODO: add some error logging here for your server";
            return 0;
          endtry
        endif
      endif
    endif
    return 0;
  endverb

  verb check_repeat_args (this none this) owner: #36 flags: "rxd"
    {repeat} = args;
    typeis = typeof(repeat);
    if (typeis == LIST)
      if (!repeat || length(repeat) < 2)
        raise(E_INVARG, "repeat arg bad value", repeat);
      endif
      a = typeof(repeat[1]);
      b = typeof(repeat[2]);
      if (a == OBJ)
        if (b != STR)
          raise(E_INVARG, "repeat arg object:verb not right", repeat);
        elseif (!$object_utils:has_callable_verb(repeat[1], repeat[2]))
          raise(E_INVARG, "repeat arg object:verb is not callable/exist", repeat);
        endif
      elseif (a == INT)
        if (b != INT)
          raise(E_INVARG, "repeat arg range not right", repeat);
        endif
      else
        raise(E_INVARG, "repeat arg range not right", repeat);
      endif
    elseif (typeis == STR)
      try
        $time_utils:seconds_until_time(repeat);
      except e (ANY)
        raise(E_INVARG, "repeat arg specific time string not in hh:mm:ss format", repeat);
      endtry
    elseif (typeis != INT)
      raise(E_INVARG, "repeat arg type invalid", repeat);
    endif
  endverb

  verb describe_repeat (this none this) owner: #36 flags: "rxd"
    {repeat} = args;
    if (!repeat)
      return "";
    elseif (typeof(repeat) == INT)
      return $string_utils:from_seconds(repeat);
    elseif (typeof(repeat) == LIST)
      if (typeof(repeat[1]) == INT)
        return tostr(repeat[1], " to ", repeat[1] + repeat[2], " seconds");
      else
        return tostr(repeat[1], ":", repeat[2]);
      endif
    elseif (typeof(repeat) == STR)
      return repeat;
    endif
    return "bad args";
  endverb

  verb display_schedule (this none this) owner: #36 flags: "rxd"
    ":display_schedule(?LIST tasks) => none";
    "display the scheduled tasks that are passed in, or the entire schedule if none passed in";
    {?to_do = this.scheduled_tasks} = args;
    filter = $nothing;
    if (args && typeof(args[1]) == OBJ)
      filter = args[1];
    endif
    player:tell("Current Time: ", ctime());
    running = $code_utils:task_valid(this.run_task) ? "YES" | "NO";
    player:tell("Currently Running: ", running);
    su = $string_utils;
    head = tostr(su:left("Next Run Time", 30), su:left("Repeat", 25), su:left("Owner", 10), "Verb");
    head2 = tostr(su:left("-------------", 30), su:left("------", 25), su:left("-----", 10), "----");
    display = {head, head2};
    toggle = 1;
    decaying = {};
    for event in (to_do)
      {repeat, object, verbo, runtime, owner, ?opargs = {}} = event;
      if (verbo == "item_decay")
        decaying = setadd(decaying, object);
        continue;
      endif
      if (filter == $nothing || $object_utils:isa(object, filter))
        rep_str = this:describe_repeat(repeat);
        thing = (references = this:core_references(object)) ? "$" + references[1] | tostr(object);
        msg = tostr((su:left(ctime(runtime), 30))[1..30], (su:left(rep_str, 25))[1..25], (su:left(owner.name, 10))[1..10], thing, ":", verbo, "(", toliteral(opargs)[2..$ - 1], ")");
        display = {@display, msg};
        toggle = !toggle;
      endif
      ticks_left() < 2000 || seconds_left() < 2 && suspend(min($login:current_lag(), 10));
    endfor
    player:tell("Current scheduled tasks:");
    player:tell(su:space(90, "*"));
    player:tell_lines(display);
    player:tell(su:space(90, "*"));
    if (decaying)
      player:tell("Decaying Items [aka - object:item_decay()]");
      player:tell($string_utils:english_list(decaying));
    endif
    player:tell("List too long? 'help $scheduler' to view @scheduled options to prune it down.");
  endverb

  verb core_references (this none this) owner: #36 flags: "rxd"
    ":core_references(OBJ thing) => LIST";
    "return a list of props on $sysobj that point to thing";
    {thing} = args;
    refs = {};
    for ref in (properties($sysobj))
      if ($sysobj.(ref) == thing)
        refs = {@refs, ref};
      endif
    endfor
    return refs;
  endverb
endobject