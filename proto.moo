object PROTO
  name: "Generic Base Primitive"
  owner: #2
  readable: true

  verb "length len" (this none this) owner: HACKER flags: "rxd"
    return length(typeof(args[1]) == MAP ? mapkeys(args[1]) | args[1]);
  endverb

  verb "*" (this none this) owner: HACKER flags: "rxd"
    "Last ditch attempt to do something useful...";
    if (verb == "initialize" || verb == "recycle")
      return;
    endif
    return args[1];
  endverb
endobject