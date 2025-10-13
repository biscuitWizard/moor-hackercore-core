object #119
  name: "String Prototype"
  parent: #114
  owner: #2

  verb "*" (this none this) owner: #2 flags: "rxd"
    "Catch-all fallback for verbs called on strings";
    "Ignore common calls, pass the rest off to $string_utils";
    if (verb in {"init_for_core", "proxy_for_core", "exitfunc", "enterfunc", "moveto"})
      return `pass(@args) ! ANY => 0';
    elseif (verb == "length" || verb == "len")
      return length(args[1]);
    elseif (verb == "strip_ansi")
      return $ansi:strip_tags(args[1]);
    endif
    if (verb == "include_for_core")
      return {};
    endif
    "So that programmers can call string:json() or string:parse_json(),";
    "And get a map as the return value (if the string can be parsed into json).";
    if (verb == "parse_json" || verb == "json")
      return call_function("parse_json", @args);
    endif
    r = $string_utils:(verb)(@args);
    if (r != 0)
      return r;
    endif
  endverb
endobject