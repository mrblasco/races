#!/bin/bash

# Check Parameters by elements (unescape)
xmlstarlet el -u $1 | sort > 3.xml
var=`diff 2.xml 3.xml`
if [ ! -z "$var"  ]; then
    echo "Input file structure not correct"
    exit 1
fi
mv $1 new_training.xml
mv $2 new_testing.xml

function fugusuki {
   echo "run for FUGUSUKI"
   # Inputs
   cp new_training.xml fugusuki/banner/training_data/
   cp new_testing.xml fugusuki/banner/testing_data/
   # Train & evaluate
   cd fugusuki/banner/crowd_words
   javac -cp "lib/*" src/org/scripps/crowdwords/*.java
   java -cp "src:lib/*" org.scripps.crowdwords.TestAggregation
   cp ./train/* ../banner_source/train/
   cd ../banner_source
   rm -f ./tagger/*
   javac -cp "lib/*" src/banner/eval/dataset/*.java
   javac -cp "lib/*" src/banner/eval/*.java
   java -cp "src:lib/*" banner.eval.BANNER
   javac -cp "lib/*" src/*.java
   java -cp "src:lib/*" BANNER_BioC
   # Outcomes
   cp $HOMES/fugusuki/banner/banner_source/BannerAnnotate.java  $HOMES/submissions/fugusuki.java
}

function orlov { 
   echo "run for orlov"
   cd $HOMES
   cp new_testing.xml orlov/banner/testing_data/
   cp new_training.xml orlov/banner/training_data/
   cd orlov
   cd bannerannotate/
   make
   ./main
   cd ../banner/training_data/
   cat ncbi_head.xml ncbi_body.xml ncbi_foot.xml > ncbi_train_bioc.xml
   cd ..
   patch -p1 < SentenceBreaker.patch
   cd banner_source
   ant -buildfile build.xml
   java -cp 'lib/*' banner.eval.BANNER train config/banner_bioc.xml
   java -cp 'lib/*' BANNER_BioC config/banner_bioc.xml $HOMES/new_testing.xml out.xml
   cp $HOMES/orlov/banner/banner_source/BannerAnnotate.java  $HOMES/submissions/orlov.java
}


echo "run for Pfr"
sudo apt-get install python3-pandas python3-lxml python3-pip && sudo pip3 install scikit-learn
cd $HOMES
cp new_testing.xml pfr/banner/testing_data/
cp new_training.xml pfr/banner/training_data/
cd $HOMES/pfr/banner
cd new
python3 ba.py
python3 crowd.py
cd ../banner_source
##compile and execute BANNER normally, using configuration file config/crowd.xml ...
java -cp 'lib/*' banner.eval.BANNER train config/crowd.xml
java -cp 'lib/*' BANNER_BioC config/crowd.xml $HOMES/new_testing.xml out.xml
cd ../new
python3 postprocess.py > final_submission.c
cp $HOMES/pfr/banner/mm_tester/BannerAnnotatorVis.java $HOMES/submissions/pfr.java


echo "run for megaterik"
cd $HOMES/
cp new_testing.xml megaterik/banner/testing_data/
cp new_training.xml megaterik/banner/training_data/
cd megaterik/banner/banner_source
java -cp "lib/*:../out/production/banner_source/" banner.eval.BANNER train config/banner_bioc.xml
java -cp "lib/*:../out/production/banner_source/" BANNER_BioC config/banner_bioc.xml $HOMES/new_testing.xml out.xml
cp $HOMES/megaterik/banner/mm_tester/src/BannerAnnotate.java $HOMES/submissions/megaterik.java


echo "run for Puffering"
cd $HOMES
cp new_testing.xml PuffRing-banner-e51a76749bea/testing_data
cp new_training.xml PuffRing-banner-e51a76749bea/training_data
cd $HOMES/PuffRing-banner-e51a76749bea/banner_source
java -cp 'lib/*' banner.eval.BANNER train config/banner_bioc.xml
java -cp 'lib/*' BANNER_BioC config/banner_bioc.xml $HOMES/new_testing.xml out.xml
cp $HOMES/PuffRing-banner-e51a76749bea/banner_source/BannerAnnotate.java $HOMES/submissions/Puffering.java

echo "run for Zhuoyu"
cd $HOMES
cp new_training.xml banner_wzy/banner_source/data/
cp new_testing.xml banner_wzy/banner_source/data/
cd banner_wzy/banner_source
java -cp 'lib/*' banner.eval.BANNER train config/banner_bioc.xml
java -cp 'lib/*' BANNER_BioC config/banner_bioc.xml $HOMES/new_testing.xml out.xml
cp $HOMES/banner_wzy/banner_source/BannerAnnotate.java $HOMES/submissions/Zhuoyu.java




echo "run for egor"
cd $HOMES
cp new_training.xml egor/banner_source/data/
cp new_testing.xml egor/banner_source/data/
cd egor/banner_source
java -cp 'lib/*' banner.eval.BANNER train config/banner_bioc.xml
java -cp 'lib/*' BANNER_BioC config/banner_bioc.xml $HOMES/new_testing.xml out.xml
cp $HOMES/egor/banner_source/BannerAnnotate.java $HOMES/submissions/egor.java
















