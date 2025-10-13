object #117
  name: "Map Prototype"
  parent: #114
  owner: #2

  verb "keys values delete" (this none this) owner: #36 flags: "rxd"
    "map:keys(), :values(), :delete(val)";
    return call_function("map" + verb, @args);
  endverb
endobject