#!/usr/bin/perl

use strict;
use warnings;

# Assign filenames for the filter list and the FASTA sequences
my $listFile=$ARGV[0];
my $seqFile=$ARGV[1];

# Make output filenames for separated HA and NA genes
my $seqFile_HA='HA_genes.ffn'; # HA gene is also known as segment 4
my $seqFile_NA='NA_genes.ffn'; # NA gene is also known as segment 6

# Define other variables
my %seqIDs=();
my $flag_print=0;
my $flag_gene='';
my $ID='';

# Open, read, and store the unique IDs of the sequences to retain in %seqIDs hash, using the unique IDs and key
open(my $listFile_FH, '<', $listFile);
while (my $line=<$listFile_FH>){
	## Check if line matches non-whitespace chatacters at the beggining (correct format)
	if ($line=~ m/^(\S+.+)/){
		$seqIDs{$1}=1;
	}
}
close($listFile_FH);

open(my $seqFile_HA_FH, '>', $seqFile_HA);
open(my $seqFile_NA_FH, '>', $seqFile_NA);

open(my $seqFile_FH, '<', $seqFile);
while (my $line=<$seqFile_FH>){
	
	## Check if line is empty (nothing in between start "^" and end "$")
	if ($line=~m/^$/){
		next;
	}
	
	## Check if line matches a fasta header (begining with ">")
	if ($line=~m/^>/){
		$flag_print=0;
		
		### Check if there is a match to "segment 4", and thus the hemaglutinin (HA) gene
		if ($line=~m/segment 4/){
			$flag_gene='HA';
		}
		
		### Check if there is a match to "segment 6", and thus the hemaglutinin (NA) gene
		elsif ($line=~m/segment 6/){
			$flag_gene='NA';
		}
		
		### Check if there is no match to either of the segments (sanity check)
		else {
			$flag_gene='none';
		}
		
		
		### Make a copy of the line in the new variable ID to modify it
		$ID=$line;
		
		### Process the current line string to keep only the unique ID
		chomp $ID;
		$ID=~s/.+virus \(//;
		$ID=~s/\)\) [a-z]+ .+/\)/;
		
		### Check if the current unique ID is stored (and thus one to filter in)
		if ($seqIDs{$ID}){
			$flag_print=1;
		}
	}
	
	## Check if a match has been found between the current header and the stored ones in %seqIDs hash
	if ($flag_print){
	
		### Check if there is a match to "segment 4", and thus the hemaglutinin (HA) gene
		if ($flag_gene eq 'HA'){
			print $seqFile_HA_FH $line;
		}
		
		### Check if there is a match to "segment 6", and thus the hemaglutinin (NA) gene
		elsif ($flag_gene eq'NA'){
			print $seqFile_NA_FH $line;
		}
		
		### Check if there is no match to either of the segments (sanity check, if prompted the message, correct script)
		elsif ($flag_gene eq'other') {
			print STDOUT "WARNING: the following sequence does not match either segment 4 or 6 strings\n$line\n";
		}
	}
}
close($seqFile_FH);

close($seqFile_HA_FH);
close($seqFile_NA_FH);
