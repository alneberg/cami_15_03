# Docker for CONCOCT (http://github.com/BinPro/CONCOCT) v0.4.0
# VERSION 0.4.0
# 

FROM ubuntu:14.04
MAINTAINER CONCOCT developer group, concoct-support@lists.sourceforge.net

ENV PATH /opt/miniconda/bin:$PATH

# Get basic ubuntu packages needed
RUN apt-get update -qq
RUN apt-get install -qq wget build-essential libgsl0-dev git zip unzip cmake

# Set up Miniconda environment for python2
RUN cd /opt;\
    wget http://repo.continuum.io/miniconda/Miniconda-3.9.1-Linux-x86_64.sh -O miniconda.sh;\
    chmod +x miniconda.sh;\
    ./miniconda.sh -p /opt/miniconda -b;\
    conda update --yes conda;\
    conda install --yes python=2.7

# Install python dependencies for concoct
RUN conda create --yes -n concoct python=2.7

RUN cd /opt;\
    conda install --yes -n concoct atlas cython numpy scipy biopython pandas pip scikit-learn pysam


# Install kallisto
RUN apt-get install -qq libhdf5-dev zlib1g-dev

RUN wget --no-check-certificate https://github.com/pachterlab/kallisto/archive/v0.42.2.1.tar.gz;\
    tar xf v0.42.2.1.tar.gz;\
    cd kallisto-0.42.2.1;\
    mkdir build;\
    cd build;\
    cmake ..;\
    make;\
    make install
    
# Install Snakemake within a conda environment
RUN conda create --yes -n snakemake python=3.4 pip pyyaml;\
    /opt/miniconda/envs/snakemake/bin/pip install snakemake

# Install Concoct
RUN apt-get install git
RUN cd /opt;\
    git clone https://github.com/BinPro/CONCOCT.git;\
    cd CONCOCT;\
    git fetch origin;\
    git checkout 311598bc9ae12adb94f974f2aa3831dea2cfdd0b;\
    /opt/miniconda/envs/concoct/bin/python setup.py install

# Add biobox schema validator
ENV VALIDATOR /bbx/validator/
ENV BASE_URL https://s3-us-west-1.amazonaws.com/bioboxes-tools/validate-biobox-file
ENV VERSION  0.x.y
RUN mkdir -p ${VALIDATOR}

# download the validate-biobox-file binary and extract it to the directory $VALIDATOR
RUN wget \
      --quiet \
      --output-document -\
      ${BASE_URL}/${VERSION}/validate-biobox-file.tar.xz \
    | tar xJf - \
      --directory ${VALIDATOR} \
      --strip-components=1

ADD schema.yaml ${VALIDATOR}

# add schema, tasks, run scripts
ADD run.sh /usr/local/bin/run
RUN chmod a+x /usr/local/bin/run 

RUN mkdir /bbx/snakemake_rundir
ADD bin/Snakefile /bbx/snakemake_rundir/Snakefile
ADD bin/config.json /bbx/config.json

ADD concoct2cami.py /bbx/snakemake_rundir/concoct2cami.py
RUN chmod a+x /bbx/snakemake_rundir/concoct2cami.py

ADD command_handler.py /bbx/command_handler.py
RUN chmod a+x /bbx/command_handler.py

# Switch to bash as default shell
ENV SHELL /bin/bash

ENTRYPOINT ["usr/local/bin/run"]
