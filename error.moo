object ERROR
  name: "Trace-Back"
  parent: CHANNEL
  owner: HACKER

  override color = "brred";

  verb log (this none this) owner: HACKER flags: "rxd"
    {code, msg, value, ?stack = {}, ?traceback = {}} = args[1];
    best_stack = {};
    trace = {};
    for line in (stack)
      if (line[1] == $nothing)
        continue;
      endif
      if (!best_stack)
        best_stack = line;
      endif
      trace = {@trace, tostr("L", line[$], " ", line[4], ":", line[2])};
    endfor
    if (best_stack)
      this:transmit(first_line = tostr(toliteral(code), " ", msg, " @ L", best_stack[$], " ", best_stack[4], ":", best_stack[2]));
    else
      this:transmit(first_line = tostr(toliteral(code), " ", msg));
    endif
    this:transmit($ansi:red($su:from_list(trace, " <- ")));
  endverb

  verb get_innermost_exception (this none this) owner: HACKER flags: "rxd"
    {exception} = args;
    if (typeof(exception) == LIST)
      if (typeof(exception[1]) == ERR)
        return exception;
      else
        return this:get_innermost_exception(exception[1]);
      endif
    endif
    return exception;
  endverb
endobject