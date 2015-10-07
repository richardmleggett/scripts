#!perl -w

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
my $n_entries = 0;
my $number_required = 1000;
my %keep;

&GetOptions(
    'a:s' => \$input_r1_file,
    'b:s' => \$input_r2_file,
    'c:s' => \$output_r1_file,
    'd:s' => \$output_r2_file,
    'e:s' => \$remainder_r1_file,
    'f:s' => \$remainder_r2_file,
    'n:i' => \$number_required,
    'wc:s' => \$wc_file
);

die if not defined $input_r1_file;
die if not defined $input_r2_file;
die if not defined $output_r1_file;
die if not defined $output_r2_file;
die if not defined $remainder_r1_file;
die if not defined $remainder_r2_file;
die if not defined $wc_file;

open(WCFILE, $wc_file) or die "Can't open $wc_file\n";
my $wc = <WCFILE>;
close(WCFILE);

if ($wc =~ /(\d+) (\S+)/) {
    $n_entries = $1 / 2;
}

die if ($n_entries == 0);

die "Less entries in file than you asked for!" if ($n_entries <= $number_required);

print "Number of entries: $n_entries\n";

print "Choosing $number_required entries...\n";

for (my $i=0; $i<$number_required; $i++) {
    my $r;

    do {
        $r = int(rand($n_entries));
    } while defined $keep{$r};

    $keep{$r} = 1;
}

print "Writing output file...\n";

open(INPUT_A, $input_r1_file) or die;
open(INPUT_B, $input_r2_file) or die;
open(OUTPUT_A, ">".$output_r1_file) or die;
open(OUTPUT_B, ">".$output_r2_file) or die;
open(REMAINDER_A, ">".$remainder_r1_file) or die;
open(REMAINDER_B, ">".$remainder_r2_file) or die;
my $n = 0;
while(<INPUT_A>) {
    my $id_a = $_;
    my $seq_a = <INPUT_A>;
    my $id_b = <INPUT_B>;
    my $seq_b = <INPUT_B>;
    my $a;
    my $b;
    
    if ($id_a =~ />(\S+)/) {
        $a = $1;
    } else {
        die "Can't get ID line from $id_a";
    }

    if ($id_b =~ />(\S+)/) {
        $b = $1;
    } else {
        die "Can't get ID line from $id_b";
    }
    
    if ($a ne $b) {
        die "IDs $a and $b not equal!";
    }
    
    
    if (defined $keep{$n}) {
        print OUTPUT_A $id_a;
        print OUTPUT_A $seq_a;
        print OUTPUT_B $id_b;
        print OUTPUT_B $seq_b;
    } else {
        print REMAINDER_A $id_a;
        print REMAINDER_A $seq_a;
        print REMAINDER_B $id_b;
        print REMAINDER_B $seq_b;
    }

    $n++;
}

close(OUTPUT_A);
close(OUTPUT_B);
close(REMAINDER_A);
close(REMAINDER_B);
close(INPUT_A);
close(INPUT_B);

print "DONE\n";
