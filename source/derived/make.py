#! /usr/bin/env python
#****************************************************
# GET LIBRARY
#****************************************************
import subprocess, shutil, os 
gslab_make_path = os.getenv('gslab_make_path')
subprocess.call('svn export --force -r 33373 ' + gslab_make_path + ' gslab_make', shell = True)
from gslab_make.py.get_externals import *
from gslab_make.py.get_externals_github import *
from gslab_make.py.make_log import *
from gslab_make.py.make_links import *
from gslab_make.py.make_link_logs import *
from gslab_make.py.run_program import *
from gslab_make.py.dir_mod import *

#****************************************************
# MAKE.PY STARTS
#****************************************************
set_option(link_logs_dir = '../output/')
clear_dirs('../external/', '../temp/')
delete_files('../output/*')
start_make_logging()

# GET_EXTERNALS
source_dir = '../../../raw/County and City Data Books/data'
dest_dir = '../external/raw_databooks'
shutil.copytree(source_dir, dest_dir)

#In case it works I will create the loop
os.system('st ../external/raw_databooks/1994/COF01.DBF ../external/raw_databooks/1994/COF01.dta')
os.system('st ../external/raw_databooks/1994/COF02.DBF ../external/raw_databooks/1994/COF02.dta')
os.system('st ../external/raw_databooks/1994/COF06.DBF ../external/raw_databooks/1994/COF06.dta')
os.system('st ../external/raw_databooks/1994/COF07.DBF ../external/raw_databooks/1994/COF07.dta')

run_stata(program = 'build.do')

end_make_logging()
raw_input('\n Press <Enter> to exit.')
