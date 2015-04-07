# Docker for CONCOCT (http://github.com/BinPro/CONCOCT) v0.4.0
# VERSION 0.4.0
# 

FROM ubuntu:13.10
MAINTAINER CONCOCT developer group, concoct-support@lists.sourceforge.net

ENV PATH /opt/miniconda/bin:$PATH
ENV PATH /opt/velvet_1.2.10:$PATH

# Get basic ubuntu packages needed
RUN apt-get update -qq
RUN apt-get install -qq wget build-essential libgsl0-dev git zip unzip

# Set up Miniconda environment for python2
RUN cd /opt;\
    wget http://repo.continuum.io/miniconda/Miniconda-3.3.0-Linux-x86_64.sh -O miniconda.sh;\
    chmod +x miniconda.sh;\
    ./miniconda.sh -p /opt/miniconda -b;\
    conda update --yes conda;\
    conda install --yes python=2.7

# Bedtools2.17
RUN apt-get install -qq bedtools

# Picard tools 1.118
# To get fuse to work, I need the following (Issue here: https://github.com/dotcloud/docker/issues/514,
# solution here: https://gist.github.com/henrik-muehe/6155333).
ENV MRKDUP /opt/picard-tools-1.118/MarkDuplicates.jar
RUN apt-get install -qq libfuse2 openjdk-7-jre-headless
RUN cd /tmp ; apt-get download fuse
RUN cd /tmp ; dpkg-deb -x fuse_* .
RUN cd /tmp ; dpkg-deb -e fuse_*
RUN cd /tmp ; rm fuse_*.deb
RUN cd /tmp ; echo -en '#!/bin/bash\nexit 0\n' > DEBIAN/postinst
RUN cd /tmp ; dpkg-deb -b . /fuse.deb
RUN cd /tmp ; dpkg -i /fuse.deb
RUN cd /opt;\
    wget "http://downloads.sourceforge.net/project/picard/picard-tools/1.118/picard-tools-1.118.zip?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fpicard%2Ffiles%2Fpicard-tools%2F1.118%2F&ts=1396879817&use_mirror=freefr" -O picard-tools-1.118.zip;\
    unzip picard-tools-1.118.zip

# Samtools 0.1.19
RUN apt-get install -qq samtools

# Bowtie2.1.0
RUN apt-get install -qq bowtie2

# Parallel 20130622-1
RUN apt-get install -qq parallel

# Install python dependencies and fetch and install CONCOCT 0.4.0
RUN cd /opt;\
    conda update --yes conda;\
    conda install --yes python=2.7 atlas cython numpy scipy biopython pandas pip scikit-learn pysam;\
    pip install bcbio-gff;\
    wget --no-check-certificate https://github.com/BinPro/CONCOCT/archive/0.4.0.tar.gz;\
    tar xf 0.4.0.tar.gz;\
    cd CONCOCT-0.4.0;\
    python setup.py install

ENV CONCOCT /opt/CONCOCT-0.4.0
ENV CONCOCT_TEST /opt/Data/CONCOCT-test-data
ENV CONCOCT_EXAMPLE /opt/Data/CONCOCT-complete-example

ADD bbx/ /bbx
RUN chmod a+x /bbx/run/default
ENV PATH /bbx/run:$PATH

