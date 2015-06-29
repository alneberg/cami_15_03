#!/usr/bin/env python
__author__ = 'pbelmann', 'alneberg'

import argparse
import yaml
import os
import sys

class Binner:
    def __init__(self, **entries):
        self.__dict__.update(entries)


if __name__ == "__main__":

    # Parse arguments
    parser = argparse.ArgumentParser(description='Parses input yaml')
    parser.add_argument('-i', '--input_yaml', dest='i', nargs=1,
                        help='YAML input file')
    parser.add_argument('-o', '--output_path', dest='o', nargs=1,
                        help='Output path')
    args = parser.parse_args()

    # get input files
    input_yaml_path = ""
    output_path = ""
    if hasattr(args, 'i'):
        input_yaml_path = args.i[0]
    if hasattr(args, 'o'):
        output_path = args.o[0]

    #serialize yaml with python object
    f = open(input_yaml_path)
    binner = Binner(**yaml.safe_load(f))
    f.close()

    reads_dir = binning.reads_dir
    assembly = binning.assembly
    
    # Construct the config.json for snakemake
    config = json.load('config.json')    
    config['assemblies'] = [assembly]
    config['reads_dir'] = reads_dir
    config.dump("/bbx/snakemake_rundir/config.json")
    
    # Start snakemake

    command = "cd /bbx/snakemake_rundir/ && snakemake --dryrun --debug all"

    exit = os.system(command)

    if (exit == 0):
        out_dir = output_path + "/bbx"
        if not os.path.exists(out_dir):
            os.makedirs(out_dir)
        yaml_output = out_dir + "/biobox.yaml"
        output_data = {'version': '0.9.0', 'arguments': [
            {"fasta": [
                {"value": "/ray/Contigs.fasta", "type": "contig" , "id" : "1"},
                {"value": "/ray/Scaffolds.fasta", "type": "scaffold", "id": "2"}]}]}
        stream = open(yaml_output, 'w')
        yaml.dump(output_data, default_flow_style=False, stream=stream)
    else:
        sys.exit(1)
