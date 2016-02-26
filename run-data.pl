#!/usr/bin/perl

# This script runs the ptrans tranform on the *.in files in the data directory, generating *.out files for each

# by Joseph Nunn, all rights reserved

use strict;
use warnings;
use File::Slurp ;

my $datadir = 'data';
my $failcount = 0;
my $goodcount = 0;
my $bar = "----------------\n";
my $exename = "ptrans" ;

print "Making Clean\n";
my $compileResult = `make clean` ;
print "Testing Compile\n";
print $bar ;
$compileResult = `make` ;
print $bar ;
print "Compilation Results:\n" ;
print "$compileResult\n" ;

print "Changing Permissions on executable\n";
if ( $^O eq "darwin" || $^O eq "linux" ) {
  my $chresult = `chmod a+x $exename` ;
} else {
  print "On windows you have to give executable permissions on the compiled $exename manually!\n\n" ;
}

print "\n" ;

if ( ! -x "ptrans" ) {
  print "ERROR! no ptrans executable can be run, check permissions or compilation results above\n" ;
  exit( 1 ) ;
}

opendir(DIR, $datadir) or die $!;

print "Running ptrans on data directory $datadir\n";
print "$bar";
while (my $infile = readdir(DIR)) {

  # We only want files
  next unless (-f "$datadir/$infile");

  # Use a regular expression to find input files
  next unless ($infile =~ m/(.*)\.in$/);

  # Output file has same name, different extension
  my $outfile = $1 . ".out" ;

  print "Generating output file $outfile for input file $infile\n" ;
  
  my $transformOutput = `./ptrans $datadir/$infile > $datadir/$outfile` ;
}

print "$bar";
print "Finished generating data output files!\n" ;

closedir(DIR);
exit 0;
