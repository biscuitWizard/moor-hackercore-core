object #115
  name: "List Prototype"
  parent: #114
  owner: #2

  verb "add remove" (this none this) owner: #2 flags: "rxd"
return call_function("set" + verb, @args);
  endverb
  verb "delete_index" (this none this) owner: #2 flags: "rxd"
return call_function("listdelete", args[1]);
  endverb
  verb "insert append" (this none this) owner: #2 flags: "rxd"
return call_function("list" + verb, args[1]);
  endverb
  verb "merge" (this none this) owner: #2 flags: "rxd"
set_task_perms(player);
return $string_utils:from_list(this, args ? args[1] | " ");
  endverb
  verb "*" (this none this) owner: #2 flags: "rxd"
set_task_perms(player);
"Don't respond to calls from built-ins";
{_, name, programmer, location, _} = callers()[1];
if (name && programmer == $nothing && location == $nothing)
  return;
endif
"Exceptions";
if (verb in {"init_for_core", "exitfunc", "enterfunc", "moveto"})
  return `pass(@args) ! ANY => 0';
elseif (verb in {"from_list", "english_list", "nn_list", "title_list", "generate_symmetrical_columns"})
  return $string_utils:(verb)(args[1]);
elseif (verb == "include_for_core")
  return {};
elseif ($object_utils:has_callable_verb($list_utils, verb))
  return $list_utils:(verb)(@args);
elseif (verb == "len")
  return length(@args);
endif
"Frobs, originally conceptualized by Todd Sundsted for Improvise.";
"Disabled by Dernan when working on hacker core 9/21/2025; add $frobs set to {} and remove the hardcoded false condition to enable.";
if (0 && this && `prototype = this[1] ! E_RANGE' in $frobs)
  return prototype:(verb)(@args);
endif
return pass(@args);
  endverb
endobject
