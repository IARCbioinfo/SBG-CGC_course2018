# SBG-CGC course 2018

[![Join the chat at https://gitter.im/IARCbioinfo/SBG-CGC_course2018](https://badges.gitter.im/IARCbioinfo/SBG-CGC_course2018.svg)](https://gitter.im/IARCbioinfo/SBG-CGC_course2018?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

IARC course on analyzing TCGA data in the SevenBridges Genomics CancerGenomicsCloud (SBG-CGC).  

## Description of the course

__Learning objectives__  
After completing this workshop, participants will be able to run their own computational tools on the cloud using TCGA data using:
* the SevenBridges web interface to select and retrieve TCGA data,
* Docker and DockerHub to build and store containers to deploy their own
computational tools,
* the Common Workflow Language (CWL) to describe the pipelines to run,
* the SevenBridges R api to run automatically reproducible analyses.  

__Main topics__
* Introduction to Cloud computing
* Introduction to Docker and DockerHub
* SevenBridges R API and web interface
* TCGA data analysis

## Agenda

__Wednesday 28 February__  
09:00-10:00 Introduction to cloud computing and the SevenBridges architecture  
10:00-10:30 Introduction to TCGA data  
10:30-11:00 Break  
11:00-11:30 Introduction to the SevenBridges web interface to run analyses  
11:30-12:30 Practical application: run your first basic analysis in the cloud  

__Thursday 1 March__  
09:00-09:30 Introduction to Docker and DockerHub  
09:30-11:00 Practical application: building your own Docker container and run it in the cloud  
11:00-11:30 Break  
11:30-12:30 Introduction to the R api and the CWL language  

__Friday 2 March__  
09:00-12:30 Practical application: running your own practical project in the cloud using the R api, CWL and Docker.  
12:30-14:00 Lunch Break  
14:00-17:00 Practical application: running your own practical project in the cloud using the R api, CWL and Docker.  

## Gitter Chat

A [gitter channel](https://gitter.im/IARCbioinfo/SBG-CGC_course2018) is open for the course. This will allow participants to discuss on their projects but also to ask any question regarding the course.

## Participants guidelines

Participants would need to install R and Rstudio. One possibility is to use the steps proposed in [this gist](https://gist.github.com/mGalarnyk/41c887e921e712baf86fecc507b3afc7).  
Caution:  
  * please change the version of rstudio installed into the last one: 1.1.423
  * you would probably need to add a key with `sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys THE_KEY`.  
  * two more packages are needed, execute: `sudo apt install libcurl4-openssl-dev` and `sudo apt-get install libssl-dev`

R package sevenbridges-r is also needed:
```
source("https://bioconductor.org/biocLite.R")
biocLite("sevenbridges")
```

## Projects

__Important__: your CGC token gives full access to your CGC account, including the protected TCGA data if you have access to it. This is like your username and password. This means that you should never share it with anyone, and only keep it in a secure location (not a USB key, a non-secure computer or a laptop leaving IARC).

For each project, we have opened an issue to discuss on, and add a folder to host the code.  

Project 1: needlestack variant calling. [Issue](https://github.com/IARCbioinfo/SBG-CGC_course2018/issues/1). [Code]().

Project 2: neutral tumor evolution. [Issue](https://github.com/IARCbioinfo/SBG-CGC_course2018/issues/2). [Code]().

Project 3: cell populations from RNA-seq. [Issue](https://github.com/IARCbioinfo/SBG-CGC_course2018/issues/3). [Code]().
