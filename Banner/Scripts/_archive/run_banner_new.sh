#!/bin/bash

# Check Data for consistency
## Boundary error, skipping: Sjögren-Larsson syndrome	 Sjögren-Larsson syndrom
## Boundary error, skipping: SLS	f S

## Move training & testing data
cp new_training.xml fugusuki/banner/training_data/
cp new_testing.xml fugusuki/banner/testing_data/

# Select solution
cd fugusuki/banner/crowd_words
javac -cp "lib/*" src/org/scripps/crowdwords/*.java
java  -Xmx400M -cp "src:lib/*" org.scripps.crowdwords.TestAggregation

## Move training data to banner source
cp ./train/* ../banner_source/train/

# Go to banner source
cd ../banner_source
rm -f ./tagger/*
javac -cp "lib/*" src/banner/eval/dataset/*.java
javac -cp "lib/*" src/banner/eval/*.java
java -Xmx400M -cp "src:lib/*" banner.eval.BANNER # evaluate Banner ???

exit 0

##  Compile ... 
javac -cp "lib/*" src/*.java
java -cp "src:lib/*" BANNER_BioC
cp $HOMES/fugusuki/banner/banner_source/BannerAnnotate.java  $HOMES/submissions/fugusuki.java

exit 0 
