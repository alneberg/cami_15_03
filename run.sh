#!/bin/bash

#validate yaml
${VALIDATOR}/validate-biobox-file --schema=${VALIDATOR}schema.yaml --input=/bbx/input/biobox.yaml

cd /opt/CONCOCT
#if valid yaml run concoct command
if [ $? -eq 0 ]
then
    source activate snakemake
    cd /bbx && /opt/miniconda/envs/snakemake/bin/python command_handler.py -i /bbx/input/biobox.yaml -o /bbx/output --config_input /bbx/config.json --config_output snakemake_rundir/config.json 2> /bbx/output/log.txt
else
    exit 1;
fi
