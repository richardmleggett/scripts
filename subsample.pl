#!/usr/bin/perl -w

# Script:  subsample.pl
# Purpose: Subsample FASTA or FASTQ files
# Author:  Richard Leggett

use warnings;
use strict;

use Getopt::Long;

my $input_r1_file;
my $input_r2_file;
my $output_r1_file;
my $output_r2_file;
my $remainder_r1_file;
my $remainder_r2_file;
my $wc_file;
my $n_readpairs;
my $number_required;
my %keep;
my $fasta;
my $fastq;
my $lines_per_entry = 4;
my $help_requested;
my $id_marker = "@";

&GetOptions(
    'a:s' => \$input_r1_file,
    'b:s' => \$input_r2_file,
    'c:s' => \$output_r1_file,
    'd:s' => \$output_r2_file,
    'e:s' => \$remainder_r1_file,
    'f:s' => \$remainder_r2_file,
    'h|help' => \$help_requested,
    'n:i' => \$number_required,
    'p|fasta' => \$fasta,
    'q|fastq' => \$fastq,
    'readpairs|r:i' => \$n_readpairs
);

if (defined $help_requested) {
    print "\nSubsample from FASTA or FASTQ files.\n\n";
    print "Usage: subsample.pl <-a input R1> <-b input R2> <-c output R1> <-d output R2> [options]\n\n";
    print "Options:\n";
    print "    -a               input R1 file\n";
    print "    -b               input R2 file\n";
    print "    -c               output R1 file\n";
    print "    -d               output R2 file\n";
    print "    -e               remainder R1 file\n";
    print "    -f               remainder R2 file\n";
    print "    -n               number of reads required\n";
    print "    -r | -readpairs  number of read pairs in file\n";
    print "                     (if not specified, will be found with wc\n";
    print "    -p | -fasta      FASTA format\n";
    print "    -q | -fastq      FASTQ format (defualt)\n";
    print "\n";
    exit;
}

die "You must specify how many reads you require" if not defined $number_required;
die "You must specify an input R1 file" if not defined $input_r1_file;
die "You must specify an input R2 file" if not defined $input_r2_file;
die "You must specify an output R1 file" if not defined $output_r1_file;
die "You must specify an output R1 file" if not defined $output_r2_file;

if (defined $fasta) {
    $lines_per_entry = 2;
    $id_marker = ">";
} else {
    $lines_per_entry = 4;
    $id_marker = "@";
}

# Get number of read pairs
if (not defined $n_readpairs) {
    my $wc = `wc -l ${input_r1_file}`;
    if ($wc =~ /(\d+) (\S+)/) {
        $n_readpairs = $1 / $lines_per_entry;
    }
}

die "Can't find number of pairs\n" if not defined $n_readpairs;

die "No entries in file!\n" if ($n_readpairs == 0);
die "Less entries in file than you asked for!" if ($n_readpairs <= $number_required);

print "Choosing ".$number_required." entries from ".$n_readpairs."...\n";

for (my $i=0; $i<$number_required; $i++) {
    my $r;

    do {
        $r = int(rand($n_readpairs));
    } while defined $keep{$r};

    $keep{$r} = 1;
}

print "Writing output file...\n";

open(my $input_a, $input_r1_file) or die;
open(my $input_b, $input_r2_file) or die;
open(my $output_a, ">".$output_r1_file) or die;
open(my $output_b, ">".$output_r2_file) or die;
my $remainder_a;
my $remainder_b;

if ((defined $remainder_r1_file) && (defined $remainder_r2_file)) {
    open($remainder_a, ">".$remainder_r1_file) or die;
    open($remainder_b, ">".$remainder_r2_file) or die;
}

my $n = 0;
while(my $line = <$input_a>) {
    my @lines_a;
    my @lines_b;
    my $id_a;
    my $id_b;
    
    $lines_a[0] = $line;
    $lines_b[0] = <$input_b>;
    for (my $i=1; $i<$lines_per_entry; $i++) {
        $lines_a[$i] = <$input_a>;
        $lines_b[$i] = <$input_b>;
    }
    
    if ($lines_a[0] =~ /$id_marker(\S+)/) {
        $id_a = $1;
    } else {
        die "Can't get ID line from ".$lines_a[0];
    }

    if ($lines_b[0] =~ /$id_marker(\S+)/) {
        $id_b = $1;
    } else {
        die "Can't get ID line from ".$lines_b[0];
    }
    
    if ($id_a ne $id_b) {
        die "IDs ".$id_a." and ".$id_b." not equal!";
    }

    for (my $i=0; $i<$lines_per_entry; $i++) {
        if (defined $keep{$n}) {
            print $output_a $lines_a[$i];
            print $output_b $lines_b[$i];
        } else {
            if ((defined $remainder_r1_file) && (defined $remainder_r2_file)) {
                print $remainder_a $lines_a[$i] if defined $remainder_a;
                print $remainder_b $lines_b[$i] if defined $remainder_b;
            }
        }
    }

    $n++;
}

close($input_a);
close($input_b);
close($output_a);
close($output_b);

if ((defined $remainder_r1_file) && (defined $remainder_r2_file)) {
    close($remainder_a) if defined $remainder_a;
    close($remainder_b) if defined $remainder_b;
}

print "DONE\n";
