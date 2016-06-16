#!/usr/bin/perl

# This script runs the ptrans tranform on the *.in files in the datain directory, generating *.out files for each in the dataout directory

# MIT License

# Copyright (c) 2016 Joseph Lee Nunn III and Sean Fulop

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE. 


use strict;
use warnings;
use File::Slurp ;

my $datain = 'data/preprocessed';
my $dataout = 'data/parsed';
my $failcount = 0;
my $goodcount = 0;
my $bar = "----------------\n";
my $exename = "ptrans" ;


if (! -d $dataout) {
    unless(mkdir $dataout) {
        die "Unable to create $dataout\n";
    }
}

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

opendir(DIR, $datain) or die $!;

print "Running ptrans on data directory $datain and output to $dataout\n";
print "$bar";
while (my $infile = readdir(DIR)) {

  # We only want files
  next unless (-f "$datain/$infile");

  # Use a regular expression to find input files
  next unless ($infile =~ m/(.*)\.in$/);

  # Output file has same name, different extension
  my $outfile = $1 . ".out" ;

  print "Generating output file $outfile for input file $infile\n" ;
  
  my $transformOutput = `./ptrans $datain/$infile > $dataout/$outfile` ;
}

print "$bar";
print "Finished generating data output files!\n" ;

closedir(DIR);
exit 0;
