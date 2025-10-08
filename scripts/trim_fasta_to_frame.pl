#!/usr/bin/perl

use strict;
use warnings;

# Assign filenames for the filter list and the FASTA sequences
my $listFile=$ARGV[0];
my $seqFile=$ARGV[1];

# Define other variables
my %seqIDs=();
my $substrOffset=0;
my $ID='';

# Open, read, and store the unique IDs of the sequences and their correct frame in %seqIDs hash, using the unique IDs and key
open(my $listFile_FH, '<', $listFile);
while (my $line=<$listFile_FH>){
	## Check if line matches non-whitespace chatacters at the beggining (correct tabular format)
	if ($line=~ m/^(\S+)\t(\S+)/){
		$seqIDs{$1}=$2;
	}
}
close($listFile_FH);


# Open, read, and trin the 5'-end of nucleotide sequences in order to get them into the correct frame
open(my $seqFile_FH, '<', $seqFile);
while (my $line=<$seqFile_FH>){
	
	## Check if line is empty (nothing in between start "^" and end "$")
	if ($line=~m/^$/){
		next;
	}
	
	## Check if line matches a fasta header (begining with ">")
	if ($line=~m/^>(\S+)/){
		$ID=$1;
		print STDOUT $line;
		
		## Go to next line (the first one containing sequence)
		$line=<$seqFile_FH>;
		
		## Remove the necessary leading nucleotides to correct frame and print the new string
		$substrOffset=$seqIDs{$ID}-1;
		print STDOUT substr($line,$substrOffset);
	}
	
	## Print non-header, non-first sequence line lines
	else {
		print STDOUT $line;
	}
}
close($seqFile_FH);
