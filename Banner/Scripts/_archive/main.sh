#!/bin/bash
now=$(date +"%Y-%m-%d")
if [ ! -e "$now" ];  then
   mkdir $now
fi
cd Banner_hvd
   
function megaterik  {
   echo "run for megaterik"
   cp new_testing.xml megaterik/banner/testing_data/
   cp new_training.xml megaterik/banner/training_data/
   cd megaterik/banner/banner_source
   java -cp "lib/*:../out/production/banner_source/" banner.eval.BANNER train config/banner_bioc.xml 
   java -cp "lib/*:../out/production/banner_source/" BANNER_BioC config/banner_bioc.xml ../testing_data/new_testing.xml out.xml
}

if [ "$1" = "megaterik" ]; then
   megaterik
fi

