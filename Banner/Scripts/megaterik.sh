#!/bin/bash
export HOMES=/Users/andrea/Documents/NTL/Banner/AlgoBanner/Submissions

echo "run for megaterik"
cd $HOMES/
cp new_testing.xml megaterik/banner/testing_data/
cp new_training.xml megaterik/banner/training_data/

TESTDATA='new_testing.xml'

# Set options for java
export _JAVA_OPTIONS="-Xms512m"

## Run all solutions
cd Topcoder/AlgoBanner/top_subs/

echo "run for megaterik"
cd megaterik/banner/banner_source
java -cp "lib/*:../out/production/banner_source/" banner.eval.BANNER train config/banner_bioc.xml
java -cp "lib/*:../out/production/banner_source/" BANNER_BioC config/banner_bioc.xml $HOMES/new_testing.xml out.xml

java -cp "lib/*:../out/production/banner_source/" BANNER_BioC config/banner_bioc.xml $HOMES/new_testing.xml out.xml

