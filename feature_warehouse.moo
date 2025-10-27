object FEATURE_WAREHOUSE
  name: "Feature Warehouse"
  parent: CONTAINER
  location: PLAYER_START
  owner: HACKER
  readable: true

  override aliases = {"Feature Warehouse", "warehouse"};
  override dark = 0;
  override opened = 1;

  verb list (any in this) owner: HACKER flags: "rxd"
    "Copied from Features Feature Object (#24300):list by Joe (#2612) Mon Oct 10 21:07:35 1994 PDT";
    if (this.contents)
      player:tell(".features objects:");
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