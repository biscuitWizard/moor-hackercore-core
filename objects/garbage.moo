object Generic Garbage
  name: "Generic Garbage"
  parent: #1
  owner: #36
  readable: true

  property disposed_on (owner: #36, flags: "r") = 0;
  property lifetime (owner: #36, flags: "r") = 0;
  property object_dump (owner: #36, flags: "r") = {};

  override aliases = {"Garbage"};
  override description = "Object reuse. Call $recycler:_create() to create an object (semantics the same as create()), $recycler:_recycle() to recycle an object. Will create a new object if nothing available in its contents. Note underscores, to avoid builtin :recycle() verb called when objects are recycled. Uses $building_utils:recreate() to prepare objects.";
endobject