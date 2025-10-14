object #60
  name: "WHO System"
  parent: #78
  owner: #36

  verb return_detailed_lines (this none this) owner: #36 flags: "rxd"
    {?viewer = player} = args;
    $login:update_top_players();
    is_wiz = $wiz_utils:is_admin(viewer);
    columns = {{"NAME", $login.max_player_name + 2}, {"CONN", 6}, {"IDLE", 6}, {"@WOW me is ...", 50}};
    rows = {};
    for column in (columns)
      rows = {@rows, {$ansi:white(column[1])}};
      if (!viewer:less_ascii())
        rows[$] = {@rows[$], $ansi:cyan($su:space(column[2] - 1, "-"))};
      endif
    endfor
    stats = [];
    for dude in (connected_players())
      dude_name = is_wiz ? dude:name(viewer) | dude:bgbb_name();
      if (!is_wiz && dude:player_option("who_invis"))
        stats["invis"] = `stats["invis"] ! E_RANGE => 0' + 1;
        dude_name = "-- INVIS --";
      endif
      rows[1] = {@rows[1], $su:left(dude_name, $login.max_player_name * -1)};
      rows[2] = {@rows[2], $su:right($tu:short_english_time(connected_seconds(dude), time(), 1), -5)};
      rows[3] = {@rows[3], $su:right($tu:short_english_time(idle_seconds(dude), time(), 1), -5)};
      rows[4] = {@rows[4], $su:left(`dude.wow_msg ! ANY => ""', -50)};
    endfor
    lines = {this:header()};
    lines = {@lines, @$su:table(@rows, $lu:slice(columns, 2))};
    lines = {@lines, this:footer(viewer)};
    stat_details = {};
    for stat, key in (stats)
      stat_details = {@stat_details, tostr($su:english_number(stat), " ", $su:pluralize("is", stat), "\n", key)};
    endfor
    stat_details = {@stat_details, tostr(length(connected_players()), " currently connected players")};
    stat_details = {@stat_details, tostr("a peak of ", $login.top_players[1], " players connected")};
    lines = {@lines, $su:capitalize(tostr($su:english_list(stat_details), "."))};
    return lines;
  endverb

  verb header (this none this) owner: #36 flags: "rxd"
    {?viewer = player} = args;
    filler = "=";
    if (viewer:less_ascii())
      filler = " ";
    endif
    return $ansi:cyan($su:space(2, filler), $su:left($ansi:brcyan("[ ", $ansi:white($network.MOO_name), " ]"), 37, filler), $su:right($ansi:brcyan("[ ", $ansi:white("@WHO"), " ]"), 37, filler), $su:space(2, filler));
  endverb

  verb footer (this none this) owner: #36 flags: "rxd"
    {?viewer = player} = args;
    if (viewer:less_ascii())
      return $su:space(78);
    endif
    return $ansi:cyan($su:space(78, "="));
  endverb
endobject