#!/bin/bash

export HOMES=/Users/andrea/Documents/NTL/Banner/AlgoBanner/Submissions

echo "run for egor"
cd $HOMES
cp new_training.xml egor/banner_source/data/
cp new_testing.xml egor/banner_source/data/
cd egor/banner_source
java -Xmx400M -cp 'lib/*' banner.eval.BANNER train config/banner_bioc.xml
java -Xmx400M -cp 'lib/*' BANNER_BioC config/banner_bioc.xml $HOMES/new_testing.xml out.xml
