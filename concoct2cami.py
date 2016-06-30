#!/usr/bin/python
# -*- coding: utf-8 -*-
"""
@author: belmann, alneberg
"""
import argparse
import os
import pandas as pd


def concoct_to_cami(input_path, output_path):
    f = open(output_path, 'w')
    f.write('@Version:0.9.0\n')
    f.write('@SampleId:All\n')
    f.write('@@SEQUENCEID\tBINID\n')   
    f.close()
    clustering_df = pd.read_table(input_path, header=None, index_col=0, sep=',')
    clustering_df.to_csv(output_path, mode='a', sep='\t', header=None)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Transform concoct to CAMI Format')
    parser.add_argument('-i', '--input',dest='input',
                        help='Path to concoct output clustering file.')
    parser.add_argument('-o', '--output',dest='output',
                        help='Output file for cami format')
 
    args = parser.parse_args()
    concoct_to_cami(args.input, args.output)
