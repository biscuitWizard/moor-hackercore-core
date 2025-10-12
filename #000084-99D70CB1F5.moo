object #000084-99D70CB1F5
  name: "Dernan"
  parent: #57
  location: #62
  owner: #2
  player: true
  wizard: true
  programmer: true

  override aliases = {"Dernan"};
  override channels = {#80, #81};
  override last_disconnect_time = 1760255172;
  override last_password_time = 1760249611;
  override password = "$argon2id$v=19$m=4096,t=3,p=1$UmIxbkJWZ3hwaDlXOXJQcnpFR3RIdw$yL9g7v1kuEaOui8R3i/BoIV0N55ET8eQSv+5FvIuBYw";
  override password_version = 2;

  verb "'" (any any any) owner: #36 flags: "rd"
    force_input(me, "say " + args[2..$]);
  endverb
endobject