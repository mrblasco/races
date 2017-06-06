%	Running Banner
%
%

1. Using Banner
2. Using Crowd annotations


Using BANNER
=============

Check folder `tutorial`


## Prerequisite Software List

- Java 1.6 Development Kit (JDK)
- Ant
- Subversion

See `BannerIntroTutorial.html`

## Download 

```
svn co https://banner.svn.sourceforge.net/svnroot/banner banner  
```

## Execution

In the `trunk` dir: 

```
ant -buildfile build_ext.xml
```

This generates the program in the dir `'lib'`.

Type the following to test the program:

```
java -cp 'lib/*' banner.eval.BANNER
```

## Train a model

File `config.xml` should store configuration parameters. Then type: 

```
train config.xml
```

For training purposes, the BioCreative dataset can be downloaded from:  http://sourceforge.net/projects/biocreative/files/biocreative2entitytagging/1.1/

Or the Arizona Disease Corpus (AZDC): `banner_AZDC.xml`


## Creating a corpus for training a model with Banner

A new corpus used with Banner must be in the proper format for Banner to train a NER model from it.  Users must find ways external to Banner to convert their corpus into one compatible for Banner because Banner does not currently supply a conversion tool for that.  

The corpus's "sentenceFilename" file should contain the format of "SentenceID<Tab>Sentence".  The "mentionTestFilename" and "mentionAlternateFilename" files should contain annotated mentions in the format "SentenceID|StartOffset1 EndOffset1|OptionalText".



Using Crowd annotations
========================

Check folder `crowd_words`


## README #

This repository contains code to translate noisy, redundant, crowdsourced annotations of natural language text, such as disease mentions, into coherent, high quality annotated corpora that could be used to train machine learning algorithms such as [BANNER](https://svn.code.sf.net/p/banner/code/trunk/).  

### How do I get set up? ###

* The repo currently contains a functional Eclipse project with all of the dependencies included as jar files in the lib folder.  If you clone the repo (see link to the top left) with Hg (mercurial), and put in your eclipse workspace, it should work.  If you have the Hg Eclipse plugin, you can use the "import" dialogue to bring the project directly into your Eclipse environment.

### How can I test it? ###
* There is a hardcoded example file called TestAggregation that you can use to test a simple voting scheme for aggregating the annotations
* Open the file up to see how it works and touch the Main if you want to change its IO..
* **Input** is a crowdsourced mention annotation file in the BioC xml format, an optional gold standard file for comparison also in BioC, and a directory to write various versions of the aggregated annotations.  
* **Output** is a comparison to the gold standard using precision, recall and the f measure (if a gold standard is provided  
* **Data** is provided in the /data directory for both crowdsourced and gold standard disease annotations
