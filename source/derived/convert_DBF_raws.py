
import sys
import os
import glob
root = os.path.abspath(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
sys.path.append(root)
from source.lib.simpledbf.simpledbf import *

filenames = glob.glob(os.path.join(root,'raw/County and City Databooks/data/1994/*.DBF'))
for file in filenames:
    dbf = Dbf5(file)
    #dbf.to_csv('/Users/ricardodahis/Downloads/'+os.path.splitext(os.path.basename(file))[0]+'.csv')
    dbf.to_csv(os.path.splitext(file)[0]+'.csv')


