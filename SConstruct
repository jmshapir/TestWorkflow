
# First testing SCons structure

import os

def build_function(target, source, env):
	# Code to build "target" from "source"
	execfile(source)
	return None

Python_Builder = Builder(action = build_function,
						suffix = '',
						src_suffix = ''
						)

env = Environment(ENV=os.environ, BUILDERS = {'Python_Builder' : Python_Builder})
Export('env')

SConscript('source/SConscript')

