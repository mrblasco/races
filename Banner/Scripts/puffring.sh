#!/bin/bash

export HOMES=/Users/andrea/Documents/NTL/Banner/AlgoBanner/Submissions

echo "run for Puffering"
cd $HOMES
cp new_testing.xml PuffRing-banner-e51a76749bea/testing_data
cp new_training.xml PuffRing-banner-e51a76749bea/training_data

## 
cd $HOMES/PuffRing-banner-e51a76749bea/banner_source
java -Xmx400M -cp 'lib/*' banner.eval.BANNER train config/banner_bioc.xml
java -Xmx400M -cp 'lib/*' BANNER_BioC config/banner_bioc.xml $HOMES/new_testing.xml out.xml




