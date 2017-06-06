#!/bin/bash
export HOMES=/Users/andrea/Documents/NTL/Banner/AlgoBanner/Submissions

echo "run for FUGUSUKI"
cd $HOMES
cp new_training.xml fugusuki/banner/training_data/
cp new_testing.xml fugusuki/banner/testing_data/

# Banner
cd fugusuki/banner/crowd_words
javac -cp "lib/*" src/org/scripps/crowdwords/*.java
java -cp "src:lib/*" org.scripps.crowdwords.TestAggregation
cp ./train/* ../banner_source/train/
cd ../banner_source
rm -f ./tagger/*
javac -cp "lib/*" src/banner/eval/dataset/*.java
javac -cp "lib/*" src/banner/eval/*.java
java -Xmx400M -cp "src:lib/*" banner.eval.BANNER
javac -cp "lib/*" src/*.java
java -cp "src:lib/*" BANNER_BioC

