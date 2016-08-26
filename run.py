from vunit import VUnit
from os.path import dirname, join
import os

vu = VUnit.from_argv()

root = join(dirname(__file__))

synchronization_lib = vu.add_library('synchronization_lib')
synchronization_lib.add_source_files(join(root, 'src', '*.vhd'))
tb_synchronization_lib = vu.add_library('tb_synchronization_lib')
tb_synchronization_lib.add_source_files(join(root, 'test', '*.vhd'))

# OSVVM is redistributed with VUnit and available as an add-on
vu.add_osvvm()

if 'UVVM_UTIL_PATH' in os.environ:
    uvvm_util_path= os.environ['UVVM_UTIL_PATH']
else:
    raise RuntimeError('Failed to find the UVVM_UTIL_PATH environment variable. It must be set to point to the UVVM Utility Library installation directory.')

uvvm_util = vu.add_library('uvvm_util')
uvvm_util.add_source_files(join(uvvm_util_path, 'uvvm_util', 'src', '*.vhd'))

vu.set_compile_option('ghdl.flags', ['-frelaxed-rules'])
vu.set_sim_option('ghdl.elab_flags', ['-frelaxed-rules'])
vu.main()
