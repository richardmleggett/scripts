#!/usr/bin/perl -w

# Script:  fastq_to_fasta.pl
# Purpose: Convert FASTQ files to FASTA format
# Author:  Richard Leggett

use warnings;
use strict;

my $input=$ARGV[0];
my $output=$ARGV[1];

open(INFILE, $input) or die "Can't open ${input}\n";
open(OUTFILE, ">".$output) or die "Can't open ${output}\n";

while(<INFILE>) {
    my $header_a = $_;
    my $read = <INFILE>;
    my $header_b = <INFILE>;
    my $quals = <INFILE>;

    $header_a =~ s/^@/>/;

    print OUTFILE $header_a;
    print OUTFILE $read;
}

close(OUTFILE);
close(INFILE); 
