object HACKER
  name: "Hacker"
  parent: PROG
  owner: HACKER
  player: true
  programmer: true
  readable: true

  override aliases = {"Hacker"};
  override description = "A system character used to own non-wizardly system verbs , properties, and objects in the core.";
  override features = {PASTING_FEATURE, #89};
  override first_connect_time = 9223372036854775807;
  override home = NOTHING;
  override last_disconnect_time = 9223372036854775807;
endobject