#!/usr/bin/env python

# script to convert .xlsx to .json so data can be easily read by game engine

import sys
import zipfile
from xml.etree.ElementTree import iterparse

from signal import signal, SIGPIPE, SIG_DFL  
signal(SIGPIPE,SIG_DFL) 


def error (msg):
    print(msg, file=sys.stderr)
    sys.exit(1)

def is_number (inp):
    try:
        float(inp)
        return True
    except ValueError:
        return False

def letter_column_number(name):
    while name[-1].isdigit():
        name = name[:-1]
    
    n = 0
    for c in name:
        n = n * 26 + 1 + ord(c) - ord('A')
    return n - 1
    
def xlsx_to_json (path, makedict = False):
    try:
        z = zipfile.ZipFile(path)
    except:
        error( 'there was an error reading the file \"' + path + '\"' )
        
    strings = [el.text for e, el in iterparse(z.open('xl/sharedStrings.xml')) if el.tag.endswith('}t')]

    buf = '{\n' if makedict else '[\n'
    row = ''

    keys = []
    value = None
    
    count = 0
    column = 0
    first = True
    rowisempty= True
    skiptonextrow = False

    for e, el in iterparse(z.open('xl/worksheets/sheet1.xml')):
        if el.tag.endswith('}row'):
            while count < len(keys):
                if keys[count] == None:
                    count += 1
                    continue

                row = row + '\"' + keys[count] + '\": ' + 'null' + ',\n'
                count += 1

            if first:
                if len(keys) == 0:
                    error( 'first row must be populated' )
            elif not first and not rowisempty:
                buf = buf + row + '},\n'
                
            row = ''
            count = 0
            first = False
            rowisempty = True
            skiptonextrow = False
            
        elif not skiptonextrow:
            if el.tag.endswith('}v'):
                value = el.text
                
            elif el.tag.endswith('}c'):
                if el.attrib.get('t') == 's':
                    value = strings[int(value)]

                column = letter_column_number( el.attrib['r'] )
            
                if first:
                    while count < column:
                        keys.append(None)
                        count += 1

                    if value != None:
                        value = value.replace('"', '\\"')

                    keys.append(value)
                    
                elif column >= len(keys):
                    skiptonextrow = True
                    
                elif keys[column] != None:
                    while count < column:
                        if keys[count] != None:
                            row = row + '"' + keys[count] + '": ' + 'null' + ',\n'
                        count += 1
                    
                    if value == None:
                        value = 'null'
                    else:
                        rowisempty = False
                        value = value.replace('"', '\\"')
                        if not is_number(value) or (makedict and count == 0):
                            value = '"' + value + '"'

                    if column == 0:
                        row = value + ': {\n' if makedict else '{\n"' + keys[column] + '": ' + value + ',\n'
                    else:
                        row = row + '"' + keys[column] + '": ' + value + ',\n'

                value = None
                count += 1
            
    buf = buf + '}' if makedict else buf + ']'
    
    return buf

def xlsx_to_json_3d (path):
    try:
        z = zipfile.ZipFile(path)
    except:
        error( 'there was an error reading the file \"' + path + '\"' )
        
    strings = [el.text for e, el in iterparse(z.open('xl/sharedStrings.xml')) if el.tag.endswith('}t')]

    buf = '{\n'
    keys = []
    value = None
    entry = ''

    firstrow = True
    inited = False
    rowisempty = True
    skiptonextrow = False

    count = 0
    
    for e, el in iterparse(z.open('xl/worksheets/sheet1.xml')):
        if el.tag.endswith('}row'):
            
            if firstrow:
                if len(keys) == 0:
                    error( 'first row must be populated' )
            elif not rowisempty:
                while count < len(keys):
                    if keys[count] == None:
                        count += 1
                        continue

                    entry = entry + '"' + keys[count] + '": ' + 'null' + ',\n'
                    count += 1

                entry = entry + '},\n'
            
            firstrow = False
            count = 0
            skiptonextrow = False
            rowisempty = True
        elif not skiptonextrow:
            if el.tag.endswith('}v'):
                value = el.text
                
            elif el.tag.endswith('}c'):
                if el.attrib.get('t') == 's':
                    value = strings[int(value)]

                column = letter_column_number( el.attrib['r'] )
                
                if firstrow:
                    if column != 0:
                        while count < column:
                            keys.append(None)
                            count += 1
                      
                        if value != None:
                            value = value.replace('"', '\\"')

                        keys.append(value)
                    else:
                        keys.append(None)
              
                elif column >= len(keys):
                    skiptonextrow = True
                    
                elif column == 0 and value != None:
                    if inited:
                        buf = buf + entry + '],\n'

                    value = value.replace('"', '\\"')

                    entry = '"' + value + '": [\n'
                    
                    inited = True
                elif not inited:
                    error( 'initialize a key in column 1' )
                    
                elif keys[column] != None:
                    if rowisempty:
                        entry = entry + '{\n'
                        
                    while count < column:
                        if keys[count] != None:
                            entry = entry + '"' + keys[count] + '": ' + 'null' + ',\n'
                        count += 1

                    if value == None:
                        value = 'null'
                    else:
                        rowisempty = False
                        value = value.replace('"', '\\"')
                        if not is_number(value):
                            value = '"' + value + '"'

                    entry = entry + '"' + keys[column] + '": ' + value + ',\n'
                    

                value = None
                count += 1

    buf = buf + entry + ']\n}' if inited else buf + entry + '}'

    return buf


args = sys.argv
arg = ''
filepath = ''
opt_3d = False

while True:
    try:
        arg = args[1]
    except:
        error( 'you must a provide a file path' )

    if arg == '-3d':
        opt_3d = True
    else:
        filepath = arg
        break

    del args[1]

output = xlsx_to_json_3d(filepath) if opt_3d else xlsx_to_json(filepath)

print(output)
