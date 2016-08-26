library vunit_lib;
-- The VUnit run context excludes VUnit checking and logging functionality
context vunit_lib.vunit_run_context;

library osvvm;
use osvvm.AlertLogPkg.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library synchronization_lib;
use synchronization_lib.synchronization_pkg.all;

entity tb_synchronization_with_other_checks is
  generic (
    runner_cfg : string);
end entity tb_synchronization_with_other_checks;

architecture test_fixture of tb_synchronization_with_other_checks is
  signal test_event, blocking_event : event_t;
  constant blocking_time_c : time := 10 ns;
begin
  test_runner : process
    variable start : time;
    variable timed_out : boolean;
  begin
    test_runner_setup(runner, runner_cfg);

    while test_suite loop
      if run("Test that an event is initially cleared using VHDL assert") then
        assert not is_set(test_event) report "Event not cleared";
      elsif run("Test feature that will never be supported using VHDL assert") then
        assert is_set(test_event) or (test_event = set) report "The code is not obfuscated";

      elsif run("Test that an event is initially cleared using OSVVM") then
        AlertIf(is_set(test_event), "Event not cleared", FAILURE);
      elsif run("Test feature that will never be supported using OSVVM") then
        AlertIfNot(is_set(test_event) or (test_event = set), "The code is not obfuscated", FAILURE);

      elsif run("Test that an event is initially cleared using UVVM") then
        check_value(not is_set(test_event), ERROR, "Event not cleared");
      elsif run("Test feature that will never be supported using UVVM") then
        check_value(is_set(test_event) or (test_event = set), ERROR, "The code is not obfuscated");
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
