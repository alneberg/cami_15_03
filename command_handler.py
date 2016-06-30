#!/usr/bin/env python
__author__ = 'pbelmann', 'alneberg'

import argparse
import yaml
import os
import sys
import json

class Binner:
    def __init__(self, **entries):
        self.__dict__.update(entries)
        self.reads = [d for d in self.arguments if 'fastq' in d][0]['fastq']
        self.assembly = [d for d in self.arguments if 'fasta' in d][0]['fasta']


if __name__ == "__main__":

    # Parse arguments
    parser = argparse.ArgumentParser(description='Parses input yaml')
    parser.add_argument('-i', '--input_yaml', dest='i', nargs=1,
                        help='YAML input file')
    parser.add_argument('-o', '--output_path', dest='o', nargs=1,
                        help='Output path')
    parser.add_argument('--config_input', help='config.json file for snakemake that will be modified')
    
    parser.add_argument('--config_output', help='config.json file for snakemake that has been modified')
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

    fastqs = {}
    for read in binner.reads:
        fastqs[read['id']] = read['value']

    # Construct the config.json for snakemake
    with open(args.config_input, 'r') as config_file:
        config = json.load(config_file)    
    config['assembly'] = binner.assembly['value']
    config['fastqs'] = fastqs
    with open(args.config_output, 'w') as ofile:
        ofile.write(json.dumps(config))
    
    # Start snakemake

    command = "cd /bbx/snakemake_rundir/ && snakemake --debug concoct_merged_all && cp -r concoct/final_result.tsv /bbx/output/"

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
        print(exit)
        sys.exit(1)
