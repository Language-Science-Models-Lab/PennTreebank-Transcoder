#!/usr/bin/perl

# This script verifies that the grammar transform program compiles and successfully runs the tests in the tests directory successfully
# Please make sure to verify your grammar changes/additions work with the existing tests and create a test sample for your additional
# rules in the tests directory, following the test-#.in and .out format, before submitting your changes to the respository!

# by Joseph Nunn, all rights reserved

use strict;
use warnings;
use File::Slurp ;
use String::Diff qw( diff );

my $testdir = 'tests';
my $failcount = 0;
my $bar = "----------------\n";
my $exename = "ptrans" ;

print "Testing Compile\n";
print $bar ;
my $compileResult = `make` ;
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

opendir(DIR, $testdir) or die $!;

print "Running Tests\n";
print "$bar";
while (my $infile = readdir(DIR)) {

  # We only want files
  next unless (-f "$testdir/$infile");

  # Use a regular expression to find input files
  next unless ($infile =~ m/(.*)\.in$/);

  # Output file has same name, different extension
  my $outfile = $1 . ".out" ;

  print "Testing input file $infile against expected output file $outfile............." ;
  
  if ( ! -r "$testdir/$outfile" ) {
	print "ERROR!, no matching output file $outfile for input file $infile!\n" ;
	$failcount++ ;
	next ;
  }

  my $outfileData = read_file("$testdir/$outfile") ;
  
  my $transformOutput = `./ptrans $testdir/$infile` ;

  my( $got, $expected ) = String::Diff::diff( $transformOutput, $outfileData ) ;

  if ( $got ne $expected ) {
	print "FAIL!\n\n" ;
	print "We got:\n\n$got\n" ;
	print "We expected:\n\n$expected\n" ;
	$failcount++ ;
  } else {
	print "OK\n" ;
  }
}

print "$bar";
print "Finished testing, " ;

if ( $failcount == 0 ) {
  print "all tests Passed.\n" ;
} else {
  print "$failcount tests Failed.\n" ;
}

closedir(DIR);
exit 0;
