#!/usr/bin/env python

from zipfile import ZipFile
import os
import sys


args = sys.argv[1:]
output = args.pop(0)
zipname = os.path.basename(output)
with ZipFile(output, 'w') as z:
    z.comment = zipname.encode() + b'\n'
    for a in args:
        with z.open(a, 'w') as f:
            f.write(zipname.encode() + b'/' + a.encode() + b'\n')
