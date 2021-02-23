#!d:\itesm\eeg\musegui\scripts\python.exe
# EASY-INSTALL-ENTRY-SCRIPT: 'muselsl==2.0.2','console_scripts','muselsl'
__requires__ = 'muselsl==2.0.2'
import re
import sys
from pkg_resources import load_entry_point

if __name__ == '__main__':
    sys.argv[0] = re.sub(r'(-script\.pyw?|\.exe)?$', '', sys.argv[0])
    sys.exit(
        load_entry_point('muselsl==2.0.2', 'console_scripts', 'muselsl')()
    )
