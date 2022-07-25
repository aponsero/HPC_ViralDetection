#!/usr/bin/env python3
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
import pandas as pd
import itertools
import sys, getopt
import argparse

def get_args():
    parser = argparse.ArgumentParser(description='parse DVF results')

    parser.add_argument('-f', '--file', help='file_dvf',
    type=str, metavar='FILE', required=True)

    parser.add_argument('-a', '--ass', help='file_assembly',
    type=str, metavar='ASS', required=True)

    parser.add_argument('-n', '--name', help='name_sample',
    type=str, metavar='NAME', required=True)

    parser.add_argument('-o', '--output', help='output directory',
    type=str, metavar='OUTPUT', required=True)

    return parser.parse_args()

def main():
	args = get_args()
	outdir= args.output
	infile=args.file
	sample_name=args.name
	assembly=args.ass

   # parse DVF table output and select significant hits
	dvf_all = pd.read_csv(infile, sep='\t')
	filtered=dvf_all[(dvf_all['score'] > 0.9)]
	table_file=outdir+"/"+sample_name+"_dvf-viral-score.csv"
	filtered.to_csv(table_file, index=False)	

	selection = filtered['name'].tolist()

   # get assembly sequences from file
	outfile=outdir+"/"+sample_name+"_dvf-viral.fa"
	selected_sequences = []
	for record in SeqIO.parse(assembly, "fasta"):
		if (record.description in selection):
			print(record.description)
			selected_sequences.append(record)

	print("Found %i sequences" % len(selected_sequences))

	SeqIO.write(selected_sequences, outfile, "fasta")

if __name__ == "__main__":main()
