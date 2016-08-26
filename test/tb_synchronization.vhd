library vunit_lib;
context vunit_lib.vunit_context;

library synchronization_lib;
use synchronization_lib.synchronization_pkg.all;

entity tb_synchronization is
  generic (
    runner_cfg : string);
end entity tb_synchronization;

architecture test_fixture of tb_synchronization is
  signal test_event, blocking_event : event_t;
  constant blocking_time_c : time := 10 ns;
begin
  test_runner : process
    variable start : time;
    variable timed_out : boolean;
  begin
    test_runner_setup(runner, runner_cfg);

    while test_suite loop
      if run("Test that an event is initially cleared") then
        check_false(is_set(test_event), "Event not cleared");
      elsif run("Test feature that will never be supported using VUnit") then
        check_implication(not is_set(test_event), test_event = set, "The code is not obfuscated");
      elsif run("Test that an event can be set and cleared") then
        set(test_event);
        wait for 0 ns;
        check(is_set(test_event), "Event not set");
        set(test_event);
        wait for 0 ns;
        check(is_set(test_event), "Setting an already set event shall not change its state");
        clear(test_event);
        wait for 0 ns;
        check_false(is_set(test_event), "Event not cleared");
        clear(test_event);
        wait for 0 ns;
        check_false(is_set(test_event), "Clearing an already cleared event shall not change its state");
      elsif run("Test that a wait on a set event does not block") then
        set(test_event);
        start := now;
        wait_on(test_event);
        check(start = now, "Blocked on an already set event");
        wait_on(test_event, 1 ns, timed_out);
        check(start = now, "Blocked on an already set event");
        check_false(timed_out, "Time out reported on set event");
        wait_on(test_event, 0 ns, timed_out);
        check(start = now, "Blocked on an already set event");
        check_false(timed_out, "Zero timeout shall not result in a timeout if event is set");
      elsif run("Test that a cleared event blocks a wait call") then
        start := now;
        wait_on(blocking_event);
        check(now - start = blocking_time_c, "Did not block correctly on event");
      elsif run("Test that a wait with timeout blocks until event is set if that happens before the timeout") then
        start := now;
        wait_on(blocking_event, blocking_time_c + 1 ns, timed_out);
        check(now - start = blocking_time_c, "Did not block correctly on event");
        check_false(timed_out, "Time out reported");
      elsif run("Test that a wait with timeout times out if timeout happens before event is set") then
        start := now;
        wait_on(blocking_event, blocking_time_c - 1 ns, timed_out);
        check(now - start = blocking_time_c - 1 ns, "Did not timeout when expected");
        check(timed_out, "Time out not reported");
      elsif run("Test that a negative timeout behaves like a zero timeout") then
        start := now;
        wait_on(test_event, -1 ns, timed_out);
        check(start = now, "Did not timeout when expected");
        check(timed_out, "Time out not reported");
        set(test_event);
        start := now;
        wait_on(test_event, -1 ns, timed_out);
        check(start = now, "Blocked on an already set event");
        check_false(timed_out, "Time out reported");
      end if;
    end loop;

    test_runner_cleanup(runner);
    wait;
  end process;

  test_runner_watchdog(runner, 100 ns);

  blocker: process is
  begin
    wait for blocking_time_c;
    set(blocking_event);
    wait;
  end process blocker;

end test_fixture;
