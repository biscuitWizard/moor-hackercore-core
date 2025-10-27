object DIFF_UTILS
  name: "Diff Utils"
  parent: GENERIC_UTILS
  owner: #2
  readable: true

  property default_hash_algo (owner: GUEST_LOG, flags: "r") = "md5";

  override aliases = {"Diff", "Utils", "Diff Utils"};
  override help_msg = {
    "STUNT DIFF UTILITY",
    "",
    "This is a repackage (01/17/2021 by Slither) of the Diff Utility & Verbs that were provided as part of the original Stunt Improvise.db. The relevant verbs were combined and rewritten to work with ToastCore. Essentially that meant rewriting how the utility outputs text, and moving from using prototype calls of :slice and :reverse to using the ToastStunt builtins for the same functionality."
  };

  verb _find_common_unique_lines (this none this) owner: HACKER flags: "rxd"
    {lines1, lines2, intern} = args;
    for v, k in (intern)
      intern[k] = {{0, 0}, {0, 0}};
    endfor
    for line, i in (lines1)
      intern[line[2]][1] = {intern[line[2]][1][1] + 1, i};
    endfor
    for line, i in (lines2)
      intern[line[2]][2] = {intern[line[2]][2][1] + 1, i};
    endfor
    items = {};
    for line in (lines1)
      item = intern[line[2]];
      if (item[1][1] == 1 && item[2][1] == 1)
        items = {@items, {item[1][2], item[2][2]}};
      endif
    endfor
    return items;
  endverb

  verb _generate_diff (this none this) owner: HACKER flags: "rxd"
    {lines1, lines2, lcs} = args;
    last = {0, 0};
    lcs = {@lcs, {length(lines1) + 1, length(lines2) + 1}};
    results = {};
    for pos in (lcs)
      i1 = last[1] + 1;
      j1 = pos[1] - 1;
      i2 = last[2] + 1;
      j2 = pos[2] - 1;
      while (i1 < j1)
        if (lines1[i1][2] == `lines2[i2][2] ! E_RANGE')
          i1 = i1 + 1;
          i2 = i2 + 1;
          continue;
        endif
        break;
      endwhile
      while (j1 >= i1)
        if (lines1[j1][2] == `lines2[j2][2] ! E_RANGE')
          j1 = j1 - 1;
          j2 = j2 - 1;
          continue;
        endif
        break;
      endwhile
      res1 = slice(lines1[i1..j1], 1);
      res2 = slice(lines2[i2..j2], 1);
      if (res1 && res2)
        results = {@results, {"r", i1, i2, res1, res2}};
      elseif (res1)
        results = {@results, {"-", i1, i2, res1}};
      elseif (res2)
        results = {@results, {"+", i1, i2, res2}};
      endif
      last = pos;
    endfor
    return results;
  endverb

  verb _hash_lines (this none this) owner: HACKER flags: "rxd"
    {lines, ?intern = []} = args;
    result = {};
    for line in (lines)
      hash = string_hash(line);
      hash = `intern[hash] ! E_RANGE => intern[hash] = hash';
      result = {@result, {line, hash}};
    endfor
    return {result, intern};
  endverb

  verb _find_lcs (this none this) owner: HACKER flags: "rxd"
    {items} = args;
    stacks = {};
    for item in (items)
      last = 0;
      for i in [1..length(stacks)]
        if (item[2] < stacks[i][$][1][2])
          stacks[i] = {@stacks[i], {item, last}};
          item = 0;
          break;
        endif
        last = length(stacks[i]);
      endfor
      if (item)
        stacks = {@stacks, {{item, last}}};
      endif
    endfor
    stacks = $lu:reverse(stacks);
    i = stacks && length(stacks[1]);
    results = {};
    for stack in (stacks)
      item = stack[i];
      results = {item[1], @results};
      i = item[2];
    endfor
    return results;
  endverb

  verb diff (this none this) owner: HACKER flags: "rxd"
    {lines1, lines2} = args;
    intern = [];
    {hashed1, intern} = this:_hash_lines(lines1, intern);
    {hashed2, intern} = this:_hash_lines(lines2, intern);
    lcs = this:_find_lcs(this:_find_common_unique_lines(hashed1, hashed2, intern));
    return this:_generate_diff(hashed1, hashed2, lcs);
  endverb

  verb diff_display (this none this) owner: HACKER flags: "rxd"
    ":diff_display(STR diff_1_name, LIST diff_1_lines, STR diff_2_name, LIST diff_2_line) => NONE";
    "this verb will diff two sets of data and display the results";
    "it is primarily designed to diff an existing verb against proposed changes";
    "the diff_1_lines are considered the primary, and the diff_2_lines are the dirty lines";
    {diff_1_name, diff_1_lines, diff_2_name, diff_2_lines} = args;
    diffs = this:diff(diff_1_lines, diff_2_lines);
    if (!diffs)
      player:tell("Files ", diff_1_name, " and ", diff_2_name, " are identical");
      return;
    endif
    for diff in (diffs)
      type = diff[1];
      if (type == "a")
        " Add: lines added to file2 ";
        pos1 = diff[2];
        pos2_start = diff[3];
        pos2_end = diff[4];
        lines2 = diff[5];
        if (pos2_start == pos2_end)
          player:tell(tostr(pos1, "a", pos2_start));
        else
          player:tell(tostr(pos1, "a", pos2_start, ",", pos2_end));
        endif
        for l in (lines2)
          player:tell(tostr("> ", l));
        endfor
      elseif (type == "d")
        " Delete: lines deleted from file1 ";
        pos1_start = diff[2];
        pos1_end = diff[3];
        pos2 = diff[4];
        lines1 = diff[5];
        if (pos1_start == pos1_end)
          player:tell(tostr(pos1_start, "d", pos2));
        else
          player:tell(tostr(pos1_start, ",", pos1_end, "d", pos2));
        endif
        for l in (lines1)
          player:tell(tostr("< ", l));
        endfor
      elseif (type == "c")
        " Change: lines changed between file1 and file2 ";
        pos1_start = diff[2];
        pos1_end = diff[3];
        pos2_start = diff[4];
        pos2_end = diff[5];
        lines1 = diff[6];
        lines2 = diff[7];
        range1 = pos1_start == pos1_end ? tostr(pos1_start) | tostr(pos1_start, ",", pos1_end);
        range2 = pos2_start == pos2_end ? tostr(pos2_start) | tostr(pos2_start, ",", pos2_end);
        player:tell(tostr(range1, "c", range2));
        for l in (lines1)
          player:tell(tostr("< ", l));
        endfor
        player:tell("---");
        for l in (lines2)
          player:tell(tostr("> ", l));
        endfor
      endif
    endfor
  endverb
endobject