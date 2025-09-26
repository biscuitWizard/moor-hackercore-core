object #116
  name: "Integer Prototype"
  parent: #114
  owner: #2

  verb "*" (this none this) owner: #2 flags: "rxd"
if (verb in {"init_for_core", "proxy_for_core", "exitfunc", "enterfunc", "moveto"})
  return `pass(@args) ! ANY => 0';
elseif (verb in {"sin", "cos", "sqrt"})
  this = tofloat(this);
elseif (verb == "english_time")
  return $time_utils:english_time(this);
elseif (verb == "include_for_core")
  return {};
endif
return call_function(verb, this, @args);
  endverb
endobject
