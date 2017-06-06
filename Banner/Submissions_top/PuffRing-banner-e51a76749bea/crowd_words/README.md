# README #

This repository contains code to translate noisy, redundant, crowdsourced annotations of natural language text, such as disease mentions, into coherent, high quality annotated corpora that could be used to train machine learning algorithms such as [BANNER](https://svn.code.sf.net/p/banner/code/trunk/).  

### How do I get set up? ###

* The repo currently contains a functional Eclipse project with all of the dependencies included as jar files in the lib folder.  If you clone the repo (see link to the top left) with Hg (mercurial), and put in your eclipse workspace, it should work.  If you have the Hg Eclipse plugin, you can use the "import" dialogue to bring the project directly into your Eclipse environment.

### How can I test it? ###
* There is a hardcoded example file called TestAggregation that you can use to test a simple voting scheme for aggregating the annotations
* Open the file up to see how it works and touch the Main if you want to change its IO..
* **Input** is a crowdsourced mention annotation file in the BioC xml format, an optional gold standard file for comparison also in BioC, and a directory to write various versions of the aggregated annotations.  
* **Output** is a comparison to the gold standard using precision, recall and the f measure (if a gold standard is provided  
* **Data** is provided in the /data directory for both crowdsourced and gold standard disease annotations