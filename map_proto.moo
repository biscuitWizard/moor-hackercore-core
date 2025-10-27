object MAP_PROTO
  name: "Map Prototype"
  parent: PROTO
  owner: #2

  verb "keys values delete" (this none this) owner: HACKER flags: "rxd"
    "map:keys(), :values(), :delete(val)";
    return call_function("map" + verb, @args);
  endverb
endobject