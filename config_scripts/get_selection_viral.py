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

    parser.add_argument('-f', '--file', help='file_recap',
    type=str, metavar='FILE', required=True)

    parser.add_argument('-a', '--ass', help='file_assembly',
    type=str, metavar='ASS', required=True)

    parser.add_argument('-c1', '--chec1', help='checkV1',
    type=str, metavar='CHEC1', required=True)

    parser.add_argument('-c2', '--chec2', help='checkV2',
    type=str, metavar='CHEC2', required=True)

    parser.add_argument('-n', '--name', help='name_sample',
    type=str, metavar='NAME', required=True)

    parser.add_argument('-o', '--output', help='output directory',
    type=str, metavar='OUTPUT', required=True)

    return parser.parse_args()

def main():
	args = get_args()
	assembly=args.ass
	list_viral=args.file

	checkV_VS=args.chec1
	checkV_DVF=args.chec2

	out_dir=args.output

	sample_name=args.name

###########################################################
	viral_all = pd.read_csv(list_viral, sep=',')

######################## PROVIRUS #########################

# get proviral sequences
	provirus = viral_all[(viral_all['provirus'] == 'Yes')]
	selected_sequences = []
	provirus_cpt=1

	print(provirus)

## VS2 proviruses
	provirus_VS = provirus[(provirus['VS2'])]
	pro_selection1 = provirus_VS['VS_contig_name'].tolist()

	pro_VS = checkV_VS+"/proviruses.fna"
	
	for record in SeqIO.parse(pro_VS, "fasta"):
		print(record.id)
		my_rec=record.id[:len(record.id)-2]
		if (my_rec in pro_selection1):
			record.id=sample_name+"_provirus_"+str(provirus_cpt)
			selected_sequences.append(record)
			provirus_cpt=provirus_cpt+1

	print("Found %i sequences" % len(selected_sequences))

## DVF proviruses
	provirus_DVF = provirus[(~provirus['VS2'])]
	pro_selection2 = provirus_DVF['contig_id'].tolist()

	pro_DVF = checkV_DVF+"/proviruses.fna"

	for record in SeqIO.parse(pro_DVF, "fasta"):
		print(record.id)
		my_rec=record.id[:len(record.id)-2]
		if (my_rec in pro_selection2):
			record.id=sample_name+"_provirus_"+str(provirus_cpt)
			selected_sequences.append(record)
			provirus_cpt=provirus_cpt+1

	print("Found %i sequences" % len(selected_sequences))

	outfile=out_dir+"/"+sample_name+"_sel1_provirus.fa"
	SeqIO.write(selected_sequences, outfile, "fasta")

######################## VIRAL #########################

# get viral sequences
	virus = viral_all[(viral_all['provirus'] == 'No')]
	selected_sequences2 = []
	viral_cpt=1

	vir_selection = virus['contig_id'].tolist()

	for record in SeqIO.parse(assembly, "fasta"):
		if (record.id in vir_selection):
			record.id=sample_name+"_viral_"+str(viral_cpt)
			selected_sequences2.append(record)
			viral_cpt=viral_cpt+1

	print("Found %i sequences" % len(selected_sequences2))

	outfile=out_dir+"/"+sample_name+"_sel1_viral.fa"
	SeqIO.write(selected_sequences2, outfile, "fasta")


if __name__ == "__main__":main()
