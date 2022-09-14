#!/bin/sh

IFS='
'

rm -rf $(find Assets -regex '.*\.import')
