## Docker demo and tutorial

### Run and manage your first images and containers

Let's first download an image of Ubuntu latest version (from https://hub.docker.com):
```bash
$ docker run -it ubuntu
Unable to find image 'ubuntu:latest' locally
latest: Pulling from library/ubuntu
2332d8973c93: Pull complete
ea358092da77: Pull complete
a467a7c6794f: Pull complete
ca4d7b1b9a51: Pull complete
library/ubuntu:latest: The image you are pulling has been verified. Important: image verification is a tech preview feature and should not be relied on to provide security.
Digest: sha256:f91f9bab1fe6d0db0bfecc751d127a29d36e85483b1c68e69a246cf1df9b4251
Status: Downloaded newer image for ubuntu:latest
root@7c94b70daa8a:/# exit
```

Let's look at the images:
```bash
$ docker images
REPOSITORY                TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
ubuntu                    latest              ca4d7b1b9a51        39 hours ago        187.9 MB
```

Be careful, our container (the instance of the image) is still here:
```bash
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                     PORTS               NAMES
7c94b70daa8a        ubuntu              "/bin/bash"         2 minutes ago       Exited (0) 2 minutes ago                       jovial_hypatia
```

You can kill it with `docker rm 7c94b70daa8a`. You can also kill all running containers using `docker rm $(docker ps -a -q)`. Similarly you can delete our ubuntu image using `docker rmi ca4d7b1b9a51` and all images using `docker rmi $(docker images -q)`.

### Create your first container

Now let's install something ([samtools](http://www.htslib.org)) in our container:
```bash
$ docker run -it ubuntu
$ apt-get update
$ apt-get install samtools
$ samtools

Program: samtools (Tools for alignments in the SAM format)
Version: 0.1.19-96b5f2294a

Usage:   samtools <command> [options]
$ exit
```

Be careful, now if you again type `docker run -it ubuntu`, samtools won't be here: the image remained the same when we installed samtools, only the container changed, but now you stopped it when you exited. You can start it again:
```bash
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                          PORTS               NAMES
e6f92d19b512        ubuntu              "/bin/bash"         3 minutes ago       Exited (1) About a minute ago                       mad_goodall
$ docker start -ia e6f92d19b512
$ samtools

Program: samtools (Tools for alignments in the SAM format)
Version: 0.1.19-96b5f2294a

Usage:   samtools <command> [options]
$ exit
```

Now if we want to keep our container as an image (to be able to re-use it), you can do it simply with:
```bash
$ docker commit -m "added samtools" e6f92d19b512 samtools_img
e664fa7478a7a74addbef19379412a901bc05c8164d21c2de58e62a32e0117c3
$ docker images
REPOSITORY                TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
samtools_img              latest              e664fa7478a7        4 seconds ago       211.5 MB
ubuntu                    latest              ca4d7b1b9a51        40 hours ago        187.9 MB
```

