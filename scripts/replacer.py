#!/usr/bin/env python

import os
import yaml
import pprint
import re

from tempfile import mkstemp
from shutil import move
from os import remove, close

def main():

  # load my patterns by file
  with open('uc2.yml', 'r') as f:
    files = yaml.load(f)

  # Go through yaml object that looks like this: array of file objects each containing and array or replacement objects
  # { [ {'name' : '/path/to/file', 'properties' : [ { 'pattern': 'regex', 'replacement':'new_value'} ] } ] }
  for cur_file in files:
   file_name = cur_file['name']
   for prop in cur_file['properties']: 
     print( ' filename: %s - regex: %s replacement: %s' % ( file_name, prop['pattern'], prop['replacement']) ) 
     replace( file_name, prop['pattern'], prop['replacement'] )

# http://stackoverflow.com/questions/39086/search-and-replace-a-line-in-a-file-in-python
def replace(file_path, pattern, subst):
  pat = re.compile( pattern )
  pprint.pprint( pat )
  #Create temp file
  fh, abs_path = mkstemp()
  with open(abs_path,'w') as new_file:
    with open(file_path) as old_file:
      for line in old_file:
	if pat.match( line ):
	  print( 'Found match: %s' % ( line ) )
          print( 'Applying replacement, regex: %s subst: %s' % (pattern, subst) )
          #new_line = line.replace( pattern, subst )
          new_line = re.sub( pattern, subst, line )
          print( 'New line: %s ' % (new_line) )
          line = new_line
        new_file.write( line )
  close(fh)
  #Remove original file
  remove(file_path)
  #Move new file
  move(abs_path, file_path)

if __name__ == "__main__":
  main()
