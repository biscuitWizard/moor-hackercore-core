object GARBAGE
  name: "Generic Garbage"
  parent: ROOT_CLASS
  owner: HACKER
  readable: true

  property disposed_on (owner: HACKER, flags: "r") = 0;
  property lifetime (owner: HACKER, flags: "r") = 0;
  property object_dump (owner: HACKER, flags: "r") = {};

  override aliases = {"Garbage"};
  override description = "Object reuse. Call $recycler:_create() to create an object (semantics the same as create()), $recycler:_recycle() to recycle an object. Will create a new object if nothing available in its contents. Note underscores, to avoid builtin :recycle() verb called when objects are recycled. Uses $building_utils:recreate() to prepare objects.";
endobject