Now that we saved it as an image, a good practice is to delete containers when we are done using them. You can simply do this by adding `--rm` when you create a container:
```bash
$ docker rm $(docker ps -a -q)
$ docker run --rm -it samtools_img
$ samtools

Program: samtools (Tools for alignments in the SAM format)
Version: 0.1.19-96b5f2294a

Usage:   samtools <command> [options]
$ exit
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

### Accessing your data

Now the final problem is that the docker container is disconnected from our machine, so we have no way of accessing any data... We can "mount" a directory from our machine in the container using `-v` option and also automatically move to this directory when the container starts. For example:
```bash
$ docker run -it --rm -v /Users/follm/Github/SBG-CGC_course2018/demo_code:/data -w /data samtools_img
$ samtools view -H NA06984.bam | head
@HD	VN:1.0	SO:coordinate
@SQ	SN:1	LN:249250621	M5:1b22b98cdeb4a9304cb5d48026a85128	UR:ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/phase2_reference_assembly_sequence/hs37d5.fa.gz	AS:NCBI37	SP:Human
$ exit
```

Note `-v` option only accepts absolute path, so a good trick is to systematically mount your current working directory using `$PWD` into the same target directory. Note that you can have multiple `-v` options when you run a container. So it makes something like this:
```bash
$ docker run -it --rm -v $PWD:$PWD -w $PWD samtools_img
$ samtools view -H NA06984.bam | head
```

So far we always run interactively docker containers, but you can actually run it automatically. Still the same example becomes:
```bash
$ docker run -it --rm -v $PWD:$PWD -w $PWD --entrypoint /bin/bash samtools_img -c "samtools view -H NA06984.bam | head"
```

One more trick to make the command simpler to type by creating a bash function:
```bash
$ samtools_docker () { docker run -it --rm -v $PWD:$PWD -w $PWD --entrypoint /bin/bash samtools_img -c "samtools $@"; }
$ samtools_docker "view -H NA06984.bam | head"
```

### Sharing your container

And voilà! You can save your image using `docker save 'samtools_img' > samtools_img.tar` and distribute it (check software licences...). You can also host it freely on [Docker Hub](https://hub.docker.com). To push a repository to the Docker Hub (see instructions [here](https://docs.docker.com/docker-hub/repos/)), you first need to create a repository on Docker Hub, and to name your local image using your Docker Hub username, and the repository name that you created. You can add multiple images to a repository, by adding a specific `:<tag>` to it (for example `docs/base:testing`). If it’s not specified, the tag defaults to `latest`. You can name your local images either when you build it, using `docker build -t <hub-user>/<repo-name>[:<tag>]`, by re-tagging an existing local image `docker tag <existing-image> <hub-user>/<repo-name>[:<tag>]`, or by using `docker commit <exiting-container> <hub-user>/<repo-name>[:<tag>]` to commit changes.

Now you can push this repository to the registry designated by its name or tag.
```
$ docker push <hub-user>/<repo-name>:<tag>
```
The image is then uploaded and available for use by your team-mates and/or the community.

You can also make the process automatic by using a [Dockerfile](http://docs.docker.com/engine/reference/builder/). In our case it looks like:
```
FROM ubuntu
MAINTAINER Matthieu Foll <follm@iarc.fr>
RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install samtools
```

If the file is called Dockerfile you simply need to type: `docker build -t samtools_img2 .` to create an image called `samtools_img2`. You can also name your local images when you build it, using `docker build -t <hub-user>/<repo-name>[:<tag>]` and then push it to Docker Hub.

The Dockerfile is easier to distribute than the actual image. Note that if you host your Dockerfile on [github](https://github.com), [Docker Hub](https://hub.docker.com) can make automatically build it whenever you modify it. Instructions for creating automated builds are [here](https://docs.docker.com/docker-hub/builds/). This is the way we recommend you to use.

You can browse [Docker Hub](https://hub.docker.com) and you will see that you can find three different classes of images:
- Base images, just containing a given Linux distributions (centos, debian, ubuntu etc.)
- Images to distribute a specific software ([R](https://hub.docker.com/_/r-base/) for example).
- Images bundling several software for a given task ([NGSeasy](https://hub.docker.com/r/compbio/ngseasy-base/) for example)

### Make your life easy

Note that some interesting projects exist to create containers organised by research topic, like the [BioContainers](http://biocontainers.pro) project for bioinformatics on [DockerHub](https://hub.docker.com/u/biocontainers/). You might already find what you need here. BioContainers is using the [bioconda](http://bioconda.github.io) package manager specialized in bioinformatics software. This is very useful as it makes the installation of bioinformatics software very easy, as most of them are not available using `apt-get` (and the samtools version we installed in the previous examples is completely outdated).  Putting together docker and bioconda is a very powerful and simple way of creating the docker containers you need. If you have a look at the dockerfiles in BioContainers you will see that they all look the same with a single `RUN` command like this for [samtools](https://hub.docker.com/r/biocontainers/samtools/~/dockerfile/) for example:
```
RUN conda install samtools=1.3.1
```

The nice possible because the [base image](https://hub.docker.com/r/biocontainers/biocontainers/~/dockerfile/) they use contains bioconda. The nice thing is that you can borrow a base image from someone else to create your container. For exmaple if you need to have both `samtools` and `bedtools` in a container, you can create a simple Dockerfile like this:
```
FROM biocontainers/biocontainers:latest
MAINTAINER Matthieu Foll <follm@iarc.fr>
RUN conda install bedtools=2.25.0
RUN conda install samtools=1.3.1
```

A final note: you will very often see Dockerfiles looking rather like this:
```
FROM biocontainers/biocontainers:latest
MAINTAINER Matthieu Foll <follm@iarc.fr>
RUN conda install bedtools=2.25.0 && \
    conda install samtools=1.3.1
```
You can find out why if you read the [best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/) along with some other interesting tips...
