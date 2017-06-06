#!/bin/bash
export HOMES=/Users/andrea/Documents/NTL/Banner/AlgoBanner/Submissions

echo "run for Zhuoyu"
cd $HOMES
cp new_training.xml banner_wzy/banner_source/data/
cp new_testing.xml banner_wzy/banner_source/data/
cd banner_wzy/banner_source
java -Xmx400M -cp 'lib/*' banner.eval.BANNER train config/banner_bioc.xml
java -Xmx400M -cp 'lib/*' BANNER_BioC config/banner_bioc.xml $HOMES/new_testing.xml out.xml
