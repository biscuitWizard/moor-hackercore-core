object SINGLETON_WAREHOUSE
  name: "Singleton Warehouse"
  parent: CONTAINER
  location: PLAYER_START
  owner: HACKER
  readable: true

  override aliases = {"Singleton Warehouse", "warehouse"};
  override dark = 0;
  override opened = 1;

  verb list (any in this) owner: HACKER flags: "rxd"
    if (this.contents)
      player:tell(".singleton objects:");
      player:tell("----------------------");
      first = 1;
      for thing in (this.contents)
        if (!first)
          player:tell();
        endif
        player:tell($string_utils:nn(thing), ":");
        `thing:look_self() ! ANY => player:tell("<<Error printing description>>")';
        first = 0;
      endfor
      player:tell("----------------------");
    else
      player:tell("No objects in ", this.name, ".");
    endif
  endverb
endobject