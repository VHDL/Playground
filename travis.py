from subprocess import call
from vunit.test.common import check_report
import sys

BUILD_NAME = sys.argv[1]

if BUILD_NAME == "ACCEPTANCE":
    report_file = 'xunit.xml'
    retcode = call('python run.py --xunit-xml=%s' % report_file, shell=True)
    assert retcode == 1
    check_report(report_file,
                 [('passed', 'tb_synchronization_lib.tb_synchronization.Test that an event is initially cleared'),
                  ('passed', 'tb_synchronization_lib.tb_synchronization.Test that an event can be set and cleared'),
                  ('passed', 'tb_synchronization_lib.tb_synchronization.Test that a wait on a set event does not block'),
                  ('passed', 'tb_synchronization_lib.tb_synchronization.Test that a cleared event blocks a wait call'),
                  ('passed', 'tb_synchronization_lib.tb_synchronization.Test that a wait with timeout blocks until event is set if that happens before the timeout'),
                  ('passed', 'tb_synchronization_lib.tb_synchronization.Test that a wait with timeout times out if timeout happens before event is set'),
                  ('passed', 'tb_synchronization_lib.tb_synchronization.Test that a negative timeout behaves like a zero timeout'),
                  ('passed', 'tb_synchronization_lib.tb_synchronization_with_other_checks.Test that an event is initially cleared using VHDL assert'),
                  ('passed', 'tb_synchronization_lib.tb_synchronization_with_other_checks.Test that an event is initially cleared using OSVVM'),
                  ('passed', 'tb_synchronization_lib.tb_synchronization_with_other_checks.Test that an event is initially cleared using UVVM'),
                  ('failed', 'tb_synchronization_lib.tb_synchronization.Test feature that will never be supported using VUnit'),
                  ('failed', 'tb_synchronization_lib.tb_synchronization_with_other_checks.Test feature that will never be supported using VHDL assert'),
                  ('failed', 'tb_synchronization_lib.tb_synchronization_with_other_checks.Test feature that will never be supported using OSVVM'),
                  ('failed', 'tb_synchronization_lib.tb_synchronization_with_other_checks.Test feature that will never be supported using UVVM')])
else:
    raise ValueError(BUILD_NAME)
