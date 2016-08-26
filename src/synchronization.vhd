package synchronization_pkg is
  type event_t is (cleared, set);

  function is_set (
    signal event : event_t)
    return boolean;

  procedure set (
    signal event : out event_t);

  procedure clear (
    signal event : out event_t);

  procedure wait_on (
    signal event : event_t);

  procedure wait_on (
    signal event       : in  event_t;
    constant timeout   : in  time;
    variable timed_out : out boolean);
end package synchronization_pkg;

package body synchronization_pkg is
  function is_set (
    signal event : event_t)
    return boolean is
  begin
    return event = set;
  end;

  procedure set (
    signal event : out event_t) is
  begin
    event <= set;
  end;

  procedure clear (
    signal event : out event_t) is
  begin
    event <= cleared;
  end;

  procedure wait_on (
    signal event : event_t) is
  begin
    if event = cleared then
      wait until event = set;
    end if;
  end;

  procedure wait_on (
    signal event       : in  event_t;
    constant timeout   : in  time;
    variable timed_out : out boolean) is
  begin
    if event = cleared then
      assert timeout > 0 ns
        report "Setting negative timeout to 0 ns" severity warning;
      wait until event = set for maximum(0 ns, timeout);
    end if;
    timed_out := event = cleared;
  end;

end package body synchronization_pkg;
