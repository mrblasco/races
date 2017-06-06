#!/usr/bin/Bash
now=$(date +"%b %d")

filename="${1##*/}" ## drop path
tempfile="${filename%.*}" ## drop extension
echo $tempfile
if [ "$#" -gt 0 ]
    then
        pdflatex -output-directory=writing/aux "$1"
        open writing/aux/$tempfile.pdf
fi
