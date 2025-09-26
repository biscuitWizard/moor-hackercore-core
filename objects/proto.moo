object #114
  name: "Generic Base Primitive"
  owner: #2
  readable: true

  verb "length len" (this none this) owner: #36 flags: "rxd"
    return length(typeof(args[1]) == MAP ? mapkeys(args[1]) | args[1]);
  endverb

  verb "*" (this none this) owner: #36 flags: "rxd"
    "Last ditch attempt to do something useful...";
    return args[1];
  endverb
endobject
