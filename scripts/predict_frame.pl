#!/usr/bin/perl

use strict;
use warnings;

# Assign filename for the tabular file
my $tabFile=$ARGV[0];

# Make output filename for tabular file specifying start frame for each sequence
my $frameFile='tmp_frame.tab';

# Define other variables
my %seqIDs=();
my $ID='';
my $currFrame=1;
my $stopContent=0;

# Open, read, and calculate correct frame per sequence, as determined by the stop codon percentage
open(my $tabFile_FH, '<', $tabFile);
while (my $line=<$tabFile_FH>){
	
	## Check if line matches the correct tabular format
	if ($line=~ m/^(\S+)\t\S+\s+(\S+)/){
		$ID=$1;
		$stopContent=$2;
		
		### If sequence ID has not been seen before, store starting values
		if (!exists($seqIDs{$ID})){
			$currFrame=1;
			$seqIDs{$ID}{'stop'}=$stopContent;
			$seqIDs{$ID}{'frame'}=$currFrame;
		}
		
		### If sequence ID has been seen before, then check if stop codon content is lower in the new sequence. If so, replace values in stored hash
		else {
			$currFrame++;
			if ($stopContent<$seqIDs{$ID}{'stop'}){
				$seqIDs{$ID}{'stop'}=$stopContent;
				$seqIDs{$ID}{'frame'}=$currFrame;
			}
		}
		
		### If reached the last forward frame, then print the stored ID and its correct frame in tabular format
		if ($currFrame==3){
			print STDOUT $ID . "\t" . $seqIDs{$ID}{'frame'} . "\n";
		}
	}
}
close($tabFile_FH);

